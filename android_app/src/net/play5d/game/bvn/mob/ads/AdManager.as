package net.play5d.game.bvn.mob.ads
{
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.mob.ads.ctrl.AdCtrler;
   import net.play5d.game.bvn.mob.ads.utils.AdEvent;
   import net.play5d.game.bvn.mob.ads.utils.IAd;
   import net.play5d.game.bvn.mob.ctrls.GamePolyCtrl;
   import net.play5d.game.bvn.mob.ctrls.MobileCtrler;
   import net.play5d.game.bvn.mob.utils.TimerOutUtils;
   
   public class AdManager
   {
      private static var _i:AdManager;
      
      public static var DEBUG:Boolean = false;
      
      private var _adCtrler:AdCtrler;
      
      private var _showMenuTimes:int;
      
      private var _showingAdType:Object = {};
      
      public var customGameEventHandler:Function = null;
      
      public function AdManager()
      {
         super();
         _adCtrler = new AdCtrler();
         _adCtrler.addEventListener("AD_ACTION",adEventHandler);
      }
      
      public static function get I() : AdManager
      {
         if(!_i)
         {
            _i = new AdManager();
         }
         return _i;
      }
      
      public static function toast(param1:String) : void
      {
         if(!DEBUG)
         {
            return;
         }
      }
      
      private function adEventHandler(param1:AdEvent) : void
      {
         switch(param1.adType)
         {
            case "OPEN":
               if(param1.adAction == "SHOW")
               {
                  _showingAdType["OPEN"] = true;
               }
               if(param1.adAction == "CLOSE" || param1.adAction == "ERROR")
               {
                  _showingAdType["OPEN"] = false;
               }
               break;
            case "VIDEO":
               if(param1.adAction == "SHOW")
               {
                  _showingAdType["VIDEO"] = true;
                  _showMenuTimes = 0;
                  MobileCtrler.I.adPause();
               }
               if(param1.adAction == "CLOSE" || param1.adAction == "ERROR")
               {
                  _showingAdType["VIDEO"] = false;
                  MobileCtrler.I.adResume();
               }
               break;
            case "INTER":
               if(param1.adAction == "SHOW")
               {
                  _showingAdType["INTER"] = true;
               }
               if(param1.adAction == "CLOSE" || param1.adAction == "ERROR")
               {
                  _showingAdType["INTER"] = false;
               }
               break;
            case "REWARD_VIDEO":
               if(param1.adAction == "SHOW")
               {
                  _showingAdType["REWARD_VIDEO"] = true;
                  GameCtrl.I.pause(true);
               }
               if(param1.adAction == "CLOSE" || param1.adAction == "ERROR")
               {
                  _showingAdType["REWARD_VIDEO"] = false;
               }
               break;
            case "NATIVE":
               if(param1.adAction == "SHOW")
               {
                  _showingAdType["NATIVE"] = true;
               }
               if(param1.adAction == "CLOSE" || param1.adAction == "ERROR")
               {
                  _showingAdType["NATIVE"] = false;
               }
         }
      }
      
      public function initAD(param1:Vector.<IAd>, param2:Boolean = false, param3:Function = null, param4:Function = null) : void
      {
         if(param1.length < 1)
         {
            param3();
            param4();
            return;
         }
         _adCtrler.initAD(param1,param2,param3,param4);
      }
      
      public function updatePolity() : void
      {
         if(!_adCtrler.avaliable())
         {
            return;
         }
         _adCtrler.updatePolity(GamePolyCtrl.I.getAdConf());
      }
      
      public function cancelInitBack() : void
      {
         if(!_adCtrler.avaliable())
         {
            return;
         }
         _adCtrler.cancelInitBack();
      }
      
      public function beforeGameInit() : void
      {
         if(!_adCtrler.avaliable())
         {
            return;
         }
         GameEvent.addEventListener("PAUSE_GAME",gameEventHandler);
         GameEvent.addEventListener("RESUME_GAME",gameEventHandler);
         GameEvent.addEventListener("GAME_OVER_CONTINUE",gameEventHandler);
         GameEvent.addEventListener("GAME_OVER",gameEventHandler);
         GameEvent.addEventListener("SHOW_WINNER",gameEventHandler);
         GameEvent.addEventListener("MOSOU_MISSION_FINISH",gameEventHandler);
         GameEvent.addEventListener("LOAD_GAME_START",gameEventHandler);
         GameEvent.addEventListener("LOAD_GAME_COMPLETE",gameEventHandler);
         GameEvent.addEventListener("MOSOU_LOADING_START",gameEventHandler);
         GameEvent.addEventListener("MOSOU_LOADING_FINISH",gameEventHandler);
         GameEvent.addEventListener("CONFRIM_BACK_MENU",gameEventHandler);
         GameEvent.addEventListener("CONFRIM_MOSOU_NEXT_MISSION",gameEventHandler);
      }
      
      public function onGameInited() : void
      {
         if(!_adCtrler.avaliable())
         {
            return;
         }
         _adCtrler.cacheInterAd();
         TimerOutUtils.setTimeout(_adCtrler.cacheVideoAd,2000);
      }
      
      private function gameEventHandler(param1:GameEvent) : void
      {
         if(customGameEventHandler != null)
         {
            if(customGameEventHandler(param1))
            {
               return;
            }
         }
         switch(param1.type)
         {
            case "PAUSE_GAME":
               showAd("INTER");
               break;
            case "RESUME_GAME":
               break;
            case "GAME_OVER_CONTINUE":
               showAd("VIDEO");
               break;
            case "GAME_OVER":
               break;
            case "SHOW_WINNER":
               _adCtrler.showSmartAd();
               break;
            case "MOSOU_MISSION_FINISH":
               _adCtrler.showSmartAd();
               break;
            case "LOAD_GAME_START":
               AdManager.toast("GameEvent.LOAD_GAME_START");
               _adCtrler.showNativeAd(false);
               break;
            case "LOAD_GAME_COMPLETE":
               AdManager.toast("GameEvent.LOAD_GAME_COMPLETE");
               _adCtrler.closeNativeAd();
               _showingAdType["NATIVE"] = false;
               break;
            case "CONFRIM_BACK_MENU":
               showAd("NATIVE");
         }
      }
      
      public function isShowingAd(param1:*) : Boolean
      {
         var _loc2_:Array = null;
         if(param1 is Array)
         {
            _loc2_ = param1;
            for each(var _loc3_:String in _loc2_)
            {
               if(_showingAdType[_loc3_])
               {
                  return true;
               }
            }
            return false;
         }
         return _showingAdType[param1] === true;
      }
      
      public function showAd(param1:String) : void
      {
         if(isShowingAd(param1))
         {
            return;
         }
         if(isShowingAd(["INTER","VIDEO","REWARD_VIDEO","NATIVE"]))
         {
            return;
         }
         switch(param1)
         {
            case "OPEN":
               _adCtrler.showOpenAd();
               break;
            case "INTER":
               _adCtrler.showInterAd();
               break;
            case "VIDEO":
               _adCtrler.showVideoAd();
               break;
            case "NATIVE":
               _adCtrler.showNativeAd(true);
         }
      }
      
      public function onDeactive() : void
      {
         if(!_adCtrler.avaliable())
         {
            return;
         }
         _adCtrler.onDeactive();
      }
      
      public function onActive() : void
      {
         if(!_adCtrler.avaliable())
         {
            return;
         }
         _adCtrler.onActive();
      }
      
      public function onPause() : void
      {
         if(!_adCtrler.avaliable())
         {
            return;
         }
         _adCtrler.onPause();
      }
      
      public function onResume() : void
      {
         if(!_adCtrler.avaliable())
         {
            return;
         }
         _adCtrler.onResume();
      }
      
      public function checkPackage() : Boolean
      {
         return true;
      }
      
      public function showRewardVideo(param1:String, param2:int, param3:Function, param4:Function) : void
      {
         if(!_adCtrler.avaliable())
         {
            return;
         }
         _showingAdType = {};
         _adCtrler.showRewardVideoAd(param1,param2,param3,param4);
      }
   }
}

