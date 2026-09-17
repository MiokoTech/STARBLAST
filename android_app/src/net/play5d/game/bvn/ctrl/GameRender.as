package net.play5d.game.bvn.ctrl
{
   import flash.display.Stage;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class GameRender
   {
      public static var isRender:Boolean = true;
      
      private static var _fucs:Dictionary = new Dictionary();
      
      public function GameRender()
      {
         super();
      }
      
      public static function initlize(param1:Stage) : void
      {
         param1.addEventListener("enterFrame",render);
      }
      
      public static function add(param1:Function, param2:* = null) : void
      {
         if(!param2)
         {
            param2 = "anyone";
         }
         if(_fucs[param2] && _fucs[param2].indexOf(param1) != -1)
         {
            return;
         }
         var _loc3_:* = param2;
         _fucs[_loc3_] ||= new Vector.<Function>();
         _fucs[param2].push(param1);
      }
      
      public static function remove(param1:Function, param2:* = null) : void
      {
         if(!param2)
         {
            param2 = "anyone";
         }
         if(!_fucs[param2])
         {
            return;
         }
         var _loc3_:int = int(_fucs[param2].indexOf(param1));
         if(_loc3_ != -1)
         {
            _fucs[param2].splice(_loc3_,1);
         }
      }
      
      private static function render(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc2_:* = undefined;
         if(!isRender)
         {
            return;
         }
         var _loc3_:int = 0;
         for each(_loc2_ in _fucs)
         {
            _loc4_ = int(_loc2_.length);
            _loc3_ = 0;
            while(_loc3_ < _loc4_)
            {
               if(_loc3_ > _loc2_.length - 1)
               {
                  break;
               }
               _loc2_[_loc3_]();
               _loc3_++;
            }
         }
      }
   }
}

