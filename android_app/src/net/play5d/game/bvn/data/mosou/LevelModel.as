package net.play5d.game.bvn.data.mosou
{
   public class LevelModel
   {
      public function LevelModel()
      {
         super();
      }
      
      public static function getLevelUpExp(param1:int) : int
      {
         var exp:int;
         var i:int;
         var level:int = param1;
         var solveExp:* = function(param1:int):int
         {
            var _loc3_:* = param1;
            return int(3.8 * _loc3_ * _loc3_ - 1.2 * _loc3_ + 48.6);
         };
         if(level <= 0)
         {
            return 0;
         }
         exp = solveExp(level);
         if(level > 1)
         {
            i = 1;
            while(i < level)
            {
               exp += solveExp(i);
               i++;
            }
         }
         return exp;
      }
   }
}

