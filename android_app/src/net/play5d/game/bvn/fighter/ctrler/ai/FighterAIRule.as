package net.play5d.game.bvn.fighter.ctrler.ai
{
   import flash.geom.Point;
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.fighter.FighterMain;

   public class FighterAIRule
   {
      public var name:String;
      public var triggerActions:Array;
      public var triggerDistXMin:Number = -1;
      public var triggerDistXMax:Number = -1;
      public var triggerDistYMin:Number = -1;
      public var triggerDistYMax:Number = -1;
      public var triggerTargetState:int = -1;
      public var triggerHitConfirmed:Boolean = false;
      public var triggerQiMin:int = 0;
      public var triggerEnergyMin:int = 0;
      public var triggerAir:int = 0;
      public var triggerOpponentAttacking:Boolean = false;
      public var action:String;
      public var priority:int = 200;
      public var chance:Number = 1.0;

      public function FighterAIRule()
      {
         super();
      }

      public function evaluate(fighter:FighterMain, targetFighter:FighterMain, currentAction:String, targetDistance:Point, isHitConfirmed:Boolean, fighterAction:Object) : Boolean
      {
         var availableAction:String = resolveAvailableActionName(action,fighterAction);
         if(availableAction == null)
         {
            return false;
         }
         if(triggerActions != null && triggerActions.length > 0)
         {
            if(!currentAction || triggerActions.indexOf(currentAction) == -1)
            {
               return false;
            }
         }
         if(targetDistance != null)
         {
            if(triggerDistXMin >= 0 && targetDistance.x < triggerDistXMin)
            {
               return false;
            }
            if(triggerDistXMax >= 0 && targetDistance.x > triggerDistXMax)
            {
               return false;
            }
            if(triggerDistYMin >= 0 && targetDistance.y < triggerDistYMin)
            {
               return false;
            }
            if(triggerDistYMax >= 0 && targetDistance.y > triggerDistYMax)
            {
               return false;
            }
         }
         if(triggerQiMin > 0 && fighter.qi < triggerQiMin)
         {
            return false;
         }
         if(triggerEnergyMin > 0 && (fighter.energy < triggerEnergyMin || fighter.energyOverLoad))
         {
            return false;
         }
         if(triggerHitConfirmed && !isHitConfirmed)
         {
            return false;
         }
         if(triggerTargetState >= 0 && targetFighter != null)
         {
            if(targetFighter.actionState != triggerTargetState)
            {
               return false;
            }
         }
         if(triggerAir == 1 && !fighter.isInAir)
         {
            return false;
         }
         if(triggerAir == -1 && fighter.isInAir)
         {
            return false;
         }
         if(triggerOpponentAttacking && targetFighter != null)
         {
            if(!FighterActionState.isAttacking(targetFighter.actionState))
            {
               return false;
            }
         }
         if(chance < 1.0 && Math.random() > chance)
         {
            return false;
         }
         return true;
      }

      public static function resolveAvailableActionName(actionName:String, fighterAction:Object) : String
      {
         if(!actionName || !fighterAction)
         {
            return null;
         }
         var normalized:String = mapActionAlias(actionName);
         if(fighterAction.hasOwnProperty(normalized) && fighterAction[normalized])
         {
            return normalized;
         }
         if(fighterAction.hasOwnProperty(actionName) && fighterAction[actionName])
         {
            return actionName;
         }
         for(var slotName:String in fighterAction)
         {
            if(fighterAction[slotName] == actionName)
            {
               return slotName;
            }
         }
         return null;
      }

      public static function mapActionAlias(actionName:String) : String
      {
         if(!actionName)
         {
            return "";
         }
         var lowerAction:String = actionName.toLowerCase();
         switch(lowerAction)
         {
            case "j":
            case "a":
            case "x":
            case "200":
            case "210":
            case "220":
            case "300":
            case "310":
            case "320":
            case "attack":
               return "attack";
            case "air_attack":
            case "ta":
            case "600":
            case "610":
            case "620":
            case "attackair":
               return "attackAIR";
            case "u":
            case "1000":
            case "1010":
            case "1020":
            case "skill1":
            case "kj1":
               return "skill1";
            case "1100":
            case "1110":
            case "1200":
            case "skill2":
            case "kj2":
               return "skill2";
            case "sj":
            case "400":
            case "410":
            case "420":
            case "1300":
            case "1400":
            case "zhao1":
            case "zh1":
               return "zhao1";
            case "wj":
            case "1500":
            case "1600":
            case "zhao2":
            case "zh2":
               return "zhao2";
            case "su":
            case "zhao3":
            case "zh3":
               return "zhao3";
            case "tz":
            case "skillair":
               return "skillAIR";
            case "i":
            case "2000":
            case "3100":
            case "bisha":
            case "bs":
               return "bisha";
            case "wi":
            case "sbs":
            case "bishaup":
               return "bishaUP";
            case "si":
            case "3000":
            case "3500":
            case "cbs":
            case "bishasuper":
               return "bishaSUPER";
            case "ki":
            case "kbs":
            case "bishaair":
               return "bishaAIR";
            case "w":
            case "40":
            case "jump":
               return "jump";
            case "s":
            case "120":
            case "130":
            case "131":
            case "132":
            case "defense":
            case "guard":
               return "defense";
            case "l":
            case "60":
            case "65":
            case "100":
            case "105":
            case "run":
            case "dash":
               return "dash";
            case "70":
            case "106":
            case "dash_back":
            case "backdash":
            case "run_atras":
               return "dash_back";
            case "catch":
            case "catch1":
               return "catch1";
            case "catch2":
               return "catch2";
            case "special":
            case "specialskill":
               return "specialSkill";
            default:
               return actionName;
         }
      }
   }
}
