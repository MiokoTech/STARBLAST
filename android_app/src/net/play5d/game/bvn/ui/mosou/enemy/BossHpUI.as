package net.play5d.game.bvn.ui.mosou.enemy
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Point;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class BossHpUI
   {
      private var _ui:Sprite;
      
      private var _bar:DisplayObject;
      
      private var _bar2:DisplayObject;
      
      private var _faceCt:Sprite;
      
      private var _fighter:FighterMain;
      
      private var _redBarMoving:Boolean;
      
      private var _redBarMoveDelay:int;
      
      private var _justHurtFly:Boolean;
      
      private var _hprate:Number = 1;
      
      private var _enabled:Boolean = true;
      
      public function BossHpUI(param1:Sprite)
      {
         super();
         _ui = param1;
         _bar = param1.getChildByName("bar");
         _bar2 = param1.getChildByName("redbar");
         _faceCt = param1.getChildByName("ct_face") as Sprite;
      }
      
      public function isEnabled() : Boolean
      {
         return _ui.visible;
      }
      
      public function enabled(param1:Boolean) : void
      {
         _ui.visible = param1;
      }
      
      public function setFighter(param1:FighterMain) : void
      {
         if(!param1)
         {
            _fighter = null;
            enabled(false);
            return;
         }
         _fighter = param1;
         enabled(true);
         updateFace();
      }
      
      private function updateFace() : void
      {
         if(!_faceCt || !_fighter)
         {
            return;
         }
         _faceCt.removeChildren();
         if(!_fighter || !_fighter.data)
         {
            return;
         }
         var _loc1_:DisplayObject = AssetManager.I.getFighterFace(_fighter.data,new Point(37,37));
         if(_loc1_)
         {
            _faceCt.addChild(_loc1_);
         }
      }
      
      public function render() : void
      {
         var _loc5_:Number = NaN;
         var _loc2_:Number = NaN;
         if(!_enabled || !_fighter)
         {
            return;
         }
         var _loc1_:Number = _fighter.hp / _fighter.hpMax;
         if(_redBarMoving && _loc1_ != _hprate)
         {
            _bar2.scaleX = _hprate;
            _redBarMoving = false;
         }
         _hprate = _loc1_;
         var _loc4_:Number = _hprate - _bar.scaleX;
         var _loc3_:Number = _loc4_ < 0 ? 0.4 : 0.04;
         if(Math.abs(_loc4_) < 0.01)
         {
            _bar.scaleX = _hprate;
         }
         else
         {
            _bar.scaleX += _loc4_ * _loc3_;
         }
         switch(_fighter.actionState - 21)
         {
            case 0:
               _redBarMoveDelay = 100;
               break;
            case 1:
            case 2:
               if(_redBarMoveDelay > 0)
               {
                  if(!_justHurtFly)
                  {
                     _redBarMoveDelay = 1.5 * GameConfig.FPS_GAME;
                     _justHurtFly = true;
                  }
                  else if(_redBarMoveDelay > 0)
                  {
                     _redBarMoveDelay--;
                  }
               }
               break;
            default:
               _redBarMoveDelay = 0;
               _justHurtFly = false;
         }
         if(_redBarMoveDelay <= 0)
         {
            _loc5_ = _hprate - _bar2.scaleX;
            _loc2_ = _loc5_ < 0 ? 0.1 : 0.02;
            if(Math.abs(_loc5_) < 0.01)
            {
               _bar2.scaleX = _hprate;
               _redBarMoving = false;
            }
            else
            {
               _bar2.scaleX += _loc5_ * _loc2_;
               _redBarMoving = true;
            }
         }
      }
   }
}

