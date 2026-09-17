package net.play5d.game.bvn.fighter.ctrler.ai
{
   public class AIMoveLogic
   {
      public function AIMoveLogic()
      {
         super();
      }
      
      public static function getMoveDecisionWindow(level:int) : int
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            return 30;
         }
         if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            return 20;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            return 12;
         }
         return 8;
      }
      
      public static function getTargetSpacing(level:int, preferCatch:Boolean) : Number
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         if(preferCatch)
         {
            if(normalizedLevel == AIDifficultyProfile.EASY)
            {
               return 22;
            }
            if(normalizedLevel == AIDifficultyProfile.NORMAL)
            {
               return 15;
            }
            if(normalizedLevel == AIDifficultyProfile.HARD)
            {
               return 12;
            }
            return 8;
         }
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            return 55;
         }
         if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            return 40;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            return 32;
         }
         return 24;
      }
      
      public static function chooseHurtDownMoveType(level:int, distanceX:Number) : int
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         var sideRate:Number = 0.5;
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            sideRate = distanceX > 125 ? 0.65 : 0.55;
         }
         else if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            sideRate = distanceX > 125 ? 0.7 : 0.55;
         }
         else if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            sideRate = distanceX > 125 ? 0.8 : 0.65;
         }
         else
         {
            sideRate = distanceX > 125 ? 0.9 : 0.75;
         }
         return Math.random() < sideRate ? 2 : 1;
      }
      
      public static function getHurtDownOrbitDistance(level:int) : Number
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            return 145;
         }
         if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            return 125;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            return 105;
         }
         return 90;
      }
      
      public static function buildMoveRateMap(level:int) : Object
      {
         var rateMap:Object = {};
         rateMap.defult = [3,5,7,8,9,10];
         rateMap[10] = [2,3,4,5,6,8];
         rateMap[11] = [2,4,3,2,1,0];
         rateMap[12] = [2,1,0,0,0,0];
         rateMap[13] = [2,1,0,0,0,0];
         applyDifficultyBias(rateMap,level);
         return rateMap;
      }
      
      private static function applyDifficultyBias(rateMap:Object, level:int) : void
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            rateMap.defult = scaleRate(rateMap.defult,0.7,0);
            rateMap[10] = scaleRate(rateMap[10],0.7,0);
            rateMap[11] = scaleRate(rateMap[11],0.7,0);
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,1.08,0.2);
            rateMap[10] = scaleRate(rateMap[10],1.08,0.2);
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.VERY_HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,1.16,0.5);
            rateMap[10] = scaleRate(rateMap[10],1.14,0.5);
            rateMap[11] = scaleRate(rateMap[11],1.12,0.3);
            rateMap[12] = scaleRate(rateMap[12],1.08,0.2);
            rateMap[13] = scaleRate(rateMap[13],1.08,0.2);
         }
      }
      
      private static function scaleRate(sourceRate:Array, multiplier:Number, offset:Number) : Array
      {
         var outputRate:Array = [];
         var i:int = 0;
         var value:Number = 0;
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
