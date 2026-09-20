package com.miokotech.opengl
{
   import flash.external.ExtensionContext;

   public class GameOpenGL
   {
      private static var _ctx:ExtensionContext;

      private static function ensureContext() : void
      {
         if(!_ctx)
         {
            try
            {
               _ctx = ExtensionContext.createExtensionContext("com.miokotech.opengl", null);
            }
            catch(err:Error)
            {
               _ctx = null;
            }
         }
      }

      public static function isSupported() : Boolean
      {
         ensureContext();
         if(!_ctx) return false;
         try
         {
            var res:* = _ctx.call("isSupported");
            return res == true;
         }
         catch(err:Error) {}
         return false;
      }

      public static function init() : Boolean
      {
         ensureContext();
         if(!_ctx) return false;
         try
         {
            var res:* = _ctx.call("initGL");
            return res == true;
         }
         catch(err:Error) {}
         return false;
      }

      public static function getGLInfo() : String
      {
         ensureContext();
         if(!_ctx) return "Context not initialized";
         try
         {
            var info:* = _ctx.call("getGLInfo");
            return info ? String(info) : "";
         }
         catch(err:Error) {}
         return "";
      }

      public static function createShadowView() : Boolean
      {
         ensureContext();
         if(!_ctx) return false;
         try
         {
            var res:* = _ctx.call("createShadowView");
            return res == true;
         }
         catch(err:Error) {}
         return false;
      }

      public static function updateShadow(id:int, x:Number, y:Number, width:Number, height:Number, scaleX:Number, scaleY:Number, skewX:Number, alpha:Number = 0.5, color:uint = 0x000000) : void
      {
         if(!_ctx) return;
         try
         {
            _ctx.call("updateShadow", id, x, y, width, height, scaleX, scaleY, skewX, alpha, color);
         }
         catch(err:Error) {}
      }

      public static function setShadowConfig(groundY:Number, lightAngle:Number = 0) : void
      {
         if(!_ctx) return;
         try
         {
            _ctx.call("setShadowConfig", groundY, lightAngle);
         }
         catch(err:Error) {}
      }

      public static function clearShadows() : void
      {
         if(!_ctx) return;
         try
         {
            _ctx.call("clearShadows");
         }
         catch(err:Error) {}
      }

      public static function dispose() : void
      {
         if(!_ctx) return;
         try
         {
            _ctx.call("disposeGL");
            _ctx.dispose();
         }
         catch(err:Error) {}
         _ctx = null;
      }
   }
}
