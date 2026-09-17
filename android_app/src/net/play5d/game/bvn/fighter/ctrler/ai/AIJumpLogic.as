package net.play5d.game.bvn.fighter.ctrler.ai
{
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class AIJumpLogic
   {
      public function AIJumpLogic()
      {
         super();
      }
      
      public static function buildJumpRateMap(level:int, isConting:Boolean, fighter:FighterMain, target:FighterMain, canAttackAir:Boolean, canSkillAir:Boolean, targetOpen:Boolean, targetHasShortHurt:Boolean) : Object
      {
         var rateMap:Object = {};
         if(isConting)
         {
            rateMap.defult = [0.3,0.8,1.6,1.6,1.2,0.8];
            rateMap[21] = [0.2,0.6,1.2,1.8,2.4,3];
         }
         else if(canAttackAir && targetOpen && !targetHasShortHurt)
         {
            rateMap.defult = [0.05,0.2,0.7,1.8,1.4,1];
         }
         else if(canSkillAir && targetOpen && !targetHasShortHurt)
         {
            rateMap.defult = [0.05,0.2,0.8,2,1.8,1.4];
         }
         else if(fighter.y > target.y + 300 || fighter.y > target.y + 50 && !target.isInAir)
         {
            rateMap.defult = [2,3,4,5,6,6];
            rateMap[12] = rateMap[13] = [2,1,0,0,0,0];
         }
         else
         {
            rateMap.defult = [0.01,0,0,0,0,0];
            rateMap[12] = rateMap[13] = [0.02,0,0,0,0,0];
         }
         applyDifficultyBias(rateMap,level,isConting);
         return rateMap;
      }
      
      public static function buildJumpDownRateMap(level:int, fighter:FighterMain, target:FighterMain) : Object
      {
         var rateMap:Object = {};
         if(fighter.y < target.y - 50)
         {
            rateMap.defult = [2,3,4,5,6,6];
            rateMap[12] = rateMap[13] = [2,1,0,0,0,0];
         }
         else
         {
            rateMap.defult = [0.01,0,0,0,0,0];
            rateMap[12] = rateMap[13] = [0.02,0,0,0,0,0];
         }
         applyDifficultyBias(rateMap,level,false);
         return rateMap;
      }
      
      private static function applyDifficultyBias(rateMap:Object, level:int, isConting:Boolean) : void
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            rateMap.defult = scaleRate(rateMap.defult,0.72,0.05);
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            rateMap.defult = scaleRate(rateMap.defult,0.9,0);
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,0.78,isConting ? 0.02 : 0);
            if(rateMap[21])
            {
               rateMap[21] = scaleRate(rateMap[21],0.82,0.02);
            }
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.VERY_HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,0.62,isConting ? 0 : 0);
            if(rateMap[21])
            {
               rateMap[21] = scaleRate(rateMap[21],0.66,0);
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
