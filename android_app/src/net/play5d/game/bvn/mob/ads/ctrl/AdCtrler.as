package net.play5d.game.bvn.mob.ads.ctrl
{
   import flash.events.EventDispatcher;
   import flash.utils.clearTimeout;
   import net.play5d.game.bvn.mob.ads.AdConfigCode;
   import net.play5d.game.bvn.mob.ads.AdManager;
   import net.play5d.game.bvn.mob.ads.utils.AdEvent;
   import net.play5d.game.bvn.mob.ads.utils.IAd;
   import net.play5d.game.bvn.mob.data.AdConfVO;
   import net.play5d.game.bvn.mob.utils.TimerOutUtils;
   
   public class AdCtrler extends EventDispatcher
   {
      public static var SHOW_OPENAD_ON_START:Boolean = true;
      
      public static var SMART_ONLY_VIDEO:Boolean = false;
      
      private var _showAdTimes:int;
      
      private const _showAdTimesTotal:int = 1;
      
      private var _showVideoAdTimes:int;
      
      private const _showVideoAdTimesTotal:int = 2;
      
      private var _initSdkBack:Function;
      
      private var _openCloseBack:Function;
      
      private var _showOpenAdTimer:int;
      
      private var _adGroup:AdGroup;
      
      private var _adConfMap:Object = {};
      
      public function AdCtrler()
      {
         super();
      }
      
      public function avaliable() : Boolean
      {
         return _adGroup && _adGroup.avaliable();
      }
      
      public function initAD(param1:Vector.<IAd>, param2:Boolean = false, param3:Function = null, param4:Function = null) : void
      {
         _initSdkBack = param3;
         _openCloseBack = param4;
         initAdGroup(param1,param2);
      }
      
      public function updatePolity(param1:Vector.<AdConfVO>) : void
      {
         var _loc3_:AdConfDir = null;
         trace("============= update AD polity ============");
         for each(var _loc2_:AdConfVO in param1)
         {
            trace(" config settings ------ ");
            trace(_loc2_.toString());
            _loc3_ = _adConfMap[_loc2_.code];
            if(_loc3_ && _loc3_.ad && _loc3_.type)
            {
               _loc3_.ad.setRank(_loc3_.type,_loc2_.rank);
               _loc3_.ad.setRate(_loc3_.type,_loc2_.rate);
               _loc3_.ad.setADEnabled(_loc3_.type,_loc2_.enabled);
               trace(" CONFIG PARAM [" + _loc2_.code + "] :: " + _loc3_.toString());
            }
            else
            {
               trace(" CONFIG PARAM [" + _loc2_.code + "] not match ------ ");
            }
         }
         trace("============= update AD polity END ============");
      }
      
      private function initAdGroup(param1:Vector.<IAd>, param2:Boolean = false) : void
      {
         _adGroup = new AdGroup();
         _adGroup.addEventListener("METHOD_CALL",methodCallHandler);
         _adGroup.addEventListener("AD_ACTION",adActionHandler);
         for each(var _loc3_:IAd in param1)
         {
            _adGroup.add(_loc3_);
         }
         if(param2 && param1.length == 1)
         {
            _adGroup.onlyOneAd = param1[0];
         }
         _adGroup.initalize();
         initConfMap();
      }
      
      private function initConfMap() : void
      {
         var i:IAd;
         var configCode:AdConfigCode;
         var setConf:* = function(param1:String, param2:IAd, param3:String):void
         {
            if(param1 != null)
            {
               _adConfMap[param1] = new AdConfDir(param1,param2,param3);
            }
         };
         _adConfMap = {};
         for each(i in _adGroup.getAdList())
         {
            configCode = i.getConfigCode();
            setConf(configCode.open,i,"OPEN");
            setConf(configCode.inter,i,"INTER");
            setConf(configCode.video,i,"VIDEO");
            setConf(configCode.rewardVideo,i,"REWARD_VIDEO");
         }
      }
      
      private function adActionHandler(param1:AdEvent) : void
      {
         if(param1.adAction == "INIT_OK")
         {
            if(_initSdkBack != null)
            {
               _initSdkBack();
               _initSdkBack = null;
            }
            if(SHOW_OPENAD_ON_START)
            {
               if(Boolean(_openCloseBack))
               {
                  _showOpenAdTimer = TimerOutUtils.setTimeout(openCloseBack,8000);
               }
               AdManager.I.showAd("OPEN");
            }
            else
            {
               openCloseBack();
            }
         }
         if(param1.adAction == "INIT_FAIL")
         {
         }
         if(param1.adAction == "SHOW")
         {
            if(param1.adType == "OPEN")
            {
               clearTimeout(_showOpenAdTimer);
            }
            if(param1.adType == "VIDEO")
            {
            }
         }
         if(param1.adAction == "CLOSE")
         {
            if(param1.adType == "OPEN")
            {
               openCloseBack();
            }
            if(param1.adType == "VIDEO")
            {
               _adGroup.cacheVideo();
            }
            if(param1.adType == "INTER")
            {
               _adGroup.cacheInter();
            }
         }
         if(param1.adAction == "CLICK")
         {
            if(param1.adType == "INTER")
            {
               _showAdTimes = 0;
            }
            if(param1.adType == "VIDEO")
            {
               _showVideoAdTimes = 0;
            }
         }
         if(param1.adAction == "ERROR")
         {
            if(param1.adType == "OPEN")
            {
               openCloseBack();
            }
            if(param1.adType == "VIDEO")
            {
            }
         }
         dispatchEvent(new AdEvent(param1.type,param1.adAction,param1.adType,param1.ad));
      }
      
      private function methodCallHandler(param1:AdEvent) : void
      {
         dispatchEvent(new AdEvent(param1.type,param1.adAction,param1.adType,param1.ad));
      }
      
      public function cancelInitBack() : void
      {
         clearTimeout(_showOpenAdTimer);
         _initSdkBack = null;
         _openCloseBack = null;
      }
      
      private function openCloseBack() : void
      {
         clearTimeout(_showOpenAdTimer);
         if(Boolean(_openCloseBack))
         {
            _openCloseBack();
            _openCloseBack = null;
         }
      }
      
      public function showSmartAd() : void
      {
         if(SMART_ONLY_VIDEO)
         {
            AdManager.I.showAd("VIDEO");
            return;
         }
         _showVideoAdTimes++;
         if(_showVideoAdTimes >= 2)
         {
            _showVideoAdTimes = 0;
            AdManager.I.showAd("VIDEO");
            return;
         }
         AdManager.I.showAd("NATIVE");
      }
      
      public function showInterAdOrVideoAd() : void
      {
         showInterAd();
      }
      
      public function showInterAd() : void
      {
         _adGroup.showInter();
      }
      
      public function cacheInterAd() : void
      {
         _adGroup.cacheInter();
      }
      
      public function cacheVideoAd() : void
      {
         _adGroup.cacheVideo();
      }
      
      public function showVideoAd() : void
      {
         _adGroup.showVideo();
      }
      
      public function showRewardVideoAd(param1:String, param2:int, param3:Function, param4:Function) : void
      {
         _adGroup.showRewardVideo(param1,param2,param3,param4);
      }
      
      public function showOpenAd() : void
      {
         if(!_adGroup.showOpen())
         {
            openCloseBack();
         }
      }
      
      public function onPause() : void
      {
         _adGroup.onGamePause();
      }
      
      public function onResume() : void
      {
         _adGroup.onGameResume();
      }
      
      public function onDeactive() : void
      {
         _adGroup.onDeactive();
      }
      
      public function onActive() : void
      {
         _adGroup.onActive();
      }
      
      public function showNativeAd(param1:Boolean) : void
      {
         _adGroup.showNativeAd(param1);
      }
      
      public function closeNativeAd() : void
      {
         _adGroup.closeNativeAd();
      }
   }
}

