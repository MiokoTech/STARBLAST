package net.play5d.game.bvn.fighter.ctrler.ai
{
   import flash.geom.Point;
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class AIDefenseLogic
   {
      public function AIDefenseLogic()
      {
         super();
      }
      
      public static function buildDefenseRateMap(aiLevel:int, fighter:FighterMain, targetFighter:FighterMain, targetDistance:Point) : Object
      {
         var rateMap:Object = {};
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(aiLevel);
         var targetHits:* = targetFighter ? targetFighter.getCurrentHits() : null;
         var hasActiveHits:Boolean = targetHits != null && targetHits.length > 0;
         var targetIsAttacking:Boolean = targetFighter && (FighterActionState.isAttacking(targetFighter.actionState) || hasActiveHits);
         var inDanger:Boolean = targetDistance && targetDistance.x <= AIDifficultyProfile.getDangerDistance(aiLevel) && targetDistance.y <= 95;
         rateMap.defult = [0,0,0,0,0,0];
         if(fighter.qi <= 10)
         {
            rateMap[10] = rateMap[11] = [1,2,3,2,1,0.5];
            rateMap[12] = rateMap[13] = [2,3,3.5,4,5,6.5];
         }
         if(targetIsAttacking && inDanger)
         {
            if(normalizedLevel == AIDifficultyProfile.EASY)
            {
               rateMap[10] = [0.3,0.5,0.8,1,1.2,1.5];
               rateMap[11] = [0.3,0.5,0.8,1,1.2,1.5];
            }
            else if(normalizedLevel == AIDifficultyProfile.NORMAL)
            {
               rateMap[10] = [0.8,1.5,2.5,3.5,4.2,5];
               rateMap[11] = [0.8,1.5,2.5,3.5,4.2,5];
               rateMap[12] = [1.2,2,3.2,4.5,5.6,6.6];
               rateMap[13] = [1.2,2,3.2,4.5,5.6,6.6];
            }
            else if(normalizedLevel == AIDifficultyProfile.HARD)
            {
               rateMap.defult = [0.2,0.5,1.2,2.2,3.6,5.2];
               rateMap[10] = [1.3,2.2,3.6,5.2,6.6,7.8];
               rateMap[11] = [1.3,2.2,3.6,5.2,6.6,7.8];
               rateMap[12] = [1.8,3,4.8,6.5,7.6,8.7];
               rateMap[13] = [1.8,3,4.8,6.5,7.6,8.7];
            }
            else
            {
               rateMap.defult = [0.5,1.2,2.8,4.8,6.8,8.8];
               rateMap[10] = [2.2,3.6,5.4,7.2,8.5,9.6];
               rateMap[11] = [2.2,3.6,5.4,7.2,8.5,9.6];
               rateMap[12] = [2.8,4.2,6.2,8.1,9.1,9.8];
               rateMap[13] = [2.8,4.2,6.2,8.1,9.1,9.8];
            }
         }
         if(targetFighter && (targetFighter.actionState == 12 || targetFighter.actionState == 13))
         {
            if(normalizedLevel == AIDifficultyProfile.HARD)
            {
               rateMap[12] = [1.5,2.8,4.3,6.1,7.3,8.5];
               rateMap[13] = [1.5,2.8,4.3,6.1,7.3,8.5];
            }
            else if(normalizedLevel == AIDifficultyProfile.VERY_HARD)
            {
               rateMap[12] = [3,4.2,5.8,7.5,8.8,9.7];
               rateMap[13] = [3,4.2,5.8,7.5,8.8,9.7];
            }
         }
         return rateMap;
      }
      
      public static function shouldForceDefense(aiLevel:int, targetFighter:FighterMain, targetDistance:Point) : Boolean
      {
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(aiLevel);
         var targetHits:* = targetFighter ? targetFighter.getCurrentHits() : null;
         var hasActiveHits:Boolean = targetHits != null && targetHits.length > 0;
         var targetIsAttacking:Boolean = targetFighter && (FighterActionState.isAttacking(targetFighter.actionState) || hasActiveHits);
         var targetUsingBisha:Boolean = targetFighter && (targetFighter.actionState == 12 || targetFighter.actionState == 13);
         var closeEnough:Boolean = targetDistance && targetDistance.x <= AIDifficultyProfile.getDangerDistance(aiLevel) && targetDistance.y <= 95;
         if(!targetFighter || !closeEnough)
         {
            return false;
         }
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            return false;
         }
         if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            return targetUsingBisha;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            return targetUsingBisha || targetIsAttacking && targetDistance.x <= 90;
         }
         return targetUsingBisha || targetIsAttacking;
      }
   }
}
