package net.play5d.game.bvn.state
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.stage.Istage;
   
   public class CreditsState implements Istage
   {
      private var _ui:Sprite;
      
      private var _btngroup:SetBtnGroup;
      
      private var _createsSp:DisplayObject;
      
      public function CreditsState()
      {
         super();
      }
      
      public function get display() : DisplayObject
      {
         return _ui;
      }
      
      public function build() : void
      {
         SoundCtrl.I.BGM(AssetManager.I.getSound("credits"));
         _ui = new Sprite();
         var _loc3_:BitmapData = ResUtils.I.createBitmapData(ResUtils.swfLib.common_ui,"cover_bgimg",GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
         var _loc2_:Bitmap = new Bitmap(_loc3_);
         _ui.addChild(_loc2_);
         var _loc1_:String = getCreditsText();
         _createsSp = GameInterface.instance.getCreadits(_loc1_);
         if(!_createsSp)
         {
            _createsSp = getDefaultCredits(_loc1_);
         }
         _ui.addChild(_createsSp);
         _btngroup = new SetBtnGroup();
         _btngroup.y = GameConfig.GAME_SIZE.y - 150;
         _btngroup.initSimpleBtns([{
            "label":"BACK",
            "cn":"返回"
         }]);
         _btngroup.addEventListener("SELECT",selectBtnHandler);
         _ui.addChild(_btngroup);
      }
      
      public function afterBuild() : void
      {
      }
      
      public function destory(param1:Function = null) : void
      {
         if(_btngroup)
         {
            _btngroup.destory();
            _btngroup.removeEventListener("SELECT",selectBtnHandler);
            _btngroup = null;
         }
      }
      
      private function selectBtnHandler(param1:SetBtnEvent) : void
      {
         MainGame.I.goMenu();
      }
      
      private function getCreditsText() : String
      {
         return "设计、美术、程序：剑jian<br/>人物制作：剑jian、数字化流天、L、V.临界幻想、Azrael，影、赤炎、水、 <br/>         洗橙子、酸菜鱼、星空、卡布托、司徒、小海、主流<br/>策划测试：剑jian、数字化流天、社长、渺渺<br/>卓越贡献：社长、渺渺<br/><br/>STARBLAST Mugen V2, Mod Bleach VS Naruto by MiokoTech<br/>Youtube: MiokoTech<br/><br/>";
      }
      
      private function getDefaultCredits(param1:String) : Sprite
      {
         var _loc4_:Sprite = new Sprite();
         var _loc2_:TextField = new TextField();
         var _loc3_:TextFormat = new TextFormat();
         _loc3_.font = "微软雅黑";
         _loc3_.size = 20;
         _loc3_.color = 0xfffff;
         _loc3_.leading = 15;
         _loc2_.defaultTextFormat = _loc3_;
         _loc2_.multiline = true;
         _loc2_.htmlText = param1;
         _loc2_.autoSize = "left";
         _loc2_.x = 50;
         _loc2_.y = 30;
         _loc4_.addChild(_loc2_);
         return _loc4_;
      }
   }
}

