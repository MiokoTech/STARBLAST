package com.miokotech.storageaccess
{
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.external.ExtensionContext;
   import flash.utils.ByteArray;

   public class StorageAccess extends EventDispatcher
   {
      private static var _instance:StorageAccess;
      private var _context:ExtensionContext;

      public function StorageAccess(enforcer:SingletonEnforcer)
      {
         super();
         try
         {
            _context = ExtensionContext.createExtensionContext("com.miokotech.storageaccess", null);
            if(_context != null)
            {
               _context.addEventListener(StatusEvent.STATUS, onStatus);
            }
         }
         catch(contextError:Error)
         {
            trace("StorageAccess init error:", contextError);
         }
      }

      private function onStatus(statusEvent:StatusEvent):void
      {
         dispatchEvent(statusEvent);
      }

      public static function get instance():StorageAccess
      {
         if(!_instance)
         {
            _instance = new StorageAccess(new SingletonEnforcer());
         }
         return _instance;
      }

      public function hasPermission():Boolean
      {
         if(!_context)
         {
            return true;
         }
         try
         {
            return _context.call("hasPermission") as Boolean;
         }
         catch(permError:Error)
         {
            return checkUri();
         }
         return false;
      }

      public function requestStorageAccess():void
      {
         if(!_context)
         {
            return;
         }
         try
         {
            _context.call("requestStorageAccess");
         }
         catch(requestError:Error)
         {
            trace("StorageAccess.requestStorageAccess error:", requestError);
         }
      }

      public function openAppSettings():void
      {
         if(!_context)
         {
            return;
         }
         try
         {
            _context.call("openAppSettings");
         }
         catch(settingsError:Error)
         {
            trace("StorageAccess.openAppSettings error:", settingsError);
         }
      }

      public function checkUri():Boolean
      {
         if(!_context)
         {
            return true;
         }
         try
         {
            return _context.call("checkUri") as Boolean;
         }
         catch(checkError:Error)
         {
            trace("StorageAccess.checkUri error:", checkError);
         }
         return false;
      }

      public function getTreeUri():String
      {
         if(!_context)
         {
            return null;
         }
         return _context.call("getTreeUri") as String;
      }

      public function writeUriFile(uri:String):Boolean
      {
         if(!_context)
         {
            return false;
         }
         return _context.call("writeUriFile", uri) as Boolean;
      }

      public function readUriFile(uri:String):String
      {
         if(!_context)
         {
            return null;
         }
         return _context.call("readUriFile", uri) as String;
      }

      public function writeJsonFile(fileName:String, jsonContent:String):Boolean
      {
         if(!_context)
         {
            return false;
         }
         return _context.call("writeJsonFile", fileName, jsonContent) as Boolean;
      }

      public function readJsonFile(fileName:String):String
      {
         if(!_context)
         {
            return null;
         }
         return _context.call("readJsonFile", fileName) as String;
      }

      public function loadSWFBytes(fileName:String):ByteArray
      {
         if(!_context)
         {
            return null;
         }
         return _context.call("loadSWFBytes", fileName) as ByteArray;
      }
   }
}

class SingletonEnforcer
{
   public function SingletonEnforcer()
   {
      super();
   }
}
