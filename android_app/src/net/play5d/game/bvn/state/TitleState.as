package net.play5d.game.bvn.state
{
   import flash.desktop.NativeApplication;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.TouchEvent;
   import flash.events.MouseEvent;
   import flash.display.Sprite;
   import flash.utils.setTimeout;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.game.bvn.utils.URL;
   import net.play5d.kyo.stage.Istage;

   public class TitleState extends Sprite implements Istage
   {
      private var _ui:MovieClip;

      public function TitleState()
      {
         super();
      }

      public function get display() : DisplayObject
      {
         return _ui;
      }

      public function build() : void
      {
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui,"title_game");
         GameInterface.instance.initTitleUI(_ui);
         GameInputer.enabled = false;
         SoundCtrl.I.BGM(AssetManager.I.getSound("title"));
      }

      public function afterBuild() : void
      {
         setTimeout(function():void
         {
            _ui.buttonMode = true;
            _ui.useHandCursor = true;
            GameRender.add(render);
            GameInputer.focus();
            GameInputer.enabled = true;
         },500);
      }

      private function render() : void
      {
         if(GameInputer.back(1))
         {
            showBtns();
         }
         if(GameInputer.skill("MENU",1))
         {
            URL.go("http://youtube.com/@MiokoTech",true);
         }
         if(GameInputer.dash("MENU",1))
         {
            NativeApplication.nativeApplication.exit();
         }
      }

      private function showBtns(... rest) : void
      {
         GameRender.remove(render);
         _ui.gotoAndPlay("out_title");
         setTimeout(function():void
         {
            MainGame.I.goMenu();
         },3200);
      }

      public function destory(param1:Function = null) : void
      {
         GameInputer.enabled = false;
      }
   }
}

