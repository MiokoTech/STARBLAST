package net.play5d.game.bvn.fighter.ctrler
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.data.HitType;
   import net.play5d.game.bvn.data.fighter.FighterInputCmd;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterAction;
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.fighter.FighterAttacker;
   import net.play5d.game.bvn.fighter.FighterMC;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.events.FighterEvent;
   import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.fighter.vos.MoveTargetParamVO;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class FighterMcCtrler
   {
      
      public var effectCtrler:FighterEffectCtrl;
      
      private var _actionCtrler:IFighterActionCtrl;
      
      private var _mc:FighterMC;
      
      private var _fighter:FighterMain;
      
      private var _action:FighterAction = new FighterAction();
      
      private var _doingAction:String;
      
      private var _doingAirAction:String;
      
      private var _isFalling:Boolean;
      
      private var _jumpDelayFrame:int = 0;
      
      private var _hurtHoldFrame:int = 0;
      
      private var _defenseHoldFrame:int = 0;
      
      private var _beHitGap:int;
      
      private var _doActionFrame:int;
      
      private var _isTouchFloor:Boolean = true;
      
      private var _isDefense:Boolean;
      
      private var _defenseFrameDelay:int = 0;
      
      private var _moveTargetParam:MoveTargetParamVO;
      
      private var _hurtDownFrame:int;
      
      private var _ghostStepIng:Boolean;
      
      private var _ghostStepFrame:int;
      
      private var _autoDirectFrame:int;
      
      private var _justDefenseFrame:int;
      
      private var _ghostType:int = 0;
      
      private var _justHurtResume:Boolean;
      
      private var _actionLogic:FighterActionLogic;
      
      public var beHitActions:Object = null;
      
      private var _hasBadAction:Boolean = false;
      
      private var _lastHurtActionTimes:uint = 0;
      
      private var _longGhostStepState:uint = 0;
      
      public var doActionTimes:uint = 1;
      
      private var _isMovingTarget:Boolean = false;
      
      public function FighterMcCtrler(param1:FighterMain)
      {
         super();
         _fighter = param1;
         _actionLogic = new FighterActionLogic(param1);
      }
      
      public function destory() : void
      {
         if(_actionCtrler)
         {
            _actionCtrler.destory();
            _actionCtrler = null;
         }
         if(_mc)
         {
            _mc.destory();
            _mc = null;
         }
         _fighter = null;
         _action = null;
         _moveTargetParam = null;
         effectCtrler = null;
      }
      
      public function getAction() : FighterAction
      {
         return _action;
      }
      
      public function getFighterMc() : FighterMC
      {
         return _mc;
      }
      
      public function getCurAction() : String
      {
         if(_doingAirAction != null)
         {
            return _doingAirAction;
         }
         return _doingAction;
      }
      
      public function getActionCtrler() : IFighterActionCtrl
      {
         return _actionCtrler;
      }
      
      public function setActionCtrler(param1:IFighterActionCtrl) : void
      {
         _actionCtrler = param1;
      }
      
      public function setNewActionLogic(param1:FighterMain) : void
      {
         _fighter = param1;
         _actionLogic = new FighterActionLogic(param1);
      }
      
      public function setMc(param1:FighterMC) : void
      {
         _mc = param1;
         idle();
      }
      
      public function initMc(param1:MovieClip) : FighterMC
      {
         _mc = new FighterMC();
         _mc.initlize(param1,_fighter,this);
         idle();
         return _mc;
      }

      private function allowBvnVisualEffect() : Boolean
      {
         return true;
      }


      public function setSteelBody(param1:Boolean, param2:Boolean = false) : void
      {
         _fighter.isSteelBody = param1;
         _fighter.isSuperSteelBody = param1 && param2;
         if(!allowBvnVisualEffect())
         {
            return;
         }
         if(param1)
         {
            effectCtrler.startGlow(param2 ? 16776960 : 16777215);
         }
         else
         {
            effectCtrler.endGlow();
         }
      }
      
      public function addQi(param1:Number) : void
      {
         _fighter.addQi(param1);
      }
      
      public function idle(param1:String = "站立") : void
      {
         var _loc2_:Boolean = false;
         if(!_fighter.isAlive)
         {
            return;
         }
         if(FighterActionState.isHurting(_fighter.actionState))
         {
            _justHurtResume = true;
         }
         endAct();
         _doingAction = null;
         _doingAirAction = null;
         setSteelBody(false);
         _justDefenseFrame = 0.1 * GameConfig.FPS_GAME;
         effectCtrler.endShake();
         _action.clearAction();
         _action.clearState();
         _fighter.actionState = 0;
         _fighter.isAllowBeHit = !_justHurtResume;
         _fighter.isApplyG = true;
         _fighter.isCross = false;
         _fighter.hurtHit = null;
         _fighter.defenseHit = null;
         _fighter.clearHurtHits();
         _fighter.getDisplay().visible = true;
         _isDefense = false;
         _autoDirectFrame = 0;
         if(!_isTouchFloor)
         {
            fall();
         }
         else
         {
            _loc2_ = true;
            _fighter.setVelocity(0,0);
            if(param1 == "站立")
            {
               _loc2_ = false;
               _action.jumpTimes = _fighter.jumpTimes;
               _action.airHitTimes = _fighter.airHitTimes;
               setAllAct();
            }
            _mc.goFrame(param1,_loc2_);
         }
         FighterEventDispatcher.dispatchEvent(_fighter,"IDLE");
      }
      
      public function loop(param1:String) : void
      {
         _mc.goFrame(param1);
      }
      
      public function stop() : void
      {
         _mc.stopRenderMainAnimate();
      }
      
      public function dash(param1:Number = 3) : void
      {
         _action.isDashing = true;
         _fighter.setVelocity(_fighter.speed * param1 * _fighter.direct,0);
         _fighter.setDamping(0,0);
         _fighter.isCross = true;
         _fighter.isAllowBeHit = false;
      }
      
      public function dashStop(param1:Number = 0.5) : void
      {
         var _loc2_:Number = _fighter.getVecX();
         var _loc3_:Number = Math.abs(_loc2_) * param1;
         _fighter.setDamping(_loc3_);
         _fighter.isAllowBeHit = true;
         _fighter.actionState = 0;
         _action.clearAction();
         _action.isDashing = false;
         _fighter.isCross = false;
      }
      
      public function setAllAct() : void
      {
         setMove();
         setDefense();
         setJump();
         setJumpDown();
         setDash();
         setAttack();
         setSkill1();
         setSkill2();
         setZhao1();
         setZhao2();
         setZhao3();
         setCatch1();
         setCatch2();
         setBisha();
         setBishaUP();
         setBishaSUPER();
         setWankai();
      }
      
      public function setAirAllAct() : void
      {
         setDash();
         setAttackAIR();
         setSkillAIR();
         setBishaAIR();
         setAirMove(true);
      }
      
      public function setAirMove(param1:Boolean) : void
      {
         _action.airMove = param1;
      }
      
      public function setMove() : void
      {
         setMoveLeft();
         setMoveRight();
      }
      
      public function setMoveLeft() : void
      {
         _action.moveLeft = "走";
      }
      
      public function setMoveRight() : void
      {
         _action.moveRight = "走";
      }
      
      public function setDefense() : void
      {
         _action.defense = "防御";
      }
      
      public function setJump(param1:String = "跳") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.jump = param1;
      }
      
      public function setJumpQuick(param1:String = "跳") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.jumpQuick = param1;
      }
      
      public function setJumpDown(param1:String = "落") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.jumpDown = param1;
      }
      
      public function setDash(param1:String = "瞬步") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.dash = param1;
      }
      
      public function setAttack(param1:String = "砍1") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.attack = param1;
      }
      
      public function setSkill1(param1:String = "砍技1") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.skill1 = param1;
      }
      
      public function setSkill2(param1:String = "砍技2") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.skill2 = param1;
      }
      
      public function setZhao1(param1:String = "招1") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.zhao1 = param1;
      }
      
      public function setZhao2(param1:String = "招2") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.zhao2 = param1;
      }
      
      public function setZhao3(param1:String = "招3") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.zhao3 = param1;
      }
      
      public function setCatch1(param1:String = "摔1") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.catch1 = param1;
      }
      
      public function setCatch2(param1:String = "摔2") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.catch2 = param1;
      }
      
      public function setBisha(param1:String = "必杀", param2:int = 100) : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.bisha = param1;
         _action.bishaQi = param2;
      }
      
      public function setBishaUP(param1:String = "上必杀", param2:int = 100) : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.bishaUP = param1;
         _action.bishaUPQi = param2;
      }
      
      public function setBishaSUPER(param1:String = "超必杀", param2:int = 300) : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.bishaSUPER = param1;
         _action.bishaSUPERQi = param2;
      }
      
      public function setAttackAIR(param1:String = "跳砍") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.attackAIR = param1;
      }
      
      public function setSkillAIR(param1:String = "跳招") : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.skillAIR = param1;
      }
      
      public function setBishaAIR(param1:String = "空中必杀", param2:int = 100) : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.bishaAIR = param1;
         _action.bishaAIRQi = param2;
      }
      
      public function setTouchFloor(param1:String = "落地", param2:Boolean = true) : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.touchFloor = param1;
         _action.touchFloorBreakAct = param2;
      }
      
      public function setWankai() : void
      {
         if(_mc.checkFrame("万解"))
         {
            _action.waiKai = "万解";
         }
         if(_mc.checkFrame("万解W"))
         {
            _action.waiKaiW = "万解W";
         }
         if(_mc.checkFrame("万解S"))
         {
            _action.waiKaiS = "万解S";
         }
      }
      
      public function setHitTarget(param1:String, param2:String) : void
      {
         _action.hitTarget = param2;
         _action.hitTargetChecker = param1;
      }
      
      public function setHurtAction(param1:String) : void
      {
         _action.hurtAction = param1;
         _fighter.actionState = 16;
      }
      
      public function setTouchSide(param1:String) : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         _action.touchSide = param1;
      }
      
      public function move(param1:Number = 0, param2:Number = 0) : void
      {
         if(param1 == 0 && param2 == 0)
         {
            stopMove();
            return;
         }
         if(_fighter.isInAir && param1 != 0)
         {
            _action.airMove = false;
         }
         param1 *= _fighter.direct;
         _fighter.setVelocity(param1,param2);
      }
      
      public function movePercent(param1:Number = 0, param2:Number = 0) : void
      {
         move(_fighter.speed * param1,_fighter.speed * param2);
      }
      
      public function stopMove() : void
      {
         _fighter.setVelocity(0,0);
      }
      
      public function damping(param1:Number = 0, param2:Number = 0) : void
      {
         _fighter.setDamping(param1,param2);
      }
      
      public function dampingPercent(param1:Number = 0, param2:Number = 0) : void
      {
         _fighter.setDamping(_fighter.speed * param1,_fighter.speed * param2);
      }
      
      public function endAct() : void
      {
         _action.clearAction();
         _fighter.actionState = 40;
         _moveTargetParam = null;
         setSteelBody(false);
      }
      
      public function fire(param1:String, param2:Object = null) : void
      {
         var mcName:String = param1;
         var params:Object = param2;
         var mc:MovieClip = _mc.getChildByName(mcName) as MovieClip;
         if(mc)
         {
            if(!params)
            {
               params = {};
            }
            params.mc = mc;
            params.hitVO = _fighter.getCtrler().hitModel.getHitVOByDisplayName(mcName);
            FighterEventDispatcher.dispatchEvent(_fighter,"FIRE_BULLET",params);
         }
         else
         {
            _fighter.setAnimateFrameOut(function():void
            {
               fire(mcName,params);
            },1);
         }
      }
      
      public function addAttacker(param1:String, param2:Object = null) : void
      {
         var mcName:String = param1;
         var params:Object = param2;
         var mc:MovieClip = _mc.getChildByName(mcName) as MovieClip;
         if(mc)
         {
            if(!params)
            {
               params = {};
            }
            params.mc = mc;
            params.hitVO = _fighter.getCtrler().hitModel.getHitVOByDisplayName(mcName);
            FighterEventDispatcher.dispatchEvent(_fighter,"ADD_ATTACKER",params);
         }
         else
         {
            _fighter.setAnimateFrameOut(function():void
            {
               addAttacker(mcName,params);
            },1);
         }
      }
      
      public function isApplyG(param1:Boolean) : void
      {
         _fighter.isApplyG = param1;
      }
      
      public function gotoAndPlay(param1:String) : void
      {
         _mc.goFrame(param1,true);
      }
      
      public function gotoAndStop(param1:String) : void
      {
         _mc.goFrame(param1,false);
      }
      
      public function hurtFly(param1:Number, param2:Number) : void
      {
         _mc.playHurtFly(param1 * _fighter.direct,param2,false);
         _action.isHurtFlying = true;
         _fighter.actionState = 22;
         _hurtDownFrame = 0;
         _isFalling = false;
      }
      
      public function moveMC(param1:DisplayObject, param2:Object = null, param3:Object = null) : void
      {
         var _loc4_:IGameSprite = _fighter.getCurrentTarget();
         if(param2)
         {
            if(param2 is Number)
            {
               param1.x = _fighter.x + param2;
            }
            else if(param2.target != undefined && _loc4_)
            {
               param1.x = _loc4_.x - _fighter.x;
               if(isNaN(Number(param2.target)))
               {
                  param1.x += Number(param2.target);
               }
            }
         }
         if(param3)
         {
            if(param3 is Number)
            {
               param1.y = _fighter.y + param3;
            }
            else if(param3.target != undefined && _loc4_)
            {
               param1.y = _loc4_.y - _fighter.y + Number(param3);
               if(isNaN(Number(param3.target)))
               {
                  param1.y += Number(param3.target);
               }
            }
         }
      }
      
      public function justHitToPlay(param1:String, param2:String, param3:Boolean = false, param4:Boolean = false) : void
      {
         if(_fighter.getCtrler().justHit(param1,param4))
         {
            _mc.goFrame(param2);
         }
         else if(param3)
         {
            idle();
         }
      }
      
      public function getAttacker(param1:String) : FighterAttackerCtrler
      {
         var _loc2_:FighterAttacker = GameCtrl.I.getAttacker(param1,_fighter.team.id);
         if(_loc2_)
         {
            return _loc2_.getCtrler();
         }
         return null;
      }
      
      
      public function moveTarget(param1:Object = null) : void
      {
         if(param1 == null && _moveTargetParam != null)
         {
            _moveTargetParam.clear();
            _moveTargetParam = null;
            return;
         }
         _moveTargetParam = new MoveTargetParamVO(param1);
         _moveTargetParam.setTarget(_fighter.getCurrentTarget());
      }
      
      public function render() : void
      {
         if(_ghostStepIng)
         {
            return;
         }
         if(_justDefenseFrame > 0)
         {
            _justDefenseFrame--;
         }
         _action.render();
         if(_moveTargetParam)
         {
            renderMoveTarget();
         }
         if(_actionCtrler)
         {
            _actionCtrler.render();
         }
         if(_action.isHurtFlying)
         {
            renderHurtFlying();
            return;
         }
         if(_action.isHurting)
         {
            renderHurt();
            return;
         }
         if(_action.isDefenseHiting)
         {
            renderDefense(false,true);
            return;
         }
         if(_action.hitTarget)
         {
            renderCheckTargetHit();
         }
         if(renderWanKaiCtrl())
         {
            return;
         }
         if(_fighter && _fighter.isInAir || _doingAirAction && !_action.touchFloorBreakAct)
         {
            renderAirAction();
         }
         else
         {
            renderFloorAction();
         }
      }
      
      private function renderHurtFlying() : void
      {
         if(!_fighter.isInAir)
         {
            _isTouchFloor = true;
         }
         if(!_fighter.isAlive)
         {
            return;
         }
         if(_fighter.actionState == 24)
         {
            _hurtDownFrame = 1;
         }
         if(_hurtDownFrame > 0)
         {
            if(!_actionLogic || !_actionLogic.enabled())
            {
               return;
            }
            if(++_hurtDownFrame < 20)
            {
               if(_actionLogic.hurtFlyResume())
               {
                  doHurtDownJump();
                  _hurtDownFrame = 0;
               }
            }
         }
      }
      
      private function renderSpecial() : void
      {
         if(_actionLogic.specailSkill())
         {
            FighterEventDispatcher.dispatchEvent(_fighter,"DO_SPECIAL");
         }
      }
      
      private function renderFloorAction() : void
      {
         if(!_fighter.isAlive)
         {
            return;
         }
         if(!_isTouchFloor)
         {
            touchFloor();
         }
         touchSide();
         
         if(_actionLogic == null || !_actionLogic.enabled())
         {
            if(_mc.currentFrameName == "走" || _mc.currentFrameName == "防御")
            {
               idle();
            }
            return;
         }

         if(_actionLogic.catch1())
         {
            doCatch(_action.catch1);
         }
         if(_actionLogic.catch2())
         {
            doCatch(_action.catch2);
         }
         if(_actionLogic.bishaSUPER())
         {
            doBisha(_action.bishaSUPER,_action.bishaSUPERQi,true);
         }
         if(_actionLogic.bishaUP())
         {
            doBisha(_action.bishaUP,_action.bishaUPQi);
         }
         if(_actionLogic.bisha())
         {
            doBisha(_action.bisha,_action.bishaQi);
         }
         if(_actionLogic.skill2())
         {
            doSkill(_action.skill2);
         }
         if(_actionLogic.skill1())
         {
            doSkill(_action.skill1);
         }
         if(_actionLogic.zhao3())
         {
            doSkill(_action.zhao3);
         }
         if(_actionLogic.zhao2())
         {
            doSkill(_action.zhao2);
         }
         if(_actionLogic.attack())
         {
            doAttack(_action.attack);
         }
         if(_actionLogic.zhao1())
         {
            doSkill(_action.zhao1);
         }
         if(_actionLogic.defense())
         {
            doDefense();
         }
         if(_actionLogic.dash())
         {
            doDash(_action.dash);
         }
         if(_actionLogic.moveLEFT())
         {
            doMove(_action.moveLeft,-1);
         }
         if(_actionLogic.moveRIGHT())
         {
            doMove(_action.moveRight,1);
         }
         if(_actionLogic.jump())
         {
            doJump(_action.jump);
         }
         if(_actionLogic.jumpDown())
         {
            doJumpDown(_action.jumpDown);
         }
         if(_action.isMoving)
         {
            renderMoving();
         }
         if(_action.isDefensing)
         {
            renderDefense();
         }
         if(_actionLogic.ghostStep())
         {
            doGhostStep();
         }
         if(_actionLogic.ghostJump())
         {
            doGhostJump();
         }
         if(FighterActionState.isAttacking(_fighter.actionState))
         {
            if(_actionLogic.attackAIR())
            {
               doAirAttack(_action.attackAIR);
            }
            if(_actionLogic.skillAIR())
            {
               doAirSkill(_action.skillAIR);
            }
            if(_actionLogic.bishaAIR())
            {
               doAirBisha(_action.bishaAIR,_action.bishaAIRQi);
            }
         }
      }
      
      private function renderWanKaiCtrl() : Boolean
      {
         if(!_actionLogic || !_actionLogic.enabled())
         {
            return false;
         }
         if(_actionLogic.waiKai())
         {
            return checkDoWankai(_action.waiKai,"万解");
         }
         if(_actionLogic.waiKaiW())
         {
            return checkDoWankai(_action.waiKaiW,"万解W");
         }
         if(_actionLogic.waiKaiS())
         {
            return checkDoWankai(_action.waiKaiS,"万解S");
         }
         return false;
      }
      
      private function checkDoWankai(param1:String, param2:String) : Boolean
      {
         if(param1)
         {
            doWaiKaiAction(param1);
            return true;
         }
         if(_doingAction == "砍1")
         {
            if(_doActionFrame < 2)
            {
               doWaiKaiAction(param2);
               return true;
            }
         }
         return false;
      }      
      
      public function renderAnimate() : void
      {
         if(_justHurtResume)
         {
            _fighter.isAllowBeHit = true;
            _justHurtResume = false;
         }
         renderBeHitGap();
         if(_mc)
         {
            _mc.renderAnimate();
         }
         if(_actionCtrler)
         {
            _actionCtrler.renderAnimate();
         }
         if(_ghostStepIng)
         {
            renderGhostStep();
            return;
         }
         if(_action)
         {
            if(_action.isHurting)
            {
               renderHurtAnimate();
            }
            if(_action.isDefenseHiting)
            {
               renderDefensHiting();
            }
            if(_action.isJumping)
            {
               renderJumpAnimate();
            }
            if(_doingAction)
            {
               _doActionFrame++;
            }
            if(_action.isDefensing)
            {
               renderDefenseAnimate();
            }
         }
         if(_mc && _mc.currentFrameName == "站立")
         {
            if(++_autoDirectFrame > 5)
            {
               _fighter.getCtrler().setDirectToTarget();
               _autoDirectFrame = 0;
            }
         }
      }

      private function renderAirAction() : void
      {
         if(!_fighter.isAlive)
         {
            return;
         }
         if(!_action.isJumping)
         {
            fall();
         }
         _isTouchFloor = false;
         if(_actionLogic == null || !_actionLogic.enabled())
         {
            return;
         }
         if(_actionLogic.attackAIR())
         {
            doAirAttack(_action.attackAIR);
         }
         if(_actionLogic.skillAIR())
         {
            doAirSkill(_action.skillAIR);
         }
         if(_actionLogic.bishaAIR())
         {
            doAirBisha(_action.bishaAIR,_action.bishaAIRQi);
         }
         if(_actionLogic.jump())
         {
            doAirJump(_action.jump);
         }
         if(_actionLogic.jumpQuick())
         {
            doAirJump(_action.jumpQuick);
         }
         if(FighterActionState.isAttacking(_fighter.actionState))
         {
            if(_actionLogic.bishaSUPER())
            {
               doBisha(_action.bishaSUPER,_action.bishaSUPERQi,true);
            }
            if(_actionLogic.bishaUP())
            {
               doBisha(_action.bishaUP,_action.bishaUPQi);
            }
            if(_actionLogic.bisha())
            {
               doBisha(_action.bisha,_action.bishaQi);
            }
            if(_actionLogic.skill2())
            {
               doSkill(_action.skill2);
            }
            if(_actionLogic.skill1())
            {
               doSkill(_action.skill1);
            }
            if(_actionLogic.zhao3())
            {
               doSkill(_action.zhao3);
            }
            if(_actionLogic.zhao2())
            {
               doSkill(_action.zhao2);
            }
            if(_actionLogic.attack())
            {
               doAttack(_action.attack);
            }
            if(_actionLogic.zhao1())
            {
               doSkill(_action.zhao1);
            }
         }
         if(_actionLogic.dash())
         {
            doDashAir(_action.dash);
         }
         if(_actionLogic.airMove())
         {
            doAirMove();
         }
         if(_actionLogic.ghostJump())
         {
            doGhostJump();
         }
         if(_actionLogic.ghostJumpDown())
         {
            doGhostJumpDown();
         }
      }
      
      private function renderMoveTarget() : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc1_:DisplayObject = null;
         var _loc4_:IGameSprite = _moveTargetParam.target;
         if(!_loc4_)
         {
            return;
         }
         if(_moveTargetParam.followMcName)
         {
            _loc1_ = _mc.getChildByName(_moveTargetParam.followMcName);
            if(!_loc1_)
            {
               return;
            }
            _loc3_ = _fighter.x + _loc1_.x * _fighter.direct;
            _loc2_ = _fighter.y + _loc1_.y;
         }
         else
         {
            if(!isNaN(_moveTargetParam.x))
            {
               _loc3_ = _moveTargetParam.x;
            }
            if(!isNaN(_moveTargetParam.y))
            {
               _loc2_ = _moveTargetParam.y;
            }
         }
         if(_moveTargetParam.speed)
         {
            if(_moveTargetParam.speed.x > 0 && !isNaN(_loc3_))
            {
               if(_loc4_.x > _loc3_ + _moveTargetParam.speed.x)
               {
                  _loc4_.x -= _moveTargetParam.speed.x;
               }
               if(_loc4_.x < _loc3_ - _moveTargetParam.speed.x)
               {
                  _loc4_.x += _moveTargetParam.speed.x;
               }
               if(_loc4_.y > _loc2_ + _moveTargetParam.speed.y)
               {
                  if(_loc4_ is BaseGameSprite)
                  {
                     (_loc4_ as BaseGameSprite).setVecY(-_moveTargetParam.speed.y);
                     (_loc4_ as BaseGameSprite).setDampingY(1);
                  }
                  else
                  {
                     _loc4_.y -= _moveTargetParam.speed.y;
                  }
               }
               if(_loc4_.y < _loc2_ - _moveTargetParam.speed.y)
               {
                  if(_loc4_ is BaseGameSprite)
                  {
                     (_loc4_ as BaseGameSprite).setVecY(_moveTargetParam.speed.y);
                     (_loc4_ as BaseGameSprite).setDampingY(1);
                  }
                  else
                  {
                     _loc4_.y += _moveTargetParam.speed.y;
                  }
               }
            }
         }
         else
         {
            if(!isNaN(_loc3_))
            {
               _loc4_.x = _loc3_;
            }
            if(!isNaN(_loc2_))
            {
               _loc4_.y = _loc2_;
            }
         }
      }
      
      private function fall() : void
      {
         if(_isFalling)
         {
            return;
         }
         if(_doingAction)
         {
            return;
         }
         _action.clearState();
         _action.clearAction();
         setAirAllAct();
         setJump();
         _isFalling = true;
         _doingAirAction = null;
         _isTouchFloor = false;
         _isDefense = false;
         _fighter.setVecX(0);
         setTouchFloor("落地",true);
         _mc.goFrame("落",false);
      }
      
      public function touchFloor() : void
      {
         if(!_fighter.isAlive)
         {
            return;
         }
         var _loc2_:String = _action.touchFloor;
         if(_isFalling)
         {
            if(!_loc2_)
            {
               _loc2_ = "落地";
            }
         }
         if(_loc2_ == null)
         {
            return;
         }
         var _loc1_:Object = _loc2_ == "落地" ? {
            "call":setAttack,
            "delay":1
         } : null;
         doAction(_loc2_,false,_loc1_);
         if(allowBvnVisualEffect())
         {
            effectCtrler.touchFloor();
         }
         _action.airHitTimes = _fighter.airHitTimes;
         _action.jumpTimes = _fighter.jumpTimes;
         _isTouchFloor = true;
         _isFalling = false;
      }
      
      public function touchSide() : void
      {
         if(!_fighter.isAlive)
         {
            return;
         }
         if(_action.touchSide == null)
         {
            return;
         }
         if(_mc.checkFrame(_action.touchSide) && _fighter.getIsTouchSide())
         {
            doAction(_action.touchSide);
            _action.touchSide = null;
         }
      }
      
      private function doAction(param1:String, param2:Boolean = false, param3:Object = null) : void
      {
         if(param1 == null)
         {
            return;
         }
                     
         effectCtrler.endShake();
         _fighter.setVelocity(0,0);
         _action.isMoving = false;
         _action.isDefensing = false;
         _action.isDashing = false;
         _doingAction = param1;
         _doingAirAction = param2 ? param1 : null;
         _action.clearAction();
         _isFalling = false;
         _isDefense = false;
         _fighter.isAllowBeHit = true;
         _fighter.isCross = false;
         _fighter.isApplyG = true;
         _doActionFrame = 0;
         _mc.goFrame(param1,true,0,param3);
         _fighter.dispatchEvent(new FighterEvent("DO_ACTION"));
      }
      
      private function setMoveAction() : void
      {
         _action.clearAction();
         _action.isMoving = true;
         setMove();
         setAttack();
         setZhao1();
         setZhao3();
         setSkill2();
         setJump();
         setDash();
         setBisha();
         setBishaUP();
         setDefense();
         setCatch1();
         setCatch2();
      }
      
      private function renderMoving() : void
      {
         if(_actionCtrler.moveLEFT())
         {
            _fighter.direct = -1;
            move(_fighter.speed);
         }
         else if(_actionCtrler.moveRIGHT())
         {
            _fighter.direct = 1;
            move(_fighter.speed);
         }
         else
         {
            idle();
         }
      }
      
      private function doMove(param1:String, param2:int = 1) : void
      {
         if(_action.isMoving)
         {
            return;
         }
         _mc.goFrame(param1,true);
         _fighter.actionState = 0;
         setMoveAction();
      }
      
      private function doAirMove() : void
      {
         if(_actionCtrler.moveLEFT())
         {
            _fighter.move(-_fighter.speed);
         }
         if(_actionCtrler.moveRIGHT())
         {
            _fighter.move(_fighter.speed);
         }
      }
      
      private function renderDefense(param1:Boolean = true, param2:Boolean = false) : void
      {
         if(_actionCtrler.moveLEFT())
         {
            if(_fighter.direct != -1)
            {
               _fighter.direct = -1;
               setDefenseAction(param1,param2);
            }
         }
         if(_actionCtrler.moveRIGHT())
         {
            if(_fighter.direct != 1)
            {
               _fighter.direct = 1;
               setDefenseAction(param1,param2);
            }
         }
      }
      
      private function renderDefenseAnimate() : void
      {
         if(_action.isDefenseHiting)
         {
            return;
         }
         if(_defenseFrameDelay-- > 0)
         {
            return;
         }
         if(_actionCtrler.enabled() && _actionCtrler.defense())
         {
            if(!_isDefense)
            {
               _isDefense = true;
            }
         }
         else
         {
            if(_defenseFrameDelay > -5)
            {
               return;
            }
            _action.isDefensing = false;
            _mc.goFrame("防御恢复",false,0,{
               "call":idle,
               "delay":1
            });
         }
      }
      
      private function setDefenseAction(param1:Boolean = true, param2:Boolean = false) : void
      {
         if(param1)
         {
            _action.clearAction();
            _action.clearState();
            _action.isDefensing = true;
            setSkill1();
            setZhao2();
            setBishaSUPER();
            setJumpDown();
         }
         if(param2)
         {
            _isDefense = true;
         }
         else
         {
            _isDefense = _justDefenseFrame > 0 ? true : false;
         }
         _defenseFrameDelay = 1;
         _mc.goFrame("防御",true,3);
         FighterEventDispatcher.dispatchEvent(_fighter,"DEFENSE");
      }
      
      private function doDefense() : void
      {
         if(_action.isDefensing)
         {
            return;
         }
         _fighter.actionState = 20;
         dampingPercent(1,1);
         setDefenseAction();
      }
      
      private function doDash(param1:String) : void
      {
         if(!_fighter.hasEnergy(20,true))
         {
            return;
         }
         _fighter.useEnergy(20);
         var dashInputDir:int = getDashInputDirection();
         if(dashInputDir != 0)
         {
            _fighter.direct = dashInputDir;
         }
         doAction(param1);
         _fighter.actionState = 15;
         _fighter.isAllowBeHit = false;
         isApplyG(false);
      }
      
      private function doDashAir(param1:String) : void
      {
         if(_action.jumpTimes < 1)
         {
            return;
         }
         if(!_fighter.hasEnergy(30,true))
         {
            return;
         }
         _fighter.useEnergy(30);
         var dashInputDir:int = getDashInputDirection();
         if(dashInputDir != 0)
         {
            _fighter.direct = dashInputDir;
         }
         doAction(param1);
         _fighter.actionState = 15;
         _fighter.isAllowBeHit = false;
         isApplyG(false);
         _action.jumpTimes = 0;
      }

      private function getDashInputDirection() : int
      {
         if(_actionCtrler.moveLEFT())
         {
            return -1;
         }
         if(_actionCtrler.moveRIGHT())
         {
            return 1;
         }
         return 0;
      }
      
      private function doJump(param1:String) : void
      {
         if(_action.jumpTimes <= 0)
         {
            return;
         }
         _action.clearAction();
         _action.clearState();
         _doingAction = null;
         _doingAirAction = null;
         _mc.goFrame("起跳",false);
         _jumpDelayFrame = GameConfig.getJumpDelayFrame(false);
         _action.isJumping = true;
         _fighter.actionState = 14;
      }
      
      private function doJumpDown(param1:String) : void
      {
         if(_fighter.isTouchBottom)
         {
            return;
         }
         _action.clear();
         _action.jumpTimes = 0;
         _fighter.setVecY(5);
         _fighter.setDamping(0,1);
         _fighter.y += 1;
         _isDefense = false;
         _mc.goFrame(param1,false);
         setTouchFloor();
      }
      
      private function doAirJump(param1:String) : void
      {
         if(_action.jumpTimes <= 0)
         {
            return;
         }
         _action.clearAction();
         _action.clearState();
         _doingAction = null;
         _doingAirAction = null;
         _jumpDelayFrame = GameConfig.getJumpDelayFrame(true);
         _action.isJumping = true;
         _fighter.actionState = 14;
      }
      
      public function renderJumpAnimate() : void
      {
         if(_doingAction)
         {
            return;
         }
         if(_jumpDelayFrame > 0)
         {
            _jumpDelayFrame--;
            if(_jumpDelayFrame == 0)
            {
               _isFalling = false;
               _action.jumpTimes--;
               _mc.goFrame("跳",false);
               _fighter.jump();
               setAirAllAct();
               if(allowBvnVisualEffect())
               {
                  if(_fighter.isInAir)
                  {
                     effectCtrler.jumpAir();
                  }
                  else
                  {
                     effectCtrler.jump();
                  }
               }
            }
            return;
         }
         if(_mc.getCurrentFrameCount() == 2)
         {
            setJumpQuick();
         }
         var _loc1_:Number = _fighter.getVecY();
         if(_mc.currentFrameName != "跳中" && _loc1_ > -_fighter.jumpPower * 0.35)
         {
            _mc.goFrame("跳中",false);
            _fighter.setAnimateFrameOut(setJump,5);
         }
         if(_loc1_ >= 0)
         {
            _action.isJumping = false;
            _isFalling = true;
         }
      }
      
      private function doAttack(param1:String) : void
      {
         doAction(param1);
         _fighter.actionState = 10;
      }
      
      private function doSkill(param1:String) : void
      {
         doAction(param1);
         _fighter.actionState = 11;
      }
      
      private function doCatch(param1:String) : void
      {
         if(!allowCatch())
         {
            return;
         }
         doAction(param1);
         _fighter.actionState = 11;
      }
      
      private function doBisha(param1:String, param2:int, param3:Boolean = false) : void
      {
         if(!_fighter.useQi(param2))
         {
            return;
         }
         if(param3)
         {
            _mc.pauseShadowBySuper();
         }
         _fighter.actionState = param3 ? 13 : 12;
         doAction(param1);
      }
      
      private function doWaiKaiAction(param1:String) : void
      {
         if(!_mc.checkFrame(param1))
         {
            return;
         }
         if(!_fighter.useQi(300))
         {
            return;
         }
         _fighter.actionState = 50;
         doAction(param1);
         _fighter.isAllowBeHit = false;
      }
      
      private function doAirAttack(param1:String) : void
      {
         if(_doingAction == null && _action.airHitTimes <= 0)
         {
            return;
         }
         _fighter.addDamping(0,3);
         _action.airHitTimes--;
         _action.jumpTimes = 0;
         doAction(param1,true);
         _fighter.actionState = 10;
      }
      
      private function doAirSkill(param1:String) : void
      {
         var _loc2_:String = null;
         if(_doingAction == null && _action.airHitTimes <= 0)
         {
            return;
         }
         if(_action.isJumping)
         {
            _loc2_ = null;
            if(_actionCtrler.zhao3())
            {
               _loc2_ = "跳招-上";
            }
            if(_actionCtrler.zhao2())
            {
               _loc2_ = "跳招-下";
            }
            if(_loc2_ && _mc.checkFrame(_loc2_))
            {
               param1 = _loc2_;
            }
         }
         _action.airHitTimes = 0;
         _action.jumpTimes = 0;
         doAction(param1,true);
         _fighter.actionState = 11;
      }
      
      private function doAirBisha(param1:String, param2:int) : void
      {
         if(_doingAction == null && _action.airHitTimes <= 0)
         {
            return;
         }
         if(!_fighter.useQi(param2))
         {
            return;
         }
         _fighter.actionState = 12;
         _action.airHitTimes = 0;
         doAction(param1,true);
      }
      
      public function beHit(param1:HitVO, param2:Rectangle = null) : void
      {
         var _loc3_:BaseGameSprite = null;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         if(_action.hurtAction)
         {
            doAction(_action.hurtAction);
            return;
         }
         if(_fighter.getIsTouchSide())
         {
            if(param1.owner && param1.owner is BaseGameSprite)
            {
               _loc3_ = param1.owner as BaseGameSprite;
               if(Math.abs(_fighter.x - param1.owner.x) < 100)
               {
                  _loc5_ = 0.3;
                  _loc4_ = -param1.hitx * _loc3_.direct * 1.4;
                  if(_loc4_ > 20)
                  {
                     _loc4_ = 20;
                  }
                  if(_loc4_ < -20)
                  {
                     _loc4_ = -20;
                  }
                  _loc3_.setVec2(_loc4_,0,_loc5_,0);
               }
            }
         }
         if(_fighter.isSteelBody && _fighter.isAlive)
         {
            doSteelHurt(param1,param2);
         }
         else if(_isDefense)
         {
            if(param1.isBreakDef && param1.hitType == 11)
            {
               doHurt(param1,param2);
               return;
            }
            if(param1.checkDirect && param1.owner)
            {
               if(checkDefDirect(param1.owner))
               {
                  doHurt(param1,param2);
                  return;
               }
            }
            doDefenseHit(param1,param2);
         }
         else
         {
            doHurt(param1,param2);
         }
      }
      
      private function checkDefDirect(param1:IGameSprite) : Boolean
      {
         var _loc2_:int = 5;
         if(_fighter.x < param1.x - _loc2_)
         {
            return _fighter.direct < 0 && param1.direct < 0;
         }
         if(_fighter.x > param1.x + _loc2_)
         {
            return _fighter.direct > 0 && param1.direct > 0;
         }
         return false;
      }
      
      private function doSteelHurt(param1:HitVO, param2:Rectangle) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:* = NaN;
         var _loc3_:* = NaN;
         if(!_fighter.isSuperSteelBody && (_fighter.energyOverLoad || param1.isBisha() || param1.isCatch()))
         {
            doHurt(param1,param2);
            return;
         }
         _fighter.hurtHit = param1;
         if(_fighter.isSuperSteelBody)
         {
            _fighter.loseHp(param1.getDamage() * 0.3);
         }
         else
         {
            _fighter.loseHp(param1.getDamage() * 0.65);
         }
         if(_fighter.isAlive && GameLogic.checkFighterDie(_fighter))
         {
            FighterEventDispatcher.dispatchEvent(_fighter,"DIE");
            _fighter.isAlive = false;
            doHurt(param1,param2);
            return;
         }
         if(param1.hurtType == 1)
         {
            _beHitGap = 10;
         }
         else
         {
            _beHitGap = 4;
         }
         if(_fighter.isSuperSteelBody)
         {
            _fighter.useEnergy(param1.getDamage() * 0.2);
         }
         else if(param1.isBreakDef)
         {
            _fighter.useEnergy(param1.getDamage());
         }
         else
         {
            _fighter.useEnergy(param1.getDamage() * 0.4);
         }
         _fighter.isAllowBeHit = false;
         if(!_fighter.isSuperSteelBody)
         {
            _loc5_ = param1.hitx;
            _loc6_ = param1.hity;
            if(param1.owner)
            {
               _loc5_ *= param1.owner.direct;
            }
            _loc4_ = _loc5_;
            _loc3_ = _loc6_;
            if(param1.isBreakDef)
            {
               _loc4_ *= 2;
               _loc3_ *= 2;
            }
            _fighter.setVec2(_loc4_,_loc3_,Math.abs(_loc5_ * 0.1),Math.abs(_loc6_ * 0.1));
         }
         if(param1 && param2)
         {
            if(allowBvnVisualEffect())
            {
               EffectCtrl.I.doSteelHitEffect(param1,param2,_fighter);
            }
         }
      }
      
      private function doHurt(param1:HitVO, param2:Rectangle) : void
      {
         if(param1 && param2)
         {
            if(allowBvnVisualEffect())
            {
               EffectCtrl.I.doHitEffect(param1,param2,_fighter);
            }
         }
         _fighter.hurtHit = param1;
         _fighter.loseHp(param1.getDamage());
         _fighter.isAllowBeHit = false;
         _beHitGap = 4;
         if(_fighter.isAlive && GameLogic.checkFighterDie(_fighter))
         {
            _fighter.isAlive = false;
            FighterEventDispatcher.dispatchEvent(_fighter,"DIE");
         }
         if(!_fighter.isAlive || !param1.isWeakHit())
         {
            doHurtAnimate(param1,param2);
         }
      }
      
      private function doHurtAnimate(hitVO:HitVO, hitRect:Rectangle) : void
      {
         effectCtrler.endShake();
         _fighter.isApplyG = true;
         _isDefense = false;
         var hitX:Number = hitVO.hitx;
         var hitY:Number = hitVO.hity;
         if(_fighter.mosouEnemyData && !_fighter.mosouEnemyData.isBoss)
         {
            if(!_fighter.isAlive)
            {
               if(hitY > 0)
               {
                  hitY += Math.random() * 3;
               }
               else
               {
                  hitY -= 3 + Math.random() * 3;
               }
               hitX += 2 + Math.random() * 3;
            }
         }
         if(hitVO.owner)
         {
            hitX *= hitVO.owner.direct;
         }
         if(_fighter.isInAir)
         {
            if(hitY <= 0)
            {
               hitY -= 3;
            }
         }
         else if(hitY < 0)
         {
            hitY -= 6;
            _isTouchFloor = false;
         }
         _action.clearState();
         _doingAirAction = null;
         _doingAction = null;
         setSteelBody(false);
         if(hitVO.hurtType == 0)
         {
            _action.isHurting = true;
            _hurtHoldFrame = GameConfig.calcHurtHoldFrame(hitVO.hurtTime);
            if(hitVO.hitType == 11)
            {
               _mc.goFrame("被打",false);
            }
            else
            {
               _mc.goFrame("被打",true,7);
            }
            _fighter.actionState = 21;
            _fighter.setVelocity(hitX,hitY);
            _fighter.setDamping(0.1,0.5);
            if(_fighter.isAlive && HitType.isHeavy(hitVO.hitType))
            {
               _fighter.getCtrler().getVoiceCtrl().playVoice(0,0.5);
            }
         }
         if(hitVO.hurtType == 1)
         {
            _action.isHurtFlying = true;
            _fighter.actionState = 22;
            _hurtDownFrame = 0;
            _mc.playHurtFly(hitX,hitY);
            if(_fighter.isAlive)
            {
               _fighter.getCtrler().getVoiceCtrl().playVoice(1,1);
            }
            else
            {
               _fighter.getCtrler().getVoiceCtrl().playVoice(2,1);
            }
         }
         _isFalling = false;
         FighterEventDispatcher.dispatchEvent(_fighter,"HURT");
      }
      
      private function renderHurt() : void
      {
         if(!_fighter.isAlive)
         {
            return;
         }
         renderHurtBreak();
      }
      
      private function renderHurtBreak() : void
      {
         if(!_actionCtrler.specailSkill())
         {
            return;
         }
         if(!_fighter.hasEnergy(50))
         {
            return;
         }
         if(_fighter.qi < 100)
         {
            return;
         }
         var _loc2_:Boolean = _fighter.getLastHurtHitVO().isBisha();
         if(_loc2_)
         {
            return;
         }
         var _loc3_:Boolean = _fighter.hurtBreakHit();
         if(_loc3_)
         {
            return;
         }
         var _loc1_:int = _fighter.currentHurtDamage();
         if(_loc1_ > 210)
         {
            return;
         }
         _fighter.useQi(100);
         _fighter.useEnergy(100);
         if(_fighter.data.comicType == 1)
         {
            _fighter.replaceSkill();
         }
         else
         {
            _fighter.energyExplode();
         }
         dispatchTrainingInput(FighterInputCmd.ASSIST,true);
         FighterEventDispatcher.dispatchEvent(_fighter,"HURT_RESUME");
      }
      
      private function renderHurtAnimate() : void
      {
         var _loc1_:Point = null;
         if(_hurtHoldFrame-- <= 0)
         {
            if(!_fighter.isAlive)
            {
               _action.clearState();
               if(_fighter.isInAir)
               {
                  _loc1_ = _fighter.getVec2();
                  hurtFly(_loc1_.x,_loc1_.y);
               }
               else
               {
                  _mc.playHurtDown();
               }
               _fighter.getCtrler().getVoiceCtrl().playVoice(2,1);
            }
            else
            {
               hurtResume();
            }
         }
      }
      
      private function hurtResume() : void
      {
         if(!_fighter.isInAir && !_isTouchFloor)
         {
            _isTouchFloor = true;
         }
         idle();
         FighterEventDispatcher.dispatchEvent(_fighter,"HURT_RESUME");
      }
      
      private function renderBeHitGap() : void
      {
         if(_beHitGap > 0)
         {
            if(--_beHitGap <= 0)
            {
               _fighter.isAllowBeHit = true;
            }
         }
      }
      
      private function doDefenseHit(hitVO:HitVO, hitRect:Rectangle) : void
      {
         _fighter.loseHp(hitVO.getDamage() * 0.05);
         if(_fighter.isAlive && GameLogic.checkFighterDie(_fighter))
         {
            FighterEventDispatcher.dispatchEvent(_fighter,"DIE");
            _fighter.isAlive = false;
            doHurt(hitVO,hitRect);
            return;
         }
         _fighter.defenseHit = hitVO;
         var defEnergy:int = 0;
         if(hitVO.isBreakDef)
         {
            defEnergy = _fighter.energyMax * GameConfig.ENERGY_LOSE_DEFENSE_BREAK_RATE;
         }
         else
         {
            defEnergy = hitVO.getDamage() / 5;
            if(defEnergy > 50)
            {
               defEnergy = 50;
            }
         }
         if(!_fighter.hasEnergy(defEnergy,false))
         {
            _fighter.useEnergy(defEnergy);
            doBreakDefense(hitVO,hitRect);
            return;
         }
         _fighter.useEnergy(defEnergy);
         _beHitGap = 4;
         _fighter.isAllowBeHit = false;
         var hitx:Number = hitVO.hitx;
         if(hitVO.owner)
         {
            hitx *= hitVO.owner.direct;
         }
         _action.isDefenseHiting = true;
         if(hitVO.hurtType == 0)
         {
            _defenseHoldFrame = GameConfig.calcDefenseHoldFrame(hitVO.hurtTime,false);
         }
         else
         {
            _defenseHoldFrame = GameConfig.calcDefenseHoldFrame(hitVO.hurtTime,true);
            _beHitGap = 8;
         }
         _fighter.setVelocity(hitx,0);
         _fighter.setDamping(1,0);
         if(hitVO && hitRect)
         {
            if(allowBvnVisualEffect())
            {
               EffectCtrl.I.doDefenseEffect(hitVO,hitRect,_fighter.defenseType);
            }
         }
      }
      
      private function doBreakDefense(param1:HitVO, param2:Rectangle) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         _fighter.loseHp(param1.getDamage() / 10);
         if(param1.hurtType == 0)
         {
            _beHitGap = 4;
         }
         if(param1.hurtType == 1)
         {
            _beHitGap = 10;
         }
         _fighter.isAllowBeHit = false;
         _fighter.energyOverLoad = false;
         _isDefense = false;
         var _loc3_:Number = param1.hitx;
         if(_loc3_ < 5)
         {
            _loc3_ = 5;
         }
         if(_loc3_ > 10)
         {
            _loc3_ = 10;
         }
         if(param1.owner)
         {
            _loc3_ *= param1.owner.direct;
         }
         _action.clearState();
         _action.isHurting = true;
         _hurtHoldFrame = GameConfig.calcBreakDefenseHoldFrame();
         _mc.goFrame("被打",true,7);
         _fighter.actionState = 21;
         _fighter.setVelocity(_loc3_);
         _fighter.setDamping(0.1);
         if(param1 && param2)
         {
            _loc4_ = param2.x + param2.width / 2;
            _loc5_ = param2.y + param2.height / 2;
            if(allowBvnVisualEffect())
            {
               EffectCtrl.I.doDefenseEffect(param1,param2,_fighter.defenseType);
               EffectCtrl.I.doEffectById("break_def",_loc4_,_loc5_,_fighter.direct);
            }
         }
      }
      
      private function renderDefensHiting() : void
      {
         if(_defenseHoldFrame > 0)
         {
            _defenseHoldFrame--;
         }
         else if(_fighter.getVecX() == 0)
         {
            _action.isDefenseHiting = false;
         }
      }
      
      private function renderCheckTargetHit() : void
      {
         var _loc2_:int = 0;
         var _loc4_:Rectangle = null;
         var _loc3_:String = _action.hitTargetChecker;
         if(!_loc3_)
         {
            return;
         }
         var _loc1_:Rectangle = _fighter.getCtrler().getHitCheckRect(_loc3_);
         if(!_loc1_)
         {
            return;
         }
         var _loc5_:Vector.<IGameSprite> = _fighter.getTargets();
         if(!_loc5_)
         {
            return;
         }
         while(_loc2_ < _loc5_.length)
         {
            if(_loc5_[_loc2_] is FighterMain)
            {
               _loc4_ = _loc5_[_loc2_].getBodyArea();
               if(_loc4_ && _loc1_.intersects(_loc4_))
               {
                  doAction(_action.hitTarget);
               }
            }
            _loc2_++;
         }
      }
      
      private function allowCatch() : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc5_:IGameSprite = _fighter.getCurrentTarget();
         if(!_loc5_)
         {
            return false;
         }
         if(_loc5_ is FighterMain)
         {
            if((_loc5_ as FighterMain).actionState == 21)
            {
               return false;
            }
         }
         var _loc4_:Rectangle = _loc5_.getBodyArea();
         var _loc3_:Rectangle = _fighter.getBodyArea();
         if(!_loc4_ || !_loc3_)
         {
            return false;
         }
         var _loc1_:Number = Math.abs(_fighter.y - _loc5_.y);
         if(_loc3_.x < _loc4_.x)
         {
            if(_fighter.direct < 0)
            {
               return false;
            }
            _loc2_ = _loc4_.x - (_loc3_.x + _loc3_.width);
         }
         else
         {
            if(_fighter.direct > 0)
            {
               return false;
            }
            _loc2_ = _loc3_.x - (_loc4_.x + _loc4_.width);
         }
         return _loc2_ < 2 && _loc1_ < 1;
      }
      
      private function doHurtDownJump() : void
      {
         if(_doingAction == "起身")
         {
            return;
         }
         if(_fighter.currentHurtDamage() > 240)
         {
            return;
         }
         if(!_fighter.hasEnergy(30))
         {
            return;
         }
         _mc.stopHurtFly();
         _fighter.useEnergy(30);
         var vecX:Number = _fighter.getVecX();
         doAction("起身");
         _fighter.isAllowBeHit = false;
         _fighter.setVelocity(vecX);
         _fighter.setDamping(vecX * 0.1, GameConfig.HURT_DOWN_JUMP_DAMPING);
         FighterEventDispatcher.dispatchEvent(_fighter,"HURT_RESUME");
      }
      
      public function sayIntro() : void
      {
         _fighter.actionState = 60;
         _mc.goFrame("\xe5\xbc\x80\xe5\x9c\xba");
      }
      
      public function doWin() : void
      {
         _fighter.actionState = 61;
         _mc.goFrame("胜利");
      }
      
      public function doLose() : void
      {
         _fighter.actionState = 62;
         _mc.goFrame("失败");
      }
      
      private function doGhostStep() : void
      {
         if(startGhostStep())
         {
            move(8,0);
            _mc.goFrame("走",true);
            _ghostType = 0;
            dispatchTrainingInput(FighterInputCmd.GHOST_DASH_S);
         }
      }
      
      private function doGhostJump() : void
      {
         if(startGhostStep())
         {
            move(0,-12);
            damping(0,0.1);
            _mc.goFrame("跳",false);
            _action.jumpTimes--;
            _ghostType = 1;
            dispatchTrainingInput(FighterInputCmd.GHOST_DASH_W);
         }
      }
      
      private function doGhostJumpDown() : void
      {
         if(startGhostStep())
         {
            move(0,15);
            _mc.goFrame("落",false);
            _ghostType = 2;
            dispatchTrainingInput(FighterInputCmd.GHOST_DASH_S);
         }
      }
      
      private function startGhostStep() : Boolean
      {
         if(_fighter.qi < 60)
         {
            return false;
         }
         if(!_fighter.hasEnergy(80,true))
         {
            return false;
         }
         _fighter.useQi(60);
         _fighter.useEnergy(80);
         _fighter.getCtrler().setDirectToTarget();
         _ghostStepIng = true;
         _ghostStepFrame = 30 * 0.4;
         _fighter.isAllowBeHit = false;
         _fighter.isCross = true;
         if(allowBvnVisualEffect())
         {
            effectCtrler.ghostStep();
         }
         return true;
      }
      
      private function renderGhostStep() : void
      {
         var _loc1_:Number = NaN;
         if(_ghostStepFrame-- <= 0)
         {
            if(_ghostType == 1)
            {
               _loc1_ = _fighter.getVecY();
               _action.isJumping = false;
               endGhostStep();
               _fighter.setVelocity(0,_loc1_);
               _fighter.setDamping(0,-_loc1_ / 10);
               setAirMove(true);
               return;
            }
            endGhostStep();
         }
         if(_ghostType == 2)
         {
            if(GameLogic.isTouchBottomFloor(_fighter))
            {
               endGhostStep();
            }
         }
      }
      
      private function endGhostStep() : void
      {
         _ghostStepIng = false;
         if(allowBvnVisualEffect())
         {
            effectCtrler.endGhostStep();
         }
         _fighter.getCtrler().setDirectToTarget();
         idle();
      }

      public function dispatchTrainingInput(inputText:String, highlight:Boolean = false) : void
      {
         if(!inputText)
         {
            return;
         }
         var actEvt:FighterEvent = new FighterEvent("DO_ACTION");
         actEvt.params = {"input": inputText, "highlight": highlight};
         _fighter.dispatchEvent(actEvt);
      }
   }
}
