package net.play5d.game.bvn.utils
{
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   
   public class KeyBoarder
   {
      private static var _inited:Boolean;
      
      private static var _stage:Stage;
      
      private static var _keyHandlers:Vector.<Function> = new Vector.<Function>();
      
      public function KeyBoarder()
      {
         super();
      }
      
      public static function initlize(param1:Stage) : void
      {
         if(_inited)
         {
            return;
         }
         _inited = true;
         _stage = param1;
         param1.addEventListener("keyDown",keyBoardHandler);
         param1.addEventListener("keyUp",keyBoardHandler);
      }
      
      public static function focus() : void
      {
         if(!_inited)
         {
            return;
         }
         _stage.focus = _stage;
      }
      
      public static function listen(param1:Function) : void
      {
         if(!_inited)
         {
            return;
         }
         if(_keyHandlers.indexOf(param1) == -1)
         {
            _keyHandlers.push(param1);
         }
      }
      
      public static function unListen(param1:Function) : void
      {
         if(!_inited)
         {
            return;
         }
         if(_keyHandlers.indexOf(param1) != -1)
         {
            _keyHandlers.splice(_keyHandlers.indexOf(param1),1);
         }
      }
      
      private static function keyBoardHandler(param1:KeyboardEvent) : void
      {
         if(!_inited)
         {
            return;
         }
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _keyHandlers.length)
         {
            _keyHandlers[_loc2_](param1);
            _loc2_++;
         }
      }
   }
}

