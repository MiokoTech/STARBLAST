package net.play5d.game.bvn.ui.mosou
{
   import flash.display.Sprite;
   import flash.text.TextField;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.kyo.utils.KyoTimerFormat;
   
   public class MosouTimeUI
   {
      private var _ui:Sprite;
      
      private var _txt:TextField;
      
      public function MosouTimeUI(param1:Sprite)
      {
         super();
         _ui = param1;
         _txt = param1.getChildByName("text") as TextField;
      }
      
      public function renderAnimate() : void
      {
         var _loc1_:int = 0;
         if(_txt)
         {
            _loc1_ = GameCtrl.I.getMosouCtrl().gameRunData.gameTime / 30;
            _txt.text = KyoTimerFormat.secToTime(_loc1_);
         }
      }
   }
}

