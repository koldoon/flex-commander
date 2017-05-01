package org.osflash.vanilla {
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;

    import mx.collections.ArrayCollection;
    import mx.collections.ArrayList;

    import org.as3commons.lang.ClassUtils;
    import org.as3commons.lang.ObjectUtils;
    import org.as3commons.reflect.Accessor;
    import org.as3commons.reflect.Field;
    import org.as3commons.reflect.Metadata;
    import org.as3commons.reflect.MetadataArgument;
    import org.as3commons.reflect.Method;
    import org.as3commons.reflect.Parameter;
    import org.as3commons.reflect.Type;
    import org.as3commons.reflect.Variable;

    public class Vanilla {
        private static const METADATA_TAG:String = "Marshall";
        private static const METADATA_FIELD_KEY:String = "field";
        private static const METADATA_TYPE_KEY:String = "type";

        //Cache InjectionMap instances
        private var injectionMapCache:Dictionary = new Dictionary();

        /**
         * Attempts to extract properties from the supplied source object into an instance of the supplied targetType.
         *
         * @param source Object which contains properties that you wish to transfer to a new instance of the
         * supplied targetType Class.
         * @param target The target Class of which an instance will be returned
         * @return An instance of the supplied targetType containing all the properties extracted from
         * the supplied source object.
         */
        public function extract(source:Object, targetType:Class, strict:Boolean = true):* {
            // Catch the case where we've been asked to extract a value which is already of the intended targetType;
            // this can often happen when Vanilla is recursing, in which case there is nothing to do.
            if (source is targetType) {
                return source;
            }

            if (!injectionMapCache[targetType]) {
                injectionMapCache[targetType] = new InjectionMap();
                addReflectedRules(injectionMapCache[targetType], targetType, Type.forClass(targetType));
            }

            const injectionMap:InjectionMap = injectionMapCache[targetType];

            // Create a new instance of the targetType; and then inject the values from the source object into it
            const target:* = instantiate(targetType, fetchConstructorArgs(source, injectionMap.getConstructorFields()));
            injectFields(source, target, injectionMap, strict);
            injectMethods(source, target, injectionMap);

            return target;
        }

        /**
         * Attempts to extract properties from the supplied source object into an instance of the supplied targetType.
         *
         * @param source Object which contains properties that you wish to transfer to a new instance of the
         * supplied targetType Class.
         * @param targetInstance The target Instance to update
         * @return An instance of the supplied targetType containing all the properties extracted from
         * the supplied source object.
         */
        public function update(source:Object, targetInstance:Object, strict:Boolean = true):* {
            var targetType:Type = Type.forInstance(targetInstance);
            var targetClass:Class = targetType.clazz;

            if (!injectionMapCache[targetClass]) {
                injectionMapCache[targetClass] = new InjectionMap();
                addReflectedRules(injectionMapCache[targetClass], targetClass, targetType);
            }

            const injectionMap:InjectionMap = injectionMapCache[targetClass];
            injectFields(source, targetInstance, injectionMap, strict);
            injectMethods(source, targetInstance, injectionMap);
        }

        private function fetchConstructorArgs(source:Object, constructorFields:Array):Array {
            const result:Array = [];
            for (var i:uint = 0; i < constructorFields.length; i++) {
                result.push(extractValue(source, constructorFields[i], true));
            }
            return result;
        }

        private function injectFields(source:Object, target:*, injectionMap:InjectionMap, strict:Boolean):void {
            const fieldNames:Array = injectionMap.getFieldNames();
            for each (var fieldName:String in fieldNames) {
                try {
                    target[fieldName] = extractValue(source, injectionMap.getField(fieldName), strict);
                }
                catch (error:Error) {
                    if (strict) {
                        throw error;
                    }
                }
            }
        }

        private function injectMethods(source:Object, target:*, injectionMap:InjectionMap):void {
            const methodNames:Array = injectionMap.getMethodsNames();
            for each (var methodName:String in methodNames) {
                const values:Array = [];
                for each (var injectionDetail:InjectionDetail in injectionMap.getMethod(methodName)) {
                    values.push(extractValue(source, injectionDetail, true));
                }
                (target[methodName] as Function).apply(null, values);
            }
        }

        private function extractValue(source:Object, injectionDetail:InjectionDetail, strict:Boolean):* {
            if (!strict && !source.hasOwnProperty(injectionDetail.name)) {
                return null;
            }

            var value:* = source[injectionDetail.name];

            // Is this a required injection?
            if (injectionDetail.isRequired && value === undefined) {
                throw new MarshallingError("Required value " + injectionDetail + " does not exist in the source object.", MarshallingError.MISSING_REQUIRED_FIELD);
            }

            if (value) {
                // automatically coerce simple types.
                if (!ObjectUtils.isSimple(value)) {
                    value = extract(value, injectionDetail.type);
                }

                // Collections are harder, we need to coerce the contents.
                else if (value is Array) {
                    if (isVector(injectionDetail.type)) {
                        value = extractVector(value, injectionDetail.type, injectionDetail.arrayTypeHint, strict);
                    }
                    else if (injectionDetail.arrayTypeHint) {
                        if (injectionDetail.type == ArrayCollection) {
                            value = new ArrayCollection(extractTypedArray(value, injectionDetail.arrayTypeHint, strict));
                        }
                        else if (injectionDetail.type == ArrayList) {
                            value = new ArrayList(extractTypedArray(value, injectionDetail.arrayTypeHint, strict));
                        }
                        else {
                            value = extractTypedArray(value, injectionDetail.arrayTypeHint, strict);
                        }
                    }
                }

                if ((value is String || value is int || value is Number) &&
                    (injectionDetail.type == String || injectionDetail.type == int || injectionDetail.type == Number)) {

                    // do nothing, numbers and strings coercing is ok so far

                }
                else if (!(value is injectionDetail.type)) {
                    if (strict) {
                        throw new MarshallingError("Could not coerce `" + injectionDetail.name + "` (value: " + value + " <" + Type.forInstance(value).clazz + "]>) from source object to " + injectionDetail.type + " on target object", MarshallingError.TYPE_MISMATCH);
                    }
                    else {
                        value = null;
                    }
                }
            }

            return value;
        }

        private function extractTypedArray(source:Array, targetClassType:Class, strict:Boolean):Array {
            const result:Array = new Array(source.length);
            for (var i:uint = 0; i < source.length; i++) {
                result[i] = extract(source[i], targetClassType, strict);
            }
            return result;
        }

        private function extractVector(source:Array, targetVectorClass:Class, targetClassType:Class, strict:Boolean):* {
            const result:* = ClassUtils.newInstance(targetVectorClass);
            for (var i:uint = 0; i < source.length; i++) {
                if (isVector(targetClassType)) {
                    const type:Type = Type.forClass(targetClassType);
                    result[i] = extractVector(source[i], targetClassType, type.parameters[0], strict);
                }
                else {
                    result[i] = extract(source[i], targetClassType, strict);
                }
            }
            return result;
        }


        private function instantiate(targetType:Class, ctorArgs:Array):* {
            return ClassUtils.newInstance(targetType, ctorArgs);
        }

        private function addReflectedRules(injectionMap:InjectionMap, targetType:Class, reflectionMap:Type):void {
            addReflectedConstructorRules(injectionMap, reflectionMap);
            addReflectedFieldRules(injectionMap, reflectionMap.fields);
            addReflectedSetterRules(injectionMap, reflectionMap.methods);
        }

        private function addReflectedConstructorRules(injectionMap:InjectionMap, reflectionMap:Type):void {
            const clazzMarshallingMetadata:Array = reflectionMap.getMetadata(METADATA_TAG);
            if (!clazzMarshallingMetadata) {
                return;
            }

            const marshallingMetadata:Metadata = clazzMarshallingMetadata[0];
            const numArgs:uint = marshallingMetadata.arguments.length;

            for (var i:uint = 0; i < numArgs; i++) {
                var argument:MetadataArgument = marshallingMetadata.arguments[i];
                if (argument.key == METADATA_FIELD_KEY) {
                    const param:Parameter = reflectionMap.constructor.parameters[i];
                    const arrayTypeHint:Class = extractArrayTypeHint(param.type);
                    injectionMap.addConstructorField(new InjectionDetail(argument.value, param.type.clazz, true, arrayTypeHint));
                }
            }
        }

        private function addReflectedFieldRules(injectionMap:InjectionMap, fields:Array):void {
            for each (var field:Field in fields) {
                if (!field.hasMetadata(Metadata.TRANSIENT) && canAccess(field)) {
                    const fieldMetadataEntries:Array = field.getMetadata(METADATA_TAG);
                    const fieldMetadata:Metadata = (fieldMetadataEntries) ? fieldMetadataEntries[0] : null;
                    const arrayTypeHint:Class = extractArrayTypeHint(field.type, fieldMetadata);
                    const sourceFieldName:String = extractFieldName(field, fieldMetadata);

                    injectionMap.addField(field.name, new InjectionDetail(sourceFieldName, field.type.clazz, false, arrayTypeHint));
                }
            }
        }

        private function addReflectedSetterRules(injectionMap:InjectionMap, methods:Array):void {
            for each (var method:Method in methods) {

                const methodMarshallingMetadata:Array = method.getMetadata(METADATA_TAG);
                if (methodMarshallingMetadata == null) {
                    continue;
                }

                const metadata:Metadata = methodMarshallingMetadata[0];
                const numArgs:uint = metadata.arguments.length;

                for (var i:uint = 0; i < numArgs; i++) {
                    var argument:MetadataArgument = metadata.arguments[i];
                    if (argument.key == METADATA_FIELD_KEY) {
                        const param:Parameter = method.parameters[i];
                        const arrayTypeHint:Class = extractArrayTypeHint(param.type, metadata);
                        injectionMap.addMethod(method.name, new InjectionDetail(argument.value, param.type.clazz, false, arrayTypeHint));
                    }
                }
            }
        }

        private function extractFieldName(field:Field, metadata:Metadata):String {
            // See if a taget fieldName has been defined in the Metadata.
            if (metadata) {
                const numArgs:uint = metadata.arguments.length;
                for (var i:uint = 0; i < numArgs; i++) {
                    var argument:MetadataArgument = metadata.arguments[i];
                    if (argument.key == METADATA_FIELD_KEY) {
                        return argument.value;
                    }
                }
            }

            // Assume it's a 1 to 1 mapping.
            return field.name;
        }

        private function extractArrayTypeHint(type:Type, metadata:Metadata = null):Class {
            // Vectors carry their own type hint.
            if (type.parameters && type.parameters[0] is Class) {
                return type.parameters[0];
            }

            // Otherwise we will look for some "type" metadata, if it was defined.
            else if (metadata) {
                const numArgs:uint = metadata.arguments.length;
                for (var i:uint = 0; i < numArgs; i++) {
                    var argument:MetadataArgument = metadata.arguments[i];
                    if (argument.key == METADATA_TYPE_KEY) {
                        const clazz:Class = ClassUtils.forName(argument.value);
                        return clazz;
                    }
                }
            }

            // No type hint.
            return null;
        }

        private function canAccess(field:Field):Boolean {
            if (field is Variable) {
                return true;
            }
            else if (field is Accessor) {
                return (field as Accessor).writeable;
            }
            return false;
        }

        private function isVector(obj:*):Boolean {
            return (getQualifiedClassName(obj).indexOf('__AS3__.vec::Vector') == 0);
        }
    }
}
