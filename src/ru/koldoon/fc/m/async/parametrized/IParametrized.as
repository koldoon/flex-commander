package ru.koldoon.fc.m.async.parametrized {

    /**
     * Describes object that can be dynamically configured used parameters
     * interface
     */
    public interface IParametrized {

        /**
         * Get parameters object, that allows to list and modify current configuration
         * @return
         */
        function getParameters():IParameters;

    }
}
