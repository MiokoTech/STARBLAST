package net.play5d.game.bvn.fighter.ctrler
{
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.ctrler.ai.AIDifficultyProfile;
   import net.play5d.game.bvn.fighter.ctrler.ai.FighterAILogic;
   import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class FighterAICtrl implements IFighterActionCtrl
   {
      public var AILevel:int;
      
      public var fighter:FighterMain;
      
      private var _target:IGameSprite;
      
      private var _aiUpdateGap:int;
      
      private var _aiUpdateFrame:int;
      
      private var _idleWatchFrame:int;
      
      private var _idleRecoverCooldownFrame:int;
      
      private var _aiLogic:FighterAILogic;
      
      public function FighterAICtrl()
      {
         super();
      }
      
      public function initlize() : void
      {
         _aiLogic = new FighterAILogic(AILevel,fighter);
         _aiUpdateGap = AIDifficultyProfile.getReactionFrameGap(AILevel);
         _aiUpdateFrame = 0;
         _idleWatchFrame = 0;
         _idleRecoverCooldownFrame = 0;
      }
      
      public function destory() : void
      {
         fighter = null;
         _target = null;
         if(_aiLogic)
         {
            _aiLogic.destory();
            _aiLogic = null;
         }
         _aiUpdateGap = 0;
         _aiUpdateFrame = 0;
         _idleWatchFrame = 0;
         _idleRecoverCooldownFrame = 0;
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
         if(!_aiLogic)
         {
            return;
         }
         if(!GameCtrl.I.actionEnable)
         {
            clearAICommandState();
            _aiUpdateFrame = 0;
            _idleWatchFrame = 0;
            _idleRecoverCooldownFrame = 0;
            return;
         }
         if(_idleRecoverCooldownFrame > 0)
         {
            _idleRecoverCooldownFrame--;
         }
         if(_aiUpdateFrame-- <= 0)
         {
            _aiUpdateFrame = _aiUpdateGap;
            _aiLogic.render();
         }
         renderIdleWatchdog();
      }
      
      public function resetRoundAIState() : void
      {
         if(!_aiLogic)
         {
            return;
         }
         _aiLogic.resetRoundState();
         clearAICommandState();
         _aiUpdateFrame = 0;
         _idleWatchFrame = 0;
         _idleRecoverCooldownFrame = 0;
      }

      public function moveLEFT() : Boolean
      {
         return _aiLogic.moveLeft;
      }
      
      public function moveRIGHT() : Boolean
      {
         return _aiLogic.moveRight;
      }
      
      public function defense() : Boolean
      {
         return _aiLogic.defense;
      }
      
      public function attack() : Boolean
      {
         return _aiLogic.attack;
      }
      
      public function jump() : Boolean
      {
         return _aiLogic.jump;
      }
      
      public function jumpQuick() : Boolean
      {
         return false;
      }
      
      public function jumpDown() : Boolean
      {
         return _aiLogic.jumpDown;
      }
      
      public function dash() : Boolean
      {
         return _aiLogic.dash;
      }
      
      public function dashJump() : Boolean
      {
         return _aiLogic.downJump;
      }
      
      public function skill1() : Boolean
      {
         return _aiLogic.skill1;
      }
      
      public function skill2() : Boolean
      {
         return _aiLogic.skill2;
      }
      
      public function zhao1() : Boolean
      {
         return _aiLogic.zhao1;
      }
      
      public function zhao2() : Boolean
      {
         return _aiLogic.zhao2;
      }
      
      public function zhao3() : Boolean
      {
         return _aiLogic.zhao3;
      }
      
      public function catch1() : Boolean
      {
         return _aiLogic.catch1;
      }
      
      public function catch2() : Boolean
      {
         return _aiLogic.catch2;
      }
      
      public function bisha() : Boolean
      {
         return _aiLogic.bisha;
      }
      
      public function bishaUP() : Boolean
      {
         return _aiLogic.bishaUP;
      }
      
      public function bishaSUPER() : Boolean
      {
         return _aiLogic.bishaSUPER;
      }
      
      public function assist() : Boolean
      {
         return _aiLogic.assist;
      }
      
      public function specailSkill() : Boolean
      {
         return _aiLogic.specialSkill;
      }
      
      public function attackAIR() : Boolean
      {
         return _aiLogic.attackAIR;
      }
      
      public function skillAIR() : Boolean
      {
         return _aiLogic.skillAIR;
      }
      
      public function bishaAIR() : Boolean
      {
         return _aiLogic.bishaAIR;
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
         return _aiLogic.ghostStep;
      }
      
      public function ghostJump() : Boolean
      {
         return _aiLogic.ghostJump;
      }
      
      public function ghostJumpDown() : Boolean
      {
         return _aiLogic.ghostJumpDowm;
      }
      
      private function clearAICommandState() : void
      {
         if(!_aiLogic)
         {
            return;
         }
         _aiLogic.moveLeft = false;
         _aiLogic.moveRight = false;
         _aiLogic.defense = false;
         _aiLogic.attack = false;
         _aiLogic.jump = false;
         _aiLogic.jumpDown = false;
         _aiLogic.dash = false;
         _aiLogic.downJump = false;
         _aiLogic.skill1 = false;
         _aiLogic.skill2 = false;
         _aiLogic.zhao1 = false;
         _aiLogic.zhao2 = false;
         _aiLogic.zhao3 = false;
         _aiLogic.catch1 = false;
         _aiLogic.catch2 = false;
         _aiLogic.bisha = false;
         _aiLogic.bishaUP = false;
         _aiLogic.bishaSUPER = false;
         _aiLogic.assist = false;
         _aiLogic.specialSkill = false;
         _aiLogic.attackAIR = false;
         _aiLogic.skillAIR = false;
         _aiLogic.bishaAIR = false;
         _aiLogic.ghostStep = false;
         _aiLogic.ghostJump = false;
         _aiLogic.ghostJumpDowm = false;
      }
      
      private function hasAnyAICommand() : Boolean
      {
         return _aiLogic.moveLeft || _aiLogic.moveRight || _aiLogic.defense || _aiLogic.attack || _aiLogic.jump || _aiLogic.jumpDown || _aiLogic.dash || _aiLogic.downJump || _aiLogic.skill1 || _aiLogic.skill2 || _aiLogic.zhao1 || _aiLogic.zhao2 || _aiLogic.zhao3 || _aiLogic.catch1 || _aiLogic.catch2 || _aiLogic.bisha || _aiLogic.bishaUP || _aiLogic.bishaSUPER || _aiLogic.assist || _aiLogic.specialSkill || _aiLogic.attackAIR || _aiLogic.skillAIR || _aiLogic.bishaAIR || _aiLogic.ghostStep || _aiLogic.ghostJump || _aiLogic.ghostJumpDowm;
      }
      
      private function shouldWatchIdleState() : Boolean
      {
         if(fighter == null || !fighter.isAlive || !fighter.getActive())
         {
            return false;
         }
         if(FighterActionState.isHurting(fighter.actionState) || FighterActionState.isHurtFlying(fighter.actionState))
         {
            return false;
         }
         return fighter.actionState == 0 || fighter.actionState == 20;
      }
      
      private function renderIdleWatchdog() : void
      {
         if(!shouldWatchIdleState())
         {
            _idleWatchFrame = 0;
            return;
         }
         if(hasAnyAICommand())
         {
            _idleWatchFrame = 0;
            return;
         }
         _idleWatchFrame++;
         if(_idleWatchFrame < 75 || _idleRecoverCooldownFrame > 0)
         {
            return;
         }
         _idleWatchFrame = 0;
         _idleRecoverCooldownFrame = 45;
         _aiLogic.recoverFromIdleFreeze();
         _aiUpdateFrame = 0;
         forceApproachEnemyTarget();
      }
      
      private function forceApproachEnemyTarget() : void
      {
         var enemyFighter:FighterMain = getCurrentEnemyFighter();
         if(enemyFighter == null || !enemyFighter.isAlive || !enemyFighter.getActive() || fighter == null)
         {
            return;
         }
         if(Math.abs(enemyFighter.x - fighter.x) < 6)
         {
            return;
         }
         _aiLogic.moveLeft = enemyFighter.x < fighter.x;
         _aiLogic.moveRight = enemyFighter.x > fighter.x;
      }
      
      private function getCurrentEnemyFighter() : FighterMain
      {
         if(GameCtrl.I == null || GameCtrl.I.gameRunData == null || fighter == null || fighter.team == null)
         {
            return null;
         }
         if(fighter.team.id == 1)
         {
            return GameCtrl.I.gameRunData.p2FighterGroup.currentFighter;
         }
         if(fighter.team.id == 2)
         {
            return GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
         }
         return null;
      }
   }
}

