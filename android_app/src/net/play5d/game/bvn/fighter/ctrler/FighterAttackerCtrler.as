package net.play5d.game.bvn.fighter.ctrler
{
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterAttacker;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class FighterAttackerCtrler
   {
      
      public var effect:FighterEffectCtrl;
      
      public var ownerMc:FighterMcCtrler;
      
      private var _attacker:FighterAttacker;
      
      private var _touchFloor:Boolean;
      
      private var _touchFloorFrame:String;
      
      private var hitTargetAction:String;
      
      private var hitTargetChecker:String;
      
      public function FighterAttackerCtrler(param1:FighterAttacker)
      {
         super();
         _attacker = param1;
      }
      
      public function get owner_mc_ctrler() : FighterMcCtrler
      {
         var _loc1_:FighterMain = _attacker.getOwner() as FighterMain;
         if(_loc1_)
         {
            return _loc1_.getCtrler().getMcCtrl();
         }
         return null;
      }
      
      public function get owner_fighter_ctrler() : FighterCtrler
      {
         var _loc1_:FighterMain = _attacker.getOwner() as FighterMain;
         if(_loc1_)
         {
            return _loc1_.getCtrler();
         }
         return null;
      }
      
      public function destory() : void
      {
         _attacker = null;
         effect = null;
         ownerMc = null;
      }
      
      public function endAct() : void
      {
         _attacker.isAttacking = false;
      }
      
      public function render() : void
      {
         renderCheckTargetHit();
         if(_attacker.isInAir)
         {
            _touchFloor = false;
            return;
         }
         if(!_touchFloor)
         {
            _touchFloor = true;
            if(_touchFloorFrame)
            {
               _attacker.gotoAndPlay(_touchFloorFrame);
               _touchFloorFrame = null;
            }
         }
      }
      
      private function renderCheckTargetHit() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Rectangle = null;
         if(!hitTargetChecker)
         {
            return;
         }
         var _loc1_:Rectangle = _attacker.getHitCheckRect(hitTargetChecker);
         if(!_loc1_)
         {
            return;
         }
         var _loc4_:Vector.<IGameSprite> = _attacker.getTargets();
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
      
      public function stopFollowTarget() : void
      {
         _attacker.stopFollowTarget();
      }
      
      public function moveToTarget(param1:Number = NaN, param2:Number = NaN) : void
      {
         _attacker.moveToTarget(param1,param2);
      }
      
      public function move(param1:Number = 0, param2:Number = 0) : void
      {
         _attacker.setVelocity(param1 * _attacker.direct,param2);
      }
      
      public function damping(param1:Number = 0, param2:Number = 0) : void
      {
         _attacker.setDamping(param1,param2);
      }
      
      public function stop() : void
      {
         _attacker.stop();
      }
      
      public function gotoAndPlay(param1:String) : void
      {
         _attacker.gotoAndPlay(param1);
      }
      
      public function gotoAndStop(param1:String) : void
      {
         _attacker.gotoAndStop(param1);
      }
      
      public function setTouchFloor(param1:String) : void
      {
         _touchFloorFrame = param1;
      }
      
      public function justHit(param1:String) : Boolean
      {
         var _loc2_:IGameSprite = _attacker.getOwner();
         if(_loc2_ is FighterMain)
         {
            return (_attacker.getOwner() as FighterMain).getCtrler().justHit(param1);
         }
         if(_loc2_ is Assister)
         {
            return (_attacker.getOwner() as Assister).getCtrler().justHit(param1);
         }
         return false;
      }
      
      public function setHitTarget(param1:String, param2:String) : void
      {
         hitTargetAction = param2;
         hitTargetChecker = param1;
      }
      
      public function setCrossMap(param1:Boolean) : void
      {
         _attacker.isAllowCrossX = _attacker.isAllowCrossBottom = param1;
      }
      
      public function removeSelf() : void
      {
         _attacker.removeSelf();
      }
      
      public function fire(param1:String, param2:Object = null) : void
      {
         var mc:MovieClip;
         var hv:HitVO;
         var mcName:String = param1;
         var params:Object = param2;
         if(!owner_fighter_ctrler || !owner_fighter_ctrler.hitModel)
         {
            trace("hitModel error!");
            return;
         }
         mc = _attacker.mc.getChildByName(mcName) as MovieClip;
         if(mc)
         {
            if(!params)
            {
               params = {};
            }
            params.mc = mc;
            hv = owner_fighter_ctrler.hitModel.getHitVOByDisplayName(mcName);
            if(!hv)
            {
               trace("hitVO error!");
               return;
            }
            hv = hv.clone();
            hv.owner = _attacker;
            params.hitVO = hv;
            FighterEventDispatcher.dispatchEvent(_attacker,"FIRE_BULLET",params);
         }
         else
         {
            _attacker.setAnimateFrameOut(function():void
            {
               fire(mcName,params);
            },1);
         }
      }
   }
}

