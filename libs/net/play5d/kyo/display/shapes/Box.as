package net.play5d.kyo.display.shapes
{
   import flash.display.Sprite;
   import flash.geom.Point;
   
   public class Box extends Sprite
   {
      public function Box(param1:Number, param2:Number, param3:int = 0, param4:Number = 1, param5:Point = null)
      {
         super();
         graphics.beginFill(param3,param4);
         graphics.drawRect(!!param5 ? -param5.x : 0,!!param5 ? -param5.y : 0,param1,param2);
         graphics.endFill();
      }
   }
}

