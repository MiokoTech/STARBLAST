package net.play5d.game.bvn.ui.dialog
{
   import com.greensock.TweenLite;
   import flash.display.Sprite;
   import flash.text.TextField;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.ui.UIUtils;
   import net.play5d.game.bvn.utils.BtnUtils;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.bitmap.BitmapFontText;
   import net.play5d.kyo.display.shapes.Box;
   
   public class ConfrimUI extends BaseDialog
   {

      private var _ui:Sprite;
      private var _old_cnTxt:TextField;
      private var _enTxt:BitmapFontText;
      private var _btnGroup:SetBtnGroup;
      
      public function ConfrimUI()
      {
         super();
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog,"dialog_confrim");
         _dialogUI = _ui;
         build();
      }
      
      override protected function onDestory() : void
      {
         super.onDestory();
         GameRender.remove(render, this);
         if(_cnTxt)
         {
            _cnTxt.destory();
            _cnTxt = null;
         }
         if(_old_cnTxt)
         {
            _old_cnTxt = null;
         }
         if(_btnGroup)
         {
            _btnGroup.destory();
            _btnGroup = null;
         }
         BtnUtils.destoryBtn(_noBtn);
         BtnUtils.destoryBtn(_yesBtn);
      }
      
      protected function build() : void
      {
         _dialogUI = _ui = new Sprite();
         var _loc2_:Box = new Box(GameConfig.GAME_SIZE.x,300,0,0.8);
         _loc2_.y = (GameConfig.GAME_SIZE.y - _loc2_.height) * 0.5;
         _ui.addChild(_loc2_);
         _enTxt = new BitmapFontText(AssetManager.I.getFont("font1"));
         _enTxt.y = 18;
         _loc2_.addChild(_enTxt);
         if(GameUI.SHOW_CN_TEXT)
         {
            _old_cnTxt = new TextField();
            UIUtils.formatText(_old_cnTxt,{
               "color":16777215,
               "size":20,
               "align":"center",
               "font":"Microsoft YaHei"
            });
            _old_cnTxt.y = _enTxt.y + _enTxt.height + 80;
            _old_cnTxt.width = GameConfig.GAME_SIZE.x;
            _old_cnTxt.height = 100;
            _old_cnTxt.mouseEnabled = false;
            _loc2_.addChild(_old_cnTxt);
         }
         _btnGroup = new SetBtnGroup();
         _btnGroup._isSubMenu = true;
         _btnGroup.startX = _btnGroup.startY = 0;
         _btnGroup.direct = 0;
         _btnGroup.gap = 200;
         _btnGroup.setBtnData([{
            "label":"YES",
            "cn":"是"
         },{
            "label":"NO",
            "cn":"否"
         }],1);
         _btnGroup.addEventListener("SELECT",selectHandler);
         _btnGroup.x = (GameConfig.GAME_SIZE.x - _btnGroup.width) * 0.5 + 30;
         _btnGroup.y = _loc2_.height - 80;
         _loc2_.addChild(_btnGroup);
         var _loc1_:Number = _loc2_.y;
         _loc2_.y = GameConfig.GAME_SIZE.y;
         TweenLite.to(_loc2_,0.2,{"y":_loc1_});
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         GameRender.add(render, this);
         GameInputer.focus();
         GameInputer.enabled = true;
      }

      private function render() : void
      {
         if(_btnGroup)
         {
            _btnGroup.render();
         }
         if(GameInputer.back(1) || GameInputer.dash("MENU", 1))
         {
            if(noBack != null)
            {
               noBack();
            }
         }
      }

      private function selectHandler(param1:SetBtnEvent) : void
      {
         switch(param1.selectedLabel)
         {
            case "YES":
               if(yesBack != null)
               {
                  yesBack();
               }
               break;
            case "NO":
               if(noBack != null)
               {
                  noBack();
               }
               break;
         }
      }
      
      override public function setMsg(param1:String = null, param2:String = null) : void
      {
         _enTxt.text = !!param1 ? param1 : "";
         _enTxt.x = (GameConfig.GAME_SIZE.x - _enTxt.width) * 0.5;
         if(!param2)
         {
            return;
         }
         if(_cnTxt)
         {
            _cnTxt.text = param2;
            _cnTxt.visible = true;
         }
         if(_old_cnTxt)
         {
            _old_cnTxt.text = param2;
            _old_cnTxt.visible = true;
         }
      }
   }
}

