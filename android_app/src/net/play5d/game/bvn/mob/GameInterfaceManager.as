package net.play5d.game.bvn.mob
{
   import flash.desktop.NativeApplication;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.filesystem.File;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.data.ConfigVO;
   import net.play5d.game.bvn.input.IGameInput;
   import net.play5d.game.bvn.interfaces.IExtendConfig;
   import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
   import net.play5d.game.bvn.interfaces.IGameInterface;
   import net.play5d.game.bvn.map.MapMain;
   import net.play5d.game.bvn.mob.ads.AdManager;
   import net.play5d.game.bvn.mob.data.ExtendConfig;
   import net.play5d.game.bvn.mob.input.InputManager;
   import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
   import net.play5d.game.bvn.mob.utils.FileUtils;
   import net.play5d.game.bvn.mob.views.ViewManager;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.utils.GameSafeKeeper;
   import net.play5d.game.bvn.utils.URL;

   public class GameInterfaceManager implements IGameInterface
   {
      private static var _extendsConfig:ExtendConfig = new ExtendConfig();
      public static var ENGLISH_VERSION:Boolean = false;

      public function GameInterfaceManager()
      {
         super();
      }

      public static function get config() : ExtendConfig
      {
         return _extendsConfig;
      }

      public function initTitleUI(param1:DisplayObject) : void
      {
      }

      public function moreGames() : void
      {
         URL.go("http://www.1212321.com/index/",true);
      }

      public function submitScore(param1:int) : void
      {
      }

      public function showRank() : void
      {
      }

      public function saveGame(param1:Object) : void
      {
         var _loc2_:String = JSON.stringify(param1,null,"\t");
         FileUtils.ensureRootFolderExists();
         var _loc3_:File = File.userDirectory.resolvePath(FileUtils.getSaveFilePath());
         FileUtils.writeFile(_loc3_.nativePath,_loc2_);
         trace("saveData",_loc2_);
      }

      public function saveOptions(data:Object) : void
      {
         var json:String = JSON.stringify(data, null, "\t");
         FileUtils.ensureRootFolderExists();
         var optionsFile:File = File.userDirectory.resolvePath(FileUtils.getOptionsFilePath());
         FileUtils.writeFile(optionsFile.nativePath,json);
      }

      public function loadGame() : Object
      {
         var _loc2_:File = File.userDirectory.resolvePath(FileUtils.getSaveFilePath());
         var _loc1_:String = FileUtils.readTextFile(_loc2_.nativePath);
         if(!_loc1_)
         {
            return null;
         }
         return JSON.parse(_loc1_);
      }

      public function loadOptions() : Object
      {
         var optionsFile:File = File.userDirectory.resolvePath(FileUtils.getOptionsFilePath());
         var jsonStr:String = FileUtils.readTextFile(optionsFile.nativePath);
         if(!jsonStr)
         {
            return null;
         }
         try
         {
            return JSON.parse(jsonStr);
         }
         catch(e:Error)
         {
            trace("GameInterfaceManager.loadOptions parse error",e);
            return null;
         }
         return null;
      }

      public function getFighterCtrl(param1:int) : IFighterActionCtrl
      {
         return null;
      }

      public function getGameMenu() : Array
      {
         return [{
            "txt":GetLangText("menu.single_play.label"),
            "cn":GetLangText("menu.single_play.str"),
            "value_cn":535,
            "children":[{
               "txt":GetLangText("menu.single_play.child.arcade.label"),
               "cn":GetLangText("menu.single_play.child.arcade.str"),
               "value_cn":535
            },{
               "txt":GetLangText("menu.single_play.child.musou.label"),
               "cn":GetLangText("menu.single_play.child.musou.str"),
               "value_cn":480
            },{
               "txt":GetLangText("menu.single_play.child.survival.label"),
               "cn":GetLangText("menu.single_play.child.survival.str"),
               "value_cn":425
            }]
         },{
            "txt":GetLangText("menu.versus.label"),
            "cn":GetLangText("menu.versus.str"),
            "value_cn":480,
            "children":[{
               "txt":GetLangText("menu.versus.child.vs_cpu.label"),
               "cn":GetLangText("menu.versus.child.vs_cpu.str"),
               "value_cn":535
            },{
               "txt":GetLangText("menu.versus.child.watch.label"),
               "cn":GetLangText("menu.versus.child.watch.str"),
               "value_cn":480
            },{
               "txt":GetLangText("menu.versus.child.network.label"),
               "cn":GetLangText("menu.verus.child.network.str"),
               "value_cn":425
            }]
         },{
            "txt":GetLangText("menu.training.label"),
            "cn":GetLangText("menu.training.str"),
            "value_cn":425
         },{
            "txt":"OPTION",
            "cn":GetLangText("menu.option.str"),
            "value_cn":370
         },{
            "txt":GetLangText("menu.credits.label"),
            "cn":GetLangText("menu.credits.str"),
            "value_cn":315
         },{
            "txt":GetLangText("menu.exit_game.label"),
            "cn":GetLangText("menu.exit_game.str"),
            "value_cn":260,
            "func":function():void
            {
               GameUI.confrim("EXIT GAME","Want exit?",NativeApplication.nativeApplication.exit);
            }
         }];
      }

      public function getGameInput(param1:String) : Vector.<IGameInput>
      {
         var _loc2_:Vector.<IGameInput> = new Vector.<IGameInput>();
         switch(param1)
         {
            case "MENU":
               _loc2_.push(InputManager.I.screen_menu);
               _loc2_.push(InputManager.I.joy_menu);
               break;
            case "P1":
               _loc2_.push(InputManager.I.screen_p1);
               _loc2_.push(InputManager.I.joy_p1);
               _loc2_.push(InputManager.I.socket_input_p1);
               break;
            case "P2":
               _loc2_.push(InputManager.I.socket_input_p2);
               break;
            default:
               return null;
         }
         return _loc2_;
      }
      
      public function getConfigExtend() : IExtendConfig
      {
         return _extendsConfig;
      }
      
      public function afterBuildGame() : void
      {
         var _loc1_:MapMain = GameCtrl.I.gameState.getMap();
         if(_loc1_.mapLayer)
         {
            _loc1_.mapLayer.cacheAsBitmapMatrix = new Matrix();
         }
         if(_loc1_.frontLayer)
         {
            _loc1_.frontLayer.cacheAsBitmapMatrix = new Matrix();
         }
         if(_loc1_.frontFixLayer)
         {
            _loc1_.frontFixLayer.cacheAsBitmapMatrix = new Matrix();
         }
         if(_loc1_.bgLayer)
         {
            _loc1_.bgLayer.cacheAsBitmap = true;
         }
      }
      
      public function updateInputConfig() : Boolean
      {
         InputManager.I.joy_menu.setConfig(_extendsConfig.joyMenuConfig);
         InputManager.I.joy_p1.setConfig(_extendsConfig.joy1Config);
         InputManager.I.socket_input_p1.enabled = false;
         InputManager.I.socket_input_p2.enabled = false;
         InputManager.I.joy_menu.enabled = true;
         InputManager.I.joy_p1.enabled = true;
         return true;
      }
      
      public function applyConfig(param1:ConfigVO) : void
      {
         switch(param1.quality)
         {
            case "best":
               GameConfig.setGameFps(60);
               GameConfig.FPS_SHINE_EFFECT = 15;
               EffectCtrl.EFFECT_SMOOTHING = true;
               EffectCtrl.SHADOW_ENABLED = true;
               EffectCtrl.SHAKE_ENABLED = true;
               EffectCtrl.BG_BULR_ENABLED = true;
               break;
            case "high":
               GameConfig.setGameFps(60);
               GameConfig.FPS_SHINE_EFFECT = 10;
               EffectCtrl.EFFECT_SMOOTHING = false;
               EffectCtrl.SHADOW_ENABLED = true;
               EffectCtrl.SHAKE_ENABLED = true;
               EffectCtrl.BG_BULR_ENABLED = false;
               break;
            case "medium":
               GameConfig.setGameFps(30);
               GameConfig.FPS_SHINE_EFFECT = 10;
               EffectCtrl.EFFECT_SMOOTHING = false;
               EffectCtrl.SHADOW_ENABLED = true;
               EffectCtrl.SHAKE_ENABLED = true;
               EffectCtrl.BG_BULR_ENABLED = false;
               break;
            case "low":
               GameConfig.setGameFps(30);
               GameConfig.FPS_SHINE_EFFECT = 0;
               EffectCtrl.EFFECT_SMOOTHING = false;
               EffectCtrl.SHADOW_ENABLED = true;
               EffectCtrl.SHAKE_ENABLED = false;
               EffectCtrl.BG_BULR_ENABLED = false;
         }
         if(GameConfig.PIXEL_STYLE_MODE)
         {
            EffectCtrl.EFFECT_SMOOTHING = false;
         }
         RootSprite.I.updateSize();
         ScreenPadManager.reBuild();
      }
      
      public function getCreadits(param1:String) : Sprite
      {
         var _loc4_:Sprite = new Sprite();
         param1 += "Youtube  : <a href=\"" + URL.markURL("https://youtube.com/@MiokoTech") + "\" target=\"_blank\">MiokoTech</a>" + "<br/>";
         param1 += "游戏官网 : <a href=\"" + URL.markURL("http://www.1212321.com/") + "\" target=\"_blank\">www.1212321.com</a>" + "<br/>";
         param1 += "游戏论坛 : <a href=\"" + URL.markURL("http://bbs.1212321.com/") + "\" target=\"_blank\">bbs.1212321.com</a>" + "<br/>";
         var _loc2_:TextField = new TextField();
         var _loc3_:TextFormat = new TextFormat();
         _loc3_.font = "微软雅黑";
         _loc3_.size = 20;
         _loc3_.color = 16776960;
         _loc3_.leading = 15;
         _loc2_.defaultTextFormat = _loc3_;
         _loc2_.multiline = true;
         if(ENGLISH_VERSION)
         {
            _loc2_.htmlText = "website : <a href=\"" + URL.markURL("http://www.1212321.com/") + "\" target=\"_blank\">www.1212321.com</a>" + "<br/>" + "bbs : <a href=\"" + URL.markURL("http://bbs.1212321.com/") + "\" target=\"_blank\">bbs.1212321.com</a>" + "<br/>";
         }
         else
         {
            _loc2_.htmlText = param1;
         }
         _loc2_.autoSize = "left";
         _loc2_.x = 50;
         _loc2_.y = 30;
         _loc4_.addChild(_loc2_);
         return _loc4_;
      }
      
      public function checkFile(param1:String, param2:ByteArray) : Boolean
      {
         return GameSafeKeeper.I.checkFile(param1,param2);
      }
      
      public function addMosouMoney(param1:Function) : void
      {
         var back:Function = param1;
         var succ:* = function():void
         {
            back(addMoney);
         };
         var fail:* = function():void
         {
            GameUI.alert("FAIL","广告加载失败或正在加载");
         };
         var watchAD:* = function():void
         {
            AdManager.I.showRewardVideo("金币",addMoney,succ,fail);
         };
         var addMoney:int = 1000 + Math.random() * 2000;
         GameUI.confrim("ADD MONEY","观看广告获得 1000-3000 金币! \n (制作不易，跪求支持)",watchAD);
      }
   }
}

