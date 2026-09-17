package net.play5d.game.bvn.state
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.bitmap.BitmapFontText;
   import net.play5d.kyo.stage.Istage;
   
   public class CongratulateState implements Istage
   {
      private var _mainUI:Sprite;
      
      private var _ui:Sprite;
      
      private var _exitHeight:Number = 0;
      
      private var _btngroup:SetBtnGroup;
      
      private var _bg:Bitmap;
      
      public function CongratulateState()
      {
         super();
      }
      
      public function get display() : DisplayObject
      {
         return _mainUI;
      }
      
      public function get innerUI() : Sprite
      {
         return _ui;
      }
      
      public function build() : void
      {
         _mainUI = new Sprite();
         var _loc1_:BitmapData = ResUtils.I.createBitmapData(ResUtils.swfLib.common_ui,"cover_bgimg",GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
         _bg = new Bitmap(_loc1_);
         _mainUI.addChild(_bg);
         _bg.alpha = -1;
         _ui = new Sprite();
         _mainUI.addChild(_ui);
         var _loc2_:MovieClip = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui,ResUtils.CONGRATULATIONS);
         _ui.addChild(_loc2_);
         _loc2_.addEventListener("complete",playComplete,false,0,true);
         _loc2_.gotoAndPlay(2);
         SoundCtrl.I.BGM(AssetManager.I.getSound("congratulation"));
      }
      
      public function getBtnY() : Number
      {
         return _btngroup.y;
      }
      
      private function playComplete(param1:Event) : void
      {
         var _loc2_:MovieClip = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui,"mc_win_all");
         _loc2_.y = GameConfig.GAME_SIZE.y;
         _ui.addChild(_loc2_);
         GameRender.add(render);
         var _loc3_:BitmapFontText = new BitmapFontText(AssetManager.I.getFont("font1"));
         _loc3_.text = "FINAL SCORE " + GameData.I.score;
         _loc3_.x = (GameConfig.GAME_SIZE.x - _loc3_.width) / 2;
         _loc3_.y = _loc2_.y + _loc2_.height + 100;
         _ui.addChild(_loc3_);
         _exitHeight = _loc3_.y - 320;
         _btngroup = new SetBtnGroup();
         _btngroup.x = 230;
         _btngroup.y = _loc3_.y + _loc3_.height + 100;
         _btngroup.setBtnData([{
            "label":"BACK",
            "cn":"返回"
         }]);
         _btngroup.addEventListener("SELECT",selectBtnHandler);
         _btngroup.keyEnable = false;
         _ui.addChild(_btngroup);
         GameEvent.dispatchEvent("GAME_PASS_ALL");
      }
      
      private function render() : void
      {
         if(GameInputer.back(1))
         {
            _ui.y = -_exitHeight;
            SoundCtrl.I.sndSelect();
         }
         _ui.y -= 1;
         _bg.alpha += 0.005;
         if(_ui.y < -_exitHeight)
         {
            GameRender.remove(render);
            _bg.alpha = 1;
            _btngroup.keyEnable = true;
         }
      }
      
      private function selectBtnHandler(param1:SetBtnEvent) : void
      {
         MainGame.I.goLogo();
      }
      
      public function afterBuild() : void
      {
      }
      
      public function destory(param1:Function = null) : void
      {
         GameRender.remove(render);
         if(_btngroup)
         {
            _btngroup.destory();
            _btngroup.removeEventListener("SELECT",selectBtnHandler);
            _btngroup = null;
         }
      }
   }
}

