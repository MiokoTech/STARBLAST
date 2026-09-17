package net.play5d.game.bvn.ui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import net.play5d.game.bvn.data.FighterVO;
   
   public class WinUI
   {
      private var _ui:*;
      
      private var _team:int;
      
      public function WinUI(param1:*, param2:int)
      {
         super();
         _ui = param1;
         _team = param2;
      }
      
      public function get ui() : DisplayObject
      {
         return _ui;
      }
      
      public function show(param1:FighterVO, param2:int) : void
      {
         var _loc3_:MovieClip = null;
         if(!param1)
         {
            return;
         }
         switch(param2 - 1)
         {
            case 0:
               _loc3_ = _team == 1 ? _ui.w1 : _ui.w2;
               break;
            case 1:
               _loc3_ = _team == 1 ? _ui.w2 : _ui.w1;
         }
         if(!_loc3_)
         {
            return;
         }
         switch(param1.comicType)
         {
            case 0:
               _loc3_.gotoAndPlay("in_bleach");
               break;
            case 1:
               _loc3_.gotoAndPlay("in_naruto");
         }
      }
   }
}

