package net.play5d.kyo.stage.events
{
   import flash.events.Event;
   import net.play5d.kyo.stage.Istage;
   
   public class KyoStageEvent extends Event
   {
      public static const CHANGE_STATE:String = "CHANGE_STATE";
      
      public var stage:Istage;
      
      public function KyoStageEvent(param1:String, param2:Istage, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.stage = param2;
      }
   }
}

