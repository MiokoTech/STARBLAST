package net.play5d.game.bvn.fighter.events
{
   import flash.events.EventDispatcher;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   
   public class FighterEventDispatcher
   {
      private static var _dispatcher:EventDispatcher = new EventDispatcher();
      
      private static var _addedEvents:Object = {};
      
      public function FighterEventDispatcher()
      {
         super();
      }
      
      public static function hasEventListener(param1:String) : Boolean
      {
         return _addedEvents[param1] != null;
      }
      
      public static function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         _addedEvents[param1] = param2;
         _dispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public static function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         delete _addedEvents[param1];
         _dispatcher.removeEventListener(param1,param2,param3);
      }
      
      public static function removeAllListeners() : void
      {
         for(var _loc1_:String in _addedEvents)
         {
            _dispatcher.removeEventListener(_loc1_,_addedEvents[_loc1_]);
         }
         _addedEvents = {};
      }
      
      public static function dispatchEvent(param1:BaseGameSprite, param2:String, param3:Object = null) : void
      {
         var _loc4_:FighterEvent = new FighterEvent(param2,false,false);
         _loc4_.fighter = param1;
         _loc4_.params = param3;
         _dispatcher.dispatchEvent(_loc4_);
      }
   }
}

