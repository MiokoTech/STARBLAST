package net.play5d.game.bvn.ui.dialog
{
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ui.Text;
   import net.play5d.game.bvn.utils.BtnUtils;
   import net.play5d.kyo.display.bitmap.BitmapFontText;
   
   public class BaseDialog
   {
      protected var _backBtn:SimpleButton;
      
      protected var _dialogUI:Sprite;
      
      private var _titleTxt:BitmapFontText;
      
      public var offsetX:Number = 0;
      
      public var offsetY:Number = 0;
      
      public var width:Number = 0;
      
      public var height:Number = 0;
      
      protected var _cnTxt:Text;
      
      public var yesBack:Function;
      
      public var noBack:Function;
      
      protected var _noBtn:SimpleButton;
      
      protected var _yesBtn:SimpleButton;
      
      public function BaseDialog()
      {
         super();
      }
      
      public function getDisplay() : DisplayObject
      {
         return _dialogUI;
      }
      
      final public function init() : void
      {
         _backBtn = _dialogUI.getChildByName("back") as SimpleButton;
         BtnUtils.initBtn(_backBtn,closeSelf);
      }
      
      final public function show(param1:Number, param2:Number) : void
      {
         _dialogUI.x = param1 + offsetX;
         _dialogUI.y = param2 + offsetY;
         onShow();
      }
      
      public function setTitle(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         if(!_titleTxt)
         {
            _titleTxt = new BitmapFontText(AssetManager.I.getFont("font1"));
            _titleTxt.y = -10;
            _dialogUI.addChild(_titleTxt);
         }
         _titleTxt.text = param1;
         _titleTxt.x = (width - _titleTxt.width) / 2;
      }
      
      final public function close() : void
      {
         onClose();
      }
      
      final public function closeSelf(... rest) : void
      {
         DialogManager.closeDialog(this);
      }
      
      final public function destory() : void
      {
         if(_titleTxt)
         {
            _titleTxt.dispose();
            _titleTxt = null;
         }
         onDestory();
      }
      
      final public function hide() : void
      {
         _dialogUI.visible = false;
         onHide();
      }
      
      final public function hiding() : Boolean
      {
         return !_dialogUI.visible;
      }
      
      final public function resume() : void
      {
         _dialogUI.visible = true;
         onResume();
      }
      
      protected function onShow() : void
      {
      }
      
      protected function onHide() : void
      {
      }
      
      protected function onResume() : void
      {
      }
      
      protected function onClose() : void
      {
      }
      
      protected function onDestory() : void
      {
      }
      
      public function setMsg(param1:String = null, param2:String = null) : void
      {
      }
   }
}

