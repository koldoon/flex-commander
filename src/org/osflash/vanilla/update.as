package org.osflash.vanilla {
    /**
     * Attempts to extract properties from the supplied source object into an instance of the supplied targetType.
     *
     * @param source Object which contains properties that you wish to transfer to a new instance of the
     * supplied targetType Class.
     * @param targetInstance The target Instance to update
     * @param strict
     * @return An instance of the supplied targetType containing all the properties extracted from
     * the supplied source object.
     */
    public function update(targetInstance:Object, source:Object, strict:Boolean = true):* {
        return VANILLA_INSTANCE.update(source, targetInstance, strict);
    }
}
