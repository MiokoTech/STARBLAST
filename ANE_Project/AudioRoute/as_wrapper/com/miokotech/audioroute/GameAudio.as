package com.miokotech.audioroute {
    import flash.external.ExtensionContext;

    public class GameAudio {
        private static var ctx:ExtensionContext;

        private static function ensureContext():void {
            if (!ctx) ctx = ExtensionContext.createExtensionContext("com.miokotech.audioroute.GameAudio", null);
        }

        public static function init():void {
            ensureContext();
            try { ctx.call("initAudio"); } catch (e:Error) {}
        }

    }
}
