package net.play5d.kyo.loader
{
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   public class KyoLoaderLite
   {
      public function KyoLoaderLite()
      {
         super();
      }
      
      public static function load(param1:String, param2:Function, param3:Function, param4:Function) : void
      {
         var l:Loader = null;
         var loadComplete:Function = null;
         var ioError:Function = null;
         var progressHandler:Function = null;
         var url:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         loadComplete = function(param1:Event):void
         {
            var _loc2_:DisplayObject = l.content;
            if(back != null)
            {
               back(_loc2_);
            }
            clear();
         };
         ioError = function(param1:IOErrorEvent):void
         {
            if(fail != null)
            {
               fail();
            }
            clear();
         };
         progressHandler = function(param1:ProgressEvent):void
         {
            if(process != null)
            {
               process(param1.bytesLoaded / param1.bytesTotal);
            }
         };
         var clear:Function = function():void
         {
            if(l == null)
            {
               return;
            }
            l.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
            l.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,ioError);
            l.unloadAndStop(true);
            l = null;
         };
         l = new Loader();
         l.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
         l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioError);
         l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,progressHandler);
         l.load(new URLRequest(url));
      }
      
      public static function loadLoader(param1:String, param2:Function, param3:Function, param4:Function) : void
      {
         var l:Loader = null;
         var loadComplete:Function = null;
         var ioError:Function = null;
         var progressHandler:Function = null;
         var ctx:LoaderContext = null;
         var url:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         loadComplete = function(param1:Event):void
         {
            if(back != null)
            {
               back(l);
            }
            clear();
         };
         ioError = function(param1:IOErrorEvent):void
         {
            if(fail != null)
            {
               fail();
            }
            clear();
         };
         progressHandler = function(param1:ProgressEvent):void
         {
            if(process != null)
            {
               process(param1.bytesLoaded / param1.bytesTotal);
            }
         };
         var clear:Function = function():void
         {
            if(l == null)
            {
               return;
            }
            l.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
            l.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,ioError);
         };
         l = new Loader();
         l.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
         l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioError);
         l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,progressHandler);
         ctx = new LoaderContext(false,new ApplicationDomain(ApplicationDomain.currentDomain));
         ctx.allowCodeImport = true;
         l.load(new URLRequest(url),ctx);
      }
      
      public static function loadBytes(param1:String, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         var loader:URLLoader = null;
         var onComplete:Function = null;
         var onError:Function = null;
         var onProgress:Function = null;
         var url:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var progress:Function = param4;
         onComplete = function(param1:Event):void
         {
            if(back != null)
            {
               back(loader.data as ByteArray);
            }
            loader = null;
         };
         onError = function(param1:*):void
         {
            if(fail != null)
            {
               fail();
            }
            loader = null;
            trace(param1);
         };
         onProgress = function(param1:ProgressEvent):void
         {
            if(progress != null)
            {
               progress(param1.bytesLoaded / param1.bytesTotal);
            }
         };
         loader = new URLLoader();
         loader.dataFormat = URLLoaderDataFormat.BINARY;
         loader.addEventListener(Event.COMPLETE,onComplete);
         loader.addEventListener(IOErrorEvent.IO_ERROR,onError);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onError);
         loader.addEventListener(ProgressEvent.PROGRESS,onProgress);
         loader.load(new URLRequest(url));
      }
      
      public static function bytesToDisplay(param1:ByteArray, param2:Function = null, param3:Function = null) : Loader
      {
         var ctx:LoaderContext;
         var loader:Loader = null;
         var onLoadComplete:Function = null;
         var onLoadError:Function = null;
         var bytes:ByteArray = param1;
         var onComplete:Function = param2;
         var onError:Function = param3;
         onLoadComplete = function(param1:Event):void
         {
            if(onComplete != null)
            {
               onComplete(loader);
            }
         };
         onLoadError = function(param1:*):void
         {
            if(onError != null)
            {
               onError();
            }
            trace(param1);
         };
         loader = new Loader();
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
         loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onLoadError);
         ctx = new LoaderContext();
         ctx.allowCodeImport = true;
         loader.loadBytes(bytes,ctx);
         return loader;
      }
   }
}

