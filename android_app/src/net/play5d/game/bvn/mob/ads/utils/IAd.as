package net.play5d.game.bvn.mob.ads.utils
{
   import net.play5d.game.bvn.mob.ads.AdConfigCode;
   
   public interface IAd
   {
      function getEnabled() : Boolean;
      
      function initalize(param1:AdEventListener) : void;
      
      function exceptDate() : Date;
      
      function getRank(param1:String) : int;
      
      function setRank(param1:String, param2:int) : void;
      
      function getRate(param1:String) : Number;
      
      function setRate(param1:String, param2:Number) : void;
      
      function getADEnabled(param1:String) : Boolean;
      
      function setADEnabled(param1:String, param2:Boolean) : void;
      
      function showOpen() : void;
      
      function cacheInter() : void;
      
      function interReady() : Boolean;
      
      function showInter() : void;
      
      function showNative(param1:Boolean) : void;
      
      function closeNative() : void;
      
      function cacheVideo() : void;
      
      function videoReady() : Boolean;
      
      function playVideo() : void;
      
      function playRewardVideo(param1:String, param2:int, param3:Function, param4:Function) : void;
      
      function onGamePause() : void;
      
      function onGameResume() : void;
      
      function getName() : String;
      
      function onDeactive() : void;
      
      function onActive() : void;
      
      function getConfigCode() : AdConfigCode;
   }
}

