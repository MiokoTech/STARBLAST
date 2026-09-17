package net.play5d.game.bvn.mob.utils
{
   import flash.display.BitmapData;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   
   public class UIAssetUtil
   {
      private static var _i:UIAssetUtil;
      
      [Embed(source='/../../common/swf/mob_ui.swf')]
      public var win_ui:Class;
      
      private var _swfPool:Dictionary;
      
      private var _initBack:Function;
      
      private var _inited:Boolean;
      
      private var _initing:Boolean;
      
      public function UIAssetUtil()
      {
         super();
      }
      
      public static function get I() : UIAssetUtil
      {
         if(!_i)
         {
            _i = new UIAssetUtil();
         }
         return _i;
      }
      
      public function initalize(param1:Function = null) : void
      {
         var _loc5_:String = null;
         var _loc6_:Class = null;
         var _loc2_:InsSwf = null;
         if(_initing)
         {
            throw new Error("正在初始化过程中，不能再次初始化！");
         }
         if(_inited)
         {
            if(param1 != null)
            {
               param1();
            }
            return;
         }
         _inited = true;
         _initing = true;
         _swfPool = new Dictionary();
         _initBack = param1;
         var _loc3_:XML = describeType(this);
         var _loc7_:Object = {};
         for each(var _loc4_:XML in _loc3_.variable)
         {
            _loc5_ = _loc4_.@name;
            _loc6_ = this[_loc5_];
            _loc2_ = new InsSwf(_loc6_);
            _loc2_.ready = swfReadyBack;
            _swfPool[_loc6_] = _loc2_;
         }
      }
      
      private function swfReadyBack(param1:InsSwf) : void
      {
         for each(var _loc2_:InsSwf in _swfPool)
         {
            if(!_loc2_.isReady)
            {
               return;
            }
         }
         finish();
      }
      
      private function finish() : void
      {
         _initing = false;
         if(_initBack != null)
         {
            _initBack();
            _initBack = null;
         }
      }
      
      public function createDisplayObject(param1:String) : *
      {
         var _loc2_:Class = getItemClass(param1);
         if(_loc2_)
         {
            return new _loc2_();
         }
      }
      
      public function createBitmapData(param1:String, param2:int, param3:int) : BitmapData
      {
         var _loc5_:Class = getItemClass(param1);
         if(!_loc5_)
         {
            return null;
         }
         return new _loc5_(param2,param3);
      }
      
      public function getItemClass(param1:String) : Class
      {
         if(!_swfPool)
         {
            throw new Error("未进行初始化！");
         }
         var _loc2_:InsSwf = _swfPool[win_ui];
         if(!_loc2_)
         {
            throw new Error("swf is undefined!");
         }
         return _loc2_.getClass(param1);
      }
   }
}

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

class InsSwf
{
   private var _swf:*;
   
   private var _domain:ApplicationDomain;
   
   public var isReady:Boolean;
   
   public var ready:Function;
   
   public function InsSwf(param1:Class)
   {
      super();
      _swf = new param1();
      var _loc2_:ByteArray = _swf.movieClipData;
      if(!_loc2_)
      {
         throw new Error("未发现swf的movieClipData!");
      }
      var _loc3_:Loader = new Loader();
      _loc3_.contentLoaderInfo.addEventListener("complete",loadComplete,false,0,true);
      var _loc4_:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
      _loc4_.allowCodeImport = true;
      _loc3_.loadBytes(_loc2_,_loc4_);
   }
   
   public function getClass(param1:String) : Class
   {
      return _domain.getDefinition(param1) as Class;
   }
   
   private function loadComplete(param1:Event) : void
   {
      var _loc2_:LoaderInfo = param1.currentTarget as LoaderInfo;
      _domain = _loc2_.applicationDomain;
      isReady = true;
      if(ready != null)
      {
         ready(this);
         ready = null;
      }
   }
}
