package net.play5d.game.bvn.fighter.ctrler.ai
{
   public class FighterAIProfile
   {
      public var characterId:String;
      public var style:String = "balanced";
      public var preferredSpacing:Number = 56;
      public var aggression:Number = 1.0;
      public var defensiveness:Number = 1.0;
      public var ranges:Object = {};
      public var rules:Vector.<FighterAIRule> = new Vector.<FighterAIRule>();
      public var combos:Object = {};

      public function FighterAIProfile(charId:String = "")
      {
         super();
         this.characterId = charId;
      }

      public function getRange(rangeName:String) : Array
      {
         if(!ranges || !rangeName)
         {
            return null;
         }
         if(ranges[rangeName] != undefined)
         {
            return ranges[rangeName] as Array;
         }
         var alias:String = mapRangeNameToAlias(rangeName);
         if(alias && ranges[alias] != undefined)
         {
            return ranges[alias] as Array;
         }
         return null;
      }

      public static function mapRangeNameToAlias(rangeName:String) : String
      {
         switch(rangeName)
         {
            case "kanmian":
               return "attack";
            case "tkanmian":
               return "attackAIR";
            case "kj1mian":
               return "skill1";
            case "kj2mian":
               return "skill2";
            case "zh1mian":
               return "zhao1";
            case "zh2mian":
               return "zhao2";
            case "zh3mian":
               return "zhao3";
            case "tzmian":
               return "skillAIR";
            case "bsmian":
               return "bisha";
            case "sbsmian":
               return "bishaUP";
            case "cbsmian":
               return "bishaSUPER";
            case "kbsmian":
               return "bishaAIR";
            default:
               return null;
         }
      }

      public function hasRules() : Boolean
      {
         return rules != null && rules.length > 0;
      }

      public function hasContent() : Boolean
      {
         if(rules != null && rules.length > 0)
         {
            return true;
         }
         if(ranges != null)
         {
            for(var rangeKey:String in ranges)
            {
               return true;
            }
         }
         if(combos != null)
         {
            for(var comboKey:String in combos)
            {
               return true;
            }
         }
         return style != "balanced" || preferredSpacing != 56 || aggression != 1.0 || defensiveness != 1.0;
      }
   }
}
