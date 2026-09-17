package net.play5d.game.bvn.fighter
{
   import net.play5d.game.bvn.GameConfig;
   
   public class FighterAction
   {
      
      public var isMoving:Boolean;
      
      public var isJumping:Boolean;
      
      public var isDefensing:Boolean;
      
      public var isDashing:Boolean;
      
      public var isHurting:Boolean;
      
      public var isHurtFlying:Boolean;
      
      public var isDefenseHiting:Boolean;
      
      public var isFlying:Boolean = false;
      
      public var airMove:Boolean;
      
      public var touchFloor:String;
      
      public var touchFloorBreakAct:Boolean = false;
      
      public var hitTarget:String;
      
      public var hitTargetChecker:String;
      
      public var touchSide:String;
      
      public var unHolding:String;
      
      public var unHoldingChecker:Function;
      
      public var moveLeft:String;
      
      public var moveRight:String;
      
      public var defense:String;
      
      public var jump:String;
      
      public var jumpQuick:String;
      
      public var jumpDown:String;
      
      public var dash:String;
      
      public var attack:String;
      
      public var skill1:String;
      
      public var skill2:String;
      
      public var zhao1:String;
      
      public var zhao2:String;
      
      public var zhao3:String;
      
      public var catch1:String;
      
      public var catch2:String;
      
      public var bisha:String;
      
      public var bishaUP:String;
      
      public var bishaSUPER:String;
      
      public var hurtAction:String;
      
      public var waiKai:String;
      
      public var waiKaiW:String;
      
      public var waiKaiS:String;
      
      public var attackAIR:String;
      
      public var skillAIR:String;
      
      public var bishaAIR:String;
      
      public var airHitTimes:int;
      
      public var jumpTimes:int;
      
      public var bishaQi:int = 100;
      
      public var bishaUPQi:int = 100;
      
      public var bishaSUPERQi:int = 300;
      
      public var bishaAIRQi:int = 100;
      
      private var _cdObj:Object = {};
      
      public var specialHurtBreak:Object;
      
      public function FighterAction()
      {
         super();
      }
      
      public function clear() : void
      {
         clearState();
         clearAction();
      }
      
      public function clearState() : void
      {
         isMoving = false;
         isJumping = false;
         isDefensing = false;
         isDashing = false;
         isHurting = false;
         isHurtFlying = false;
         isDefenseHiting = false;
         touchFloorBreakAct = false;
         isFlying = false;
      }
      
      public function clearAction() : void
      {
         hitTarget = null;
         hitTargetChecker = null;
         touchSide = null;
         moveLeft = null;
         moveRight = null;
         defense = null;
         jump = null;
         jumpQuick = null;
         jumpDown = null;
         dash = null;
         attack = null;
         skill1 = null;
         skill2 = null;
         zhao1 = null;
         zhao2 = null;
         zhao3 = null;
         catch1 = null;
         catch2 = null;
         bisha = null;
         bishaUP = null;
         bishaSUPER = null;
         bishaQi = 100;
         bishaUPQi = 100;
         bishaAIRQi = 100;
         bishaSUPERQi = 300;
         hurtAction = null;
         waiKai = null;
         waiKaiW = null;
         waiKaiS = null;
         attackAIR = null;
         skillAIR = null;
         bishaAIR = null;
         touchFloor = null;
         airMove = false;
      }
      
      public function render() : void
      {
         for(var i:String in _cdObj)
         {
            var v:int = _cdObj[i];
            if((_cdObj[i] = --v) <= 0)
            {
               delete _cdObj[i];
            }
         }
      }
      
      public function setCD(param1:String, param2:int) : void
      {
         _cdObj[param1] = param2 / GameConfig.FPS_GAME;
      }
      
      public function CDOK(param1:String) : Boolean
      {
         return !_cdObj[param1];
      }
   }
}

