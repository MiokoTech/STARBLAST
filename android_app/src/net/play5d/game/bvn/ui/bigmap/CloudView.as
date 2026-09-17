package net.play5d.game.bvn.ui.bigmap
{
   import flash.display.MovieClip;
   import net.play5d.game.bvn.utils.ResUtils;
   
   public class CloudView
   {
      public var speed:Number = 0;
      
      public var mc:MovieClip;
      
      public function CloudView(param1:Number, param2:Number)
      {
         super();
         mc = ResUtils.I.createDisplayObject(ResUtils.swfLib.bigmap,"cloud_mc") as MovieClip;
         mc.x = param1;
         mc.y = param2;
         mc.alpha = 0.2 + Math.random() * 0.3;
         mc.gotoAndStop(1 + int(Math.random() * mc.totalFrames));
         speed = 0.02 + Math.random() * 0.1;
      }
      
      public function render() : Boolean
      {
         mc.y -= speed;
         return mc.y < -mc.height + 30;
      }
   }
}

