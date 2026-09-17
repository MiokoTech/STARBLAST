package net.play5d.game.bvn.ui
{
   import flash.display.DisplayObject;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.ui.dialog.AlertUI;
   import net.play5d.game.bvn.ui.dialog.ConfrimUI;
   import net.play5d.game.bvn.ui.dialog.DialogManager;
   import net.play5d.game.bvn.ui.fight.FightUI;
   import net.play5d.game.bvn.ui.mosou.MosouUI;
   
   public class GameUI
   {
      public static var I:GameUI;
      
      private static var _confrimUI:ConfrimUI;
      
      private static var _alertUI:AlertUI;
      
      public static var BITMAP_UI:Boolean = true;
      
      public static var SHOW_CN_TEXT:Boolean = true;
      
      public static var SHOW_HP_TEXT:Boolean = false;
      
      private var _ui:IGameUI;
      
      private var _renderAnimateGap:int;
      
      private var _renderAnimateFrame:int = 0;
      
      public function GameUI()
      {
         super();
         I = this;
         SHOW_HP_TEXT = GameMode.currentMode == 40;
         _renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / 30) - 1;
      }
      
      public static function showingDialog() : Boolean
      {
         return _confrimUI != null || _alertUI != null;
      }
      
      public static function showingConfrim() : Boolean
      {
         return _confrimUI != null;
      }
      
      public static function showingAlert() : Boolean
      {
         return _alertUI != null;
      }
      
      public static function confrim(param1:String = null, param2:String = null, param3:Function = null, param4:Function = null) : void
      {
         var enMsg:String = param1;
         var cnMsg:String = param2;
         var yes:Function = param3;
         var no:Function = param4;
         var yesClose:* = function():void
         {
            if(yes != null)
            {
               yes();
            }
            closeConfrim();
         };
         var noClose:* = function():void
         {
            if(no != null)
            {
               no();
            }
            closeConfrim();
            GameEvent.dispatchEvent("UI_CONFRIM_CLOSE");
         };
         closeConfrim();
         _confrimUI = new ConfrimUI();
         _confrimUI.setMsg(enMsg,cnMsg);
         _confrimUI.yesBack = yesClose;
         _confrimUI.noBack = noClose;
         GameEvent.dispatchEvent("UI_CONFRIM");
         DialogManager.showDialog(_confrimUI,false);
      }
      
      public static function alert(param1:String = null, param2:String = null, param3:Function = null) : void
      {
         var enMsg:String = param1;
         var cnMsg:String = param2;
         var close:Function = param3;
         var closeBack:* = function():void
         {
            if(close != null)
            {
               close();
            }
            closeAlert();
            GameEvent.dispatchEvent("UI_ALERT_CLOSE");
         };
         closeAlert();
         _alertUI = new AlertUI();
         _alertUI.setMsg(enMsg,cnMsg);
         _alertUI.yesBack = closeBack;
         DialogManager.showDialog(_alertUI,false);
         GameEvent.dispatchEvent("UI_ALERT",{
            "enMsg":enMsg,
            "cnMsg":cnMsg
         });
      }
      
      public static function closeAlert() : void
      {
         if(_alertUI)
         {
            DialogManager.closeDialog(_alertUI);
            _alertUI = null;
         }
      }
      
      public static function closeConfrim() : void
      {
         if(_confrimUI)
         {
            DialogManager.closeDialog(_confrimUI);
            _confrimUI = null;
         }
      }
      
      public static function cancelConfrim() : void
      {
         if(_confrimUI)
         {
            if(_confrimUI.noBack != null)
            {
               _confrimUI.noBack();
            }
            else
            {
               closeConfrim();
            }
         }
      }
      
      public function getUI() : IGameUI
      {
         return _ui;
      }
      
      public function getUIDisplay() : DisplayObject
      {
         return _ui.getUI();
      }
      
      public function initFight(param1:GameRunFighterGroup, param2:GameRunFighterGroup) : void
      {
         var _loc3_:Number = GameData.I.config.soundVolume;
         if(_ui)
         {
            if(_ui is FightUI == false)
            {
               _ui.destory();
               _ui = new FightUI();
               _ui.setVolume(_loc3_);
            }
         }
         else
         {
            _ui = new FightUI();
            _ui.setVolume(_loc3_);
         }
         (_ui as FightUI).initlize(param1,param2);
      }
      
      public function initMission(param1:GameRunFighterGroup) : void
      {
         var _loc2_:Number = GameData.I.config.soundVolume;
         if(_ui)
         {
            if(_ui is FightUI == false)
            {
               _ui.destory();
               _ui = new FightUI();
               _ui.setVolume(_loc2_);
            }
         }
         else
         {
            _ui = new MosouUI();
            _ui.setVolume(_loc2_);
         }
         (_ui as MosouUI).initlize(param1);
      }
      
      public function render() : void
      {
         if(!_ui)
         {
            return;
         }
         _ui.render();
         if(isRenderAnimate())
         {
            renderAnimate();
         }
      }
      
      private function renderAnimate() : void
      {
         if(_ui)
         {
            _ui.renderAnimate();
         }
      }
      
      private function isRenderAnimate() : Boolean
      {
         if(_renderAnimateGap > 0)
         {
            if(_renderAnimateFrame++ >= _renderAnimateGap)
            {
               _renderAnimateFrame = 0;
               return true;
            }
            return false;
         }
         return true;
      }
      
      public function fadIn() : void
      {
         var _loc1_:Number = NaN;
         if(_ui)
         {
            _loc1_ = GameData.I.config.soundVolume;
            _ui.fadIn();
            _ui.setVolume(_loc1_);
         }
      }
      
      public function fadOut() : void
      {
         if(_ui)
         {
            _ui.fadIn();
         }
      }
      
      public function destory() : void
      {
         if(_ui)
         {
            _ui.destory();
         }
      }
   }
}

