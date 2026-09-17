package net.play5d.game.bvn.fighter.ctrler.ai
{
   public class AITacticalSupportLogic
   {
      public function AITacticalSupportLogic()
      {
         super();
      }
      
      public static function buildCatchRateMaps(level:int, justStandUp:Boolean, distanceX:Number) : Object
      {
         var catch1Rate:Object = {};
         var catch2Rate:Object = {};
         if(distanceX < 50)
         {
            if(justStandUp)
            {
               catch2Rate.defult = [0,0.5,1,1,0.5,0.1];
               catch2Rate[20] = catch2Rate[40] = [1,2,3,4,3,2];
               catch1Rate.defult = [0,0.5,1,1,1.5,2];
               catch1Rate[20] = catch1Rate[40] = [1,2,4,5,7,10];
            }
            else
            {
               catch2Rate.defult = [0,0.5,1,3,1.5,0.5];
               catch2Rate[20] = catch2Rate[40] = [1,2,3,2,1,0.5];
               catch1Rate.defult = [0,0.5,1,3,5,8];
               catch1Rate[20] = catch1Rate[40] = [1,2,4,5,7,10];
            }
         }
         else
         {
            catch2Rate.defult = [0,0.5,1,0,0,0];
            catch2Rate[20] = [1,2,3,4,3,2];
            catch1Rate.defult = [0,0.5,1,0,0,0];
            catch1Rate[20] = [1,2,3,4,3,2];
         }
         catch2Rate[16] = catch2Rate[21] = [0.2,0.1,0,0,0,0];
         catch1Rate[16] = catch1Rate[21] = [0.2,0.1,0,0,0,0];
         applyDifficultyBias(catch1Rate,level,0.15);
         applyDifficultyBias(catch2Rate,level,0.05);
         return {
            "catch1":catch1Rate,
            "catch2":catch2Rate
         };
      }
      
      public static function buildAssistRateMap(level:int, distanceX:Number) : Object
      {
         var rateMap:Object = {};
         if(distanceX <= 250)
         {
            rateMap.defult = [0,0.5,1,1.5,2,2.5];
            rateMap[20] = [0,0.5,1,1.75,2.5,3.5];
            rateMap[21] = rateMap[22] = rateMap[23] = rateMap[24] = [0,0,0,0,0,0];
         }
         else
         {
            rateMap.defult = [0,0.02,0.05,0.1,0.1,0.1];
         }
         applyDifficultyBias(rateMap,level,0.1);
         return rateMap;
      }
      
      public static function buildSpecialSkillRateMap(level:int) : Object
      {
         var rateMap:Object = {};
         rateMap.defult = [0.5,2,4,7,9,9.5];
         rateMap[11] = [0.5,1.5,4,6,8,9];
         rateMap[12] = [0.5,3,6,8,9.25,9.75];
         rateMap[13] = [0.5,3,6,8,9.25,9.75];
         applyDifficultyBias(rateMap,level,0.3);
         return rateMap;
      }
      
      public static function allowGhostLogic(level:int, isConting:Boolean, actionState:int, distanceX:Number, distanceY:Number) : Boolean
      {
         if(!(isConting || actionState == 40))
         {
            return false;
         }
         if(distanceX > 100 || distanceY > 100)
         {
            return false;
         }
         if(AIDifficultyProfile.normalizeLevel(level) == AIDifficultyProfile.EASY)
         {
            return Math.random() < 0.35;
         }
         return true;
      }
      
      public static function buildGhostStepRateMap(level:int, actionState:int) : Object
      {
         var rateMap:Object = {};
         rateMap.defult = [0,0,0,0.1,0.1,0.5];
         if(actionState == 40)
         {
            rateMap[0] = [0,0,0.1,0.3,0.75,1.5];
            rateMap[10] = rateMap[11] = rateMap[12] = rateMap[13] = [0,0,0.1,0.3,0.75,2];
         }
         else
         {
            rateMap[10] = rateMap[11] = rateMap[12] = rateMap[13] = [0,0,0.1,0.2,0.5,1.5];
         }
         rateMap[21] = rateMap[22] = rateMap[23] = rateMap[24] = rateMap[30] = [0,0,0,0,0,0];
         applyDifficultyBias(rateMap,level,0.2);
         return rateMap;
      }
      
      public static function buildGhostJumpRateMap(level:int, actionState:int) : Object
      {
         var rateMap:Object = {};
         rateMap.defult = [0,0,0,0.1,0.1,0.1];
         if(actionState == 40)
         {
            rateMap[10] = rateMap[11] = rateMap[12] = rateMap[13] = [0,0,0.1,0.06,0.03,0.1];
         }
         else
         {
            rateMap[10] = rateMap[11] = rateMap[12] = rateMap[13] = [0,0,0.1,0.06,0.03,0.1];
         }
         rateMap[21] = rateMap[22] = rateMap[23] = rateMap[24] = rateMap[30] = [0,0,0,0,0,0];
         applyDifficultyBias(rateMap,level,-0.05);
         return rateMap;
      }
      
      private static function applyDifficultyBias(rateMap:Object, level:int, offset:Number) : void
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            rateMap.defult = scaleRate(rateMap.defult,0.65,offset - 0.2);
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,1.08,offset + 0.1);
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.VERY_HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,1.16,offset + 0.3);
            if(rateMap[20])
            {
               rateMap[20] = scaleRate(rateMap[20],1.12,offset + 0.2);
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
