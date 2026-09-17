package net.play5d.game.bvn.utils
{
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.display.DisplayObject;
   import flash.media.SoundTransform;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import net.play5d.game.bvn.interfaces.ISwfLib;
   import net.play5d.game.bvn.data.GameData;
   
   public class ResUtils
   {
      private static var _i:ResUtils;      

      public static var SETTING:String = "stg_set_ui";
      public static var CONGRATULATIONS:String = "mc_congratulations";
      public static var WINNER:String = "winner_stg_mc";
      public static var TITLE:String = "stg_title";
      public static var GAME_OVER:String = "stg_gameover_mc";
      public static var SELECT:String = "stg_select";
      public static var MOSOU:String = "stg_mosou";
      public static var BIG_MAP:String = "big_map_mc";

      public static var swfLib:ISwfLib;
      private var _swfPool:Dictionary;      
      private var _initBack:Function;
      private var _initError:Function;
      private var _inited:Boolean;
      private var _initing:Boolean;
      
      public function ResUtils()
      {
      }
      
      public static function get I() : ResUtils
      {
         _i ||= new ResUtils();
         return _i;
      }
      
      public function initalize(back:Function = null, error:Function = null) : void
      {
         if(_initing)
         {
            throw new Error("正在初始化过程中，不能再次初始化！");
         }
         if (swfLib == null) {
            throw new Error('未初始化SwfLib !!');
         }
         if(_inited)
         {
            if(back != null)
            {
               back();
            }
            return;
         }
         _inited = true;
         _initing = true;
         _swfPool ||= new Dictionary();
         _initBack = back;
         _initError = error;
         var xml:XML = describeType(swfLib);
         for each(var i:XML in xml.accessor)
         {
            var k:String = i.@name;
            var cls:Class = swfLib[k];
            var swf:InsSwf = new InsSwf(cls);
            swf.ready = swfReadyBack;
            swf.error = swfErrorBack;
            _swfPool[cls] = swf;
         }
      }
      
      private function swfReadyBack(target:InsSwf) : void
      {
         for each(var i:InsSwf in _swfPool)
         {
            if(!i.isReady)
            {
               return;
            }
         }
         finish();
      }
      
      private function swfErrorBack(msg:String) : void
      {
         if(_initError != null)
         {
            _initError();
         }
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
      
      public function createDisplayObject(embedSwf:Class, itemName:String) : *
      {
         var cls:Class = getItemClass(embedSwf, itemName);
         if(cls)
         {
            var d:* = new cls();
            if(d is Sprite)
            {
               var mc:Sprite = d as Sprite;
               var st:SoundTransform = mc.soundTransform;
               st.volume = GameData.I.config.soundVolume;
               mc.soundTransform = st;
               return mc;
            }
            return d;
         }
      }
      
      public function createBitmapData(embedSwf:Class, itemName:String, width:int, height:int) : BitmapData
      {
         var cls:Class = getItemClass(embedSwf, itemName);
         if(!cls)
         {
            return null;
         }
         return new cls(width,height);
      }
      
      public function getItemClass(embedSwf:Class, itemName:String) : Class
      {
         if(!_swfPool)
         {
            throw new Error("未进行初始化！");
         }
         var swf:InsSwf = _swfPool[embedSwf];
         if(!swf)
         {
            throw new Error("swf is undefined!");
         }
         return swf.getClass(itemName);
      }
   }
}

import flash.display.DisplayObject;
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
   private var _content:DisplayObject;
   public var isReady:Boolean;
   public var ready:Function;   
   public var error:Function;
   
   
   public function InsSwf(swfClass:Class)
   {
      _swf = new swfClass();
      var bytes:ByteArray = _swf.movieClipData;
      if(!bytes)
      {
         error("未发现swf的movieClipData!");
         throw new Error("未发现swf的movieClipData!");
      }
      var loader:Loader = new Loader();
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete, false, 0, true);
      var lc:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
      lc.allowCodeImport = true;
      loader.loadBytes(bytes,lc);
   }
   
   public function getClass(name:String) : Class
   {
      return _domain.getDefinition(name) as Class;
   }
   
   private function loadComplete(e:Event) : void
   {
      var l:LoaderInfo = e.currentTarget as LoaderInfo;
      _domain = l.applicationDomain;
      _content = l.content;
      isReady = true;
      if(ready != null)
      {
         ready(this);
         ready = null;
      }
   }
}
