package net.play5d.game.bvn.state
{
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.ConfigVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.KeyConfigVO;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.interfaces.IInnerSetUI;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.mob.views.CustomScreenBtnView;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   import net.play5d.game.bvn.ui.SetCtrlBtnUI;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.stage.Istage;

   public class SettingState implements Istage
   {
      private var _ui:MovieClip;

      private var _btnGroup:SetBtnGroup;
      private var _innerSetUI:IInnerSetUI;

      public function SettingState()
      {
         super();
      }

      public function get display() : DisplayObject
      {
         return _ui;
      }

      public function build() : void
      {
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting,ResUtils.SETTING) as MovieClip;
         _btnGroup = new SetBtnGroup();
         _btnGroup.startY = 250;
         _btnGroup.startX = 95;
         _btnGroup.endY = 550;
         _btnGroup.gap = 45;
         _btnGroup.initWithTab();
         _btnGroup.addEventListener(SetBtnEvent.SELECT, onBtnSelect);
         _btnGroup.addEventListener(SetBtnEvent.OPTION_CHANGE, onOptionChange);
         _ui.addChild(_btnGroup);
         SoundCtrl.I.BGM(AssetManager.I.getSound("option"));
      }

      private function onOptionChange(e:SetBtnEvent) : void
      {
         var config:ConfigVO = GameData.I.config;
         config.setValueByKey(e.optionKey, e.optionValue);
      }

      private function onBtnSelect(e:SetBtnEvent) : void
      {
         switch(e.selectedLabel)
         {
            case "P1 KEY SET":
               goKeyConfig(1,GameData.I.config.key_p1);
               break;
            case "P2 KEY SET":
               goKeyConfig(2,GameData.I.config.key_p2);
               break;
            case "Screenpad Layout":
               var csb:CustomScreenBtnView = new CustomScreenBtnView();
               RootSprite.I.addChild(csb.getDisplay());
               break;
            case "APPLY":
               GameData.I.saveOptionsData();
               GameData.I.config.applyConfig();
               GameInputer.updateConfig();
               MainGame.I.goMenu();
         }
      }

      private function goKeyConfig(player:int, key:KeyConfigVO) : void
      {
         var setBtnUI:SetCtrlBtnUI = new SetCtrlBtnUI();
         setBtnUI.setKey(key);

         goInnerSetPage(setBtnUI);
      }

      public function goInnerSetPage(param1:IInnerSetUI) : void
      {
         var innerUI:IInnerSetUI = param1;
         var tweenComplete:* = function():void
         {
            _btnGroup.visible = false;
         };
         destoryInnerSetUI();
         _innerSetUI = innerUI;

         innerUI.addEventListener(SetBtnEvent.APPLY_SET, innerSetHandler);
         innerUI.addEventListener(SetBtnEvent.CANCEL_SET, innerSetHandler);

         _ui.addChild(innerUI.getUI());
         innerUI.fadIn();
         TweenLite.to(_btnGroup,0.2,{
            "y":-GameConfig.GAME_SIZE.y,
            "onComplete":tweenComplete
         });
         _btnGroup.keyEnable = false;
      }

      private function destoryInnerSetUI() : void
      {
         if(_innerSetUI)
         {
            try
            {
               _ui.removeChild(_innerSetUI.getUI());
            }
            catch(e:Error)
            {
            }
            _innerSetUI.removeEventListener(SetBtnEvent.APPLY_SET, innerSetHandler);
            _innerSetUI.removeEventListener(SetBtnEvent.CANCEL_SET, innerSetHandler);
            _innerSetUI.destory();
            _innerSetUI = null;
         }
      }

      private function goMainSetting() : void
      {
         var tweenComplete:* = function():void
         {
            _btnGroup.keyEnable = true;
         };
         TweenLite.to(_btnGroup,0.2,{
            "y":0,
            "onComplete":tweenComplete,
            "delay":0.1
         });
         _btnGroup.visible = true;
         if(_innerSetUI)
         {
            _innerSetUI.fadOut();
            _innerSetUI.removeEventListener(SetBtnEvent.APPLY_SET, innerSetHandler);
            _innerSetUI.removeEventListener(SetBtnEvent.CANCEL_SET, innerSetHandler);
         }
      }

      private function innerSetHandler(param1:String) : void
      {
         goMainSetting();
      }

      public function afterBuild() : void
      {
      }

      public function destory(param1:Function = null) : void
      {
         if(_btnGroup)
         {
            try
            {
               _ui.removeChild(_btnGroup);
            }
            catch(e:Error)
            {
            }
            _btnGroup.removeEventListener(SetBtnEvent.SELECT, onBtnSelect);
            _btnGroup.removeEventListener(SetBtnEvent.OPTION_CHANGE, onOptionChange);
            _btnGroup.destory();
            _btnGroup = null;
         }
         destoryInnerSetUI();
      }
   }
}

