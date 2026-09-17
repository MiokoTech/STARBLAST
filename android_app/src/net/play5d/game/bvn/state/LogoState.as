package net.play5d.game.bvn.state
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.stage.Istage;
   
   public class LogoState implements Istage
   {
      private var _ui:MovieClip;
      
      public function LogoState()
      {
         super();
      }
      
      public function get display() : DisplayObject
      {
         return _ui;
      }
      
      public function build() : void
      {
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui,"logo_movie") as MovieClip;
         _ui.addEventListener("complete",playComplete);
         _ui.gotoAndPlay(2);
      }
      
      private function playComplete(param1:Event) : void
      {
         _ui.removeEventListener("complete",playComplete);
         MainGame.I.goTitle();
      }
      
      public function afterBuild() : void
      {
      }
      
      public function destory(param1:Function = null) : void
      {
         _ui.removeEventListener("complete",playComplete);
      }
   }
}

