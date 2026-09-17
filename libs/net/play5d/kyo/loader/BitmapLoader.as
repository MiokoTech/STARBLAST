package net.play5d.kyo.loader
{
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   
   public class BitmapLoader
   {
      public var bitmap:Bitmap;
      
      public var url:String;
      
      public function BitmapLoader()
      {
         super();
      }
      
      public function load(param1:String, param2:Function = null, param3:Function = null) : void
      {
         var loader:Loader = null;
         var loadComplete:Function = null;
         var loadFail:Function = null;
         var url:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         loadComplete = function(param1:Event):void
         {
            bitmap = loader.content as Bitmap;
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,loadFail);
            loader.unload();
            loader = null;
            if(back != null)
            {
               back(bitmap);
            }
         };
         loadFail = function(param1:IOErrorEvent):void
         {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,loadFail);
            loader = null;
            if(fail != null)
            {
               fail();
            }
         };
         this.url = url;
         loader = new Loader();
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadFail);
         loader.load(new URLRequest(url));
      }
   }
}

