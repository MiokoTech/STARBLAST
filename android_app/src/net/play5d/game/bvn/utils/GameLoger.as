package net.play5d.game.bvn.utils
{
   import net.play5d.game.bvn.interfaces.ILoger;
   
   public class GameLoger
   {
      private static var _loger:ILoger;
      
      public function GameLoger()
      {
         super();
      }
      
      public static function setLoger(param1:ILoger) : void
      {
         _loger = param1;
      }
      
      public static function log(param1:String) : void
      {
         if(_loger)
         {
            _loger.log(param1);
         }
         else
         {
            trace(param1);
         }
      }
   }
}

