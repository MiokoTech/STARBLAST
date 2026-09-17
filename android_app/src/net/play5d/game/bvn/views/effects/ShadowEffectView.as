package net.play5d.game.bvn.views.effects
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.kyo.utils.KyoUtils;
   
   public class ShadowEffectView
   {
      
      public var target:DisplayObject;
      
      public var r:int = 0;
      
      public var g:int = 0;
      
      public var b:int = 0;
      
      public var container:Sprite;
      
      private var _bps:Vector.<Bitmap> = new Vector.<Bitmap>();
      
      private var _alphaLose:Number = 0.1;
      
      private var _alphaStart:Number = 0.8;
      
      private var _addBpGap:int = 1;
      
      private var _addBpFrame:int = 0;
      
      public var stopShadow:Boolean;
      
      public var isStaticShadow:Boolean = false;
      
      private var _staticBmp:Bitmap;
      
      public var onRemove:Function;
      
      public function ShadowEffectView(param1:DisplayObject, param2:int = 0, param3:int = 0, param4:int = 0)
      {
         super();
         this.target = param1;
         this.r = param2;
         this.g = param3;
         this.b = param4;
         this._addBpFrame = 0;
      }
      
      public function destory() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Bitmap = null;
         this.target = null;
         while(_loc1_ < this._bps.length)
         {
            _loc2_ = this._bps[_loc1_];
            _loc2_.bitmapData.dispose();
            try
            {
               this.container.removeChild(_loc2_);
            }
            catch(error:Error)
            {
            }
            _loc1_++;
         }
         this._bps = null;
      }
      
      public function render() : void
      {
         var _loc2_:Bitmap = null;
         var _loc1_:int = 0;
         if(!EffectCtrl.SHADOW_ENABLED)
         {
            if(this._bps.length > 0)
            {
               while(this._bps.length > 0)
               {
                  this.removeBitmap(this._bps[0]);
               }
            }
            return;
         }
         if(this.stopShadow)
         {
            if(this._bps.length <= 0)
            {
               this.removeSelf();
            }
         }
         this.addShadowBp();
         while(this._bps.length > 1)
         {
            this.removeBitmap(this._bps[0]);
         }
      }
      
      private function addShadowBp() : void
      {
         var _loc1_:ColorTransform = new ColorTransform();
         _loc1_.redMultiplier = 0;
         _loc1_.greenMultiplier = 0;
         _loc1_.blueMultiplier = 0;
         _loc1_.alphaMultiplier = 0.8;
         var _loc2_:Rectangle = this.target.getBounds(this.target);
         var _loc3_:Bitmap = KyoUtils.drawDisplay(this.target,true,true,0,_loc1_);
         if(_loc3_ == null)
         {
            return;
         }
         _loc3_.alpha = this._alphaStart;
         _loc3_.x = this.target.x + _loc2_.x * this.target.scaleX;
         _loc3_.y = this.target.y + _loc2_.y * this.target.scaleY;
         _loc3_.scaleX = this.target.scaleX;
         _loc3_.scaleY = this.target.scaleY;
         this.container.addChildAt(_loc3_,0);
         this._bps.push(_loc3_);
      }
      
      private function removeBitmap(param1:Bitmap) : void
      {
         var _loc2_:int = int(this._bps.indexOf(param1));
         if(_loc2_ != -1)
         {
            this._bps.splice(_loc2_,1);
         }
         try
         {
            this.container.removeChild(param1);
         }
         catch(e:Error)
         {
         }
         param1.bitmapData.dispose();
      }
      
      private function removeSelf() : void
      {
         if(this.onRemove != null)
         {
            this.onRemove(this);
         }
      }
   }
}

