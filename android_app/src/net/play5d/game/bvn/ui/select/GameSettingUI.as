package net.play5d.game.bvn.ui.select
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.data.ConfigVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   import net.play5d.game.bvn.utils.ResUtils;
   
   public class GameSettingUI extends Sprite
   {
      private var _ui:Sprite;
      
      private var _btnGroup:SetBtnGroup;
      
      public function GameSettingUI()
      {
         super();
         build();
      }
      
      private function build() : void
      {
         try
         {
            _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting,"setting_game") as Sprite;
         }
         catch(e:Error)
         {
            _ui = null;
            trace("GameSettingUI setting.swf setting_game load failed:",e);
         }
         if(_ui == null)
         {
            _ui = buildFallbackSettingGameUI();
         }
         _ui.visible = true;
         _btnGroup = new SetBtnGroup();
         _btnGroup.startX = 260;
         _btnGroup.startY = 285;
         _btnGroup.endY = 300;
         _btnGroup.gap = 50;
         _btnGroup.setBtnData([{
            "label":"Game Difficulty",
            "cn":"",
            "options":[{
               "label":"Easy",
               "cn":"",
               "value":1
            },{
               "label":"Normal",
               "cn":"",
               "value":2
            },{
               "label":"Hard",
               "cn":"",
               "value":3
            },{
               "label":"Very Hard",
               "cn":"",
               "value":4
            }],
            "optoinKey":"difficulty"
         },{
            "label":"Game Rounds",
            "cn":"",
            "options":[{
               "label":"1",
               "cn":"",
               "value":1
            },{
               "label":"2",
               "cn":"",
               "value":2
            },{
               "label":"3",
               "cn":"",
               "value":3
            }],
            "optoinKey":"rounds"
         },{
            "label":"Player 1",
            "cn":"",
            "options":[{
               "label":"1",
               "cn":"",
               "value":1
            },{
               "label":"2",
               "cn":"",
               "value":2
            },{
               "label":"3",
               "cn":"",
               "value":3
            }],
            "optoinKey":"player1"
         },{
            "label":"Player 2",
            "cn":"",
            "options":[{
               "label":"1",
               "cn":"",
               "value":1
            },{
               "label":"2",
               "cn":"",
               "value":2
            },{
               "label":"3",
               "cn":"",
               "value":3
            }],
            "optoinKey":"player2"
         },{
            "label":"Life",
            "cn":"",
            "options":[{
               "label":"50%",
               "cn":"5",
               "value":0.5
            },{
               "label":"100%",
               "cn":"",
               "value":1
            },{
               "label":"200%",
               "cn":"",
               "value":2
            },{
               "label":"300%",
               "cn":"",
               "value":3
            },{
               "label":"500%",
               "cn":"",
               "value":5
            },{
               "label":"600%",
               "cn":"",
               "value":6
            },{
               "label":"700%",
               "cn":"",
               "value":7
            },{
               "label":"800%",
               "cn":"",
               "value":8
            },{
               "label":"900%",
               "cn":"",
               "value":9
            },{
               "label":"99999%",
               "cn":"",
               "value":999
            }],
            "optoinKey":"fighterHP"
         },{
            "label":"Time",
            "cn":"",
            "options":[{
               "label":"30s",
               "cn":"",
               "value":30
            },{
               "label":"60s",
               "cn":"",
               "value":60
            },{
               "label":"90s",
               "cn":"",
               "value":90
            },{
               "label":"120s",
               "cn":"",
               "value":120
            },{
               "label":"180s",
               "cn":"",
               "value":180
            },{
               "label":"∞",
               "cn":"",
               "value":-1
            }],
            "optoinKey":"fightTime"
         },{
            "label":"APPLY",
            "cn":""
         }]);
         _btnGroup.addEventListener("SELECT",onBtnSelect);
         _btnGroup.addEventListener("OPTION_CHANGE",onOptionChange);
         _ui.addChild(_btnGroup);
         this.addChild(_ui);
         _ui.x = 120;
         _ui.alpha -= 0.05;
         addEventListener(Event.ENTER_FRAME,updateUI);
      }

      private function buildFallbackSettingGameUI() : Sprite
      {
         var fallbackPanel:Sprite = new Sprite();
         fallbackPanel.graphics.beginFill(0x0B1423,0.92);
         fallbackPanel.graphics.lineStyle(2,0x4D7EB2,0.88);
         fallbackPanel.graphics.drawRoundRect(40,60,1200,560,24,24);
         fallbackPanel.graphics.endFill();
         var titleText:TextField = new TextField();
         titleText.defaultTextFormat = new TextFormat("_sans",28,0xA5EBFF,true,null,null,null,null,TextFormatAlign.CENTER);
         titleText.width = GameConfig.GAME_SIZE.x;
         titleText.height = 52;
         titleText.y = 20;
         titleText.text = "GAME SETTINGS";
         titleText.selectable = false;
         fallbackPanel.addChild(titleText);
         return fallbackPanel;
      }
      
      private function updateUI(event:Event) : void
      {
         _ui.x -= 10;
         if(_ui.x <= 0)
         {
            removeEventListener(Event.ENTER_FRAME,updateUI);
         }
      }
      
      private function removeUI(event:Event) : void
      {
         _ui.x -= 10;
         _ui.alpha -= 0.05;
         if(_ui.x <= -200)
         {
            try
            {
               this.removeChild(_ui);
               _ui.visible = false;
            }
            catch(e:Error)
            {
               trace(e);
            }
            removeEventListener(Event.ENTER_FRAME,updateUI);
         }
      }
      
      private function onBtnSelect(param1:SetBtnEvent) : void
      {
         switch(param1.selectedLabel)
         {
            case "APPLY":
               GameData.I.saveData();
               closeSelf();
         }
      }
      
      private function onOptionChange(param1:SetBtnEvent) : void
      {
         var _loc2_:ConfigVO = GameData.I.config;
         _loc2_.setValueByKey(param1.optionKey,param1.optionValue);
      }
      
      private function closeSelf() : void
      {
         addEventListener(Event.ENTER_FRAME,removeUI);
         if(_btnGroup)
         {
            try
            {
               _btnGroup.destory();
               _btnGroup.keyEnable = false;
               _ui.removeChild(_btnGroup);
               _btnGroup = null;
            }
            catch(e:Error)
            {
               trace(e);
            }
         }
         dispatchEvent(new Event("SETTINGS_COMPLETED"));
      }
   }
}

