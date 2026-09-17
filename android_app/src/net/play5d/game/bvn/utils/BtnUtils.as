package net.play5d.game.bvn.utils
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.geom.ColorTransform;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.kyo.utils.KyoUtils;
   
   public class BtnUtils
   {
      private static var _btnMap:Dictionary = new Dictionary();
      
      public function BtnUtils()
      {
         super();
      }
      
      public static function btnMode(param1:Sprite, param2:Boolean = true, param3:Boolean = false) : void
      {
         if(!param1)
         {
            return;
         }
         param1.buttonMode = param2;
         param1.mouseChildren = param3;
      }
      
      public static function initBtn(param1:DisplayObject, param2:Function, param3:* = null) : void
      {
         if(!param1)
         {
            return;
         }
         if(!param3)
         {
            param3 = param1;
         }
         _btnMap[param1] = {
            "handler":param2,
            "target":param3,
            "transform":KyoUtils.cloneColorTransform(param1.transform.colorTransform)
         };
         if(GameConfig.TOUCH_MODE)
         {
            param1.addEventListener("touchEnd",touchHandler);
         }
         else
         {
            param1.addEventListener("mouseOver",btnHandler);
            param1.addEventListener("mouseOut",btnHandler);
            param1.addEventListener("click",btnHandler);
         }
      }
      
      private static function btnHandler(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = param1.currentTarget as DisplayObject;
         switch(param1.type)
         {
            case "click":
               applyBtnFunc(_loc2_);
               break;
            case "mouseOver":
               overEffect(_loc2_,true);
               break;
            case "mouseOut":
               overEffect(_loc2_,false);
         }
      }
      
      private static function touchHandler(param1:TouchEvent) : void
      {
         var _loc2_:DisplayObject = param1.currentTarget as DisplayObject;
         var _loc3_:* = param1.type;
         if("touchEnd" === _loc3_)
         {
            applyBtnFunc(_loc2_);
         }
      }
      
      private static function overEffect(param1:DisplayObject, param2:Boolean) : void
      {
         var _loc3_:ColorTransform = null;
         var _loc5_:Object = _btnMap[param1];
         var _loc4_:ColorTransform = _loc5_.transform;
         if(param2)
         {
            _loc3_ = KyoUtils.cloneColorTransform(_loc4_);
            _loc3_.redOffset += 30;
            _loc3_.greenOffset += 30;
            _loc3_.blueOffset += 30;
            param1.transform.colorTransform = _loc3_;
            SoundCtrl.I.sndSelect();
         }
         else
         {
            param1.transform.colorTransform = _loc4_;
         }
      }
      
      private static function applyBtnFunc(param1:DisplayObject) : void
      {
         var _loc2_:Object = _btnMap[param1];
         if(!_loc2_ || !_loc2_.handler)
         {
            return;
         }
         SoundCtrl.I.sndConfrim();
         _loc2_.handler(_loc2_.target);
      }
      
      public static function destoryBtn(param1:DisplayObject) : void
      {
         if(!param1)
         {
            return;
         }
         param1.removeEventListener("touchEnd",touchHandler);
         param1.removeEventListener("mouseOver",btnHandler);
         param1.removeEventListener("mouseOut",btnHandler);
         param1.removeEventListener("click",btnHandler);
         delete _btnMap[param1];
      }
   }
}

