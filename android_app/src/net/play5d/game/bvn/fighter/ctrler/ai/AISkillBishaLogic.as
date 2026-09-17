package net.play5d.game.bvn.fighter.ctrler.ai
{
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class AISkillBishaLogic
   {
      public function AISkillBishaLogic()
      {
         super();
      }
      
      public static function buildSkillRateMap(level:int, isConting:Boolean, isBreakAct:Boolean, targetHasShortHurt:Boolean) : Object
      {
         var rateMap:Object = {};
         if(isBreakAct)
         {
            rateMap.defult = isConting ? [0.1,0.2,0.5,3,6,10] : [0,0.2,0.5,2,1,0.5];
            rateMap[20] = isConting ? [0,0.2,0.7,5,7,9] : [0.1,0.2,0.5,1,2,2];
            rateMap[21] = isConting ? [0.5,1,3,5,8,10] : [0,0.2,0.5,2,1,0.5];
         }
         else
         {
            rateMap.defult = isConting ? [0,0,0.1,1,5,10] : [0.1,0.5,1,3,2,0.2];
            rateMap[20] = [0,0,1,1,0,0.5];
            rateMap[21] = isConting ? [1,2,3,5,7,10] : [0.1,0.5,1,3,1.5,1];
         }
         rateMap[16] = [0.5,1,0.5,0,0,0];
         rateMap[10] = [0,0,0,1,1,2];
         rateMap[11] = rateMap[12] = rateMap[13] = [0,0,0,0,0.5,1];
         if(targetHasShortHurt)
         {
            rateMap[21] = [1,0.5,0.2,0,0,0];
         }
         applyDifficultyBias(rateMap,level,isConting);
         return rateMap;
      }
      
      public static function getSkillOrderBase(level:int, isHitDownAct:Boolean) : int
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            return isHitDownAct ? 50 : 72;
         }
         if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            return isHitDownAct ? 68 : 96;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            return isHitDownAct ? 88 : 122;
         }
         return isHitDownAct ? 108 : 146;
      }
      
      public static function getNormalBishaQiRequirement(level:int) : int
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            return 180;
         }
         if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            return 130;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            return 110;
         }
         return 95;
      }
      
      public static function buildBishaRateMap(level:int, isConting:Boolean, qiRequirement:int, isBreakAct:Boolean, targetHasShortHurt:Boolean) : Object
      {
         var rateMap:Object = {};
         if(qiRequirement > 200)
         {
            rateMap.defult = [0.05,0.02,0.01,0,0,0];
            rateMap[20] = [0.1,0.2,0,0,0,0];
            rateMap[21] = [0.1,0.2,0,0,0,0];
         }
         else if(isBreakAct)
         {
            rateMap.defult = isConting ? [0,0,0.5,2.6,6.2,10] : [0.2,0.4,0.9,2.6,3,3.8];
            rateMap[20] = isConting ? [0.1,0.2,0.8,3.8,8.2,9.8] : [0.2,0.4,1.4,6.8,8.8,10];
            rateMap[21] = [0.3,0.8,1.6,3.8,6.1,8.8];
         }
         else
         {
            rateMap.defult = isConting ? [0,0.1,0.8,4.8,8.8,10] : [0.3,0.7,1.4,2.8,3.2,1.2];
            rateMap[21] = [0.4,0.9,1.7,3.8,5.8,6.9];
            rateMap[14] = [0.3,0.7,1.4,3.6,4.8,4.8];
            rateMap[20] = isConting ? [0.3,0.7,1.4,3.8,2.8,1.8] : [0.3,0.7,1.4,2.6,1.8,0.9];
         }
         rateMap[15] = [0.2,0.5,0,0,0,0];
         rateMap[16] = [0.2,0.5,0,0,0,0];
         rateMap[10] = rateMap[11] = [0,0.2,0.5,2,1,0.66];
         rateMap[12] = rateMap[13] = [0,0.1,0.3,1,2,5];
         rateMap[0] = [0,0,0.1,0,0.01,0.02];
         if(targetHasShortHurt)
         {
            rateMap[21] = [1,0.5,0.2,0,0,0];
         }
         applyDifficultyBias(rateMap,level,isConting);
         return rateMap;
      }
      
      public static function shouldConfirmBisha(level:int, target:FighterMain) : Boolean
      {
         if(!target)
         {
            return false;
         }
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         var targetHpRate:Number = target.hpMax > 0 ? target.hp / target.hpMax : 1;
         var targetLowHp:Boolean = targetHpRate <= 0.45;
         var targetMidLowHp:Boolean = targetHpRate <= 0.62;
         var targetInConfirmState:Boolean = target.actionState == FighterActionState.HURT_ING || FighterActionState.isHurting(target.actionState);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            return targetLowHp || target.hurtBreakHit() || target.currentHurtDamage() > 210;
         }
         if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            return targetLowHp || target.qi < 120 || target.hurtBreakHit() || target.currentHurtDamage() > 185;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            return target.qi < 160 || target.energy < 45 && target.energyOverLoad || targetInConfirmState || targetMidLowHp || target.hurtBreakHit() || target.currentHurtDamage() > 130;
         }
         return target.qi < 200 || target.energy < 55 && target.energyOverLoad || targetInConfirmState || targetHpRate <= 0.75 || target.hurtBreakHit() || target.currentHurtDamage() > 90;
      }
      
      private static function applyDifficultyBias(rateMap:Object, level:int, isConting:Boolean) : void
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(level);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            rateMap.defult = scaleRate(rateMap.defult,0.65,0);
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,1.08,isConting ? 0.2 : 0.1);
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.VERY_HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,1.16,isConting ? 0.6 : 0.3);
            if(rateMap[20])
            {
               rateMap[20] = scaleRate(rateMap[20],1.15,0.5);
            }
            if(rateMap[21])
            {
               rateMap[21] = scaleRate(rateMap[21],1.12,0.4);
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
