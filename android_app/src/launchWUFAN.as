package
{
   import com.miokotech.audioroute.GameAudio;
   import com.miokotech.storageaccess.StorageAccess;
   import flash.desktop.NativeApplication;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageQuality;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.mob.ads.AdManager;
   import net.play5d.game.bvn.mob.AssetLoader;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.mob.SwfLib;
   import net.play5d.game.bvn.mob.ctrls.MobileCtrler;
   import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
   import net.play5d.game.bvn.mob.utils.FileUtils;
   import net.play5d.game.bvn.mob.utils.MultiLangUtils;
   import net.play5d.game.bvn.mob.utils.TimerOutUtils;
   import net.play5d.game.bvn.mob.utils.UIAssetUtil;
   import net.play5d.game.bvn.ui.UIUtils;
   import net.play5d.game.bvn.ui.fight.FightUI;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.game.bvn.utils.URL;
   
   [SWF(width='1280', height='720', frameRate='30', backgroundColor='#000000')]
   public class launchWUFAN extends Sprite
   {
      [Embed(source='/../assets/startup.jpg')]
      private var startupBitmap:Class;

      private var _startBitmap:Bitmap;
      private var _sdkTimer:int;
      private var _isActive:Boolean = true;
      private var _preInited:Boolean = false;
      private var _assetLoader:AssetLoader = new AssetLoader();

      public function launchWUFAN()
      {
         if(stage)
         {
            initlize();
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,initlize);
         }
      }

      private function initlize(e:Event = null) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,initlize);
         stage.align = StageAlign.TOP_LEFT;
         stage.scaleMode = StageScaleMode.NO_SCALE;
         if(GameConfig.PIXEL_STYLE_MODE)
         {
            stage.quality = StageQuality.LOW;
         }
         showStartPic();
         GameConfig.TOUCH_MODE = true;

         // Check standard storage permissions on startup
         // Option A: Automatically open app permission settings if not yet granted
         try
         {
            if(!StorageAccess.instance.hasPermission())
            {
               StorageAccess.instance.requestStorageAccess();
            }
            else
            {
               FileUtils.ensureRootFolderExists();
            }
         }
         catch(storageCheckError:Error)
         {
            trace("launchWUFAN storage permission check error:", storageCheckError);
            FileUtils.ensureRootFolderExists();
         }

         _sdkTimer = TimerOutUtils.setTimeout(initGame,6000);
      }

      private function showStartPic() : void
      {
         RootSprite.STAGE = stage;
         RootSprite.I.init(this);
         RootSprite.I.updateFullScreenSize();
         stage.addEventListener(Event.DEACTIVATE,activeHandler);
         stage.addEventListener(Event.ACTIVATE,activeHandler);
         _startBitmap = new startupBitmap();
         _startBitmap.width = RootSprite.FULL_SCREEN_SIZE.x;
         _startBitmap.height = RootSprite.FULL_SCREEN_SIZE.y;
         addChild(_startBitmap);
      }

      private function preInitGame() : void
      {
         if(_preInited)
         {
            return;
         }
         _preInited = true;
      }

      private function removeStartBitmap() : void
      {
         if(_startBitmap)
         {
            try
            {
               removeChild(_startBitmap);
            }
            catch(e:Error)
            {
            }
            _startBitmap.bitmapData.dispose();
            _startBitmap = null;
         }
      }

      private function initGame() : void
      {
         GameAudio.init();
         TimerOutUtils.clearTimeout(_sdkTimer);
         preInitGame();
         removeStartBitmap();
         stage.addEventListener(KeyboardEvent.KEY_DOWN,keyHandler);
         stage.addEventListener(Event.RESIZE,RootSprite.I.updateFullScreenSize);
         ResUtils.swfLib = new SwfLib();
         AssetManager.I.setAssetLoader(_assetLoader);
         MultiLangUtils.I.initialize();
         GameInterface.instance = new GameInterfaceManager();
         GameData.I.config.difficulty = 1;
         GameData.I.config.quality = "high";
         GameData.I.config.keyInputMode = 1;
         GameConfig.SHOW_HOW_TO_PLAY = true;
         UIUtils.LOCK_FONT = "Droid Sans Fallback";
         URL.MARK = "bvn_mobV3.7";
         ScreenPadManager.initlize(stage);
         UIAssetUtil.I.initalize(buildGame);
      }

      private function activeHandler(e:Event) : void
      {
         if(e.type == "deactivate")
         {
            if(!_isActive)
            {
               return;
            }
            _isActive = false;
            TimerOutUtils.pauseAllTimer();
            MobileCtrler.I.pause();
            AdManager.I.onDeactive();
         }
         else
         {
            if(_isActive)
            {
               return;
            }
            _isActive = true;
            TimerOutUtils.resumeAllTimer();
            MobileCtrler.I.resume();
            AdManager.I.onActive();

            // When returning from Android App Settings, re-check and ensure root folder exists
            try
            {
               if(StorageAccess.instance.hasPermission())
               {
                  FileUtils.ensureRootFolderExists();
               }
            }
            catch(activePermError:Error)
            {
            }
         }
      }

      private function keyHandler(e:KeyboardEvent) : void
      {
         if(e.keyCode == Keyboard.BACK)
         {
            e.preventDefault();
         }
      }

      private function buildGame() : void
      {
         RootSprite.I.buildGame(initBackHandler,initFailHandler);
         GameEvent.addEventListener(GameEvent.ENTER_SINGLE_STAGE,this.enterStageHandler);
         GameEvent.addEventListener(GameEvent.ENTER_TEAM_STAGE,this.enterStageHandler);
         GameEvent.addEventListener(GameEvent.ENTER_TRAIN_STAGE,this.enterStageHandler);
         GameEvent.addEventListener(GameEvent.ENTER_MOSOU_STAGE,this.enterStageHandler);
      }

      private function enterStageHandler(e:GameEvent) : void
      {
         switch(e.type)
         {
            case GameEvent.ENTER_SINGLE_STAGE:
               break;
            case GameEvent.ENTER_TEAM_STAGE:
               break;
            case GameEvent.ENTER_TRAIN_STAGE:
               break;
            case GameEvent.ENTER_MOSOU_STAGE:
         }
      }

      private function initBackHandler() : void
      {
         ScreenPadManager.listen();
         FightUI.QI_BAR_MODE = 1;
         RootSprite.I.getMainGame().goLogo();
      }

      private function initFailHandler(errorMessage:String) : void
      {
         NativeApplication.nativeApplication.exit();
      }
   }
}
