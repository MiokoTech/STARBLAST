package net.play5d.kyo.loader
{
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.utils.Dictionary;
   
   public class KyoClassLoader extends EventDispatcher
   {
      private var _classes:Object = {};
      
      private var _urls:Array;
      
      private var _defaultId:String;
      
      private var _loadedAmount:int;
      
      private var _loadLength:int;
      
      private var _directory:Dictionary = new Dictionary();
      
      private var _loading:Boolean;
      
      public function KyoClassLoader()
      {
         super();
      }
      
      public function getClass(param1:String, param2:String = null) : Class
      {
         var className:String = param1;
         var swf:String = param2;
         swf ||= this._defaultId;
         var app:ApplicationDomain = this._classes[swf];
         if(!app)
         {
            throw new Error(swf + "未加载!");
         }
         try
         {
            return app.getDefinition(className) as Class;
         }
         catch(e:Error)
         {
            throw new Error("在 " + swf + " 中找不到 " + className + " 的定义!");
         }
         return null;
      }
      
      public function get loadedAmount() : int
      {
         return this._loadedAmount;
      }
      
      public function load(param1:Object) : void
      {
         if(this._loading)
         {
            throw new Error("不可以在没完成加载时继续调用此方法!");
         }
         if(param1 is String)
         {
            this._urls = [param1];
         }
         if(param1 is Array)
         {
            this._urls = param1 as Array;
         }
         this._loadLength = this._urls.length;
         this._loadedAmount = 0;
         this.loadNext();
         this._loading = true;
      }
      
      public function addSwf(param1:String, param2:Loader) : void
      {
         var id:String = param1;
         var swf:Loader = param2;
         this._classes[id] = swf.contentLoaderInfo.applicationDomain;
         try
         {
            swf.unloadAndStop(true);
         }
         catch(e:Error)
         {
            swf.unload();
         }
      }
      
      private function loadNext() : Boolean
      {
         if(this._urls.length < 1)
         {
            return false;
         }
         ++this._loadedAmount;
         var _loc1_:Loader = new Loader();
         _loc1_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadComplete);
         _loc1_.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.loadProgress);
         _loc1_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.loadError);
         var _loc2_:String = this._urls.shift();
         _loc1_.load(new URLRequest(_loc2_));
         this._directory[_loc1_] = _loc2_;
         return true;
      }
      
      private function removeLoader(param1:Loader) : void
      {
         var loader:Loader = param1;
         loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.loadComplete);
         loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.loadProgress);
         loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.loadError);
         try
         {
            loader.unloadAndStop(true);
         }
         catch(e:Error)
         {
            loader.unload();
         }
         loader = null;
      }
      
      private function loadComplete(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.currentTarget as LoaderInfo;
         var _loc3_:Loader = _loc2_.loader;
         var _loc4_:String = this._directory[_loc3_];
         this._defaultId = this._defaultId || _loc4_;
         this._classes[_loc4_] = _loc2_.applicationDomain;
         this.removeLoader(_loc3_);
         this.checkComplete();
      }
      
      private function loadProgress(param1:ProgressEvent) : void
      {
         dispatchEvent(param1);
      }
      
      private function loadError(param1:IOErrorEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:Loader = (param1.currentTarget as LoaderInfo).loader;
         if(Boolean(_loc2_) && Boolean(_loc2_.loaderInfo))
         {
            _loc3_ = _loc2_.loaderInfo.loaderURL;
         }
         trace("loadError",_loc3_);
         dispatchEvent(param1);
         this.checkComplete();
      }
      
      private function checkComplete() : void
      {
         if(this.loadNext() == false)
         {
            this._loading = false;
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
   }
}

