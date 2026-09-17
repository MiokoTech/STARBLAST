package net.play5d.game.bvn.data
{
   public class HitType
   {
      public static const KAN:int = 1;
      
      public static const KAN_HEAVY:int = 6;
      
      public static const DA:int = 2;
      
      public static const DA_HEAVY:int = 3;
      
      public static const MAGIC:int = 4;
      
      public static const MAGIC_HEAVY:int = 5;
      
      public static const FIRE:int = 7;
      
      public static const ICE:int = 8;
      
      public static const ELECTRIC:int = 9;
      
      public static const STONE:int = 10;
      
      public static const CATCH:int = 11;
      
      private static const heavyTypes:Array = [6,3,5,7,8,9];
      
      public function HitType()
      {
         super();
      }
      
      public static function isHeavy(param1:int) : Boolean
      {
         return heavyTypes.indexOf(param1) != -1;
      }
   }
}

