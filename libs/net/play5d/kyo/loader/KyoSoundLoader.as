package net.play5d.kyo.loader
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.media.Sound;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class KyoSoundLoader
   {
      private var _urls:Array;
      
      private var _curUrl:String;
      
      private var _soundObj:Object = {};
      
      private var _loadBack:Function;
      
      private var _loadProcess:Function;
      
      private var _loadLength:int;
      
      public function KyoSoundLoader()
      {
         super();
      }
      
      public function unload() : void
      {
         var _loc1_:Sound = null;
         if(this._soundObj)
         {
            for each(_loc1_ in this._soundObj)
            {
               _loc1_.close();
            }
            this._soundObj = {};
         }
      }
      
      public function loadSounds(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         this._loadBack = param2;
         this._loadProcess = param3;
         this._urls = param1.concat();
         this._loadLength = param1.length;
         this.loadNext();
      }
      
      public function getSound(param1:String) : Sound
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(this._soundObj[param1])
         {
            return this._soundObj[param1];
         }
         for(_loc2_ in this._soundObj)
         {
            _loc3_ = _loc2_.substr(_loc2_.lastIndexOf("/") + 1);
            _loc3_ = _loc3_.substr(0,_loc3_.lastIndexOf("."));
            if(_loc3_ == param1)
            {
               return this._soundObj[_loc2_];
            }
         }
         return null;
      }
      
      public function addSound(param1:String, param2:Sound) : void
      {
         this._soundObj[param1] = param2;
      }
      
      private function loadNext() : void
      {
         var _loc1_:String = this._urls.shift();
         this._curUrl = _loc1_;
         var _loc2_:Sound = new Sound(new URLRequest(_loc1_));
         _loc2_.addEventListener(Event.COMPLETE,this.loadCom);
         _loc2_.addEventListener(ProgressEvent.PROGRESS,this.loadProcess);
         _loc2_.addEventListener(IOErrorEvent.IO_ERROR,this.loadErr);
      }
      
      private function loadProcess(param1:ProgressEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this._loadProcess != null)
         {
            _loc2_ = param1.bytesLoaded / param1.bytesTotal;
            _loc3_ = this._loadLength - this._urls.length - 1 + _loc2_;
            _loc4_ = _loc3_ / this._loadLength;
            this._loadProcess(_loc4_);
         }
      }
      
      private function loadCom(param1:Event) : void
      {
         var _loc2_:Sound = param1.currentTarget as Sound;
         _loc2_.removeEventListener(Event.COMPLETE,this.loadCom);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.loadErr);
         _loc2_.removeEventListener(ProgressEvent.PROGRESS,this.loadProcess);
         this._soundObj[this._curUrl] = _loc2_;
         if(this._urls.length < 1)
         {
            this.loadFin();
         }
         else
         {
            this.loadNext();
         }
      }
      
      private function loadErr(param1:IOErrorEvent) : void
      {
         var _loc2_:Sound = param1.currentTarget as Sound;
         _loc2_.removeEventListener(Event.COMPLETE,this.loadCom);
         _loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.loadErr);
         _loc2_.removeEventListener(ProgressEvent.PROGRESS,this.loadProcess);
         trace("KyoSoundLoader.loadErr :: 加载声音失败 : " + _loc2_.url);
         if(this._urls.length < 1)
         {
            this.loadFin();
         }
         else
         {
            this.loadNext();
         }
      }
      
      private function loadFin() : void
      {
         if(this._loadBack != null)
         {
            this._loadBack();
            this._loadBack = null;
         }
      }
      
      public function loadPath(param1:String, param2:String, param3:Function = null) : void
      {
         var l:URLLoader = null;
         var path:String = param1;
         var listXML:String = param2;
         var back:Function = param3;
         l = new URLLoader(new URLRequest(path + "/" + listXML));
         l.addEventListener(Event.COMPLETE,function(param1:Event):void
         {
            var _loc4_:Object = null;
            var _loc2_:XML = new XML(l.data);
            var _loc3_:Array = [];
            for each(_loc4_ in _loc2_.children())
            {
               _loc3_.push(path + "/" + _loc4_.toString());
            }
            loadSounds(_loc3_,back);
         });
      }
   }
}

