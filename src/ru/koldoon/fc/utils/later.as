package ru.koldoon.fc.utils {
    import com.greensock.TweenLite;

    /**
     * Shortcut for delayed function call
     * 1 parameter - callback with default animation duration
     * 2 params - Timeout (sec), Callback
     */
    public function later(...args):TweenLite {
        if (args.length == 2) {
            if (isNaN(Number(args[0])) || !(args[1] is Function)) {
                throw new Error("Unsupported arguments: ", args);
            }

            return TweenLite.to(this, 0, {
                delay:      args[0],
                onComplete: args[1]
            });
        }
        else if (args.length == 1) {
            return TweenLite.to(this, 0, {
                delay:      0.2,
                onComplete: args[0]
            });
        }
        else {
            throw new Error("Incompatible arguments.");
        }
    }

}
