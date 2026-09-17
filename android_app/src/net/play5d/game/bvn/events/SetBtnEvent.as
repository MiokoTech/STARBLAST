package net.play5d.game.bvn.events
{
   import flash.events.Event;
   
   public class SetBtnEvent extends Event
   {
      public static const SELECT:String = "SELECT";
      
      public static const OPTION_CHANGE:String = "OPTION_CHANGE";
      
      public static const APPLY_SET:String = "APPLY_SET";
      
      public static const CANCEL_SET:String = "CANCEL_SET";
      
      public var selectedLabel:String;
      
      public var optionKey:String;
      
      public var optionValue:*;
      
      public function SetBtnEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function newEvent() : SetBtnEvent
      {
         var _loc1_:SetBtnEvent = new SetBtnEvent(type,bubbles,cancelable);
         _loc1_.selectedLabel = selectedLabel;
         _loc1_.optionKey = optionKey;
         _loc1_.optionValue = optionValue;
         return _loc1_;
      }
   }
}

