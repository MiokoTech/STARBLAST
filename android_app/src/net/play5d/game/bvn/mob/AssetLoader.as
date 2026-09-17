package net.play5d.game.bvn.mob
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.filesystem.File;
   import flash.media.Sound;
   import flash.net.URLRequest;
   import net.play5d.game.bvn.interfaces.IAssetLoader;
   import net.play5d.kyo.loader.KyoLoaderLite;
   import net.play5d.kyo.loader.KyoURLoader;
   
   public class AssetLoader implements IAssetLoader
   {
      public function AssetLoader()
      {
         super();
      }
      
      public function loadXML(param1:String, param2:Function, param3:Function = null) : void
      {
         var url:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         url = getFullUrl(url);
         KyoURLoader.load(url,function(param1:String):void
         {
            back(new XML(param1));
         },fail);
      }
      
      public function loadJSON(param1:String, param2:Function, param3:Function = null) : void
      {
         var url:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         url = getFullUrl(url);
         KyoURLoader.load(url,function(param1:String):void
         {
            var _loc2_:Object = null;
            try
            {
               _loc2_ = JSON.parse(param1);
               back(_loc2_);
            }
            catch(e:Error)
            {
               trace(e);
               if(fail != null)
               {
                  fail();
               }
            }
         },fail);
      }
      
      public function loadSwf(param1:String, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         param1 = getFullUrl(param1);
         KyoLoaderLite.loadLoader(param1,param2,param3,param4);
      }
      
      public function loadBitmap(param1:String, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         param1 = getFullUrl(param1);
         KyoLoaderLite.load(param1,param2,param3,param4);
      }
      
      public function loadSound(param1:String, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         var url:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         var clear:* = function():void
         {
            s.removeEventListener("complete",onComplete);
            s.removeEventListener("ioError",onError);
            s.removeEventListener("progress",onProgress);
         };
         var onComplete:* = function(param1:Event):void
         {
            back(s);
            clear();
         };
         var onError:* = function(param1:IOErrorEvent):void
         {
            if(fail != null)
            {
               fail();
            }
            clear();
         };
         var onProgress:* = function(param1:ProgressEvent):void
         {
            if(process != null)
            {
               process(param1.bytesLoaded / param1.bytesTotal);
            }
         };
         url = getFullUrl(url);
         var s:Sound = new Sound();
         s.addEventListener("complete",onComplete);
         s.addEventListener("ioError",onError);
         s.addEventListener("progress",onProgress);
         s.load(new URLRequest(url));
      }
      
      public function dispose(param1:String) : void
      {
      }
      
      public function needPreLoad() : Boolean
      {
         return false;
      }
      
      public function loadPreLoad(param1:Function, param2:Function = null, param3:Function = null) : void
      {
      }
      
      private function getFullUrl(param1:String) : String
      {
         if(!param1 || param1.length < 1)
         {
            return param1;
         }
         var normalizedUrl:String = param1.toLowerCase();
         if(normalizedUrl.indexOf("http://") == 0 || normalizedUrl.indexOf("https://") == 0 || normalizedUrl.indexOf("file://") == 0)
         {
            return param1;
         }
         if(param1.indexOf("/") == 0)
         {
            return new File(param1).url;
         }
         if(param1.indexOf("STARBLAST/") == 0)
         {
            return File.userDirectory.resolvePath(param1).url;
         }
         if(param1.indexOf("assets/") == 0)
         {
            return param1;
         }
         return "assets/" + param1;
      }
   }
}

