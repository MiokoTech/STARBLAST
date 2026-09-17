package net.play5d.game.bvn.ui.dialog.select
{
   import flash.display.MovieClip;
   import net.play5d.game.bvn.utils.ResUtils;
   
   public class DotItemUI
   {
      private var _ui:MovieClip;
      
      public var page:int = 0;
      
      public function DotItemUI()
      {
         super();
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog,"dot_mc") as MovieClip;
         _ui.mouseChildren = false;
         _ui.buttonMode = true;
         _ui.gotoAndStop(2);
      }
      
      public function getUI() : MovieClip
      {
         return _ui;
      }
      
      public function focus(param1:Boolean) : void
      {
         _ui.gotoAndStop(param1 ? 1 : 2);
      }
   }
}

