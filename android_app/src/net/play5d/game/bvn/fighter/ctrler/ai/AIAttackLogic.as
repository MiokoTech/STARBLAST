package net.play5d.game.bvn.fighter.ctrler.ai
{
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class AIAttackLogic
   {
      public function AIAttackLogic()
      {
         super();
      }
      
      public static function buildAttackRateMap(aiLevel:int, isConting:Boolean, fighter:FighterMain, targetFighter:FighterMain) : Object
      {
         var rateMap:Object = {};
         rateMap.defult = isConting ? [1,2,3,6,9,10] : [0.5,1,4,6,8,10];
         rateMap[20] = isConting ? [1,2,3,6,9,9] : [0.5,1,3,2,2,1];
         rateMap[16] = [0.5,1,1,0.5,0,0];
         rateMap[10] = [0.5,1,1,0,3,10];
         rateMap[11] = [0,0,0,0,3,10];
         rateMap[12] = rateMap[13] = [0.5,1,1,0,0,0];
         rateMap[21] = isConting ? [1,2,3,5,7,10] : [0.1,0.5,1,3,1.5,1];
         if(targetFighter && targetFighter.hurtHit && targetFighter.hurtHit.id && targetFighter.hurtHit.id.indexOf("sh") != -1 && (targetFighter.x - fighter.x) * fighter.direct <= 0)
         {
            rateMap[21] = [1,0.5,0.2,0,0,0];
         }
         else
         {
            rateMap[21] = [10,10,10,10,10,10];
         }
         applyDifficultyBias(rateMap,aiLevel,isConting);
         return rateMap;
      }
      
      public static function shouldCommitAttack(aiLevel:int, isConting:Boolean, isGroundRange:Boolean, isAirRange:Boolean, targetFighter:FighterMain) : Boolean
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(aiLevel);
         var targetIsRecovering:Boolean = targetFighter != null && targetFighter.actionState == 21;
         var targetIsOpen:Boolean = targetFighter != null && !FighterActionState.isAttacking(targetFighter.actionState) && targetFighter.isAllowBeHit;
         var targetIsWhiffing:Boolean = targetFighter != null && FighterActionState.isAttacking(targetFighter.actionState) && !targetFighter.isSteelBody;
         var targetLowEnergy:Boolean = targetFighter != null && (targetFighter.energy <= 25 || targetFighter.energyOverLoad);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            return isGroundRange || isAirRange;
         }
         if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            return isGroundRange || isAirRange || isConting && targetIsRecovering;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            return isGroundRange || isAirRange || isConting && (targetIsRecovering || targetIsOpen);
         }
         return isGroundRange || isAirRange || isConting && (targetIsRecovering || targetIsOpen || targetIsWhiffing || targetLowEnergy);
      }
      
      private static function applyDifficultyBias(rateMap:Object, aiLevel:int, isConting:Boolean) : void
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(aiLevel);
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            rateMap.defult = scaleRate(rateMap.defult,0.75,0);
            rateMap[20] = scaleRate(rateMap[20],0.75,0);
            rateMap[10] = scaleRate(rateMap[10],0.7,0);
            rateMap[11] = scaleRate(rateMap[11],0.7,0);
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,1.05,isConting ? 0.2 : 0);
            rateMap[20] = scaleRate(rateMap[20],1.08,0.2);
            rateMap[10] = scaleRate(rateMap[10],1.1,0.3);
            rateMap[11] = scaleRate(rateMap[11],1.1,0.3);
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.VERY_HARD)
         {
            rateMap.defult = scaleRate(rateMap.defult,1.12,0.5);
            rateMap[20] = scaleRate(rateMap[20],1.15,0.6);
            rateMap[10] = scaleRate(rateMap[10],1.15,0.8);
            rateMap[11] = scaleRate(rateMap[11],1.15,0.8);
            rateMap[21] = scaleRate(rateMap[21],1.08,0.4);
         }
      }
      
      private static function scaleRate(sourceRate:Array, multiplier:Number, offset:Number) : Array
      {
         var outputRate:Array = [];
         var value:Number = 0;
         var i:int = 0;
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
