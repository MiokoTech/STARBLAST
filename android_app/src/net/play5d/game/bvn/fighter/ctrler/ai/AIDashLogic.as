package net.play5d.game.bvn.fighter.ctrler.ai
{
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class AIDashLogic
   {
      public function AIDashLogic()
      {
         super();
      }
      
      public static function buildDashDecision(level:int, fighter:FighterMain, target:FighterMain, distanceX:Number, distanceY:Number, justStandUp:Boolean) : Object
      {
         var decision:Object = {};
         var rateMap:Object = {};
         var targetDirect:Number = target.x > fighter.x ? 1 : -1;
         var setOrder:Boolean = false;
         var orderBase:int = 114;
         if(fighter.actionState == 23 || justStandUp)
         {
            orderBase = 400;
            setOrder = true;
            if(distanceX <= 60)
            {
               rateMap.defult = [2,3,4,5,6,9];
            }
            else if(distanceX <= 180)
            {
               rateMap.defult = [1,2,3,4,4,4];
            }
            else
            {
               rateMap.defult = [1,2,3,2,1,0.5];
            }
            rateMap[21] = rateMap[22] = rateMap[23] = rateMap[24] = [0,0,0.1,0.5,0,0];
         }
         else if(fighter.actionState >= 10 && fighter.actionState <= 13)
         {
            rateMap.defult = [0,0,0.2,0.5,2,8];
            rateMap[21] = [0,0,0.1,0.5,0,0];
            setOrder = true;
         }
         else if(fighter.energy < 60)
         {
            if(distanceX > 250 && fighter.direct == targetDirect)
            {
               rateMap.defult = [0,0,0.1,0.5,0,0];
               rateMap[10] = rateMap[11] = [0,0.05,0.3,1,1.7,2.5];
               rateMap[12] = rateMap[13] = [0,0,0,0,0,0];
            }
            else if(distanceX < 125 && fighter.energy > 20 && !fighter.energyOverLoad && distanceY <= 75)
            {
               rateMap.defult = [0,0,0.05,1,1,1];
               rateMap[10] = rateMap[11] = [0.5,1,1.5,2.5,3,4.5];
               rateMap[12] = rateMap[13] = [0.5,1,1.5,2.5,3,4.5];
               rateMap[15] = [0,0,0.1,0.5,0,0];
               rateMap[21] = [0,0,0.1,0,0,0];
               setOrder = true;
            }
            else
            {
               rateMap.defult = [0,0,0.05,0,0,0];
               rateMap[10] = rateMap[11] = rateMap[12] = rateMap[13] = [0,0,0,0,0,0];
            }
         }
         else if(distanceX > 250 && fighter.direct == targetDirect)
         {
            rateMap.defult = [0.5,1,1.5,2.5,4,5.5];
            rateMap[10] = [0,0,0.1,3,2,1];
            rateMap[11] = [0,0,0.05,1,1.5,2];
            rateMap[12] = rateMap[13] = [0,0,0,0,0,0];
            rateMap[15] = [0,0,0.1,0.5,0.05,0.05];
            rateMap[21] = [0,0,0.1,0,0,0];
         }
         else if(distanceX < 125 && distanceY <= 75)
         {
            rateMap.defult = [0,0,0.05,1,1.5,2.5];
            rateMap[10] = rateMap[11] = [0.5,1,1.5,2.5,5,8];
            rateMap[12] = rateMap[13] = [0.5,1,1.5,2.5,6,9];
            rateMap[15] = [0,0,0.1,0.5,0,0];
            rateMap[21] = [0,0,0.1,0,0,0];
            setOrder = true;
         }
         else
         {
            rateMap.defult = [0,0,0.05,0.1,0,0];
            rateMap[10] = rateMap[11] = rateMap[12] = rateMap[13] = [0,0,0,0,0,0];
         }
         applyDifficultyBias(rateMap,level,setOrder);
         decision.rateMap = rateMap;
         decision.setOrder = setOrder;
         decision.orderBase = orderBase;
         return decision;
      }
      
      private static function applyDifficultyBias(rateMap:Object, level:int, setOrder:Boolean) : void
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            rateMap.defult = scaleRate(rateMap.defult,0.7,0);
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,1.1,setOrder ? 0.2 : 0);
            if(rateMap[10])
            {
               rateMap[10] = scaleRate(rateMap[10],1.08,0.2);
            }
            if(rateMap[11])
            {
               rateMap[11] = scaleRate(rateMap[11],1.08,0.2);
            }
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.VERY_HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,1.18,setOrder ? 0.5 : 0.2);
            if(rateMap[10])
            {
               rateMap[10] = scaleRate(rateMap[10],1.15,0.5);
            }
            if(rateMap[11])
            {
               rateMap[11] = scaleRate(rateMap[11],1.15,0.5);
            }
            if(rateMap[12])
            {
               rateMap[12] = scaleRate(rateMap[12],1.1,0.3);
            }
            if(rateMap[13])
            {
               rateMap[13] = scaleRate(rateMap[13],1.1,0.3);
            }
         }
      }
      
      private static function scaleRate(sourceRate:Array, multiplier:Number, offset:Number) : Array
      {
         var outputRate:Array = [];
         var i:int = 0;
         var value:Number = 0;
         if(sourceRate == null)
         {
            return outputRate;
         }
         while(i < sourceRate.length)
         {
            value = Number(sourceRate[i]);
            if(isNaN(value))
            {
               value = 0;
            }
            value = value * multiplier + offset;
            if(value < 0)
            {
               value = 0;
            }
            else if(value > 10)
            {
               value = 10;
            }
            outputRate[i] = value;
            i++;
         }
         return outputRate;
      }
   }
}
