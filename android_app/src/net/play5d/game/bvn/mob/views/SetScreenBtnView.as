package net.play5d.game.bvn.mob.views
{
   import flash.display.Sprite;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.mob.data.ScreenPadConfigVO;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   
   public class SetScreenBtnView extends Sprite
   {
      private var _btnGroup:SetBtnGroup;
      
      public function SetScreenBtnView()
      {
         super();
         this.graphics.beginFill(0,0.8);
         this.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
         this.graphics.endFill();
         _btnGroup = new SetBtnGroup();
         _btnGroup.startY = 30;
         _btnGroup.endY = 550;
         _btnGroup.gap = 70;
         var _loc1_:ScreenPadConfigVO = GameInterfaceManager.config.screenPadConfig;
         _btnGroup.setBtnData([{
            "label":"PREINSTALL",
            "cn":"预置位置",
            "options":[{
               "label":"TYPE 1",
               "cn":"",
               "value":0
            },{
               "label":"TYPE 2",
               "cn":"",
               "value":1
            }],
            "optoinKey":"joyMode",
            "optionValue":_loc1_.joyMode
         },{
            "label":"Transparent",
            "cn":"",
            "options":[{
               "label":"0%",
               "cn":"0%",
               "value":0
            },{
               "label":"10%",
               "cn":"10%",
               "value":0.1
            },{
               "label":"30%",
               "cn":"30%",
               "value":0.3
            },{
               "label":"50%",
               "cn":"50%",
               "value":0.5
            },{
               "label":"70%",
               "cn":"70%",
               "value":0.7
            },{
               "label":"100%",
               "cn":"100%",
               "value":1
            }],
            "optoinKey":"joyAlpha",
            "optionValue":_loc1_.joyAlpha
         },{
            "label":"SP SKILL",
            "cn":"",
            "options":[{
               "label":"AUTO",
               "cn":"",
               "value":true
            },{
               "label":"ALWAYS",
               "cn":"",
               "value":false
            }],
            "optoinKey":"superSkillAutoHide",
            "optionValue":_loc1_.superSkillAutoHide
         },{
            "label":"WANKAI",
            "cn":"",
            "options":[{
               "label":"AUTO",
               "cn":"",
               "value":true
            },{
               "label":"ALWAYS",
               "cn":"",
               "value":false
            }],
            "optoinKey":"wankaiAutoHide",
            "optionValue":_loc1_.wankaiAutoHide
         },{
            "label":"SPECIAL",
            "cn":"",
            "options":[{
               "label":"AUTO",
               "cn":"",
               "value":true
            },{
               "label":"ALWAYS",
               "cn":"",
               "value":false
            }],
            "optoinKey":"specialAutoHide",
            "optionValue":_loc1_.specialAutoHide
         },{
            "label":"CUSTOM",
            "cn":""
         },{
            "label":"APPLY",
            "cn":""
         }]);
         _btnGroup.addEventListener("SELECT",onBtnSelect);
         _btnGroup.addEventListener("OPTION_CHANGE",onOptionChange);
         this.addChild(_btnGroup);
      }
      
      private function onBtnSelect(param1:SetBtnEvent) : void
      {
         switch(param1.selectedLabel)
         {
            case "APPLY":
               closeSelf();
         }
      }
      
      private function onOptionChange(param1:SetBtnEvent) : void
      {
         var config:ScreenPadConfigVO;
         var e:SetBtnEvent = param1;
         if(e.optionKey == "joyMode")
         {
            if(GameInterfaceManager.config.screenPadConfig.joySet)
            {
               GameUI.confrim("Custom already set, are you sure ?","自定义按钮已设定，改变此项将丢失自定义按钮设定，确定要改变？",function():void
               {
                  GameInterfaceManager.config.screenPadConfig.joySet = null;
                  var _loc1_:ScreenPadConfigVO = GameInterfaceManager.config.screenPadConfig;
                  _loc1_.setValueByKey(e.optionKey,e.optionValue);
               });
               return;
            }
         }
         config = GameInterfaceManager.config.screenPadConfig;
         config.setValueByKey(e.optionKey,e.optionValue);
      }
      
      private function closeSelf() : void
      {
         if(_btnGroup)
         {
            try
            {
               _btnGroup.destory();
               this.removeChild(_btnGroup);
               _btnGroup = null;
            }
            catch(e:Error)
            {
               trace(e);
            }
         }
         try
         {
            this.parent.removeChild(this);
         }
         catch(e:Error)
         {
            trace(e);
         }
      }
   }
}

