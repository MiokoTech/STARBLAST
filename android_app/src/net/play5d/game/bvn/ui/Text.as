package net.play5d.game.bvn.ui
{
   import flash.filters.DropShadowFilter;
   import net.play5d.kyo.display.BitmapText;
   
   public class Text extends BitmapText
   {
      public function Text(param1:uint = 16777215, param2:int = 20)
      {
         super(true,param1,[new DropShadowFilter()]);
         font = "Arial";
         fontSize = param2;
      }
      
      override public function get textWidth() : Number
      {
         return _tf.textWidth;
      }
      
      override public function get textHeight() : Number
      {
         return _tf.textHeight;
      }
   }
}

