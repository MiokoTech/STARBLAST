package net.play5d.game.bvn.mob.screenpad
{
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   import flash.events.TouchEvent;
   import flash.geom.Point;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.mob.input.ScreenPadInput;
   
   public class ScreenPadMenu extends EventDispatcher
   {
      public var inputers:Vector.<ScreenPadInput>;
      
      private var _arrow:ScreenPadArrow;
      
      private var _stage:Stage;
      
      private var _listened:Boolean;
      
      private var _downCache:Object = {};
      
      private var _btns:Vector.<ScreenPadBtnBase>;
      
      private var W:Number;
      
      private var H:Number;
      
      public function ScreenPadMenu(param1:Stage)
      {
         super();
         _stage = param1;
         build();
      }
      
      public function reBuild() : void
      {
         var _loc1_:int = 0;
         try
         {
            while(_loc1_ < _btns.length)
            {
               _stage.removeChild(_btns[_loc1_].display);
               _btns[_loc1_].onRemove();
               _loc1_++;
            }
         }
         catch(e:Error)
         {
         }
         build();
      }
      
      private function build() : void
      {
         W = RootSprite.FULL_SCREEN_SIZE.x;
         H = RootSprite.FULL_SCREEN_SIZE.y;
         _btns = new Vector.<ScreenPadBtnBase>();
         _arrow = addArrow(["up","down","left","right"],ScreenPadAsset.arrow,0.2,0,0,0.2,0.5);
         addBtn("attack",ScreenPadAsset.attack,0,0,2.1,1,0.1);
         addBtn("jump",ScreenPadAsset.jump2, 0, 0, 1.1, 0.1, 0.1);
         addBtn("dash",ScreenPadAsset.dash,0,0,0.1,1,0.1);
         addBtn("skill",ScreenPadAsset.skill,0,0,1.1,1.9,0.1);
         addBtn("superSkill",ScreenPadAsset.spskill,0,0,0.2,4.5);
         addBtn("special",ScreenPadAsset.special,0,0,2.3,4.5);
         addBtn("wankai",ScreenPadAsset.wanjie,0.1,0,0,4.5);
         var pause:ScreenPadBtn = addBtn("back", ScreenPadAsset.pause, 0, 0, 0, 0.3, 0.5, 0.7);
         pause.display.x = (W - pause.display.width) / 2;

         var _loc1_:Object = GameInterfaceManager.config.screenPadConfig.joySet;
         if(_loc1_)
         {
            setBtnByConfig(_loc1_);
         }
         initBtns();
      }
      
      private function setBtnByConfig(param1:Object) : void
      {
         var _loc2_:Object = null;
         for each(var p:ScreenPadBtnBase in _btns)
         {
            _loc2_ = param1[p.keyId];
            if(_loc2_)
            {
               if(_loc2_.scale)
               {
                  p.setScale(_loc2_.scale);
               }
               if(_loc2_.x)
               {
                  p.display.x = _loc2_.x;
               }
               if(_loc2_.y)
               {
                  p.display.y = _loc2_.y;
               }
            }
         }
      }
      
      private function addArrow(param1:Array, param2:Class, param3:Number = 0, param4:Number = 0, param5:Number = 0, param6:Number = 0, param7:Number = 0, param8:Number = 3) : ScreenPadArrow
      {
         var _loc9_:Point = new Point();
         _loc9_.x = ScreenPadUtils.cm2pixel(param8);
         var _loc10_:ScreenPadArrow = ScreenPadUtils.getArrow(param2,_loc9_);
         _loc10_.moveAble = false;
         _loc10_.keyId = "arrow";
         _loc10_.setKeyIds(param1[0],param1[1],param1[2],param1[3]);
         _loc10_.areaAdd = ScreenPadUtils.cm2pixel(param7);
         if(param3 != 0)
         {
            _loc10_.display.x = ScreenPadUtils.cm2pixel(param3);
         }
         if(param4 != 0)
         {
            _loc10_.display.y = ScreenPadUtils.cm2pixel(param4);
         }
         if(param5 != 0)
         {
            _loc10_.display.x = W - _loc10_.display.width - ScreenPadUtils.cm2pixel(param5);
         }
         if(param6 != 0)
         {
            _loc10_.display.y = H - _loc10_.display.height - ScreenPadUtils.cm2pixel(param6);
         }
         _btns.push(_loc10_);
         return _loc10_;
      }
      
      private function addBtn(param1:String, param2:Class, param3:Number = 0, param4:Number = 0, param5:Number = 0, param6:Number = 0, param7:Number = 0, param8:Number = 1.1) : ScreenPadBtn
      {
         var _loc9_:Point = new Point();
         _loc9_.x = ScreenPadUtils.cm2pixel(param8);
         var _loc10_:ScreenPadBtn = ScreenPadUtils.getButton(param2,_loc9_);
         _loc10_.moveAble = false;
         _loc10_.keyId = param1;
         _loc10_.areaAdd = ScreenPadUtils.cm2pixel(param7);
         if(param3 != 0)
         {
            _loc10_.display.x = ScreenPadUtils.cm2pixel(param3);
         }
         if(param4 != 0)
         {
            _loc10_.display.y = ScreenPadUtils.cm2pixel(param4);
         }
         if(param5 != 0)
         {
            _loc10_.display.x = W - _loc10_.display.width - ScreenPadUtils.cm2pixel(param5);
         }
         if(param6 != 0)
         {
            _loc10_.display.y = H - _loc10_.display.height - ScreenPadUtils.cm2pixel(param6);
         }
         _btns.push(_loc10_);
         return _loc10_;
      }
      
      private function initBtns() : void
      {
         for each(var i:ScreenPadBtnBase in _btns)
         {
            i.initArea();
         }
      }
      
      public function show() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < _btns.length)
         {
            _stage.addChild(_btns[_loc1_].display);
            _btns[_loc1_].onAdd();
            _loc1_++;
         }
      }
      
      public function hide() : void
      {
         var _loc1_:*;
         var _loc2_:int = 0;
         try
         {
            while(_loc2_ < _btns.length)
            {
               _stage.removeChild(_btns[_loc2_].display);
               _btns[_loc2_].onRemove();
               _loc2_++;
            }
         }
         catch(e:Error)
         {
         }
         for each(_loc1_ in inputers)
         {
            _loc1_.clear();
         }
      }
      
      public function touchHandler(param1:TouchEvent) : void
      {
         var _loc3_:ScreenPadBtnBase = null;
         var _loc6_:int = 0;
         var _loc2_:int = param1.touchPointID;
         var _loc5_:Number = param1.stageX;
         var _loc4_:Number = param1.stageY;
         if(param1.type == TouchEvent.TOUCH_END)
         {
            if(_downCache[_loc2_])
            {
               _loc3_ = _downCache[_loc2_].btn;
               _loc3_.touchUP();
               setInputerDown(_downCache[_loc2_].key,false);
               delete _downCache[_loc2_];
            }
            return;
         }
         for(; _loc6_ < _btns.length; _loc6_++)
         {
            _loc3_ = _btns[_loc6_];
            switch(param1.type)
            {
               case TouchEvent.TOUCH_BEGIN:
                  if(_loc3_.checkArea(_loc5_,_loc4_))
                  {
                     _loc3_.touchDown(_loc5_,_loc4_);
                     _downCache[_loc2_] = {
                        "btn":_loc3_,
                        "key":_loc3_.keyId
                     };
                     setInputerDown(_loc3_.keyId,true);
                  }
                  continue;
               case TouchEvent.TOUCH_MOVE:
                  _loc3_.touchMove(_loc5_,_loc4_);
                  if(_loc3_ == _arrow && _loc3_.isDown() && _downCache[_loc2_].key != _loc3_.keyId)
                  {
                     setInputerDown(_downCache[_loc2_].key,false);
                     _downCache[_loc2_].key = _loc3_.keyId;
                     setInputerDown(_loc3_.keyId,true);
                     break;
                  }
            }
         }
      }
      
      private function setInputerDown(param1:Object, param2:Boolean) : void
      {
         var _loc3_:ScreenPadInput = null;
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         var _loc4_:Array = null;
         var _loc8_:String = null;
         var _loc7_:int = 0;
         var _loc5_:int = 0;
         if(param1 == null)
         {
            return;
         }
         _loc5_ = int(inputers.length);
         _loc9_ = 0;
         while(_loc9_ < _loc5_)
         {
            _loc3_ = inputers[_loc9_];
            if(param1 is String)
            {
               _loc3_.setDown(param1 as String,param2);
            }
            if(param1 is Array)
            {
               _loc4_ = param1 as Array;
               _loc7_ = int(_loc4_.length);
               _loc6_ = 0;
               while(_loc6_ < _loc7_)
               {
                  _loc8_ = _loc4_[_loc6_];
                  _loc3_.setDown(_loc8_,param2);
                  _loc6_++;
               }
            }
            _loc9_++;
         }
      }
   }
}

