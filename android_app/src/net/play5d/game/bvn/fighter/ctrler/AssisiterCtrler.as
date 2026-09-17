package net.play5d.game.bvn.fighter.ctrler
{
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
   import net.play5d.game.bvn.fighter.models.FighterHitModel;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class AssisiterCtrler
   {
      public var hitModel:FighterHitModel;
      
      private var _effectCtrl:FighterEffectCtrl;
      
      private var _assister:Assister;
      
      private var _touchFloor:Boolean;
      
      private var _touchFloorFrame:String;
      
      private var hitTargetAction:String;
      
      private var hitTargetChecker:String;
      
      public function AssisiterCtrler()
      {
         super();
      }
      
      public function get effect() : FighterEffectCtrl
      {
         return _effectCtrl;
      }
      
      public function destory() : void
      {
         if(_effectCtrl)
         {
            _effectCtrl.destory();
            _effectCtrl = null;
         }
         if(hitModel)
         {
            hitModel.destory();
            hitModel = null;
         }
         _assister = null;
      }
      
      public function getTarget() : IGameSprite
      {
         var _loc1_:FighterMain = _assister.getOwner() as FighterMain;
         if(_loc1_)
         {
            return _loc1_.getCurrentTarget();
         }
         return null;
      }
      
      public function getOwner() : IGameSprite
      {
         return _assister.getOwner();
      }
      
      public function getSelf() : Assister
      {
         return _assister;
      }
      
      public function setApplyG(param1:Boolean) : void
      {
         _assister.isApplyG = param1;
      }
      
      public function finish(param1:Boolean = true) : void
      {
         if(param1)
         {
            EffectCtrl.I.assisterEffect(_assister);
         }
         _assister.isAttacking = false;
         removeSelf();
         _assister.gotoAndStop(1);
      }
      
      public function defineAction(param1:String, param2:Object) : void
      {
         hitModel.addHitVO(param1,param2);
      }
      
      public function get owner_mc_ctrler() : FighterMcCtrler
      {
         var _loc1_:FighterMain = _assister.getOwner() as FighterMain;
         if(_loc1_)
         {
            return _loc1_.getCtrler().getMcCtrl();
         }
         return null;
      }
      
      public function get owner_fighter_ctrler() : FighterCtrler
      {
         var _loc1_:FighterMain = _assister.getOwner() as FighterMain;
         if(_loc1_)
         {
            return _loc1_.getCtrler();
         }
         return null;
      }
      
      public function initAssister(param1:Assister) : void
      {
         hitModel = new FighterHitModel(param1);
         _assister = param1;
         _effectCtrl = new FighterEffectCtrl(param1);
      }
      
      public function endAct() : void
      {
         _assister.isAttacking = false;
      }
      
      public function render() : void
      {
         renderCheckTargetHit();
         if(_assister.isInAir)
         {
            _touchFloor = false;
            return;
         }
         if(!_touchFloor)
         {
            _touchFloor = true;
            if(_touchFloorFrame)
            {
               _assister.gotoAndPlay(_touchFloorFrame);
               _touchFloorFrame = null;
            }
         }
      }
      
      public function moveToTarget(param1:Object = null, param2:Object = null, param3:Boolean = true) : void
      {
         var _loc4_:FighterMain = _assister.getOwner() as FighterMain;
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:IGameSprite = _loc4_.getCurrentTarget();
         if(!_loc5_)
         {
            return;
         }
         if(param1 != null)
         {
            _assister.x = _loc5_.x + Number(param1) * _assister.direct;
         }
         if(param2 != null)
         {
            _assister.y = _loc5_.y + Number(param2);
         }
         if(param3)
         {
            _assister.direct = _assister.x < _loc5_.x ? 1 : -1;
         }
      }
      
      public function setDirectToTarget() : void
      {
         var _loc1_:IGameSprite = getTarget();
         if(!_loc1_)
         {
            return;
         }
         _assister.direct = _assister.x < _loc1_.x ? 1 : -1;
      }
      
      public function move(param1:Number = 0, param2:Number = 0) : void
      {
         _assister.setVelocity(param1 * _assister.direct,param2);
      }
      
      public function damping(param1:Number = 0, param2:Number = 0) : void
      {
         _assister.setDamping(param1,param2);
      }
      
      public function stop() : void
      {
         _assister.stop();
      }
      
      public function gotoAndPlay(param1:String) : void
      {
         _assister.gotoAndPlay(param1);
      }
      
      public function gotoAndStop(param1:String) : void
      {
         _assister.gotoAndStop(param1);
      }
      
      public function setTouchFloor(param1:String) : void
      {
         _touchFloorFrame = param1;
      }
      
      public function justHit(param1:String, param2:String = null, param3:Boolean = false) : Boolean
      {
         if(isJustHit(param1,param3))
         {
            if(param2 != null)
            {
               gotoAndPlay(param2);
            }
            return true;
         }
         return false;
      }
      
      private function isJustHit(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc5_:HitVO = null;
         var _loc4_:HitVO = null;
         var _loc3_:FighterMain = _assister.getOwner() as FighterMain;
         var _loc6_:IGameSprite = _loc3_.getCurrentTarget();
         if(_loc6_ && _loc6_ is FighterMain)
         {
            _loc5_ = (_loc6_ as FighterMain).hurtHit;
            if(_loc5_)
            {
               return _loc5_.id == param1;
            }
            if(param2)
            {
               _loc4_ = (_loc6_ as FighterMain).defenseHit;
               if(_loc4_)
               {
                  return _loc4_.id == param1;
               }
            }
         }
         return false;
      }
      
      public function setHitTarget(param1:String, param2:String) : void
      {
         hitTargetAction = param2;
         hitTargetChecker = param1;
      }
      
      public function removeSelf() : void
      {
         _assister.removeSelf();
      }
      
      public function fire(param1:String, param2:Object = null) : void
      {
         var mcName:String = param1;
         var params:Object = param2;
         var mc:MovieClip = _assister.mc.getChildByName(mcName) as MovieClip;
         if(mc)
         {
            if(!params)
            {
               params = {};
            }
            params.mc = mc;
            params.hitVO = hitModel.getHitVO(mcName);
            FighterEventDispatcher.dispatchEvent(_assister,"FIRE_BULLET",params);
         }
         else
         {
            _assister.setAnimateFrameOut(function():void
            {
               fire(mcName,params);
            },1);
         }
      }
      
      public function addAttacker(param1:String, param2:Object = null) : void
      {
         var mcName:String = param1;
         var params:Object = param2;
         var mc:MovieClip = _assister.mc.getChildByName(mcName) as MovieClip;
         if(mc)
         {
            if(!params)
            {
               params = {};
            }
            params.mc = mc;
            params.hitVO = hitModel.getHitVOByDisplayName(mcName);
            FighterEventDispatcher.dispatchEvent(_assister,"ADD_ATTACKER",params);
         }
         else
         {
            _assister.setAnimateFrameOut(function():void
            {
               addAttacker(mcName,params);
            },1);
         }
      }
      
      public function checkHitOwner(param1:String) : Boolean
      {
         var _loc2_:Rectangle = _assister.getHitCheckRect(param1);
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:Rectangle = _assister.getOwner().getArea();
         if(!_loc3_)
         {
            return false;
         }
         return _loc2_.intersects(_loc3_);
      }
      
      private function renderCheckTargetHit() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Rectangle = null;
         if(!hitTargetChecker)
         {
            return;
         }
         var _loc1_:Rectangle = _assister.getHitCheckRect(hitTargetChecker);
         if(!_loc1_)
         {
            return;
         }
         var _loc4_:Vector.<IGameSprite> = _assister.getTargets();
         if(!_loc4_)
         {
            return;
         }
         while(_loc2_ < _loc4_.length)
         {
            _loc3_ = _loc4_[_loc2_].getBodyArea();
            if(_loc3_ && _loc1_.intersects(_loc3_))
            {
               gotoAndPlay(hitTargetAction);
            }
            _loc2_++;
         }
      }
   }
}

