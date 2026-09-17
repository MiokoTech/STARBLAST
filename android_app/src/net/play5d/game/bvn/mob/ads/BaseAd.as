package net.play5d.game.bvn.mob.ads
{
   import net.play5d.game.bvn.mob.ads.utils.AdEventListener;
   import net.play5d.game.bvn.mob.ads.utils.IAd;
   
   public class BaseAd implements IAd
   {
      protected var $enabled:Boolean = true;
      
      protected var $name:String = "Unset Name";
      
      protected var $interReady:Boolean = false;
      
      protected var $videoReady:Boolean = false;
      
      protected var $configCode:AdConfigCode = null;
      
      protected var $exceptDate:Date;
      
      private var _rankObj:Object = {};
      
      private var _rateObj:Object = {};
      
      private var _adEnableObj:Object = {};
      
      public function BaseAd()
      {
         super();
      }
      
      public function getEnabled() : Boolean
      {
         return $enabled;
      }
      
      public function exceptDate() : Date
      {
         return $exceptDate;
      }
      
      public function getRank(param1:String) : int
      {
         if(_rankObj[param1])
         {
            return _rankObj[param1];
         }
         return 3;
      }
      
      public function setRank(param1:String, param2:int) : void
      {
         _rankObj[param1] = param2;
      }
      
      public function getRate(param1:String) : Number
      {
         if(_rateObj[param1])
         {
            return _rateObj[param1];
         }
         return 10;
      }
      
      public function setRate(param1:String, param2:Number) : void
      {
         _rateObj[param1] = param2;
      }
      
      public function setRankAndRate(param1:String, param2:int, param3:Number) : void
      {
         _rankObj[param1] = param2;
         _rateObj[param1] = param3;
      }
      
      public function getADEnabled(param1:String) : Boolean
      {
         if(_adEnableObj[param1] !== undefined)
         {
            return _adEnableObj[param1];
         }
         return true;
      }
      
      public function setADEnabled(param1:String, param2:Boolean) : void
      {
         _adEnableObj[param1] = param2;
      }
      
      public function getName() : String
      {
         return $name;
      }
      
      public function interReady() : Boolean
      {
         return $interReady;
      }
      
      public function videoReady() : Boolean
      {
         return $videoReady;
      }
      
      public function getConfigCode() : AdConfigCode
      {
         return $configCode;
      }
      
      public function initalize(param1:AdEventListener) : void
      {
      }
      
      public function showOpen() : void
      {
      }
      
      public function cacheInter() : void
      {
      }
      
      public function showInter() : void
      {
      }
      
      public function showNative(param1:Boolean) : void
      {
      }
      
      public function closeNative() : void
      {
      }
      
      public function cacheVideo() : void
      {
      }
      
      public function playVideo() : void
      {
      }
      
      public function playRewardVideo(param1:String, param2:int, param3:Function, param4:Function) : void
      {
      }
      
      public function onGamePause() : void
      {
      }
      
      public function onGameResume() : void
      {
      }
      
      public function onDeactive() : void
      {
      }
      
      public function onActive() : void
      {
      }
   }
}

