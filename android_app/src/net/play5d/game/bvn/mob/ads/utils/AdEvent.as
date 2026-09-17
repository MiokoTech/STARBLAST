package net.play5d.game.bvn.mob.ads.utils
{
   import flash.events.Event;
   
   public class AdEvent extends Event
   {
      public static const AD_ACTION:String = "AD_ACTION";
      
      public static const METHOD_CALL:String = "METHOD_CALL";
      
      public var ad:IAd;
      
      public var adType:String;
      
      public var adAction:String;
      
      public function AdEvent(param1:String, param2:String, param3:String, param4:IAd = null)
      {
         super(param1,false,false);
         this.adType = param3;
         this.adAction = param2;
         this.ad = param4;
      }
   }
}

