package net.play5d.kyo.display.bitmap
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.Event;
   import net.play5d.kyo.loader.BitmapLoader;
   import net.play5d.kyo.loader.KyoURLoader;
   
   public class BitmapFontLoader
   {
      private var _urls:Array;
      
      private var _fontObj:Object = {};
      
      private var _loadAmount:int;
      
      private var _loadBack:Function;
      
      private var _loadProcess:Function;
      
      public function BitmapFontLoader()
      {
         super();
      }
      
      public function clear() : void
      {
         this._fontObj = {};
      }
      
      public function loadFonts(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         this._loadBack = param2;
         this._loadProcess = param3;
         this._urls = param1;
         this._loadAmount = param1.length;
         this.loadNext();
      }
      
      public function loadFont(param1:String, param2:XML, param3:Function = null, param4:Function = null) : void
      {
         var _loc5_:String = param2.pages.page.@file;
         var _loc6_:String = param1.substr(0,param1.lastIndexOf("/") + 1);
         var _loc7_:String = _loc6_ + _loc5_;
         this.loadBitmapData(_loc7_,param2,param3,param4);
      }
      
      public function addFont(param1:XML, param2:BitmapData) : void
      {
         var _loc3_:String = param1.info.@face;
         this._fontObj[_loc3_] = new BitmapFont(param1,param2);
      }
      
      public function getFont(param1:String) : BitmapFont
      {
         return this._fontObj[param1];
      }
      
      private function loadComplete() : void
      {
         if(this._loadBack != null)
         {
            this._loadBack();
            this._loadBack = null;
         }
         this._loadProcess = null;
      }
      
      private function loadNext() : void
      {
         var url:String = null;
         var loadXMLFin:Function = null;
         var loadXMLFail:Function = null;
         var cur:int = 0;
         loadXMLFin = function(param1:String):void
         {
            var _loc2_:XML = new XML(param1);
            var _loc3_:String = _loc2_.pages.page.@file;
            var _loc4_:String = url.substr(0,url.lastIndexOf("/") + 1);
            var _loc5_:String = _loc4_ + _loc3_;
            loadBitmapData(_loc5_,_loc2_,loadNext,loadNext);
         };
         loadXMLFail = function():void
         {
            trace("BitmapFontLoader.loadXMLFail::" + url);
            loadNext();
         };
         if(this._loadProcess != null)
         {
            cur = this._loadAmount - this._urls.length;
            this._loadProcess(cur / this._loadAmount);
         }
         if(this._urls.length < 1)
         {
            this.loadComplete();
            return;
         }
         url = this._urls.shift();
         KyoURLoader.load(url,loadXMLFin,loadXMLFail);
      }
      
      private function loadBitmapData(param1:String, param2:XML, param3:Function = null, param4:Function = null) : void
      {
         var fontid:String = null;
         var loadBpComplete:Function = null;
         var loadBpFail:Function = null;
         var bpurl:String = param1;
         var xml:XML = param2;
         var back:Function = param3;
         var fail:Function = param4;
         loadBpComplete = function(param1:Bitmap):void
         {
            _fontObj[fontid] = new BitmapFont(xml,param1.bitmapData);
            if(back != null)
            {
               back();
            }
         };
         loadBpFail = function(param1:Event):void
         {
            trace("BitmapFontLoader.loadBpFail::" + bpurl);
            if(fail != null)
            {
               fail();
            }
         };
         fontid = xml.info.@face;
         var loader:BitmapLoader = new BitmapLoader();
         loader.load(bpurl,loadBpComplete,loadBpFail);
      }
   }
}

