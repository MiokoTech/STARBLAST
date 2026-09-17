package net.play5d.game.bvn.mob.views
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class GameSideBg extends Bitmap
   {
      [Embed(source='/../assets/side_bg.jpg')]
      private var _sideBg:Class;
  
      [Embed(source='/../assets/side_shadow.png')]
      private var _sideShadow:Class;
      
      public function GameSideBg(param1:Point, param2:Rectangle)
      {
         super(null,"auto",false);
         update(param1,param2);
      }
      
      public function update(param1:Point, param2:Rectangle) : void
      {
         if(this.bitmapData)
         {
            this.bitmapData.dispose();
            this.bitmapData = null;
         }
         param1.x <<= 0;
         param1.y <<= 0;
         param2.x <<= 0;
         param2.y <<= 0;
         param2.width <<= 0;
         param2.height <<= 0;
         var _loc6_:BitmapData = new BitmapData(param1.x,param1.y,false,0);
         var _loc11_:Bitmap = new _sideBg();
         _loc11_.height = param1.y;
         _loc11_.scaleX = _loc11_.scaleY;
         var _loc3_:Matrix = new Matrix();
         _loc3_.scale(_loc11_.scaleX,_loc11_.scaleY);
         _loc6_.draw(_loc11_,_loc3_,null,null,new Rectangle(0,0,param2.x,param1.y));
         var _loc7_:Matrix = _loc3_.clone();
         var _loc9_:Number = _loc11_.width - (param1.x - param2.right);
         _loc7_.translate(param2.right - _loc9_ << 0,0);
         var _loc10_:Rectangle = new Rectangle(param2.right,0,param1.x,param1.y);
         _loc6_.draw(_loc11_,_loc7_,null,null,_loc10_);
         var _loc8_:Bitmap = new _sideShadow();
         _loc8_.height = param1.y;
         _loc8_.scaleX = _loc8_.scaleY;
         var _loc5_:Matrix = new Matrix();
         _loc5_.scale(_loc8_.scaleX,_loc8_.scaleY);
         _loc5_.translate(param2.x - _loc8_.width + 1 << 0,0);
         _loc6_.draw(_loc8_,_loc5_,null);
         var _loc4_:Matrix = new Matrix();
         _loc4_.scale(-_loc8_.scaleX,_loc8_.scaleY);
         _loc4_.translate(param2.right + _loc8_.width << 0,0);
         _loc6_.draw(_loc8_,_loc4_,null);
         this.bitmapData = _loc6_;
         _loc11_.bitmapData.dispose();
         _loc8_.bitmapData.dispose();
      }
      
      public function destory() : void
      {
         try
         {
            this.parent.removeChild(this);
         }
         catch(e:Error)
         {
            trace(e);
         }
         if(this.bitmapData)
         {
            this.bitmapData.dispose();
            this.bitmapData = null;
         }
      }
   }
}

