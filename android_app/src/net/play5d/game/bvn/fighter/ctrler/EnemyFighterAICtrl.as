package net.play5d.game.bvn.fighter.ctrler
{
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class EnemyFighterAICtrl implements IFighterActionCtrl
   {
      public var fighter:FighterMain;
      
      private var _target:IGameSprite;
      
      private var _followFrame:int = 0;
      
      private var _following:Boolean = false;
      
      private var _followDis:int = 0;
      
      private var _moveLeft:Boolean = false;
      
      private var _moveRight:Boolean = false;
      
      private var _jump:Boolean = false;
      
      private var _jumpDown:Boolean = false;
      
      private var _attackFrame:int = 0;
      
      private var _attack:Boolean = false;
      
      private var _zhao:Boolean;
      
      public function EnemyFighterAICtrl()
      {
         super();
      }
      
      public function initlize() : void
      {
      }
      
      public function destory() : void
      {
         fighter = null;
         _target = null;
      }
      
      public function enabled() : Boolean
      {
         return GameCtrl.I.actionEnable;
      }
      
      public function render() : void
      {
      }
      
      public function renderAnimate() : void
      {
         if(!fighter)
         {
            return;
         }
         if(!GameCtrl.I.actionEnable)
         {
            _moveLeft = false;
            _moveRight = false;
            _jump = false;
            _jumpDown = false;
            _attack = false;
            _zhao = false;
            _following = false;
            return;
         }
         _target = fighter.getCurrentTarget();
         if(!_target)
         {
            _following = false;
            _attack = false;
            _zhao = false;
            _moveLeft = false;
            _moveRight = false;
            return;
         }
         renderFollow();
         renderMove();
         renderAttack();
      }
      
      private function renderFollow() : void
      {
         if(_followFrame-- > 0)
         {
            return;
         }
         _followFrame = 60;
         _following = Math.random() < 0.5;
         if(_following)
         {
            _followDis = Math.random() > 0.6 ? 10 + Math.random() * 20 : 50 + Math.random() * 100;
         }
      }
      
      private function renderMove() : void
      {
         if(!_following)
         {
            return;
         }
         var _loc1_:Number = fighter.x > _target.x ? _target.x + _followDis : _target.x - _followDis;
         _moveLeft = _moveRight = false;
         if(fighter.x < _loc1_ - 20)
         {
            _moveRight = true;
         }
         if(fighter.x > _loc1_ + 20)
         {
            _moveLeft = true;
         }
         if(Math.abs(fighter.y - _target.y) < 30)
         {
            _jump = false;
            _jumpDown = false;
         }
         else
         {
            _jump = fighter.y > _target.y;
            _jumpDown = fighter.y < _target.y;
         }
         if(!_moveLeft && !_moveRight && !_jump && !_jumpDown)
         {
            _following = false;
         }
      }
      
      private function renderAttack() : void
      {
         if(FighterActionState.isAttacking(fighter.actionState))
         {
            _attack = Math.random() < 0.05;
            _zhao = false;
            return;
         }
         if(_attackFrame++ < 90)
         {
            return;
         }
         _attackFrame = 0;
         _attack = Math.random() < 0.2;
         _zhao = Math.random() < 0.1;
      }
      
      private function targetInRange(param1:String) : Boolean
      {
         var _loc2_:Rectangle = _target.getBodyArea();
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:Rectangle = fighter.getHitRange(param1);
         if(!_loc3_)
         {
            return false;
         }
         return _loc2_.intersection(_loc3_).isEmpty() == false;
      }
      
      public function moveLEFT() : Boolean
      {
         return _moveLeft;
      }
      
      public function moveRIGHT() : Boolean
      {
         return _moveRight;
      }
      
      public function defense() : Boolean
      {
         return false;
      }
      
      public function attack() : Boolean
      {
         return _attack && targetInRange("kanmian");
      }
      
      public function jump() : Boolean
      {
         return _jump;
      }
      
      public function jumpQuick() : Boolean
      {
         return false;
      }
      
      public function jumpDown() : Boolean
      {
         return _jumpDown;
      }
      
      public function dash() : Boolean
      {
         return false;
      }
      
      public function dashJump() : Boolean
      {
         return false;
      }
      
      public function skill1() : Boolean
      {
         return _zhao && targetInRange("kj1mian");
      }
      
      public function skill2() : Boolean
      {
         return _zhao && targetInRange("kj2mian");
      }
      
      public function zhao1() : Boolean
      {
         return _zhao && targetInRange("zh1mian");
      }
      
      public function zhao2() : Boolean
      {
         return _zhao && targetInRange("zh2mian");
      }
      
      public function zhao3() : Boolean
      {
         return _zhao && targetInRange("zh3mian");
      }
      
      public function catch1() : Boolean
      {
         return false;
      }
      
      public function catch2() : Boolean
      {
         return false;
      }
      
      public function bisha() : Boolean
      {
         return false;
      }
      
      public function bishaUP() : Boolean
      {
         return false;
      }
      
      public function bishaSUPER() : Boolean
      {
         return false;
      }
      
      public function assist() : Boolean
      {
         return false;
      }
      
      public function specailSkill() : Boolean
      {
         return false;
      }
      
      public function attackAIR() : Boolean
      {
         return _attack && targetInRange("tkanmian");
      }
      
      public function skillAIR() : Boolean
      {
         return _zhao && targetInRange("tzmian");
      }
      
      public function bishaAIR() : Boolean
      {
         return false;
      }
      
      public function waiKai() : Boolean
      {
         return false;
      }
      
      public function waiKaiW() : Boolean
      {
         return false;
      }
      
      public function waiKaiS() : Boolean
      {
         return false;
      }
      
      public function ghostStep() : Boolean
      {
         return false;
      }
      
      public function ghostJump() : Boolean
      {
         return false;
      }
      
      public function ghostJumpDown() : Boolean
      {
         return false;
      }
   }
}

