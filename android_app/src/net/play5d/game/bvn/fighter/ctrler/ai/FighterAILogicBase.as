package net.play5d.game.bvn.fighter.ctrler.ai
{
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.fighter.FighterAction;
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.fighter.FighterMC;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class FighterAILogicBase
   {
      
      protected var AILevel:int;
      
      private var _AImain:MovieClip;
      
      protected var _fighter:FighterMain;
      
      protected var _fighterAction:FighterAction;
      
      protected var _target:IGameSprite;
      
      protected var _targetFighter:FighterMain;
      
      protected var _isConting:Boolean;
      
      private var _breakActCache:Object = {};
      
      private var _hitDownActCache:Object = {};
      
      private var _contOrder:Array = [];
      
      protected var _attackAction:Object = {
         "招1":"zh1mian",
         "砍1":"kanmian",
         "招2":"zh2mian",
         "招3":"zh3mian",
         "砍技1":"kj1mian",
         "砍技2":"kj2mian",
         "跳砍":"tzmian",
         "跳招":"tkanmian"
      };
      
      protected var _aiProfile:FighterAIProfile;

      public function FighterAILogicBase(aiLevel:int, fighter:FighterMain)
      {
         super();
         this.AILevel = aiLevel;
         _fighter = fighter;
         _aiProfile = FighterAIProfileLoader.getProfile(fighter);
      }
      
      protected static function mergeRateObject(targetRates:Object, sourceRates:Object) : void
      {
         var rateCount:int = 0;
         var rateIndex:int = 0;
         for(var rateKey:String in sourceRates)
         {
            if(targetRates[rateKey] == undefined)
            {
               targetRates[rateKey] = sourceRates[rateKey];
            }
            else
            {
               rateCount = int(sourceRates[rateKey].length);
               rateIndex = 0;
               while(rateIndex < rateCount)
               {
                  if(targetRates[rateKey][rateIndex] < sourceRates[rateKey][rateIndex])
                  {
                     targetRates[rateKey][rateIndex] = sourceRates[rateKey][rateIndex];
                  }
                  rateIndex++;
               }
            }
         }
      }
      
      public function destory() : void
      {
         _fighter = null;
         _fighterAction = null;
         _target = null;
         _targetFighter = null;
         _breakActCache = null;
         _hitDownActCache = null;
         _AImain = null;
         _attackAction = null;
         _aiProfile = null;
      }
      
      protected function addContOrder(orderId:String, orderPriority:int) : void
      {
         var orderIndex:int = findContOrderIndex(orderId);
         var randomOrderOffset:int = getOrderRandomOffset();
         if(orderIndex != -1)
         {
            _contOrder[orderIndex].order = orderPriority;
         }
         else
         {
            _contOrder.push({
               "id":orderId,
               "order":orderPriority + randomOrderOffset
            });
         }
      }

      private function getOrderRandomOffset() : int
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            return int(Math.floor(Math.random() * 12));
         }
         if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            return int(Math.floor(Math.random() * 8));
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            return int(Math.floor(Math.random() * 4));
         }
         return int(Math.floor(Math.random() * 2));
      }

      private function findContOrderIndex(orderId:String) : int
      {
         var orderIndex:int = 0;
         while(orderIndex < _contOrder.length)
         {
            if(_contOrder[orderIndex].id == orderId)
            {
               return orderIndex;
            }
            orderIndex++;
         }
         return -1;
      }
      
      protected function updateConting() : void
      {
         _isConting = FighterActionState.isAttacking(_fighter.actionState);
      }
      
      public function render() : void
      {
         _target = _fighter.getCurrentTarget();
         _targetFighter = _target as FighterMain;
         updateConting();
         if(_fighterAction == null)
         {
            _fighterAction = _fighter.getCtrler().getMcCtrl().getAction();
         }
         updateActionAI();
         updateContOrder();
      }
      
      private function updateContOrder() : void
      {
         var orderIndex:int = 0;
         var orderId:String = null;
         if(_contOrder.length < 1)
         {
            return;
         }
         _contOrder.sortOn("order",2 | 0x10);
         orderIndex = 1;
         while(orderIndex < _contOrder.length)
         {
            orderId = String(_contOrder[orderIndex].id);
            this[orderId] = false;
            orderIndex++;
         }
         _contOrder = [];
      }
      
      protected function updateActionAI() : void
      {
      }
      
      protected function getAIByFighterState(rateMapByTargetState:Object) : Boolean
      {
         var defaultRates:Array = rateMapByTargetState.defult;
         var targetActionState:int = this._targetFighter ? int(this._targetFighter.actionState) : -1;
         var selectedRates:Array = Boolean(rateMapByTargetState) && Boolean(rateMapByTargetState[targetActionState]) ? rateMapByTargetState[targetActionState] : defaultRates;
         return getAIResult(selectedRates[0],selectedRates[1],selectedRates[2],selectedRates[3],selectedRates[4],selectedRates[5]);
      }
      
      protected function getAIResult(easyRate:Number, normalRate:Number, hardRate:Number, veryHardRate:Number, legacyRate5:Number, legacyRate6:Number) : Boolean
      {
         var randomRoll:Number = Math.random() * 10;
         var safeEasyRate:Number = isNaN(easyRate) ? 0 : easyRate;
         var safeNormalRate:Number = isNaN(normalRate) ? 0 : normalRate;
         var safeHardRate:Number = isNaN(hardRate) ? 0 : hardRate;
         var safeVeryHardRate:Number = isNaN(veryHardRate) ? 0 : veryHardRate;
         var safeLegacyRate5:Number = isNaN(legacyRate5) ? 0 : legacyRate5;
         var safeLegacyRate6:Number = isNaN(legacyRate6) ? 0 : legacyRate6;
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(AILevel);
         var selectedRate:Number = 0;
         switch(normalizedLevel)
         {
            case AIDifficultyProfile.EASY:
               selectedRate = safeEasyRate * 0.8;
               break;
            case AIDifficultyProfile.NORMAL:
               selectedRate = safeNormalRate;
               break;
            case AIDifficultyProfile.HARD:
               selectedRate = Math.max(safeHardRate,safeNormalRate + 0.2);
               break;
            case AIDifficultyProfile.VERY_HARD:
            default:
               selectedRate = Math.max(safeVeryHardRate,safeLegacyRate5,safeLegacyRate6);
               if(selectedRate > 0.2)
               {
                  selectedRate += 0.6;
               }
         }
         if(selectedRate < 0)
         {
            selectedRate = 0;
         }
         else if(selectedRate > 10)
         {
            selectedRate = 10;
         }
         return randomRoll < selectedRate;
      }
      
      protected function getTargetDistance(targetSprite:IGameSprite) : Point
      {
         var distanceX:Number = Math.abs(targetSprite.x - _fighter.x);
         var distanceY:Number = Math.abs(targetSprite.y - _fighter.y);
         return new Point(distanceX,distanceY);
      }
      
      final public function targetInDistance(targetSprite:IGameSprite, maxDistanceX:Number, maxDistanceY:Number) : Boolean
      {
         var targetDistance:Point = getTargetDistance(targetSprite);
         return targetDistance.x <= maxDistanceX && targetDistance.y <= maxDistanceY;
      }
      
      final public function targetInRange(hitRangeName:String) : Boolean
      {
         var targetBodyArea:Rectangle = _target.getBodyArea();
         if(targetBodyArea == null)
         {
            return false;
         }
         var attackHitRange:Rectangle = _fighter.getHitRange(hitRangeName);
         if(attackHitRange)
         {
            return targetBodyArea.intersection(attackHitRange).isEmpty() == false;
         }
         return checkTargetInRangeFallback(hitRangeName);
      }

      protected function checkTargetInRangeFallback(hitRangeName:String) : Boolean
      {
         if(_target == null || _fighter == null)
         {
            return false;
         }
         var targetDistance:Point = getTargetDistance(_target);
         var isInFront:Boolean = (_target.x - _fighter.x) * _fighter.direct >= -20;
         if(!isInFront)
         {
            return false;
         }
         if(_aiProfile != null)
         {
            var customRange:Array = _aiProfile.getRange(hitRangeName);
            if(customRange != null && customRange.length >= 2)
            {
               var minDistanceX:Number = Number(customRange[0]);
               var maxDistanceX:Number = Number(customRange[1]);
               return targetDistance.x >= minDistanceX && targetDistance.x <= maxDistanceX && targetDistance.y <= 95;
            }
         }
         switch(hitRangeName)
         {
            case "kanmian":
               return targetDistance.x <= 130 && targetDistance.y <= 65;
            case "tkanmian":
               return targetDistance.x <= 135 && targetDistance.y <= 95;
            case "kj1mian":
            case "kj2mian":
            case "zh1mian":
            case "zh2mian":
               return targetDistance.x <= 210 && targetDistance.y <= 85;
            case "zh3mian":
               return targetDistance.x <= 235 && targetDistance.y <= 90;
            case "tzmian":
               return targetDistance.x <= 190 && targetDistance.y <= 115;
            case "bsmian":
            case "cbsmian":
               return targetDistance.x <= 250 && targetDistance.y <= 95;
            case "sbsmian":
               return targetDistance.x <= 190 && targetDistance.y <= 140;
            case "kbsmian":
               return targetDistance.x <= 210 && targetDistance.y <= 130;
            default:
               return targetDistance.x <= 165 && targetDistance.y <= 80;
         }
      }
      
      protected function get AImain() : MovieClip
      {
         var fighterMc:FighterMC = null;
         if(_AImain == null)
         {
            fighterMc = _fighter.getMC();
            if(fighterMc == null)
            {
               return null;
            }
            _AImain = fighterMc.getChildByName("AImain") as MovieClip;
         }
         return _AImain;
      }
      
      protected function setAIByMain(rateMap:Object, actionName:String) : void
      {
         var aiMainClip:MovieClip = AImain;
         if(aiMainClip == null)
         {
            return;
         }
         var getActionAIFunction:Function = aiMainClip.getActionAI as Function;
         if(getActionAIFunction == null)
         {
            return;
         }
         var mainRateOverrides:Object = getActionAIFunction(actionName);
         if(mainRateOverrides != null)
         {
            for(var overrideKey:Object in mainRateOverrides)
            {
               rateMap[overrideKey] = mainRateOverrides[overrideKey];
            }
         }
      }
      
      protected function isBreakAct(actionId:String) : Boolean
      {
         if(_breakActCache[actionId] != undefined)
         {
            return _breakActCache[actionId];
         }
         var actionHitVOList:Vector.<HitVO> = _fighter.getCtrler().hitModel.getHitVOLike(actionId);
         for each(var hitVO:HitVO in actionHitVOList)
         {
            if(hitVO.isBreakDef)
            {
               _breakActCache[actionId] = true;
               return true;
            }
         }
         _breakActCache[actionId] = false;
         return false;
      }
      
      protected function isHitDownAct(actionId:String) : Boolean
      {
         if(_hitDownActCache[actionId] != undefined)
         {
            return _hitDownActCache[actionId];
         }
         var actionHitVOList:Vector.<HitVO> = _fighter.getCtrler().hitModel.getHitVOLike(actionId);
         for each(var hitVO:HitVO in actionHitVOList)
         {
            if(hitVO.hurtType == 1)
            {
               _hitDownActCache[actionId] = true;
               return true;
            }
         }
         _hitDownActCache[actionId] = false;
         return false;
      }
      
      protected function targetCanBeHit() : Boolean
      {
         if(_target == null)
         {
            return false;
         }
         if(_targetFighter != null)
         {
            if(!_targetFighter.isAlive)
            {
               return false;
            }
            if(_targetFighter.actionState == 21)
            {
               return true;
            }
            if(_targetFighter.actionState == 22 && _targetFighter.isAllowBeHit)
            {
               return true;
            }
            return _targetFighter.isAllowBeHit;
         }
         return _target.getBodyArea() != null;
      }
   }
}
