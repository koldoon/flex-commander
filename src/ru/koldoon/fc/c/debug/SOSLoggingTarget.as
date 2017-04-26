/**
 * @author Vadim Usoltsev
 * @version $Id$
 *          $LastChangedDate$
 *          $Author$
 *          $Date$
 *          $Rev$
 */
package ru.koldoon.fc.c.debug {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.Socket;

    import mx.logging.AbstractTarget;
    import mx.logging.ILogger;
    import mx.logging.LogEvent;
    import mx.logging.LogEventLevel;

    /**
     * Extended log target based on SOS log target. Uses JSON for transmittin data through socket,
     * always send full log info, not for folded messages only.
     */
    public class SOSLoggingTarget extends AbstractTarget {
        private static const SERVER_PORT:uint = 64661;
        public static const CALL_LEVEL:int = 32;
        public static const RESULT_LEVEL:int = 64;

        private static const MAX_HISTORY_ENTRIES:int = 100;
        private var currentItemId:Number;
        private var socket:Socket;
        private var history:Array;

        [Inspectable(category="General", defaultValue="localhost")]
        public var server:String = "localhost";


        public function SOSLoggingTarget() {
            socket = new Socket();
            history = [];

            socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            socket.addEventListener(Event.CONNECT, onConnect);
        }


        override public function logEvent(event:LogEvent):void {
            var now:Date = new Date();

            var logItem:Object = {
                time:     now.getTime(),
                message:  event.message,
                category: ILogger(event.target).category,
                key:      getKeyByLogLevel(event.level)
            };

            if (socket.connected) {
                send(logItem);
            }
            else {
                history.push(logItem);
                if (history.length > MAX_HISTORY_ENTRIES) {
                    history.shift();
                }

                socket.connect(server, SERVER_PORT);
            }
        }


        private function onIOError(e:IOErrorEvent):void {
        }


        private function onSecurityError(e:SecurityErrorEvent):void {
            trace("SOSLoggingTarget: XMLSocket SecurityError");
        }


        private function onConnect(e:Event):void {
            while (history.length > 0) {
                send(history.shift());
            }
        }


        private function send(obj:Object):void {
            obj.id = currentItemId++;
            socket.writeUTFBytes('!SOS!' + JSON.stringify(obj));
            socket.flush();
        }


        private static const KEY_BY_LOG_LEVEL:Object = {};
        {
            KEY_BY_LOG_LEVEL[LogEventLevel.DEBUG] = "DEBUG";
            KEY_BY_LOG_LEVEL[LogEventLevel.INFO] = "INFO";
            KEY_BY_LOG_LEVEL[LogEventLevel.WARN] = "WARN";
            KEY_BY_LOG_LEVEL[LogEventLevel.ERROR] = "ERROR";
            KEY_BY_LOG_LEVEL[LogEventLevel.FATAL] = "FATAL";
            KEY_BY_LOG_LEVEL[CALL_LEVEL] = "CALL";
            KEY_BY_LOG_LEVEL[RESULT_LEVEL] = "RESULT";
        }

        private static function getKeyByLogLevel(level:int):String {
            return KEY_BY_LOG_LEVEL[level] || "INFO";
        }
    }
}
