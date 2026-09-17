package net.play5d.game.bvn.fighter.ctrler.ai
{
   import net.play5d.game.bvn.ctrl.GameLogic;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.fighter.FighterMC;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class FighterAILogic extends FighterAILogicBase
   {
      
      public var moveLeft:Boolean;
      
      public var moveRight:Boolean;
      
      public var jump:Boolean;
      
      public var jumpDown:Boolean;
      
      public var dash:Boolean;
      
      public var downJump:Boolean;
      
      public var defense:Boolean;
      
      private var _hurtDownMoveType:int = 0;
      
      private var _justStandUp:Boolean = false;
      
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
      
      private var _isFirstAssister:Boolean = true;
      
      private var _skillCooldownFrameByAction:Object = {};
      
      private var _skillPressureFrame:int = 0;
      
      private var _lastGroundSkillActionName:String;

      private var _groundSkillRepeatCount:int = 0;

      private var _groundSkillStaleFrameByAction:Object = {};
      
      private var _rapidSkillChainActionName:String;
      
      private var _rapidSkillChainFrame:int = 0;

      private var _explicitComboChain:Array;

      private var _explicitComboChainIndex:int = -1;

      private var _explicitComboChainFrame:int = 0;
      
      private var _combatStyleContext:Object;

      private var _hiddenComboBishaFrame:int = 0;

      private var _hiddenComboBishaPower:int = 0;

      private var _hiddenComboLastSkillActionName:String;
      
      public function FighterAILogic(aiLevel:int, fighter:FighterMain)
      {
         super(aiLevel,fighter);
      }
      
      override public function destory() : void
      {
         _skillCooldownFrameByAction = null;
         _lastGroundSkillActionName = null;
         _groundSkillRepeatCount = 0;
         _groundSkillStaleFrameByAction = null;
         _skillPressureFrame = 0;
         _rapidSkillChainActionName = null;
         _rapidSkillChainFrame = 0;
         _explicitComboChain = null;
         _explicitComboChainIndex = -1;
         _explicitComboChainFrame = 0;
         _combatStyleContext = null;
         _hiddenComboBishaFrame = 0;
         _hiddenComboBishaPower = 0;
         _hiddenComboLastSkillActionName = null;
         super.destory();
      }
      
      public function resetRoundState() : void
      {
         moveLeft = false;
         moveRight = false;
         jump = false;
         jumpDown = false;
         dash = false;
         downJump = false;
         defense = false;
         attack = false;
         attackAIR = false;
         skillAIR = false;
         bishaAIR = false;
         skill1 = false;
         skill2 = false;
         zhao1 = false;
         zhao2 = false;
         zhao3 = false;
         catch1 = false;
         catch2 = false;
         bisha = false;
         bishaUP = false;
         bishaSUPER = false;
         assist = false;
         specialSkill = false;
         ghostStep = false;
         ghostJump = false;
         ghostJumpDowm = false;
         _hurtDownMoveType = 0;
         _justStandUp = false;
         _moveFrame = 0;
         _defenseFrame = 0;
         _isFirstAssister = true;
         _skillCooldownFrameByAction = {};
         _skillPressureFrame = 0;
         _lastGroundSkillActionName = null;
         _groundSkillRepeatCount = 0;
         _groundSkillStaleFrameByAction = {};
         _rapidSkillChainActionName = null;
         _rapidSkillChainFrame = 0;
         clearExplicitComboChain();
         _combatStyleContext = null;
         _hiddenComboBishaFrame = 0;
         _hiddenComboBishaPower = 0;
         _hiddenComboLastSkillActionName = null;
      }
      
      public function recoverFromIdleFreeze() : void
      {
         _moveFrame = 0;
         _defenseFrame = 0;
         _hurtDownMoveType = 0;
         _justStandUp = false;
         _skillPressureFrame = 0;
         _rapidSkillChainActionName = null;
         _rapidSkillChainFrame = 0;
         clearExplicitComboChain();
         _hiddenComboBishaFrame = 0;
         _hiddenComboBishaPower = 0;
         _hiddenComboLastSkillActionName = null;
         if(_skillCooldownFrameByAction == null)
         {
            _skillCooldownFrameByAction = {};
         }
         else
         {
            for(var actionName:String in _skillCooldownFrameByAction)
            {
               _skillCooldownFrameByAction[actionName] = 0;
            }
         }
      }
      
      override public function render() : void
      {
         super.render();
         if(_fighter == null || _target == null)
         {
            return;
         }
         try
         {
            updateHurtAI();
            updateGhostStep();
         }
         catch(err:Error)
         {
            Debugger.errorMsg("FightAILogic.render :: Render error.");
            if(err.getStackTrace() != null)
            {
               Debugger.log(err.getStackTrace());
            }
            else
            {
               Debugger.log(err.toString());
            }
         }
      }
      
      override protected function updateActionAI() : void
      {
         if(_fighter != null && _target != null && _targetFighter != null)
         {
            updateCombatStyleContext();
            updateSkillCadence();
            updateDashAI();
            updateAttackAI();
            updateSkill();
            updateBisha();
            updateCatch();
            updateAssist();
            updateMoveAI();
            updateJumpAI();
            updateJumpDownAI();
            updateDefenseAI();
            updateSpecialSkill();
            updateCustomAIRules();
         }
      }
      
      private function updateHurtAI() : void
      {
         downJump = false;
         if(_fighter.energy <= 60 || _fighter.energyOverLoad)
         {
            return;
         }
         var hurtRateMap:Object = {};
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            hurtRateMap.defult = [0,0,0.1,0.4,1,1.6];
         }
         else if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            hurtRateMap.defult = [0,0,0.2,1,3,5];
         }
         else if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            hurtRateMap.defult = [0,0.2,0.8,2.2,4.2,6.5];
         }
         else
         {
            hurtRateMap.defult = [0,0.5,1.5,3.8,6.2,8.6];
         }
         hurtRateMap[11] = [0,0,0,0,0,0];
         hurtRateMap[12] = [0,0,0,0,0,0];
         hurtRateMap[13] = [0,0,0,0,0,0];
         setAIByMain(hurtRateMap,"downJump");
         downJump = getAIByFighterState(hurtRateMap);
      }
      
      private function updateMoveAI() : void
      {
         moveLeft = false;
         moveRight = false;
         var targetDistance:Point = getTargetDistance(_target);
         if(FighterActionState.isHurtFlying(_targetFighter.actionState))
         {
            if(!_hurtDownMoveType)
            {
               _hurtDownMoveType = AIMoveLogic.chooseHurtDownMoveType(AILevel,targetDistance.x);
            }
         }
         else
         {
            _hurtDownMoveType = 0;
         }
         var moveDecisionWindow:int = AIMoveLogic.getMoveDecisionWindow(AILevel);
         var shouldMove:Boolean = false;
         if(_moveFrame < moveDecisionWindow)
         {
            _moveFrame++;
            shouldMove = true;
         }
         else
         {
            var moveRateMap:Object = AIMoveLogic.buildMoveRateMap(AILevel);
            applyContextScaleToRateMap(moveRateMap,getCombatScale("moveRateScale",1));
            setAIByMain(moveRateMap,"move");
            shouldMove = getAIByFighterState(moveRateMap);
            if(shouldMove)
            {
               _moveFrame = 0;
            }
         }
         if(shouldMove)
         {
            var targetSpacing:Number = 0;
            if(_hurtDownMoveType == 1)
            {
               if(_target.direct > 0 ? _fighter.x > _target.x - 5 : _fighter.x > _target.x + 10)
               {
                  moveLeft = true;
               }
               else if(_target.direct > 0 ? _fighter.x < _target.x - 20 : _fighter.x < _target.x + 5)
               {
                  moveRight = true;
               }
            }
            else if(_hurtDownMoveType == 2)
            {
               targetSpacing = AIMoveLogic.getHurtDownOrbitDistance(AILevel);
               var orbitTargetX:Number = _fighter.x > _target.x ? _target.x + targetSpacing : _target.x - targetSpacing;
               if(_fighter.x > 20 + orbitTargetX)
               {
                  moveLeft = true;
               }
               else if(_fighter.x < -20 + orbitTargetX)
               {
                  moveRight = true;
               }
            }
            else
            {
               var preferCatchSpacing:Boolean = (catch1 || catch2) && targetDistance.y < 2;
               targetSpacing = AIMoveLogic.getTargetSpacing(AILevel,preferCatchSpacing);
               targetSpacing = getPreferredCombatSpacing(targetSpacing,preferCatchSpacing);
               if(_fighter.x > _target.x + targetSpacing)
               {
                  moveLeft = true;
               }
               else if(_fighter.x < _target.x - targetSpacing)
               {
                  moveRight = true;
               }
            }
         }
         if(!moveLeft && !moveRight)
         {
            _moveFrame = moveDecisionWindow;
         }
         var swapMove:Boolean = false;
         if(_targetFighter && (_targetFighter.isSteelBody && _targetFighter.isSuperSteelBody && !_fighter.isSteelBody))
         {
            swapMove = moveLeft;
            moveLeft = moveRight;
            moveRight = swapMove;
         }
         else if(_fighter.isInAir && _fighterAction.airHitTimes < 1)
         {
            swapMove = moveLeft;
            moveLeft = moveRight;
            moveRight = swapMove;
         }
         applyMapEdgeRepositionMove(targetDistance);
      }
      
      private function updateJumpAI() : void
      {
         if(!_fighterAction.jump)
         {
            jump = false;
            return;
         }
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var targetDistance:Point = getTargetDistance(_target);
         var hasGroundSkillChoices:Boolean = hasGroundSkillAction();
         var closeRangeJumpBlockDistance:Number = getCombatScale("closeRangeJumpBlockDistance",0);
         if(closeRangeJumpBlockDistance > 0 && targetDistance.x <= closeRangeJumpBlockDistance && targetDistance.y <= 105 && normalizedLevel >= AIDifficultyProfile.NORMAL && getCombatMode() != AICombatStyleLogic.MODE_APPROACH)
         {
            jump = false;
            return;
         }
         if(_skillPressureFrame > 0 && hasGroundSkillChoices && targetDistance.x < 220 && targetDistance.y < 90)
         {
            jump = false;
            return;
         }
         var targetHasShortHurt:Boolean = _targetFighter != null && _targetFighter.hurtHit != null && _targetFighter.hurtHit.id != null && _targetFighter.hurtHit.id.indexOf("sh") != -1;
         var targetIsOpen:Boolean = _targetFighter != null && _targetFighter.isAllowBeHit && !_targetFighter.isSteelBody && _targetFighter.actionState != 16;
         var jumpRateMap:Object = AIJumpLogic.buildJumpRateMap(AILevel,_isConting,_fighter,_targetFighter,targetInRange("tkanmian"),targetInRange("tzmian"),targetIsOpen,targetHasShortHurt);
         applyContextScaleToRateMap(jumpRateMap,getCombatScale("jumpRateScale",1));
         if(hasGroundSkillChoices && targetDistance.x < 190 && targetDistance.y < 85)
         {
            applyRateScale(jumpRateMap,"defult",0.55,0);
            applyRateScale(jumpRateMap,21,0.7,0);
         }
         if(getCombatFlag("suppressJump",false) && targetDistance.x < 230 && targetDistance.y < 95)
         {
            applyRateScale(jumpRateMap,"defult",0.5,0);
            applyRateScale(jumpRateMap,21,0.6,0);
         }
         setAIByMain(jumpRateMap,"jump");
         jump = getAIByFighterState(jumpRateMap);
         if(normalizedLevel >= AIDifficultyProfile.HARD && (getCombatMode() == AICombatStyleLogic.MODE_PRESSURE || getCombatMode() == AICombatStyleLogic.MODE_PUNISH || getCombatMode() == AICombatStyleLogic.MODE_FOOTSIES) && targetDistance.x < 245 && targetDistance.y < 105)
         {
            jump = false;
         }
         if(hasGroundSkillChoices && targetDistance.x < 160 && targetDistance.y < 80 && normalizedLevel <= AIDifficultyProfile.NORMAL)
         {
            jump = false;
         }
         if(_isConting && jump)
         {
            if(jumpRateMap["order"])
            {
               addContOrder("jump",110 + jumpRateMap["order"]);
            }
            else
            {
               addContOrder("jump",110);
            }
         }
      }
      
      private function updateJumpDownAI() : void
      {
         var jumpDownRateMap:Object = AIJumpLogic.buildJumpDownRateMap(AILevel,_fighter,_targetFighter);
         setAIByMain(jumpDownRateMap,"jumpDown");
         jumpDown = getAIByFighterState(jumpDownRateMap);
      }
      
      private function updateDashAI() : void
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var combatMode:String = getCombatMode();
         var targetDistance:Point = getTargetDistance(_target);
         var dashDecision:Object = AIDashLogic.buildDashDecision(AILevel,_fighter,_targetFighter,targetDistance.x,targetDistance.y,_justStandUp);
         _justStandUp = _fighter.actionState == 23;
         var dashRateMap:Object = dashDecision.rateMap;
         applyContextScaleToRateMap(dashRateMap,getCombatScale("dashRateScale",1));
         setAIByMain(dashRateMap,"dash");
         dash = getAIByFighterState(dashRateMap);
         var targetFacingDirection:Number = _target.x > _fighter.x ? 1 : -1;
         var emergencyThreat:Boolean = combatMode == AICombatStyleLogic.MODE_DEFENSE && FighterActionState.isAttacking(_targetFighter.actionState) && targetDistance.x <= 130 && targetDistance.y <= 100;
         if(emergencyThreat)
         {
            dash = false;
         }
         else if(!dash && normalizedLevel >= AIDifficultyProfile.HARD && _fighter.direct == targetFacingDirection && targetDistance.y <= 95)
         {
            var shouldForceForwardDash:Boolean = false;
            if(combatMode == AICombatStyleLogic.MODE_APPROACH && targetDistance.x >= 210)
            {
               shouldForceForwardDash = true;
            }
            else if(combatMode == AICombatStyleLogic.MODE_PUNISH && targetDistance.x >= 130 && targetDistance.x <= 280)
            {
               shouldForceForwardDash = true;
            }
            else if(combatMode == AICombatStyleLogic.MODE_PRESSURE && targetDistance.x >= 95 && targetDistance.x <= 210 && _targetFighter.actionState == 21)
            {
               shouldForceForwardDash = true;
            }
            if(shouldForceForwardDash)
            {
               dash = true;
               dashDecision.setOrder = true;
               dashDecision.orderBase = int(Math.max(int(dashDecision.orderBase),165));
            }
         }
         if(shouldAvoidEdgeDash(targetDistance))
         {
            dash = false;
         }
         if(!dash)
         {
            dashDecision.setOrder = false;
         }
         if(dashDecision.setOrder)
         {
            var dashOrder:int = int(dashDecision.orderBase);
            if(dashRateMap["order"])
            {
               dashOrder += dashRateMap["order"];
            }
            if(combatMode == AICombatStyleLogic.MODE_DEFENSE)
            {
               dashOrder += int(getCombatScale("defenseOrderBonus",0));
            }
            else
            {
               dashOrder += int(getCombatScale("attackOrderBonus",0) * 0.5);
            }
            addContOrder("dash",dashOrder);
         }
      }
      
      private function updateDefenseAI() : void
      {
         if(_fighter.energy <= 20 || _fighter.isSteelBody)
         {
            defense = false;
            _defenseFrame = 0;
            return;
         }
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var targetDistance:Point = getTargetDistance(_target);
         var dangerDistance:Number = AIDifficultyProfile.getDangerDistance(AILevel);
         var targetIsAttacking:Boolean = FighterActionState.isAttacking(_targetFighter.actionState);
         var closeThreat:Boolean = targetDistance.x <= dangerDistance && targetDistance.y <= 105;
         var defenseRateMap:Object = AIDefenseLogic.buildDefenseRateMap(AILevel,_fighter,_targetFighter,targetDistance);
         applyContextScaleToRateMap(defenseRateMap,getCombatScale("defenseRateScale",1));
         setAIByMain(defenseRateMap,"defense");
         var shouldDefense:Boolean = getAIByFighterState(defenseRateMap);
         if(!shouldDefense)
         {
            shouldDefense = AIDefenseLogic.shouldForceDefense(AILevel,_targetFighter,targetDistance);
         }
         if(!shouldDefense && _defenseFrame > 0 && targetDistance.x <= dangerDistance)
         {
            shouldDefense = true;
            _defenseFrame--;
         }
         if(!shouldDefense && getCombatMode() == AICombatStyleLogic.MODE_DEFENSE && closeThreat && targetIsAttacking)
         {
            shouldDefense = true;
         }
         else if(!shouldDefense)
         {
            _defenseFrame = 0;
         }
         defense = shouldDefense;
         if(defense)
         {
            _defenseFrame = normalizedLevel >= AIDifficultyProfile.HARD ? 6 : 4;
            var defenseOrderBase:int = 118 + int(getCombatScale("defenseOrderBonus",0));
            if(closeThreat && targetIsAttacking)
            {
               defenseOrderBase = int(Math.max(defenseOrderBase,normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 420 : 320));
               clearOffenseForDefense();
            }
            else if(normalizedLevel >= AIDifficultyProfile.HARD)
            {
               defenseOrderBase = int(Math.max(defenseOrderBase,152));
            }
            doInDefense(defenseRateMap,defenseOrderBase);
            return;
         }
      }
      
      private function doInDefense(defenseRateMap:Object = null, defenseOrderBase:int = 115) : void
      {
         if(defenseRateMap && defenseRateMap["order"])
         {
            addContOrder("defense",defenseOrderBase + defenseRateMap["order"]);
         }
         else
         {
            addContOrder("defense",defenseOrderBase);
         }
         if(_target.x < _fighter.x)
         {
            moveLeft = true;
            moveRight = false;
         }
         else
         {
            moveLeft = false;
            moveRight = true;
         }
      }
      
      private function clearOffenseForDefense() : void
      {
         attack = false;
         attackAIR = false;
         skillAIR = false;
         skill1 = false;
         skill2 = false;
         zhao1 = false;
         zhao2 = false;
         zhao3 = false;
         bisha = false;
         bishaUP = false;
         bishaSUPER = false;
         bishaAIR = false;
         catch1 = false;
         catch2 = false;
         specialSkill = false;
      }
      
      private function updateAttackAI() : void
      {
         attack = false;
         attackAIR = false;
         if(!_fighterAction.attack && !_fighterAction.attackAIR)
         {
            return;
         }
         var attackRateMap:Object = AIAttackLogic.buildAttackRateMap(AILevel,_isConting,_fighter,_targetFighter);
         applyContextScaleToRateMap(attackRateMap,getCombatScale("attackRateScale",1));
         if(_fighterAction.attack)
         {
            setAIByMain(attackRateMap,"attack");
         }
         if(_fighterAction.attackAIR)
         {
            setAIByMain(attackRateMap,"attackAIR");
         }
         var randomDecision:Boolean = getAIByFighterState(attackRateMap);
         var inGroundRange:Boolean = targetInRange("kanmian");
         var inAirRange:Boolean = targetInRange("tkanmian");
         var logicCommit:Boolean = AIAttackLogic.shouldCommitAttack(AILevel,_isConting,inGroundRange,inAirRange,_targetFighter);
         var targetDistance:Point = getTargetDistance(_target);
         var combatMode:String = getCombatMode();
         if(combatMode == AICombatStyleLogic.MODE_DEFENSE && FighterActionState.isAttacking(_targetFighter.actionState) && targetDistance.x <= 130 && targetDistance.y <= 100)
         {
            return;
         }
         if(combatMode == AICombatStyleLogic.MODE_PUNISH && targetDistance.x <= 210 && targetDistance.y <= 100)
         {
            logicCommit = true;
         }
         else if(combatMode == AICombatStyleLogic.MODE_PRESSURE && targetDistance.x <= 170 && targetDistance.y <= 95 && _isConting)
         {
            logicCommit = true;
         }
         if(!randomDecision && !logicCommit)
         {
            return;
         }
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var preferHitConfirmSkill:Boolean = getCombatFlag("preferHitConfirmSkill",false);
         var targetInHurtConfirmWindow:Boolean = _targetFighter != null && (_targetFighter.actionState == 21 || FighterActionState.isHurting(_targetFighter.actionState)) && targetDistance.x <= 185 && targetDistance.y <= 95;
         if(preferHitConfirmSkill && hasGroundSkillAction() && targetInHurtConfirmWindow && normalizedLevel >= AIDifficultyProfile.HARD)
         {
            return;
         }
         var canPredictiveAttack:Boolean = normalizedLevel >= AIDifficultyProfile.HARD;
         attack = _fighterAction.attack && (inGroundRange || canPredictiveAttack && logicCommit && _isConting);
         attackAIR = _fighterAction.attackAIR && (inAirRange || canPredictiveAttack && logicCommit && _isConting && _fighter.y < _target.y);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            attack = attack && inGroundRange;
            attackAIR = attackAIR && inAirRange;
         }
         if(!attack && !attackAIR)
         {
            return;
         }
         var attackOrder:int = 116;
         if(_isConting)
         {
            var currentAction:String = _fighter.getCtrler().getMcCtrl().getCurAction();
            var isNormalComboAction:Boolean = currentAction != null && (currentAction.indexOf("砍") != -1 || currentAction.indexOf("普攻") != -1 || currentAction == "砍1");
            var targetInConfirmState:Boolean = _targetFighter != null && (_targetFighter.actionState == 21 || _targetFighter.actionState == 22 || isTargetInSkillConfirmState());
            if(targetInConfirmState)
            {
               attackOrder = 114;
            }
            else if(isNormalComboAction)
            {
               attackOrder = 185;
            }
            else
            {
               attackOrder = 200;
            }
         }
         if(attackRateMap["order"])
         {
            attackOrder += attackRateMap["order"];
         }
         attackOrder += int(getCombatScale("attackOrderBonus",0));
         if(combatMode == AICombatStyleLogic.MODE_PUNISH && normalizedLevel >= AIDifficultyProfile.HARD)
         {
            attackOrder += 10;
         }
         if(attack)
         {
            addContOrder("attack",attackOrder);
         }
         if(attackAIR)
         {
            addContOrder("attackAIR",attackOrder);
         }
      }
      
      private function updateSkill() : void
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var combatMode:String = getCombatMode();
         var prioritizeDownCommandSkill:Boolean = getCombatFlag("preferDownCommandSkill",false);
         var prioritizeUpperCommandSkill:Boolean = getCombatFlag("preferUpperCommandSkill",false);
         var preferHitConfirmSkill:Boolean = getCombatFlag("preferHitConfirmSkill",false);
         var skillOrderBonus:int = int(getCombatScale("skillOrderBonus",0));
         var pressureModeBonus:int = combatMode == AICombatStyleLogic.MODE_PRESSURE || combatMode == AICombatStyleLogic.MODE_PUNISH ? 10 : 0;
         var antiAirModeBonus:int = combatMode == AICombatStyleLogic.MODE_ANTI_AIR ? 8 : 0;
         var confirmModeBonus:int = 0;
         var targetDistance:Point = getTargetDistance(_target);
         var inConfirmWindow:Boolean = targetDistance != null && targetDistance.x <= 195 && targetDistance.y <= 95 && _targetFighter != null && (_targetFighter.actionState == 21 || FighterActionState.isHurting(_targetFighter.actionState));
         if(preferHitConfirmSkill && inConfirmWindow)
         {
            confirmModeBonus = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 20 : normalizedLevel >= AIDifficultyProfile.HARD ? 14 : 8;
         }
         var skill1BaseOrder:int = (prioritizeDownCommandSkill ? 28 : 24) + skillOrderBonus + pressureModeBonus + confirmModeBonus;
         var zhao2BaseOrder:int = (prioritizeDownCommandSkill ? 24 : 20) + skillOrderBonus + pressureModeBonus + confirmModeBonus;
         var skill2BaseOrder:int = (prioritizeUpperCommandSkill ? 28 : 22) + skillOrderBonus + pressureModeBonus + antiAirModeBonus + confirmModeBonus;
         var zhao3BaseOrder:int = (prioritizeUpperCommandSkill ? 24 : 18) + skillOrderBonus + pressureModeBonus + antiAirModeBonus + confirmModeBonus;
         var zhao1BaseOrder:int = int(Math.round(20 + skillOrderBonus + pressureModeBonus + confirmModeBonus * 0.5));
         var skillAirBaseOrder:int = int(Math.round(12 + skillOrderBonus * 0.4 + antiAirModeBonus));
         skill1 = _fighterAction.skill1 && getSkillAI("skill1","kj1","kj1mian",skill1BaseOrder,true,false,true);
         skill2 = _fighterAction.skill2 && getSkillAI("skill2","kj2","kj2mian",skill2BaseOrder,false,false,true);
         zhao1 = _fighterAction.zhao1 && getSkillAI("zhao1","zh1","zh1mian",zhao1BaseOrder,false,false,true);
         zhao2 = _fighterAction.zhao2 && getSkillAI("zhao2","zh2","zh2mian",zhao2BaseOrder,true,false,true);
         zhao3 = _fighterAction.zhao3 && getSkillAI("zhao3","zh3","zh3mian",zhao3BaseOrder,false,false,true);
         skillAIR = _fighterAction.skillAIR && getSkillAI("skillAIR","tz","tzmian",skillAirBaseOrder,false,true,false);
      }
      
      private function getSkillAI(skillActionName:String, skillHitActionId:String, skillHitRangeName:String, baseOrder:int, isDownCommandSkill:Boolean, isAirCommandSkill:Boolean, allowRapidChain:Boolean) : Boolean
      {
         var targetDistance:Point = getTargetDistance(_target);
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var inRapidSkillChain:Boolean = canContinueRapidSkillChain(skillActionName,targetDistance,allowRapidChain);
         var inExplicitComboChain:Boolean = canContinueExplicitComboChain(skillActionName,targetDistance,allowRapidChain);
         if(getSkillCooldown(skillActionName) > 0 && !inRapidSkillChain && !inExplicitComboChain)
         {
            return false;
         }
         if(shouldLockToExplicitComboAction(skillActionName,allowRapidChain))
         {
            return false;
         }
         var targetHasShortHurt:Boolean = _targetFighter != null && _targetFighter.hurtHit != null && _targetFighter.hurtHit.id != null && _targetFighter.hurtHit.id.indexOf("sh") != -1;
         var skillRateMap:Object = AISkillBishaLogic.buildSkillRateMap(AILevel,_isConting,isBreakAct(skillHitActionId),targetHasShortHurt);
         applySkillContextBias(skillRateMap,skillActionName,isDownCommandSkill,isAirCommandSkill);
         setAIByMain(skillRateMap,skillActionName);
         var bypassVarietyPenalty:Boolean = inRapidSkillChain || inExplicitComboChain;
         applySkillVarietyBias(skillRateMap,skillActionName,isAirCommandSkill,bypassVarietyPenalty);
         var inSkillRange:Boolean = targetInRange(skillHitRangeName);
         var allowPredictiveSkill:Boolean = allowPredictiveSkillRange(skillActionName,targetDistance,isAirCommandSkill);
         var targetInHurtConfirmWindow:Boolean = _targetFighter != null && targetDistance != null && targetDistance.x <= 200 && targetDistance.y <= 100 && (_targetFighter.actionState == 21 || FighterActionState.isHurting(_targetFighter.actionState));
         var targetInSkillConfirmState:Boolean = isTargetInSkillConfirmState();
         var targetInFront:Boolean = isTargetInFrontForSkill();
         var predictiveSkillReady:Boolean = allowPredictiveSkill && targetInSkillConfirmState;
         var shouldUseSkill:Boolean = (inRapidSkillChain || inExplicitComboChain || getAIByFighterState(skillRateMap)) && (inSkillRange || predictiveSkillReady || inRapidSkillChain || inExplicitComboChain) && targetCanBeHit();
         if(!isAirCommandSkill && !targetInFront)
         {
            shouldUseSkill = false;
         }
         if(!shouldUseSkill && getCombatFlag("preferHitConfirmSkill",false) && targetInHurtConfirmWindow && normalizedLevel >= AIDifficultyProfile.HARD)
         {
            shouldUseSkill = (inSkillRange || predictiveSkillReady) && targetCanBeHit();
            if(!isAirCommandSkill && !targetInFront)
            {
               shouldUseSkill = false;
            }
         }
         if(shouldUseSkill)
         {
            if(_isConting || _targetFighter.actionState == 21 || normalizedLevel >= AIDifficultyProfile.HARD)
            {
               var skillOrder:int = baseOrder + AISkillBishaLogic.getSkillOrderBase(AILevel,isHitDownAct(skillHitActionId)) + int(getCombatScale("skillOrderBonus",0));
               if(inRapidSkillChain)
               {
                  skillOrder += normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 55 : normalizedLevel >= AIDifficultyProfile.HARD ? 42 : 25;
               }
               if(inExplicitComboChain)
               {
                  skillOrder += normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 72 : normalizedLevel >= AIDifficultyProfile.HARD ? 56 : 38;
               }
               if(targetInHurtConfirmWindow && getCombatFlag("preferHitConfirmSkill",false))
               {
                  skillOrder += normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 28 : normalizedLevel >= AIDifficultyProfile.HARD ? 18 : 10;
               }
               if(isAirCommandSkill && getCombatMode() == AICombatStyleLogic.MODE_ANTI_AIR)
               {
                  skillOrder += 20;
               }
               if(skillRateMap["order"])
               {
                  skillOrder += skillRateMap["order"];
               }
               skillOrder += getSkillVarietyOrderBonus(skillActionName,isAirCommandSkill,bypassVarietyPenalty);
               addContOrder(skillActionName,skillOrder);
            }
            startSkillCadence(skillActionName,isDownCommandSkill,isAirCommandSkill,allowRapidChain,targetDistance);
         }
         return shouldUseSkill;
      }
      
      public function updateBisha() : void
      {
         bisha = bishaUP = bishaSUPER = bishaAIR = false;
         var normalBishaQi:int = AISkillBishaLogic.getNormalBishaQiRequirement(AILevel);
         bishaSUPER = _fighterAction.bishaSUPER && getBishaAI("bishaSUPER","cbs","cbsmian",300,100);
         bisha = _fighterAction.bisha && getBishaAI("bisha","bs","bsmian",normalBishaQi,115);
         bishaUP = _fighterAction.bishaUP && getBishaAI("bishaUP","sbs","sbsmian",normalBishaQi,115);
         bishaAIR = _fighterAction.bishaAIR && getBishaAI("bishaAIR","kbs","kbsmian",normalBishaQi,115);
      }
      
      private function getBishaAI(bishaActionName:String, bishaHitActionId:String, bishaHitRangeName:String, requiredQi:int, baseOrder:int) : Boolean
      {
         var bishaRateMap:Object = {};
         var shouldUseBisha:Boolean = false;
         var pursueHiddenComboFinisher:Boolean = shouldPursueHiddenComboBisha(bishaActionName,requiredQi);
         var inBishaRange:Boolean = false;
         if(_fighter.qi >= requiredQi)
         {
            var targetHasShortHurt:Boolean = _targetFighter != null && _targetFighter.hurtHit != null && _targetFighter.hurtHit.id != null && _targetFighter.hurtHit.id.indexOf("sh") != -1;
            bishaRateMap = AISkillBishaLogic.buildBishaRateMap(AILevel,_isConting,requiredQi,isBreakAct(bishaHitActionId),targetHasShortHurt);
            setAIByMain(bishaRateMap,bishaActionName);
            if(pursueHiddenComboFinisher)
            {
               applyHiddenComboBishaBias(bishaRateMap,bishaActionName);
            }
            inBishaRange = targetInRange(bishaHitRangeName);
            shouldUseBisha = getAIByFighterState(bishaRateMap) && (inBishaRange || (pursueHiddenComboFinisher && allowPredictiveHiddenComboBishaRange(bishaActionName))) && targetCanBeHit();
            if(shouldUseBisha && _targetFighter)
            {
               shouldUseBisha = AISkillBishaLogic.shouldConfirmBisha(AILevel,_targetFighter) || (pursueHiddenComboFinisher && isTargetInSkillConfirmState());
            }
         }
         if(shouldUseBisha)
         {
            if(_isConting || _targetFighter.actionState == 21 || AIDifficultyProfile.normalizeLevel(AILevel) >= AIDifficultyProfile.HARD)
            {
               var bishaOrder:int = baseOrder;
               if(AIDifficultyProfile.normalizeLevel(AILevel) >= AIDifficultyProfile.VERY_HARD)
               {
                  bishaOrder -= 15;
               }
               else if(AIDifficultyProfile.normalizeLevel(AILevel) >= AIDifficultyProfile.HARD)
               {
                  bishaOrder -= 5;
               }
               if(bishaRateMap["order"])
               {
                  bishaOrder += bishaRateMap["order"];
               }
               if(pursueHiddenComboFinisher)
               {
                  bishaOrder += getHiddenComboBishaOrderBonus(bishaActionName,inBishaRange);
               }
               addContOrder(bishaActionName,bishaOrder);
            }
            if(pursueHiddenComboFinisher)
            {
               consumeHiddenComboBishaWindow();
            }
         }
         return shouldUseBisha;
      }
      
      private function updateCatch() : void
      {
         if(_target == null || _targetFighter == null)
         {
            return;
         }
         catch1 = false;
         catch2 = false;
         if(!getCombatFlag("allowCatch",true))
         {
            return;
         }
         if(FighterActionState.isHurting(_targetFighter.actionState) || _targetFighter.isSuperSteelBody || !_targetFighter.isAllowBeHit)
         {
            return;
         }
         var targetDistance:Point = getTargetDistance(_target);
         var catchRateMaps:Object = AITacticalSupportLogic.buildCatchRateMaps(AILevel,_justStandUp,targetDistance.x);
         var catch1RateMap:Object = catchRateMaps["catch1"];
         var catch2RateMap:Object = catchRateMaps["catch2"];
         setAIByMain(catch1RateMap,"catch1");
         setAIByMain(catch2RateMap,"catch2");
         catch1 = targetCanBeHit() && getAIByFighterState(catch1RateMap);
         catch2 = targetCanBeHit() && getAIByFighterState(catch2RateMap) && !catch1;
      }
      
      private function updateSpecialSkill() : void
      {
         specialSkill = false;
         if(defense)
         {
            return;
         }
         if(_target == null || _targetFighter == null)
         {
            return;
         }
         if(!FighterActionState.isAttacking(_targetFighter.actionState))
         {
            return;
         }
         var targetHits:* = _targetFighter.getCurrentHits();
         if(targetHits == null || targetHits.length == 0)
         {
            return;
         }
         if(_targetFighter.actionState == 16)
         {
            return;
         }
         var specialSkillRateMap:Object = AITacticalSupportLogic.buildSpecialSkillRateMap(AILevel);
         applyContextScaleToRateMap(specialSkillRateMap,getCombatScale("skillRateScale",1));
         setAIByMain(specialSkillRateMap,"specialSkill");
         specialSkill = getAIByFighterState(specialSkillRateMap);
      }
      
      private function updateAssist() : void
      {
         assist = false;
         if(!_isFirstAssister)
         {
            var fighterMc:FighterMC = _fighter.getMC();
            var assistHitRange:Rectangle = fighterMc.getHitRange("assistmian");
            if(assistHitRange != null && !assistHitRange.isEmpty())
            {
               if(!targetInRange("assistmian"))
               {
                  return;
               }
            }
         }
         if(_fighter.actionState != 0 && _fighter.actionState != 20)
         {
            return;
         }
         if(FighterActionState.isHurtFlying(_targetFighter.actionState))
         {
            return;
         }
         if((_target.x - _fighter.x) * _fighter.direct <= 0)
         {
            return;
         }
         var targetDistanceX:Number = getTargetDistance(_target).x;
         var assistRateMap:Object = AITacticalSupportLogic.buildAssistRateMap(AILevel,targetDistanceX);
         setAIByMain(assistRateMap,"assist");
         assist = getAIByFighterState(assistRateMap);
         if(_isFirstAssister && assist)
         {
            _isFirstAssister = false;
         }
      }
      
      private function updateSkillCadence() : void
      {
         updateGroundSkillVarietyMemory();
         updateHiddenComboBishaWindow();
         if(_skillPressureFrame > 0)
         {
            _skillPressureFrame--;
         }
         if(_rapidSkillChainFrame > 0)
         {
            _rapidSkillChainFrame--;
            if(_rapidSkillChainFrame <= 0)
            {
               _rapidSkillChainActionName = null;
            }
         }
         if(_explicitComboChainFrame > 0)
         {
            _explicitComboChainFrame--;
            if(_explicitComboChainFrame <= 0)
            {
               clearExplicitComboChain();
            }
         }
         if(_skillCooldownFrameByAction == null)
         {
            return;
         }
         for(var skillActionName:String in _skillCooldownFrameByAction)
         {
            var remainFrame:int = int(_skillCooldownFrameByAction[skillActionName]);
            if(remainFrame > 0)
            {
               _skillCooldownFrameByAction[skillActionName] = remainFrame - 1;
            }
         }
      }
      
      private function hasGroundSkillAction() : Boolean
      {
         if(_fighterAction == null)
         {
            return false;
         }
         return _fighterAction.skill1 || _fighterAction.skill2 || _fighterAction.zhao1 || _fighterAction.zhao2 || _fighterAction.zhao3;
      }
      
      private function getSkillCooldown(skillActionName:String) : int
      {
         if(_skillCooldownFrameByAction == null || _skillCooldownFrameByAction[skillActionName] == undefined)
         {
            return 0;
         }
         return int(_skillCooldownFrameByAction[skillActionName]);
      }
      
      private function startSkillCadence(skillActionName:String, isDownCommandSkill:Boolean, isAirCommandSkill:Boolean, allowRapidChain:Boolean, targetDistance:Point) : void
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var combatMode:String = getCombatMode();
         var cooldownFrame:int = 0;
         var expectedExplicitAction:String = null;
         if(_explicitComboChain != null && _explicitComboChainFrame > 0)
         {
            expectedExplicitAction = getExpectedExplicitComboAction();
            if(expectedExplicitAction != null && expectedExplicitAction == skillActionName)
            {
               _explicitComboChainIndex++;
               _explicitComboChainFrame += 4;
               if(_explicitComboChainFrame > 24)
               {
                  _explicitComboChainFrame = 24;
               }
               if(_explicitComboChainIndex >= _explicitComboChain.length - 1)
               {
                  clearExplicitComboChain();
               }
            }
         }
         switch(normalizedLevel)
         {
            case AIDifficultyProfile.EASY:
               cooldownFrame = 24;
               break;
            case AIDifficultyProfile.NORMAL:
               cooldownFrame = 18;
               break;
            case AIDifficultyProfile.HARD:
               cooldownFrame = 12;
               break;
            default:
               cooldownFrame = 8;
         }
         if(isDownCommandSkill)
         {
            cooldownFrame -= 4;
         }
         if(isAirCommandSkill)
         {
            cooldownFrame += 3;
         }
         if(_lastGroundSkillActionName == skillActionName)
         {
            cooldownFrame += 4 + int(Math.min(4,_groundSkillRepeatCount)) * 2;
         }
         cooldownFrame = int(Math.round(cooldownFrame * getCombatScale("skillCadenceScale",1)));
         if(normalizedLevel >= AIDifficultyProfile.HARD && (combatMode == AICombatStyleLogic.MODE_PRESSURE || combatMode == AICombatStyleLogic.MODE_PUNISH))
         {
            cooldownFrame -= 2;
         }
         if(getCombatFlag("preferHitConfirmSkill",false) && _targetFighter && (_targetFighter.actionState == 21 || FighterActionState.isHurting(_targetFighter.actionState)))
         {
            cooldownFrame -= 1;
         }
         if(cooldownFrame < 3)
         {
            cooldownFrame = 3;
         }
         var rapidChainDistanceX:Number = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 205 : normalizedLevel >= AIDifficultyProfile.HARD ? 185 : 170;
         var rapidChainDistanceY:Number = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 105 : normalizedLevel >= AIDifficultyProfile.HARD ? 95 : 90;
         var rapidChainAllowedByMode:Boolean = combatMode == AICombatStyleLogic.MODE_PRESSURE || combatMode == AICombatStyleLogic.MODE_PUNISH || getCombatFlag("preferUpperCommandSkill",false) || getCombatFlag("preferDownCommandSkill",false);
         var canUseRapidChain:Boolean = allowRapidChain && allowRapidChainForAction(skillActionName,isDownCommandSkill,isAirCommandSkill) && targetDistance != null && targetDistance.x <= rapidChainDistanceX && targetDistance.y <= rapidChainDistanceY && normalizedLevel >= AIDifficultyProfile.NORMAL && rapidChainAllowedByMode;
         var useExplicitComboChain:Boolean = false;
         if(canUseRapidChain && (_explicitComboChain == null || _explicitComboChainFrame <= 0) && shouldStartExplicitComboChain(skillActionName,targetDistance,isDownCommandSkill,isAirCommandSkill,normalizedLevel,combatMode))
         {
            useExplicitComboChain = startExplicitComboChain(skillActionName,targetDistance,isDownCommandSkill,isAirCommandSkill,normalizedLevel,combatMode);
         }
         if(useExplicitComboChain)
         {
            cooldownFrame = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 3 : 4;
            _rapidSkillChainActionName = null;
            _rapidSkillChainFrame = 0;
         }
         else if(canUseRapidChain)
         {
            cooldownFrame = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 3 : normalizedLevel >= AIDifficultyProfile.HARD ? 4 : 5;
            _rapidSkillChainActionName = skillActionName;
            _rapidSkillChainFrame = (normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 12 : normalizedLevel >= AIDifficultyProfile.HARD ? 9 : 6) + int(getCombatScale("rapidChainBonusFrame",0));
            if(_rapidSkillChainFrame < 3)
            {
               _rapidSkillChainFrame = 3;
            }
         }
         else if(_rapidSkillChainActionName == skillActionName)
         {
            _rapidSkillChainActionName = null;
            _rapidSkillChainFrame = 0;
         }
         _skillCooldownFrameByAction[skillActionName] = cooldownFrame;
         if(_skillCooldownFrameByAction[skillActionName] < 5)
         {
            _skillCooldownFrameByAction[skillActionName] = 5;
         }
         registerGroundSkillUsage(skillActionName,isAirCommandSkill);
         triggerHiddenComboBishaWindow(skillActionName,isAirCommandSkill,targetDistance,normalizedLevel,combatMode,useExplicitComboChain,canUseRapidChain);
         if(normalizedLevel >= AIDifficultyProfile.HARD)
         {
            _skillPressureFrame = combatMode == AICombatStyleLogic.MODE_PRESSURE || combatMode == AICombatStyleLogic.MODE_PUNISH ? 18 : 14;
         }
         else if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            _skillPressureFrame = combatMode == AICombatStyleLogic.MODE_PRESSURE ? 12 : 10;
         }
         else
         {
            _skillPressureFrame = 6;
         }
      }
      
      private function canContinueRapidSkillChain(skillActionName:String, targetDistance:Point, allowRapidChain:Boolean) : Boolean
      {
         if(!allowRapidChain || targetDistance == null || _rapidSkillChainFrame <= 0)
         {
            return false;
         }
         if(_rapidSkillChainActionName != skillActionName)
         {
            return false;
         }
         if(!isTargetInSkillConfirmState())
         {
            return false;
         }
         if(!isTargetInFrontForSkill())
         {
            return false;
         }
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var maxChainDistanceX:Number = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 205 : normalizedLevel >= AIDifficultyProfile.HARD ? 185 : 165;
         var maxChainDistanceY:Number = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 105 : normalizedLevel >= AIDifficultyProfile.HARD ? 95 : 90;
         return targetDistance.x <= maxChainDistanceX && targetDistance.y <= maxChainDistanceY && targetCanBeHit();
      }

      private function canContinueExplicitComboChain(skillActionName:String, targetDistance:Point, allowRapidChain:Boolean) : Boolean
      {
         if(!allowRapidChain || targetDistance == null || _explicitComboChain == null || _explicitComboChainFrame <= 0)
         {
            return false;
         }
         var expectedActionName:String = getExpectedExplicitComboAction();
         if(expectedActionName == null || expectedActionName != skillActionName)
         {
            return false;
         }
         if(!isTargetInSkillConfirmState())
         {
            clearExplicitComboChain();
            return false;
         }
         if(!isTargetInFrontForSkill())
         {
            clearExplicitComboChain();
            return false;
         }
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var maxChainDistanceX:Number = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 212 : normalizedLevel >= AIDifficultyProfile.HARD ? 195 : 178;
         var maxChainDistanceY:Number = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 112 : normalizedLevel >= AIDifficultyProfile.HARD ? 100 : 92;
         if(targetDistance.x > maxChainDistanceX || targetDistance.y > maxChainDistanceY)
         {
            clearExplicitComboChain();
            return false;
         }
         return targetCanBeHit();
      }

      private function shouldLockToExplicitComboAction(skillActionName:String, allowRapidChain:Boolean) : Boolean
      {
         if(!allowRapidChain || _explicitComboChain == null || _explicitComboChainFrame <= 0)
         {
            return false;
         }
         var expectedActionName:String = getExpectedExplicitComboAction();
         if(expectedActionName == null)
         {
            return false;
         }
         return expectedActionName != skillActionName;
      }

      private function getExpectedExplicitComboAction() : String
      {
         if(_explicitComboChain == null || _explicitComboChain.length < 2 || _explicitComboChainIndex < 0)
         {
            return null;
         }
         var expectedIndex:int = _explicitComboChainIndex + 1;
         if(expectedIndex >= _explicitComboChain.length)
         {
            return null;
         }
         return String(_explicitComboChain[expectedIndex]);
      }

      private function shouldStartExplicitComboChain(skillActionName:String, targetDistance:Point, isDownCommandSkill:Boolean, isAirCommandSkill:Boolean, normalizedLevel:int, combatMode:String) : Boolean
      {
         if(isAirCommandSkill || targetDistance == null || normalizedLevel < AIDifficultyProfile.NORMAL)
         {
            return false;
         }
         if(!(combatMode == AICombatStyleLogic.MODE_PRESSURE || combatMode == AICombatStyleLogic.MODE_PUNISH || getCombatFlag("preferHitConfirmSkill",false)))
         {
            return false;
         }
         if(targetDistance.x > 210 || targetDistance.y > 105)
         {
            return false;
         }
         if(isDownCommandSkill)
         {
            return true;
         }
         return skillActionName == "skill1" || skillActionName == "zhao1" || skillActionName == "zhao2" || normalizedLevel >= AIDifficultyProfile.HARD;
      }

      private function isTargetInSkillConfirmState() : Boolean
      {
         if(_targetFighter == null)
         {
            return false;
         }
         return _targetFighter.actionState == 21 || FighterActionState.isHurting(_targetFighter.actionState) || _targetFighter.hurtBreakHit();
      }

      private function isTargetInFrontForSkill() : Boolean
      {
         if(_target == null || _fighter == null)
         {
            return false;
         }
         return (_target.x - _fighter.x) * _fighter.direct >= -10;
      }

      private function startExplicitComboChain(skillActionName:String, targetDistance:Point, isDownCommandSkill:Boolean, isAirCommandSkill:Boolean, normalizedLevel:int, combatMode:String) : Boolean
      {
         var comboActions:Array = buildExplicitComboChain(skillActionName,isDownCommandSkill,isAirCommandSkill,normalizedLevel,combatMode);
         if(comboActions == null || comboActions.length < 2)
         {
            clearExplicitComboChain();
            return false;
         }
         _explicitComboChain = comboActions;
         _explicitComboChainIndex = 0;
         _explicitComboChainFrame = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 18 : normalizedLevel >= AIDifficultyProfile.HARD ? 14 : 10;
         _explicitComboChainFrame += int(getCombatScale("rapidChainBonusFrame",0));
         if(_explicitComboChainFrame < 6)
         {
            _explicitComboChainFrame = 6;
         }
         return true;
      }

      private function buildExplicitComboChain(skillActionName:String, isDownCommandSkill:Boolean, isAirCommandSkill:Boolean, normalizedLevel:int, combatMode:String) : Array
      {
         var comboActions:Array = [];
         var fallbackActions:Array = ["skill1","zhao1","zhao2","skill2","zhao3"];
         var preferredActions:Array = [];
         if(isAirCommandSkill)
         {
            return comboActions;
         }
         appendComboAction(comboActions,skillActionName);
         if(combatMode == AICombatStyleLogic.MODE_ANTI_AIR || getCombatFlag("preferUpperCommandSkill",false))
         {
            preferredActions = ["skill2","zhao3","zhao1","skill1","zhao2"];
         }
         else if(isDownCommandSkill || getCombatFlag("preferDownCommandSkill",false))
         {
            preferredActions = ["zhao2","skill1","zhao1","skill2","zhao3"];
         }
         else if(getCombatFlag("preferHitConfirmSkill",false))
         {
            preferredActions = ["zhao1","skill1","zhao2","skill2","zhao3"];
         }
         else
         {
            preferredActions = ["skill1","zhao1","zhao2","skill2","zhao3"];
         }
         preferredActions = sortSkillActionsByVariety(preferredActions);
         for each(var actionName:String in preferredActions)
         {
            appendComboAction(comboActions,actionName);
         }
         fallbackActions = sortSkillActionsByVariety(fallbackActions);
         for each(actionName in fallbackActions)
         {
            appendComboAction(comboActions,actionName);
         }
         var maxChainCount:int = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 4 : normalizedLevel >= AIDifficultyProfile.HARD ? 3 : 2;
         var filteredActions:Array = [];
         appendComboAction(filteredActions,skillActionName);
         for each(actionName in comboActions)
         {
            if(actionName == skillActionName || !isSkillActionAvailable(actionName))
            {
               continue;
            }
            filteredActions.push(actionName);
            if(filteredActions.length >= maxChainCount)
            {
               break;
            }
         }
         return filteredActions;
      }

      private function appendComboAction(actionList:Array, actionName:String) : void
      {
         if(actionName == null || actionName.length < 1 || actionList == null)
         {
            return;
         }
         if(actionList.indexOf(actionName) == -1)
         {
            actionList.push(actionName);
         }
      }

      private function isSkillActionAvailable(actionName:String) : Boolean
      {
         if(_fighterAction == null)
         {
            return false;
         }
         switch(actionName)
         {
            case "skill1":
               return _fighterAction.skill1 != null && _fighterAction.skill1.length > 0;
            case "skill2":
               return _fighterAction.skill2 != null && _fighterAction.skill2.length > 0;
            case "zhao1":
               return _fighterAction.zhao1 != null && _fighterAction.zhao1.length > 0;
            case "zhao2":
               return _fighterAction.zhao2 != null && _fighterAction.zhao2.length > 0;
            case "zhao3":
               return _fighterAction.zhao3 != null && _fighterAction.zhao3.length > 0;
            default:
               return false;
         }
      }

      private function clearExplicitComboChain() : void
      {
         _explicitComboChain = null;
         _explicitComboChainIndex = -1;
         _explicitComboChainFrame = 0;
      }

      private function updateHiddenComboBishaWindow() : void
      {
         if(_hiddenComboBishaFrame <= 0)
         {
            return;
         }
         _hiddenComboBishaFrame--;
         if(_hiddenComboBishaFrame <= 0)
         {
            _hiddenComboBishaFrame = 0;
            _hiddenComboBishaPower = 0;
            _hiddenComboLastSkillActionName = null;
            return;
         }
         if(_hiddenComboBishaPower > 1 && _hiddenComboBishaFrame % 8 == 0)
         {
            _hiddenComboBishaPower--;
         }
      }

      private function triggerHiddenComboBishaWindow(skillActionName:String, isAirCommandSkill:Boolean, targetDistance:Point, normalizedLevel:int, combatMode:String, useExplicitComboChain:Boolean, canUseRapidChain:Boolean) : void
      {
         if(isAirCommandSkill || targetDistance == null || skillActionName == null || skillActionName.length < 1)
         {
            return;
         }
         var targetInConfirmState:Boolean = isTargetInSkillConfirmState();
         var shouldPrimeHiddenCombo:Boolean = targetInConfirmState || useExplicitComboChain || canUseRapidChain || combatMode == AICombatStyleLogic.MODE_PRESSURE || combatMode == AICombatStyleLogic.MODE_PUNISH;
         if(!shouldPrimeHiddenCombo)
         {
            return;
         }
         var maxDistanceX:Number = targetInConfirmState ? 240 : 205;
         var maxDistanceY:Number = targetInConfirmState ? 115 : 100;
         if(targetDistance.x > maxDistanceX || targetDistance.y > maxDistanceY)
         {
            return;
         }
         var frameWindow:int = normalizedLevel >= AIDifficultyProfile.VERY_HARD ? 30 : normalizedLevel >= AIDifficultyProfile.HARD ? 24 : normalizedLevel >= AIDifficultyProfile.NORMAL ? 20 : 16;
         if(combatMode == AICombatStyleLogic.MODE_PRESSURE || combatMode == AICombatStyleLogic.MODE_PUNISH)
         {
            frameWindow += 5;
         }
         var comboPower:int = useExplicitComboChain ? 4 : canUseRapidChain || targetInConfirmState ? 3 : 2;
         if(getCombatFlag("preferHitConfirmSkill",false) && targetInConfirmState)
         {
            comboPower++;
         }
         if(comboPower > 5)
         {
            comboPower = 5;
         }
         if(_hiddenComboBishaFrame < frameWindow)
         {
            _hiddenComboBishaFrame = frameWindow;
         }
         if(_hiddenComboBishaPower < comboPower)
         {
            _hiddenComboBishaPower = comboPower;
         }
         _hiddenComboLastSkillActionName = skillActionName;
      }

      private function shouldPursueHiddenComboBisha(bishaActionName:String, requiredQi:int) : Boolean
      {
         if(_hiddenComboBishaFrame <= 0 || _hiddenComboBishaPower <= 0 || _fighter == null || _target == null)
         {
            return false;
         }
         if(_fighter.qi < requiredQi)
         {
            return false;
         }
         var targetDistance:Point = getTargetDistance(_target);
         var maxDistanceX:Number = 218 + _hiddenComboBishaPower * 8;
         var maxDistanceY:Number = 98 + _hiddenComboBishaPower * 5;
         if(bishaActionName == "bishaSUPER")
         {
            maxDistanceX += 25;
            maxDistanceY += 8;
         }
         else if(bishaActionName == "bishaAIR")
         {
            maxDistanceY += 28;
         }
         if(targetDistance.x > maxDistanceX || targetDistance.y > maxDistanceY)
         {
            return false;
         }
         return _isConting || isTargetInSkillConfirmState();
      }

      private function allowPredictiveHiddenComboBishaRange(bishaActionName:String) : Boolean
      {
         if(_target == null)
         {
            return false;
         }
         var targetDistance:Point = getTargetDistance(_target);
         var allowDistanceX:Number = bishaActionName == "bishaSUPER" ? 220 : 188;
         var allowDistanceY:Number = bishaActionName == "bishaAIR" ? 150 : 96;
         if(_hiddenComboBishaPower >= 4)
         {
            allowDistanceX += 18;
            allowDistanceY += 12;
         }
         if(targetDistance.x > allowDistanceX || targetDistance.y > allowDistanceY)
         {
            return false;
         }
         return isTargetInFrontForSkill();
      }

      private function applyHiddenComboBishaBias(bishaRateMap:Object, bishaActionName:String) : void
      {
         if(bishaRateMap == null)
         {
            return;
         }
         var scaleBoost:Number = 1.14 + _hiddenComboBishaPower * 0.06;
         var offsetBoost:Number = 0.2 + _hiddenComboBishaPower * 0.07;
         if(bishaActionName == "bishaSUPER")
         {
            scaleBoost += 0.08;
            offsetBoost += 0.1;
         }
         applyRateScale(bishaRateMap,"defult",scaleBoost,offsetBoost);
         applyRateScale(bishaRateMap,20,scaleBoost * 0.95,offsetBoost * 0.9);
         applyRateScale(bishaRateMap,21,scaleBoost * 0.98,offsetBoost);
      }

      private function getHiddenComboBishaOrderBonus(bishaActionName:String, inBishaRange:Boolean) : int
      {
         var orderBonus:int = 34 + _hiddenComboBishaPower * 8;
         if(_hiddenComboLastSkillActionName == "skill2" || _hiddenComboLastSkillActionName == "zhao3")
         {
            orderBonus += 6;
         }
         if(bishaActionName == "bishaSUPER")
         {
            orderBonus += 12;
         }
         else if(bishaActionName == "bishaUP" || bishaActionName == "bishaAIR")
         {
            orderBonus += 5;
         }
         if(!inBishaRange)
         {
            orderBonus -= 10;
         }
         return orderBonus;
      }

      private function consumeHiddenComboBishaWindow() : void
      {
         _hiddenComboBishaFrame = 0;
         _hiddenComboBishaPower = 0;
         _hiddenComboLastSkillActionName = null;
      }

      private function ensureGroundSkillVarietyEntries() : void
      {
         if(_groundSkillStaleFrameByAction == null)
         {
            _groundSkillStaleFrameByAction = {};
         }
         for each(var actionName:String in getGroundSkillActionNames())
         {
            if(_groundSkillStaleFrameByAction[actionName] == undefined)
            {
               _groundSkillStaleFrameByAction[actionName] = 90;
            }
         }
      }

      private function updateGroundSkillVarietyMemory() : void
      {
         ensureGroundSkillVarietyEntries();
         for each(var actionName:String in getGroundSkillActionNames())
         {
            var staleFrame:int = int(_groundSkillStaleFrameByAction[actionName]);
            if(staleFrame < 360)
            {
               _groundSkillStaleFrameByAction[actionName] = staleFrame + 1;
            }
         }
      }

      private function registerGroundSkillUsage(skillActionName:String, isAirCommandSkill:Boolean) : void
      {
         if(isAirCommandSkill || skillActionName == null || skillActionName.length < 1)
         {
            return;
         }
         ensureGroundSkillVarietyEntries();
         if(_lastGroundSkillActionName == skillActionName)
         {
            _groundSkillRepeatCount++;
         }
         else
         {
            _groundSkillRepeatCount = 1;
         }
         _lastGroundSkillActionName = skillActionName;
         _groundSkillStaleFrameByAction[skillActionName] = 0;
      }

      private function getGroundSkillActionNames() : Array
      {
         return ["skill1","skill2","zhao1","zhao2","zhao3"];
      }

      private function getGroundSkillStaleFrame(skillActionName:String) : int
      {
         if(skillActionName == null || _groundSkillStaleFrameByAction == null || _groundSkillStaleFrameByAction[skillActionName] == undefined)
         {
            return 0;
         }
         return int(_groundSkillStaleFrameByAction[skillActionName]);
      }

      private function applySkillVarietyBias(skillRateMap:Object, skillActionName:String, isAirCommandSkill:Boolean, bypassVarietyPenalty:Boolean) : void
      {
         if(skillRateMap == null || isAirCommandSkill || skillActionName == null)
         {
            return;
         }
         var repeatPenalty:Number = getGroundSkillRepeatRatePenalty(skillActionName,bypassVarietyPenalty);
         if(repeatPenalty < 1)
         {
            applyRateScale(skillRateMap,"defult",repeatPenalty,0);
            applyRateScale(skillRateMap,20,repeatPenalty,0);
            applyRateScale(skillRateMap,21,repeatPenalty,0);
         }
         var staleFrame:int = getGroundSkillStaleFrame(skillActionName);
         if(staleFrame >= 200)
         {
            applyRateScale(skillRateMap,"defult",1.18,0.22);
            applyRateScale(skillRateMap,20,1.14,0.15);
            applyRateScale(skillRateMap,21,1.1,0.12);
         }
         else if(staleFrame >= 140)
         {
            applyRateScale(skillRateMap,"defult",1.12,0.14);
            applyRateScale(skillRateMap,20,1.09,0.1);
            applyRateScale(skillRateMap,21,1.07,0.08);
         }
         else if(staleFrame >= 90)
         {
            applyRateScale(skillRateMap,"defult",1.07,0.08);
            applyRateScale(skillRateMap,20,1.05,0.05);
            applyRateScale(skillRateMap,21,1.04,0.04);
         }
      }

      private function getGroundSkillRepeatRatePenalty(skillActionName:String, bypassVarietyPenalty:Boolean) : Number
      {
         if(bypassVarietyPenalty || _lastGroundSkillActionName != skillActionName || _groundSkillRepeatCount <= 1)
         {
            return 1;
         }
         var penalty:Number = 1;
         if(_groundSkillRepeatCount == 2)
         {
            penalty = 0.86;
         }
         else if(_groundSkillRepeatCount == 3)
         {
            penalty = 0.72;
         }
         else
         {
            penalty = 0.58;
         }
         if(AIDifficultyProfile.normalizeLevel(AILevel) <= AIDifficultyProfile.NORMAL)
         {
            penalty += 0.08;
         }
         if(getCombatFlag("preferUpperCommandSkill",false) && (skillActionName == "skill2" || skillActionName == "zhao3"))
         {
            penalty -= 0.06;
         }
         if(penalty < 0.35)
         {
            penalty = 0.35;
         }
         else if(penalty > 1)
         {
            penalty = 1;
         }
         return penalty;
      }

      private function getSkillVarietyOrderBonus(skillActionName:String, isAirCommandSkill:Boolean, bypassVarietyPenalty:Boolean) : int
      {
         if(isAirCommandSkill || skillActionName == null)
         {
            return 0;
         }
         var orderAdjust:int = 0;
         if(!bypassVarietyPenalty && _lastGroundSkillActionName == skillActionName && _groundSkillRepeatCount > 1)
         {
            if(_groundSkillRepeatCount == 2)
            {
               orderAdjust -= 8;
            }
            else if(_groundSkillRepeatCount == 3)
            {
               orderAdjust -= 14;
            }
            else
            {
               orderAdjust -= 22;
            }
            if(AIDifficultyProfile.normalizeLevel(AILevel) >= AIDifficultyProfile.HARD)
            {
               orderAdjust -= 4;
            }
         }
         var staleFrame:int = getGroundSkillStaleFrame(skillActionName);
         if(staleFrame >= 200)
         {
            orderAdjust += 12;
         }
         else if(staleFrame >= 140)
         {
            orderAdjust += 8;
         }
         else if(staleFrame >= 90)
         {
            orderAdjust += 4;
         }
         return orderAdjust;
      }

      private function sortSkillActionsByVariety(actionList:Array) : Array
      {
         if(actionList == null || actionList.length < 2)
         {
            return actionList;
         }
         var sortedActions:Array = actionList.concat();
         sortedActions.sort(function(actionA:String, actionB:String):Number
         {
            var scoreA:Number = getSkillVarietyPriorityScore(actionA);
            var scoreB:Number = getSkillVarietyPriorityScore(actionB);
            if(scoreA > scoreB)
            {
               return -1;
            }
            if(scoreA < scoreB)
            {
               return 1;
            }
            return 0;
         });
         return sortedActions;
      }

      private function getSkillVarietyPriorityScore(skillActionName:String) : Number
      {
         var score:Number = getGroundSkillStaleFrame(skillActionName);
         if(_lastGroundSkillActionName == skillActionName)
         {
            score -= 90 + _groundSkillRepeatCount * 18;
         }
         if(getCombatFlag("preferUpperCommandSkill",false) && (skillActionName == "skill2" || skillActionName == "zhao3"))
         {
            score += 8;
         }
         if(getCombatFlag("preferDownCommandSkill",false) && (skillActionName == "skill1" || skillActionName == "zhao2"))
         {
            score += 6;
         }
         return score;
      }

      private function applyMapEdgeRepositionMove(targetDistance:Point) : void
      {
         if(_fighter == null || _target == null)
         {
            return;
         }
         var edgeDistance:Number = GameLogic.getMapSideDistanceX(_fighter,10);
         if(edgeDistance == Number.MAX_VALUE)
         {
            return;
         }
         var targetEdgeDistance:Number = GameLogic.getMapSideDistanceX(_target,10);
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var nearEdgeDistance:Number = normalizedLevel >= AIDifficultyProfile.HARD ? 180 : normalizedLevel == AIDifficultyProfile.NORMAL ? 165 : 150;
         var forceBackCenterDistance:Number = normalizedLevel >= AIDifficultyProfile.HARD ? 120 : 108;
         var avoidEdgeFightDistance:Number = normalizedLevel >= AIDifficultyProfile.HARD ? 220 : 195;
         var shouldEscapeEdge:Boolean = _fighter.getIsTouchSide() || edgeDistance <= forceBackCenterDistance;
         var shouldReduceEdgeFight:Boolean = !shouldEscapeEdge && targetDistance != null && targetDistance.x <= avoidEdgeFightDistance && targetDistance.y <= 110 && (edgeDistance <= nearEdgeDistance || targetEdgeDistance <= nearEdgeDistance);
         if(!shouldEscapeEdge && !shouldReduceEdgeFight)
         {
            return;
         }
         var centerX:Number = GameLogic.getMapCenterX();
         if(_fighter.x < centerX)
         {
            moveLeft = false;
            moveRight = true;
         }
         else
         {
            moveLeft = true;
            moveRight = false;
         }
      }

      private function shouldAvoidEdgeDash(targetDistance:Point) : Boolean
      {
         if(_fighter == null || _target == null || targetDistance == null)
         {
            return false;
         }
         var edgeDistance:Number = GameLogic.getMapSideDistanceX(_fighter,10);
         if(edgeDistance == Number.MAX_VALUE)
         {
            return false;
         }
         var targetEdgeDistance:Number = GameLogic.getMapSideDistanceX(_target,10);
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var avoidEdgeDistance:Number = normalizedLevel >= AIDifficultyProfile.HARD ? 145 : 130;
         if(edgeDistance > avoidEdgeDistance && targetEdgeDistance > avoidEdgeDistance)
         {
            return false;
         }
         return targetDistance.x <= 250 && targetDistance.y <= 110;
      }
      
      private function allowRapidChainForAction(skillActionName:String, isDownCommandSkill:Boolean, isAirCommandSkill:Boolean) : Boolean
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         if(isAirCommandSkill)
         {
            return false;
         }
         if(isDownCommandSkill)
         {
            return normalizedLevel >= AIDifficultyProfile.NORMAL;
         }
         if(skillActionName == "skill2" || skillActionName == "zhao3")
         {
            return normalizedLevel >= AIDifficultyProfile.NORMAL;
         }
         if(normalizedLevel >= AIDifficultyProfile.VERY_HARD && (skillActionName == "skill1" || skillActionName == "zhao1" || skillActionName == "zhao2"))
         {
            return true;
         }
         return normalizedLevel >= AIDifficultyProfile.HARD && (getCombatMode() == AICombatStyleLogic.MODE_PRESSURE || getCombatMode() == AICombatStyleLogic.MODE_PUNISH) && (skillActionName == "skill1" || skillActionName == "zhao1");
      }
      
      private function allowPredictiveSkillRange(skillActionName:String, targetDistance:Point, isAirCommandSkill:Boolean) : Boolean
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         if(normalizedLevel < AIDifficultyProfile.HARD || targetDistance == null)
         {
            return false;
         }
         if(isAirCommandSkill)
         {
            return targetDistance.x <= 210 && targetDistance.y <= 150 && _fighter.y < _target.y + 90;
         }
         if(skillActionName == "skill1" || skillActionName == "zhao2")
         {
            return targetDistance.x <= 220 && targetDistance.y <= 90;
         }
         if(skillActionName == "skill2" || skillActionName == "zhao3")
         {
            return targetDistance.x <= 185 && targetDistance.y <= 85;
         }
         return targetDistance.x <= 200 && targetDistance.y <= 85;
      }
      
      private function applySkillContextBias(skillRateMap:Object, skillActionName:String, isDownCommandSkill:Boolean, isAirCommandSkill:Boolean) : void
      {
         if(skillRateMap == null || _target == null)
         {
            return;
         }
         applyContextScaleToRateMap(skillRateMap,getCombatScale("skillRateScale",1));
         var targetDistance:Point = getTargetDistance(_target);
         if(targetDistance == null)
         {
            return;
         }
         if(isDownCommandSkill && targetDistance.x < 190 && targetDistance.y < 90)
         {
            applyRateScale(skillRateMap,"defult",1.28,0.35);
            applyRateScale(skillRateMap,20,1.18,0.25);
            applyRateScale(skillRateMap,21,1.12,0.2);
         }
         if(!isDownCommandSkill && !isAirCommandSkill && targetDistance.x < 150 && targetDistance.y < 75)
         {
            applyRateScale(skillRateMap,"defult",1.08,0.1);
         }
         if(getCombatFlag("preferUpperCommandSkill",false) && (skillActionName == "skill2" || skillActionName == "zhao3"))
         {
            applyRateScale(skillRateMap,"defult",1.16,0.2);
            applyRateScale(skillRateMap,20,1.1,0.1);
            applyRateScale(skillRateMap,21,1.1,0.1);
         }
         if(getCombatFlag("preferHitConfirmSkill",false) && _targetFighter && (_targetFighter.actionState == 21 || FighterActionState.isHurting(_targetFighter.actionState)) && targetDistance.x < 205 && targetDistance.y < 100)
         {
            applyRateScale(skillRateMap,"defult",1.24,0.25);
            applyRateScale(skillRateMap,20,1.18,0.18);
            applyRateScale(skillRateMap,21,1.14,0.14);
         }
         if(isAirCommandSkill && targetDistance.y > 170)
         {
            applyRateScale(skillRateMap,"defult",0.7,0);
         }
      }
      
      private function updateCombatStyleContext() : void
      {
         if(_fighter == null || _targetFighter == null || _target == null)
         {
            _combatStyleContext = null;
            return;
         }
         var targetDistance:Point = getTargetDistance(_target);
         _combatStyleContext = AICombatStyleLogic.buildCombatContext(AILevel,_fighter,_targetFighter,targetDistance.x,targetDistance.y,_isConting);
      }
      
      private function getCombatMode() : String
      {
         if(_combatStyleContext == null || _combatStyleContext.mode == null)
         {
            return AICombatStyleLogic.MODE_NEUTRAL;
         }
         return String(_combatStyleContext.mode);
      }
      
      private function getCombatScale(scaleKey:String, defaultValue:Number = 1) : Number
      {
         if(_combatStyleContext == null || _combatStyleContext[scaleKey] == undefined)
         {
            return defaultValue;
         }
         var scaleValue:Number = Number(_combatStyleContext[scaleKey]);
         if(isNaN(scaleValue))
         {
            return defaultValue;
         }
         return scaleValue;
      }
      
      private function getCombatFlag(flagKey:String, defaultValue:Boolean = false) : Boolean
      {
         if(_combatStyleContext == null || _combatStyleContext[flagKey] == undefined)
         {
            return defaultValue;
         }
         return Boolean(_combatStyleContext[flagKey]);
      }
      
      private function getPreferredCombatSpacing(defaultSpacing:Number, preferCatchSpacing:Boolean) : Number
      {
         var baseSpacing:Number = defaultSpacing;
         if(_aiProfile != null && !isNaN(_aiProfile.preferredSpacing) && _aiProfile.preferredSpacing > 0)
         {
            baseSpacing = _aiProfile.preferredSpacing;
         }
         if(_combatStyleContext == null || _combatStyleContext.preferredSpacing == undefined)
         {
            return baseSpacing;
         }
         var preferredSpacing:Number = Number(_combatStyleContext.preferredSpacing);
         if(isNaN(preferredSpacing) || preferredSpacing <= 0)
         {
            return baseSpacing;
         }
         if(preferCatchSpacing)
         {
            return Math.min(baseSpacing,preferredSpacing);
         }
         if(getCombatMode() == AICombatStyleLogic.MODE_DEFENSE)
         {
            return Math.max(baseSpacing,preferredSpacing);
         }
         return preferredSpacing;
      }

      private function updateCustomAIRules() : void
      {
         if(_aiProfile == null || _aiProfile.rules == null || _aiProfile.rules.length == 0)
         {
            return;
         }
         if(_fighter == null || _fighterAction == null)
         {
            return;
         }
         var currentAction:String = _fighter.getCtrler().getMcCtrl().getCurAction();
         var targetDistance:Point = getTargetDistance(_target);
         var isHitConfirmed:Boolean = isTargetInSkillConfirmState();
         for each(var rule:FighterAIRule in _aiProfile.rules)
         {
            if(rule == null)
            {
               continue;
            }
            if(rule.evaluate(_fighter,_targetFighter,currentAction,targetDistance,isHitConfirmed,_fighterAction))
            {
               var resolvedAction:String = FighterAIRule.resolveAvailableActionName(rule.action,_fighterAction);
               if(resolvedAction && this.hasOwnProperty(resolvedAction))
               {
                  this[resolvedAction] = true;
                  addContOrder(resolvedAction,rule.priority);
               }
               else if(this.hasOwnProperty(rule.action))
               {
                  this[rule.action] = true;
                  addContOrder(rule.action,rule.priority);
               }
            }
         }
      }
      
      private function applyContextScaleToRateMap(rateMap:Object, scaleValue:Number) : void
      {
         if(rateMap == null || isNaN(scaleValue) || scaleValue == 1)
         {
            return;
         }
         applyRateScale(rateMap,"defult",scaleValue,0);
         applyRateScale(rateMap,0,scaleValue,0);
         applyRateScale(rateMap,10,scaleValue,0);
         applyRateScale(rateMap,11,scaleValue,0);
         applyRateScale(rateMap,12,scaleValue,0);
         applyRateScale(rateMap,13,scaleValue,0);
         applyRateScale(rateMap,14,scaleValue,0);
         applyRateScale(rateMap,15,scaleValue,0);
         applyRateScale(rateMap,16,scaleValue,0);
         applyRateScale(rateMap,20,scaleValue,0);
         applyRateScale(rateMap,21,scaleValue,0);
         applyRateScale(rateMap,22,scaleValue,0);
         applyRateScale(rateMap,23,scaleValue,0);
         applyRateScale(rateMap,24,scaleValue,0);
         applyRateScale(rateMap,40,scaleValue,0);
      }
      
      private function applyRateScale(rateMap:Object, rateKey:Object, multiplier:Number, offset:Number) : void
      {
         if(rateMap == null || rateMap[rateKey] == null)
         {
            return;
         }
         rateMap[rateKey] = scaleRateArray(rateMap[rateKey],multiplier,offset);
      }
      
      private function scaleRateArray(sourceRate:Array, multiplier:Number, offset:Number) : Array
      {
         var scaledRate:Array = [];
         var rateIndex:int = 0;
         var rateValue:Number = 0;
         if(sourceRate == null)
         {
            return scaledRate;
         }
         while(rateIndex < sourceRate.length)
         {
            rateValue = Number(sourceRate[rateIndex]);
            if(isNaN(rateValue))
            {
               rateValue = 0;
            }
            rateValue = rateValue * multiplier + offset;
            if(rateValue < 0)
            {
               rateValue = 0;
            }
            else if(rateValue > 10)
            {
               rateValue = 10;
            }
            scaledRate[rateIndex] = rateValue;
            rateIndex++;
         }
         return scaledRate;
      }
      
      private function updateGhostStep() : void
      {
         var targetDistance:Point = getTargetDistance(_target);
         ghostStep = ghostJump = ghostJumpDowm = false;
         if(!_fighter.getCtrler() || !_fighter.getCtrler().getMcCtrl())
         {
            return;
         }
         if(_fighter.isSteelBody || !_fighter.isAllowBeHit || !_fighter.getBodyArea())
         {
            return;
         }
         if(!AITacticalSupportLogic.allowGhostLogic(AILevel,_isConting,_fighter.actionState,targetDistance.x,targetDistance.y))
         {
            return;
         }
         var currentAction:String = _fighter.getCtrler().getMcCtrl().getCurAction();
         var shouldReposition:Boolean = _attackAction[currentAction] && !targetInRange(_attackAction[currentAction]);
         if(!shouldReposition)
         {
            return;
         }
         var ghostStepRateMap:Object = AITacticalSupportLogic.buildGhostStepRateMap(AILevel,_fighter.actionState);
         var ghostJumpRateMap:Object = AITacticalSupportLogic.buildGhostJumpRateMap(AILevel,_fighter.actionState);
         setAIByMain(ghostStepRateMap,"ghostStep");
         setAIByMain(ghostJumpRateMap,"ghostJump");
         ghostStep = getAIByFighterState(ghostStepRateMap);
         ghostJump = !ghostStep && getAIByFighterState(ghostJumpRateMap);
      }
   }
}

