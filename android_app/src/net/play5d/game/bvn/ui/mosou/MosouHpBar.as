package net.play5d.game.bvn.ui.mosou
{
   import flash.display.DisplayObject;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class MosouHpBar
   {
      private var _fighter:FighterMain;
      
      private var _bar:DisplayObject;
      
      private var _bar2:DisplayObject;
      
      private var _hprate:Number = 1;
      
      private var _redBarMoving:Boolean;
      
      private var _redBarMoveDelay:int;
      
      private var _justHurtFly:Boolean;
      
      private var _direct:int;
      
      public function MosouHpBar(param1:DisplayObject, param2:DisplayObject)
      {
         super();
         _bar = param1;
         _bar2 = param2;
      }
      
      public function setFighter(param1:FighterMain) : void
      {
         _fighter = param1;
      }
      
      public function render() : void
      {
         var _loc5_:Number = NaN;
         var _loc2_:Number = NaN;
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

