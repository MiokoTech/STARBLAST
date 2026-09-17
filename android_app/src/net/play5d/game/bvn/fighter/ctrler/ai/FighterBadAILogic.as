package net.play5d.game.bvn.fighter.ctrler.ai
{
   import flash.geom.Point;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.Bullet;
   import net.play5d.game.bvn.fighter.FighterAttacker;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class FighterBadAILogic extends FighterAILogicBase
   {
      public var moveLeft:Boolean;
      
      public var moveRight:Boolean;
      
      public var jump:Boolean;
      
      public var jumpDown:Boolean;
      
      public var dash:Boolean;
      
      public var downJump:Boolean;
      
      public var defense:Boolean;
      
      private var _moveKeep:Number = 40;
      
      private var _catchMoveKeep:Number = 15;
      
      private var _dashKeep:Number = 200;
      
      private var _jumpKeep:Number = 50;
      
      public var attack:Boolean;
      
      public var attackAIR:Boolean;
      
      public var skillAIR:Boolean;
      
      public var bishaAIR:Boolean;
      
      public var skill1:Boolean;
      
      public var skill2:Boolean;
      
      public var zhao1:Boolean;
      
      public var zhao2:Boolean;
      
      public var zhao3:Boolean;
      
      public var catch1:Boolean;
      
      public var catch2:Boolean;
      
      public var bisha:Boolean;
      
      public var bishaUP:Boolean;
      
      public var bishaSUPER:Boolean;
      
      public var assist:Boolean;
      
      public var specialSkill:Boolean;
      
      public var ghostStep:Boolean;
      
      public var ghostJump:Boolean;
      
      public var ghostJumpDowm:Boolean;
      
      private var _moveFrame:int;
      
      private var _defenseFrame:int;
      
      public function FighterBadAILogic(param1:int, param2:FighterMain)
      {
         super(param1,param2);
      }
      
      override public function render() : void
      {
         super.render();
         if(!_fighter || !_target)
         {
            return;
         }
         updateMoveAI();
         updateJumpAI();
         updateJumpDownAI();
         updateHurtAI();
         updateDefenseAI();
         updateSpecialSkill();
         updateGhostStep();
      }
      
      override protected function updateActionAI() : void
      {
         updateDashAI();
         updateAttackAI();
         updateSkill();
         updateBisha();
         updateCache();
         updateAssist();
      }
      
      private function updateHurtAI() : void
      {
         downJump = false;
         var _loc1_:Object = {};
         _loc1_["defult"] = [0,0,0.2,1,3,5];
         _loc1_[11] = [0,0,0,0,0,0];
         _loc1_[12] = _loc1_[13] = [0,0,0,0,0,0];
         downJump = getAIByFighterState(_loc1_);
      }
      
      private function updateMoveAI() : void
      {
         var _loc2_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc4_:Object = null;
         var _loc3_:Boolean = false;
         var _loc1_:Number = NaN;
         moveLeft = false;
         moveRight = false;
         var _loc5_:* = _fighter.actionState == 20;
         if(_loc5_)
         {
            _loc2_ = getAIResult(1,2,4,5,6,8);
            if(_loc2_)
            {
               if(_fighter.x > _target.x + 20)
               {
                  moveLeft = true;
               }
               if(_fighter.x < _target.x - 20)
               {
                  moveRight = true;
               }
            }
            return;
         }
         if(_moveFrame < GameConfig.FPS_GAME)
         {
            _moveFrame++;
            _loc6_ = true;
         }
         else
         {
            _loc4_ = {};
            _loc4_["defult"] = [3,5,7,8,9,10];
            _loc4_[10] = [2,4,5,3,1,0];
            _loc4_[11] = [2,4,3,2,0,0];
            _loc4_[12] = _loc4_[13] = [2,1,0,0,0,0];
            _loc6_ = getAIByFighterState(_loc4_);
            if(_loc6_)
            {
               _moveFrame = 0;
            }
         }
         if(_loc6_)
         {
            _loc3_ = (catch1 || catch2) && Math.abs(_fighter.y - _target.y) < 2;
            _loc1_ = _loc3_ ? _catchMoveKeep : _moveKeep;
            if(_fighter.x > _target.x + _loc1_)
            {
               moveLeft = true;
            }
            if(_fighter.x < _target.x - _loc1_)
            {
               moveRight = true;
            }
         }
         if(!moveLeft && !moveRight)
         {
            _moveFrame = GameConfig.FPS_GAME;
         }
      }
      
      private function updateJumpAI() : void
      {
         var _loc1_:Object = {};
         if(_isConting)
         {
            _loc1_["defult"] = [1,2,3,2,1,0];
            _loc1_[21] = [0,1,2,3,3,4];
         }
         else if(_fighter.y > _target.y + _jumpKeep)
         {
            _loc1_["defult"] = [2,3,4,5,6,6];
            _loc1_[12] = _loc1_[13] = [2,1,0,0,0,0];
         }
         else
         {
            _loc1_["defult"] = [0.01,0,0,0,0,0];
            _loc1_[12] = _loc1_[13] = [0.02,0,0,0,0,0];
         }
         jump = getAIByFighterState(_loc1_);
         if(_isConting && jump)
         {
            addContOrder("jump",10);
         }
      }
      
      private function updateJumpDownAI() : void
      {
         var _loc1_:Object = {};
         if(_fighter.y < _target.y - _jumpKeep)
         {
            _loc1_["defult"] = [2,3,4,5,6,6];
            _loc1_[12] = _loc1_[13] = [2,1,0,0,0,0];
         }
         else
         {
            _loc1_["defult"] = [0.01,0,0,0,0,0];
            _loc1_[12] = _loc1_[13] = [0.02,0,0,0,0,0];
         }
         jumpDown = getAIByFighterState(_loc1_);
      }
      
      private function updateDashAI() : void
      {
         var _loc2_:Object = {};
         var _loc3_:Number = getTargetDistance(_target).x;
         var _loc1_:Number = _target.x > _fighter.x ? 1 : -1;
         if(_fighter.energy < 40)
         {
            if(_loc3_ > _dashKeep && _fighter.direct == _loc1_)
            {
               _loc2_["defult"] = [0,0,0.1,0.5,0,0];
               _loc2_[10] = _loc2_[11] = [0,0.05,0.3,1,0,0];
               _loc2_[12] = _loc2_[13] = [0,0,0,0,0,0];
            }
            else
            {
               _loc2_["defult"] = [0,0,0.05,0,0,0];
               _loc2_[10] = _loc2_[11] = _loc2_[12] = _loc2_[13] = [0,0,0,0,0,0];
            }
         }
         else if(_loc3_ > _dashKeep && _fighter.direct != _target.direct)
         {
            _loc2_["defult"] = [0.5,1,2,5,7,9];
            _loc2_[10] = [0,0,0.1,3,1,0];
            _loc2_[11] = [0,0,0.05,1,0,0];
            _loc2_[12] = _loc2_[13] = [0,0,0,0,0,0];
         }
         else
         {
            _loc2_["defult"] = [0,0,0.05,0.1,0,0];
            _loc2_[10] = _loc2_[11] = _loc2_[12] = _loc2_[13] = [0,0,0,0,0,0];
         }
         dash = getAIByFighterState(_loc2_);
      }
      
      private function updateDefenseAI() : void
      {
         var _loc6_:Object = null;
         var _loc2_:* = null;
         var _loc7_:Point = null;
         if(defense)
         {
            _loc6_ = {};
            _loc6_["defult"] = [10,10,10,10,10,10];
            _loc6_[40] = [5,4,4,3,2,1];
            _loc6_[0] = [2,1,1,0,0,0];
            _loc6_[21] = [0,0,0,0,0,0];
            _loc6_[22] = [0,0,0,0,0,0];
            _loc6_[23] = [0,0,0,0,0,0];
            defense = getAIByFighterState(_loc6_);
            if(defense)
            {
               return;
            }
         }
         var _loc3_:Point = getTargetDistance(_target);
         var _loc1_:Object = {};
         _loc1_["defult"] = [0,0,0,0,0,0];
         if(_loc3_.x < 100 && _loc3_.y < 100)
         {
            _loc1_[10] = [0.5,1,3,5,7,9];
         }
         else
         {
            _loc1_[10] = [0.5,1,3,2,1,0];
         }
         _loc1_[11] = [1,3,5,7,9,10];
         _loc1_[12] = _loc1_[13] = [2,4,6,8,10,10];
         defense = getAIByFighterState(_loc1_);
         if(defense)
         {
            return;
         }
         var _loc5_:Vector.<IGameSprite> = _fighter.getTargets();
         for each(var _loc4_ in _loc5_)
         {
            if(_loc4_ != _target)
            {
               if(_loc4_ is Bullet && (_loc4_ as Bullet).isAttacking())
               {
                  _loc7_ = getTargetDistance(_loc4_);
                  if(_loc7_.x < 200 && _loc7_.y < 150)
                  {
                     defense = getAIResult(2,4,5,7,9,10);
                  }
                  else
                  {
                     defense = getAIResult(2,4,5,5,2,1);
                  }
                  if(defense)
                  {
                     return;
                  }
               }
               if(_loc4_ is FighterAttacker && (_loc4_ as FighterAttacker).isAttacking)
               {
                  defense = getAIResult(2,4,5,7,9,10);
                  if(defense)
                  {
                     return;
                  }
               }
               if(_loc4_ is Assister && (_loc4_ as Assister).isAttacking)
               {
                  defense = getAIResult(2,4,6,8,10,10);
                  if(defense)
                  {
                     return;
                  }
               }
            }
         }
      }
      
      private function updateAttackAI() : void
      {
         var _loc3_:String = null;
         attack = false;
         attackAIR = false;
         if(!_fighterAction.attack && !_fighterAction.attackAIR)
         {
            return;
         }
         if(!targetCanBeHit())
         {
            return;
         }
         var _loc2_:Object = {};
         _loc2_.defult = _isConting ? [1,2,3,6,9,10] : [0.5,1,4,6,8,10];
         _loc2_[20] = [0.5,1,3,2,2,1];
         _loc2_[16] = [0.5,1,1,0.5,0,0];
         _loc2_[10] = [0.5,1,1,0,0,0];
         _loc2_[11] = _loc2_[12] = _loc2_[13] = [0,0,0,0,0,0];
         var _loc1_:Boolean = getAIByFighterState(_loc2_);
         if(!_loc1_)
         {
            return;
         }
         var _loc4_:int = 10;
         if(_isConting)
         {
            attack = true;
            attackAIR = _fighter.y < _target.y;
            _loc3_ = _fighter.getCtrler().getMcCtrl().getCurAction();
            if(_loc3_ == "砍1")
            {
               _loc4_ = 200;
            }
         }
         else
         {
            attack = targetInRange("kanmian");
            attackAIR = targetInRange("tkanmian") && _fighter.y < _target.y;
            _loc4_ = 300;
         }
         if(attack)
         {
            addContOrder("attack",_loc4_);
         }
         if(attackAIR)
         {
            addContOrder("attackAIR",_loc4_);
         }
      }
      
      private function updateSkill() : void
      {
         skill1 = _fighterAction.skill1 && getSkillAI("skill1","kj1","kj1mian",10);
         skill2 = _fighterAction.skill2 && getSkillAI("skill2","kj2","kj2mian",10);
         zhao1 = _fighterAction.zhao1 && getSkillAI("zhao1","zh1","zh1mian",10);
         zhao2 = _fighterAction.zhao2 && getSkillAI("zhao2","zh2","zh2mian",10);
         zhao3 = _fighterAction.zhao3 && getSkillAI("zhao3","zh3","zh3mian",10);
         skillAIR = _fighterAction.skillAIR && getSkillAI("skillAIR","tz","tzmian",10);
      }
      
      private function getSkillAI(param1:String, param2:String, param3:String, param4:int) : Boolean
      {
         var _loc6_:Object = {};
         var _loc5_:Boolean = false;
         if(isBreakAct(param2))
         {
            _loc6_.defult = _isConting ? [0.1,0.2,0.5,3,6,10] : [0,0.2,0.5,2,1,0];
            _loc6_[20] = _isConting ? [0,0.2,0.7,5,7,9] : [0.1,0.2,0.5,1,2,2];
         }
         else
         {
            _loc6_.defult = _isConting ? [0,0,0.1,1,5,10] : [0.1,0.5,1,3,2,0.2];
            _loc6_[20] = [0,0,1,1,0,0];
         }
         _loc6_[16] = [0.5,1,0.5,0,0,0];
         _loc6_[10] = [0,0,0,1,1,2];
         _loc6_[11] = _loc6_[12] = _loc6_[13] = [0,0,0,0,0,0];
         _loc5_ = getAIByFighterState(_loc6_) && targetCanBeHit() && targetInRange(param3);
         if(_loc5_)
         {
            if(_isConting)
            {
               addContOrder(param1,isHitDownAct(param2) ? param4 : param4 + 100);
            }
         }
         return _loc5_;
      }
      
      public function updateBisha() : void
      {
         bisha = _fighterAction.bisha && getBishaAI("bisha","bs","bsmian",100,100);
         bishaUP = _fighterAction.bishaUP && getBishaAI("bishaUP","sbs","sbsmian",100,100);
         bishaSUPER = _fighterAction.bishaSUPER && getBishaAI("bishaSUPER","cbs","cbsmian",300,200);
         bishaAIR = _fighterAction.bishaAIR && getBishaAI("bishaAIR","kbs","kbsmian",100,210);
      }
      
      private function getBishaAI(param1:String, param2:String, param3:String, param4:int, param5:int) : Boolean
      {
         var _loc7_:Object = {};
         var _loc6_:Boolean = false;
         if(_fighter.qi >= param4)
         {
            if(isBreakAct(param2))
            {
               _loc7_.defult = _isConting ? [0,0,0.3,2,5,10] : [0.1,0.2,0.5,2,2,2];
               _loc7_[20] = _isConting ? [0,0,0.5,3,7,9] : [0.1,0.2,1,6,8,10];
            }
            else
            {
               _loc7_.defult = _isConting ? [0,0,0.5,4,8,10] : [0.2,0.5,1,2,2,0];
               _loc7_[21] = [0.2,0.5,1,3,5,6];
               _loc7_[14] = [0.2,0.5,1,3,4,4];
               _loc7_[20] = _isConting ? [0.2,0.5,1,3,2,1] : [0.2,0.5,1,2,1,0];
            }
            _loc7_[16] = [0.2,0.5,0,0,0,0];
            _loc7_[10] = [0,0.2,0.5,2,1,1];
            _loc7_[11] = _loc7_[12] = _loc7_[13] = [0,0,0.1,0,0,0];
            _loc6_ = getAIByFighterState(_loc7_) && targetCanBeHit() && targetInRange(param3);
         }
         if(_loc6_)
         {
            if(_isConting)
            {
               addContOrder(param1,param5);
            }
         }
         return _loc6_;
      }
      
      private function updateCache() : void
      {
         catch1 = false;
         catch2 = false;
         var _loc1_:Object = {};
         if(_targetFighter && (_targetFighter.actionState == 21 || _targetFighter.actionState == 22 || _targetFighter.actionState == 23))
         {
            return;
         }
         var _loc2_:Point = getTargetDistance(_target);
         if(_loc2_.x < 50)
         {
            _loc1_.defult = [0,0.5,1,3,2,1];
            _loc1_[20] = [1,2,4,5,7,10];
         }
         else
         {
            _loc1_.defult = [0,0.5,1,0,0,0];
            _loc1_[20] = [1,2,3,4,3,2];
         }
         catch1 = getAIByFighterState(_loc1_) && targetCanBeHit();
         catch2 = getAIByFighterState(_loc1_) && targetCanBeHit();
         if(catch1)
         {
            addContOrder("catch1",150);
         }
         if(catch2)
         {
            addContOrder("catch2",110);
         }
      }
      
      private function updateSpecialSkill() : void
      {
         var _loc1_:Object = null;
         if(_fighter.actionState == 21)
         {
            if(_fighter.hp > _fighter.hpMax * 0.6)
            {
               return;
            }
            if(_fighter.qi < 150)
            {
               return;
            }
            _loc1_ = {};
            _loc1_.defult = [0,0,0,0,0.1,0.2];
            _loc1_[11] = [0,0,0,0,0.2,0.4];
            specialSkill = getAIByFighterState(_loc1_);
         }
      }
      
      private function updateAssist() : void
      {
         var _loc1_:Object = {};
         _loc1_.defult = [0,0.02,0.05,0.05,0,0];
         _loc1_[20] = [0,0.02,0.05,0.1,0.3,0.5];
         _loc1_[12] = [0,0,0,0,0,0];
         _loc1_[13] = [0,0,0,0,0,0];
         assist = getAIByFighterState(_loc1_);
      }
      
      private function updateGhostStep() : void
      {
         var _loc1_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Point = getTargetDistance(_target);
         if(_loc4_.x > 80 || _loc4_.y > 80)
         {
            return;
         }
         if(_fighter.qi < 200)
         {
            return;
         }
         if(_fighter.actionState != 10 && _fighter.actionState != 11)
         {
            return;
         }
         var _loc2_:Object = {};
         _loc2_.defult = [0,0,0,0,0,0];
         _loc2_[21] = [0,0,0,0,0.1,0.2];
         ghostStep = getAIByFighterState(_loc2_);
         if(_target.y - _fighter.y < -80 && _target.y - _fighter.y > -100)
         {
            _loc1_ = {};
            _loc1_.defult = [0,0,0,0,0,0];
            _loc1_[21] = [0,0,0.1,0.1,0.1,0.1];
            ghostJump = getAIByFighterState(_loc2_);
         }
         else
         {
            ghostJump = false;
         }
         if(_target.y - _fighter.y < 80 && _target.y - _fighter.y > 100)
         {
            _loc3_ = {};
            _loc3_.defult = [0,0,0,0,0,0];
            _loc3_[21] = [0,0,0,0.1,0.1,0.1];
            ghostJumpDowm = getAIByFighterState(_loc3_);
         }
         else
         {
            ghostJumpDowm = false;
         }
      }
   }
}

