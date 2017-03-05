package ru.koldoon.fc.m.storage.impl {
    import ru.koldoon.fc.m.async.IPromise;

    public class RepositoryOperationDescritptor {
        public function RepositoryOperationDescritptor() {
        }


        public var operation:Class;
        public var promise:IPromise;
    }
}
