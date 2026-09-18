package net.play5d.game.bvn.fighter.ctrler
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.fighter.FighterMC;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   
   public class FighterEffectCtrl
   {
      
      private var _target:BaseGameSprite;
      
      private var _targetDisplay:DisplayObject;
      
      private var _inGhostStep:Boolean;
      
      private var _faceObj:Object = {};
      
      private var _isShakeIng:Boolean;
      
      private var _isShadowIng:Boolean;
      
      private var _isGlowIng:Boolean;
      
      public function FighterEffectCtrl(param1:BaseGameSprite)
      {
         super();
         _target = param1;
         _targetDisplay = param1.getDisplay();
      }
      
      public function destory() : void
      {
         _target = null;
         _targetDisplay = null;
         _faceObj = null;
      }
      
      public function setBishaFace(param1:String, param2:Class) : void
      {
         _faceObj[param1] = param2;
      }
      
      private function getFace(param1:String) : DisplayObject
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:Class = _faceObj[param1];
         if(!_loc2_)
         {
            Debugger.errorMsg("未定义必杀特写:" + param1);
            return null;
         }
         var _loc3_:BitmapData = new _loc2_();
         var _loc4_:Bitmap = new Bitmap(_loc3_);
         _loc4_.smoothing = !GameConfig.PIXEL_STYLE_MODE;
         return _loc4_;
      }
      
      public function shine(param1:uint = 16777215) : void
      {
         var _loc2_:Number = param1 == 16777215 ? 0.3 : 0.2;
         EffectCtrl.I.shine(param1,_loc2_);
      }
      
      public function shake(param1:Number = 0, param2:Number = 3, param3:Number = 0) : void
      {
         var _loc4_:Number = Math.max(param1,param2);
         EffectCtrl.I.shake(0,_loc4_ * 2,param3 * 1000);
      }
      
      public function startShake(param1:Number = 0, param2:Number = 3) : void
      {
         _isShakeIng = true;
         EffectCtrl.I.startShake(param1,param2);
      }
      
      public function endShake() : void
      {
         if(_isShakeIng)
         {
            EffectCtrl.I.endShake();
            _isShakeIng = false;
         }
      }

      public function shadow(param1:int = 0, param2:int = 0, param3:int = 0) : void
      {
         _isShadowIng = true;
         var fighterMain:FighterMain = _target as FighterMain;
         if(fighterMain != null)
         {
            var fighterMc:FighterMC = fighterMain.getMC();
            if(fighterMc != null)
            {
               fighterMc.startShadow(fighterMc.mc,param1,param2,param3);
               return;
            }
         }
         EffectCtrl.I.startShadow(_targetDisplay,param1,param2,param3);
      }

      public function endShadow() : void
      {
         if(_isShadowIng)
         {
            _isShadowIng = false;
            var fighterMain:FighterMain = _target as FighterMain;
            if(fighterMain != null)
            {
               var fighterMc:FighterMC = fighterMain.getMC();
               if(fighterMc != null)
               {
                  fighterMc.startShadow(fighterMc.mc,0,0,0);
                  return;
               }
            }
            EffectCtrl.I.endShadow(_targetDisplay);
         }
      }

            
      public function dash(param1:Boolean = true) : void
      {
         if(_target.isInAir)
         {
            EffectCtrl.I.doEffectById("dash_air",_target.x,_target.y,_target.direct,null,param1);
         }
         else
         {
            EffectCtrl.I.doEffectById("dash",_target.x,_target.y,_target.direct,null,param1);
         }
      }
      
      public function bisha(param1:Boolean = false, param2:String = null) : void
      {
         var _loc3_:DisplayObject = getFace(param2);
         EffectCtrl.I.bisha(_target,param1,_loc3_);
         EffectCtrl.I.startRenderBlackBack();
      }
      
      public function endBisha() : void
      {
         EffectCtrl.I.endBisha(_target);
      }
      
      public function startWanKai(param1:String = null) : void
      {
         var _loc2_:DisplayObject = param1 ? getFace(param1) : null;
         EffectCtrl.I.wanKai(_target as FighterMain,_loc2_);
      }
      
      public function endWanKai() : void
      {
         if((_target as FighterMain).actionState == 50)
         {
            EffectCtrl.I.endWanKai(_target as FighterMain);
         }
      }
      
      public function walk() : void
      {
         if(_inGhostStep)
         {
            EffectCtrl.I.doEffectById("ghost_step",_target.x,_target.y,_target.direct);
         }
         else
         {
            SoundCtrl.I.playAssetSoundRandom("step1","step2","step3");
         }
      }
      
      public function jump() : void
      {
         EffectCtrl.I.jumpEffect(_targetDisplay.x,_targetDisplay.y);
      }
      
      public function jumpAir() : void
      {
         EffectCtrl.I.jumpAirEffect(_targetDisplay.x,_targetDisplay.y);
      }
      
      public function touchFloor() : void
      {
         EffectCtrl.I.touchFloorEffect(_targetDisplay.x,_targetDisplay.y);
      }
      
      public function hitFloor(type:int, shakePow:Number = 0) : void
      {
         if(_target is FighterMain && (_target as FighterMain).mosouEnemyData && !(_target as FighterMain).mosouEnemyData.isBoss)
         {
            if(shakePow > 1)
            {
               shakePow = 1;
            }
         }
         if(shakePow > 0)
         {
            shake(0,shakePow);
         }
         EffectCtrl.I.hitFloorEffect(type,_targetDisplay.x,_targetDisplay.y);
      }
      
      public function hitWall(type:int = 0, shakePow:Number = 3) : void
      {
         if(_target is FighterMain && (_target as FighterMain).mosouEnemyData && !(_target as FighterMain).mosouEnemyData.isBoss)
         {
            if(shakePow > 1)
            {
               shakePow = 1;
            }
         }
         if(shakePow > 0)
         {
            shake(shakePow,shakePow * 0.5);
         }
         var impactY:Number = _targetDisplay.y - 35;
         EffectCtrl.I.hitFloorEffect(type,_targetDisplay.x,impactY);
      }
      
      public function slowDown(param1:Number) : void
      {
         EffectCtrl.I.slowDown(1.5,param1 * 1000);
      }
      
      public function energyExplode() : void
      {
         EffectCtrl.I.energyExplode(_target);
      }
      
      public function replaceSkill() : void
      {
         EffectCtrl.I.replaceSkill(_target);
      }
      
      public function ghostStep() : void
      {
         _inGhostStep = true;
         EffectCtrl.I.ghostStep(_target);
      }
      
      public function endGhostStep() : void
      {
         _inGhostStep = false;
         EffectCtrl.I.endGhostStep(_target);
      }
      
      public function startGlow(param1:uint = 16777215) : void
      {
         _isGlowIng = true;
         var _loc3_:Point = new Point(20,20);
         var _loc4_:Number = 2;
         var _loc2_:GlowFilter = new GlowFilter(param1,1,_loc3_.x,_loc3_.y,_loc4_,1,false,true);
         EffectCtrl.I.startFilter(_target,_loc2_,_loc3_);
      }
      
      public function endGlow() : void
      {
         if(_isGlowIng)
         {
            EffectCtrl.I.endFilter(_target);
         }
         _isGlowIng = false;
      }
      
      public function clean() : void
      {
         endGhostStep();
         endGlow();
         endShadow();
      }
   }
}

