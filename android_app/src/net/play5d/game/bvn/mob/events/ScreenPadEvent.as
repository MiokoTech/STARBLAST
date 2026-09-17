package net.play5d.game.bvn.mob.events
{
   import flash.events.Event;
   import net.play5d.game.bvn.mob.screenpad.ScreenPadBtnBase;
   
   public class ScreenPadEvent extends Event
   {
      public static const CUSTOM_SELECT:String = "ScreenPadEvent_CUSTOM_SELECT";
      
      public static const CUSTOM_MOVING:String = "ScreenPadEvent_CUSTOM_MOVING";
      
      public var screenPadBtn:ScreenPadBtnBase;
      
      public function ScreenPadEvent(param1:String, param2:ScreenPadBtnBase, param3:Boolean = false, param4:Boolean = false)
      {
         this.screenPadBtn = param2;
         super(param1,param3,param4);
      }
   }
}

