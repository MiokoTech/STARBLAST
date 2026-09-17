package net.play5d.game.bvn.ui.dialog
{
   public class AlertUI extends ConfrimUI
   {
      public function AlertUI()
      {
         super();
         build();
      }
      
      override protected function build() : void
      {
         super.build();
         _noBtn.visible = false;
         _yesBtn.x = 253;
      }
   }
}

