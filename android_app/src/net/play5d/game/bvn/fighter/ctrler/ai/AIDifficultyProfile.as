package net.play5d.game.bvn.fighter.ctrler.ai
{
   public class AIDifficultyProfile
   {
      public static const EASY:int = 1;
      public static const NORMAL:int = 2;
      public static const HARD:int = 3;
      public static const VERY_HARD:int = 4;
      
      public function AIDifficultyProfile()
      {
         super();
      }
      
      public static function normalizeLevel(level:int) : int
      {
         if(level <= 1)
         {
            return EASY;
         }
         if(level == 2)
         {
            return NORMAL;
         }
         if(level == 3)
         {
            return HARD;
         }
         return VERY_HARD;
      }
      
      public static function getReactionFrameGap(level:int) : int
      {
         var normalizedLevel:int = normalizeLevel(level);
         switch(normalizedLevel)
         {
            case EASY:
               return 3;
            case NORMAL:
               return 2;
            case HARD:
               return 1;
            default:
               return 0;
         }
      }
      
      public static function getDangerDistance(level:int) : Number
      {
         var normalizedLevel:int = normalizeLevel(level);
         switch(normalizedLevel)
         {
            case EASY:
               return 60;
            case NORMAL:
               return 85;
            case HARD:
               return 110;
            default:
               return 145;
         }
      }
   }
}
