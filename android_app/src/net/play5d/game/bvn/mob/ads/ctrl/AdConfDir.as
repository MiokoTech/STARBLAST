package net.play5d.game.bvn.mob.ads.ctrl
{
   import net.play5d.game.bvn.mob.ads.utils.IAd;
   
   public class AdConfDir
   {
      public var code:String;
      
      public var ad:IAd;
      
      public var type:String;
      
      public function AdConfDir(param1:String, param2:IAd, param3:String)
      {
         super();
         this.code = param1;
         this.ad = param2;
         this.type = param3;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "AdConfDir ::  code[" + code + "]" + " type[" + type + "]";
         if(ad)
         {
            _loc1_ += " enabled[" + ad.getADEnabled(type) + "] rank[" + ad.getRank(type) + "]" + " rate[" + ad.getRate(type) + "]";
         }
         return _loc1_;
      }
   }
}

