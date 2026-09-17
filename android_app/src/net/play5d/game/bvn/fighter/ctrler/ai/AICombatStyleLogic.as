package net.play5d.game.bvn.fighter.ctrler.ai
{
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.fighter.FighterMain;

   public class AICombatStyleLogic
   {
      public static const MODE_NEUTRAL:String = "neutral";
      public static const MODE_FOOTSIES:String = "footsies";
      public static const MODE_APPROACH:String = "approach";
      public static const MODE_PRESSURE:String = "pressure";
      public static const MODE_PUNISH:String = "punish";
      public static const MODE_ANTI_AIR:String = "anti_air";
      public static const MODE_DEFENSE:String = "defense";

      public function AICombatStyleLogic()
      {
         super();
      }

      public static function buildCombatContext(aiLevel:int, fighter:FighterMain, target:FighterMain, distanceX:Number, distanceY:Number, isConting:Boolean) : Object
      {
         var combatContext:Object = createDefaultContext();
         if(fighter == null || target == null)
         {
            return combatContext;
         }
         var normalizedLevel:int = AIDifficultyProfile.normalizeLevel(aiLevel);
         var targetIsAttacking:Boolean = FighterActionState.isAttacking(target.actionState);
         var targetIsRecovering:Boolean = target.actionState == 21 || FighterActionState.isHurting(target.actionState);
         var targetIsInAir:Boolean = target.isInAir;
         var fighterLowEnergy:Boolean = fighter.energy < 30 || fighter.energyOverLoad;
         var fighterCanSpendEnergy:Boolean = fighter.energy > 28 && !fighter.energyOverLoad;
         var closeRange:Boolean = distanceX <= 125 && distanceY <= 95;
         if(targetIsAttacking && closeRange)
         {
            applyMode(combatContext,MODE_DEFENSE);
         }
         else if(targetIsInAir && distanceY > 65 && distanceX < 210)
         {
            applyMode(combatContext,MODE_ANTI_AIR);
         }
         else if(targetIsRecovering && distanceX < (normalizedLevel >= AIDifficultyProfile.HARD ? 245 : 210) && distanceY < 110)
         {
            applyMode(combatContext,MODE_PUNISH);
         }
         else if((isConting || closeRange) && fighterCanSpendEnergy && distanceX < 190 && distanceY < 95)
         {
            applyMode(combatContext,MODE_PRESSURE);
         }
         else if(distanceX > (normalizedLevel >= AIDifficultyProfile.HARD ? 220 : 245))
         {
            applyMode(combatContext,MODE_APPROACH);
         }
         else if(distanceX < 80 && !isConting)
         {
            applyMode(combatContext,MODE_FOOTSIES);
         }
         else
         {
            applyMode(combatContext,MODE_NEUTRAL);
         }
         if(fighterLowEnergy)
         {
            combatContext.skillRateScale *= 0.8;
            combatContext.defenseRateScale *= 1.22;
            combatContext.dashRateScale *= 0.9;
            combatContext.jumpRateScale *= 0.82;
            combatContext.preferredSpacing += 14;
            combatContext.allowCatch = false;
            combatContext.skillOrderBonus -= 8;
            combatContext.attackOrderBonus -= 6;
            combatContext.defenseOrderBonus += 6;
            combatContext.skillCadenceScale *= 1.15;
         }
         applyDifficultyScale(combatContext,normalizedLevel);
         adaptByDistance(combatContext,distanceX,distanceY,targetIsAttacking);
         clampContext(combatContext);
         return combatContext;
      }

      private static function createDefaultContext() : Object
      {
         return {
            "mode":MODE_NEUTRAL,
            "preferredSpacing":56,
            "attackRateScale":1,
            "skillRateScale":1,
            "defenseRateScale":1,
            "dashRateScale":1,
            "moveRateScale":1,
            "jumpRateScale":1,
            "suppressJump":false,
            "allowCatch":true,
            "preferDownCommandSkill":false,
            "preferUpperCommandSkill":false,
            "preferHitConfirmSkill":false,
            "skillOrderBonus":0,
            "attackOrderBonus":0,
            "defenseOrderBonus":0,
            "skillCadenceScale":1,
            "rapidChainBonusFrame":0,
            "closeRangeJumpBlockDistance":0
         };
      }

      private static function applyMode(context:Object, mode:String) : void
      {
         context.mode = mode;
         switch(mode)
         {
            case MODE_FOOTSIES:
               context.preferredSpacing = 70;
               context.attackRateScale = 1.05;
               context.skillRateScale = 1.1;
               context.defenseRateScale = 1.1;
               context.dashRateScale = 0.92;
               context.moveRateScale = 1.04;
               context.jumpRateScale = 0.62;
               context.suppressJump = true;
               context.preferHitConfirmSkill = true;
               context.skillOrderBonus = 10;
               context.attackOrderBonus = 5;
               context.defenseOrderBonus = 8;
               context.skillCadenceScale = 0.92;
               context.rapidChainBonusFrame = 1;
               context.closeRangeJumpBlockDistance = 170;
               break;
            case MODE_APPROACH:
               context.preferredSpacing = 88;
               context.attackRateScale = 0.96;
               context.skillRateScale = 0.94;
               context.defenseRateScale = 0.96;
               context.dashRateScale = 1.28;
               context.moveRateScale = 1.2;
               context.jumpRateScale = 0.74;
               context.skillOrderBonus = -4;
               context.attackOrderBonus = 4;
               context.skillCadenceScale = 1.06;
               context.rapidChainBonusFrame = -1;
               break;
            case MODE_PRESSURE:
               context.preferredSpacing = 42;
               context.attackRateScale = 1.2;
               context.skillRateScale = 1.45;
               context.defenseRateScale = 0.9;
               context.dashRateScale = 1.2;
               context.moveRateScale = 1.12;
               context.jumpRateScale = 0.5;
               context.suppressJump = true;
               context.allowCatch = true;
               context.preferDownCommandSkill = true;
               context.preferHitConfirmSkill = true;
               context.skillOrderBonus = 20;
               context.attackOrderBonus = 12;
               context.defenseOrderBonus = -4;
               context.skillCadenceScale = 0.75;
               context.rapidChainBonusFrame = 5;
               context.closeRangeJumpBlockDistance = 235;
               break;
            case MODE_PUNISH:
               context.preferredSpacing = 46;
               context.attackRateScale = 1.34;
               context.skillRateScale = 1.62;
               context.defenseRateScale = 0.92;
               context.dashRateScale = 1.2;
               context.moveRateScale = 1.1;
               context.jumpRateScale = 0.44;
               context.suppressJump = true;
               context.allowCatch = true;
               context.preferDownCommandSkill = true;
               context.preferUpperCommandSkill = true;
               context.preferHitConfirmSkill = true;
               context.skillOrderBonus = 30;
               context.attackOrderBonus = 16;
               context.defenseOrderBonus = -8;
               context.skillCadenceScale = 0.68;
               context.rapidChainBonusFrame = 7;
               context.closeRangeJumpBlockDistance = 250;
               break;
            case MODE_ANTI_AIR:
               context.preferredSpacing = 68;
               context.attackRateScale = 1.04;
               context.skillRateScale = 1.34;
               context.defenseRateScale = 1.1;
               context.dashRateScale = 0.95;
               context.moveRateScale = 1;
               context.jumpRateScale = 0.4;
               context.suppressJump = true;
               context.preferUpperCommandSkill = true;
               context.preferHitConfirmSkill = true;
               context.skillOrderBonus = 18;
               context.attackOrderBonus = 8;
               context.defenseOrderBonus = 10;
               context.skillCadenceScale = 0.84;
               context.rapidChainBonusFrame = 3;
               context.closeRangeJumpBlockDistance = 220;
               break;
            case MODE_DEFENSE:
               context.preferredSpacing = 96;
               context.attackRateScale = 0.76;
               context.skillRateScale = 0.72;
               context.defenseRateScale = 1.5;
               context.dashRateScale = 0.84;
               context.moveRateScale = 0.95;
               context.jumpRateScale = 0.3;
               context.suppressJump = true;
               context.allowCatch = false;
               context.skillOrderBonus = -22;
               context.attackOrderBonus = -25;
               context.defenseOrderBonus = 30;
               context.skillCadenceScale = 1.15;
               context.rapidChainBonusFrame = -3;
               context.closeRangeJumpBlockDistance = 280;
               break;
            case MODE_NEUTRAL:
            default:
               context.preferredSpacing = 56;
               context.attackRateScale = 1;
               context.skillRateScale = 1;
               context.defenseRateScale = 1;
               context.dashRateScale = 1;
               context.moveRateScale = 1;
               context.jumpRateScale = 0.86;
               context.suppressJump = false;
               context.allowCatch = true;
               context.preferDownCommandSkill = false;
               context.preferUpperCommandSkill = false;
               context.preferHitConfirmSkill = false;
               context.skillOrderBonus = 0;
               context.attackOrderBonus = 0;
               context.defenseOrderBonus = 0;
               context.skillCadenceScale = 1;
               context.rapidChainBonusFrame = 0;
               context.closeRangeJumpBlockDistance = 130;
         }
      }

      private static function applyDifficultyScale(context:Object, normalizedLevel:int) : void
      {
         if(normalizedLevel == AIDifficultyProfile.EASY)
         {
            context.attackRateScale *= 0.78;
            context.skillRateScale *= 0.7;
            context.defenseRateScale *= 0.82;
            context.dashRateScale *= 0.85;
            context.moveRateScale *= 0.9;
            context.jumpRateScale *= 1.22;
            context.preferredSpacing += 10;
            context.allowCatch = false;
            context.preferDownCommandSkill = false;
            context.preferUpperCommandSkill = false;
            context.preferHitConfirmSkill = false;
            context.skillOrderBonus -= 16;
            context.attackOrderBonus -= 10;
            context.defenseOrderBonus -= 8;
            context.skillCadenceScale *= 1.28;
            context.rapidChainBonusFrame -= 3;
            context.closeRangeJumpBlockDistance *= 0.5;
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.NORMAL)
         {
            context.attackRateScale *= 0.96;
            context.skillRateScale *= 0.95;
            context.defenseRateScale *= 0.97;
            context.dashRateScale *= 0.98;
            context.jumpRateScale *= 1.05;
            context.skillOrderBonus -= 2;
            context.attackOrderBonus -= 1;
            context.skillCadenceScale *= 1.05;
            context.rapidChainBonusFrame -= 1;
            context.closeRangeJumpBlockDistance *= 0.8;
            return;
         }
         if(normalizedLevel == AIDifficultyProfile.HARD)
         {
            context.attackRateScale *= 1.1;
            context.skillRateScale *= 1.18;
            context.defenseRateScale *= 1.06;
            context.dashRateScale *= 1.06;
            context.moveRateScale *= 1.03;
            context.jumpRateScale *= 0.88;
            context.preferredSpacing -= 3;
            context.preferHitConfirmSkill = true;
            context.skillOrderBonus += 10;
            context.attackOrderBonus += 8;
            context.defenseOrderBonus += 12;
            context.skillCadenceScale *= 0.82;
            context.rapidChainBonusFrame += 2;
            context.closeRangeJumpBlockDistance += 30;
            return;
         }
         context.attackRateScale *= 1.2;
         context.skillRateScale *= 1.35;
         context.defenseRateScale *= 1.15;
         context.dashRateScale *= 1.1;
         context.moveRateScale *= 1.06;
         context.jumpRateScale *= 0.75;
         context.preferredSpacing -= 6;
         context.suppressJump = true;
         context.preferHitConfirmSkill = true;
         context.skillOrderBonus += 22;
         context.attackOrderBonus += 16;
         context.defenseOrderBonus += 18;
         context.skillCadenceScale *= 0.68;
         context.rapidChainBonusFrame += 4;
         context.closeRangeJumpBlockDistance += 55;
      }

      private static function adaptByDistance(context:Object, distanceX:Number, distanceY:Number, targetIsAttacking:Boolean) : void
      {
         if(distanceX > 280)
         {
            context.dashRateScale *= 1.15;
            context.moveRateScale *= 1.12;
            context.skillRateScale *= 0.85;
            context.attackRateScale *= 0.9;
            context.skillOrderBonus -= 6;
            context.attackOrderBonus += 4;
         }
         else if(distanceX < 95 && distanceY <= 95)
         {
            context.suppressJump = true;
            context.skillRateScale *= 1.12;
            context.attackRateScale *= 1.08;
            context.skillOrderBonus += 8;
            context.attackOrderBonus += 5;
         }
         if(targetIsAttacking && distanceX <= 130 && distanceY <= 100)
         {
            context.defenseRateScale *= 1.2;
            context.defenseOrderBonus += 20;
            context.attackOrderBonus -= 10;
            context.skillOrderBonus -= 8;
         }
         if(distanceY > 155)
         {
            context.skillRateScale *= 0.88;
            context.attackRateScale *= 0.9;
         }
      }

      private static function clampContext(context:Object) : void
      {
         context.attackRateScale = clamp(Number(context.attackRateScale),0.35,2.2);
         context.skillRateScale = clamp(Number(context.skillRateScale),0.35,2.3);
         context.defenseRateScale = clamp(Number(context.defenseRateScale),0.35,2.3);
         context.dashRateScale = clamp(Number(context.dashRateScale),0.35,2.1);
         context.moveRateScale = clamp(Number(context.moveRateScale),0.35,2.1);
         context.jumpRateScale = clamp(Number(context.jumpRateScale),0.2,1.8);
         context.preferredSpacing = clamp(Number(context.preferredSpacing),28,120);
         context.skillOrderBonus = clamp(Number(context.skillOrderBonus),-60,80);
         context.attackOrderBonus = clamp(Number(context.attackOrderBonus),-60,80);
         context.defenseOrderBonus = clamp(Number(context.defenseOrderBonus),-40,120);
         context.skillCadenceScale = clamp(Number(context.skillCadenceScale),0.45,1.8);
         context.rapidChainBonusFrame = clamp(Number(context.rapidChainBonusFrame),-6,12);
         context.closeRangeJumpBlockDistance = clamp(Number(context.closeRangeJumpBlockDistance),0,320);
      }

      private static function clamp(value:Number, minValue:Number, maxValue:Number) : Number
      {
         if(isNaN(value))
         {
            return minValue;
         }
         if(value < minValue)
         {
            return minValue;
         }
         if(value > maxValue)
         {
            return maxValue;
         }
         return value;
      }
   }
}
