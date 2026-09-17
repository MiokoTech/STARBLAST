package net.play5d.game.bvn.ui
{
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.display.MovieClip;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.bitmap.BitmapFontText;
   
   public class SetBtnDialog
   {
      public var ui:MovieClip;
      
      public var isShow:Boolean = true;
      
      private var _pushTxt:BitmapFontText;
      
      private var _keyNameTxt:BitmapFontText;
      
      private var _cntxt:TextField;
      
      public function SetBtnDialog()
      {
         super();
         ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting,"key_set_dialog_mc");
         ui.visible = false;
         _pushTxt = new BitmapFontText(AssetManager.I.getFont("font1"));
         _keyNameTxt = new BitmapFontText(AssetManager.I.getFont("font1"));
         _pushTxt.y = _keyNameTxt.y = -30;
         _pushTxt.text = "PUSH A KEY FOR";
         _pushTxt.x = -_pushTxt.width / 2;
         ui.ct_msg.addChild(_pushTxt);
         ui.ct_keyname.addChild(_keyNameTxt);
         _cntxt = ui.txt;
         _cntxt.defaultTextFormat = new TextFormat("楷体",20);
      }
      
      public function show(param1:String, param2:String) : void
      {
         ui.visible = true;
         _keyNameTxt.text = param1;
         _keyNameTxt.x = -_keyNameTxt.width / 2;
         _cntxt.text = "请按下一个键设置【" + param2 + "】";
         isShow = true;
      }
      
      public function hide() : void
      {
         ui.visible = false;
         isShow = false;
      }
   }
}

