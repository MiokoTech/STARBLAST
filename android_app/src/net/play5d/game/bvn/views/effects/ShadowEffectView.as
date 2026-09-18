package net.play5d.game.bvn.views.effects
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   
   public class ShadowEffectView
   {
      public var target:DisplayObject;
      public var r:int = 0;
      public var g:int = 0;
      public var b:int = 0;
      public var container:Sprite;
      public var groundY:Number = NaN;
      
      private var _bps:Vector.<Bitmap> = new Vector.<Bitmap>();
      private var _alphaStart:Number = 0.8;
      public var stopShadow:Boolean;
      public var isStaticShadow:Boolean = false;
      public var onRemove:Function;
      
      public function ShadowEffectView(targetObj:DisplayObject, red:int = 0, green:int = 0, blue:int = 0)
      {
         super();
         this.target = targetObj;
         this.r = red;
         this.g = green;
         this.b = blue;
      }
      
      public function destory() : void
      {
         this.target = null;
         if(this._bps)
         {
            while(this._bps.length > 0)
            {
               this.removeBitmap(this._bps[0]);
            }
            this._bps = null;
         }
         this.container = null;
         this.onRemove = null;
      }
      
      public function render() : void
      {
         if(!EffectCtrl.SHADOW_ENABLED)
         {
            if(this._bps && this._bps.length > 0)
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
            if(!this._bps || this._bps.length <= 0)
            {
               this.removeSelf();
               return;
            }
         }
         this.addShadowBp();
         while(this._bps && this._bps.length > 1)
         {
            this.removeBitmap(this._bps[0]);
         }
      }
      
      private function addShadowBp() : void
      {
         if(!this.target || !this.container)
         {
            return;
         }
         
         var hiddenList:Vector.<DisplayObject> = new Vector.<DisplayObject>();
         var containerTarget:DisplayObjectContainer = this.target as DisplayObjectContainer;
         if(containerTarget != null)
         {
            var numKids:int = containerTarget.numChildren;
            for(var i:int = 0; i < numKids; i++)
            {
               var child:DisplayObject = containerTarget.getChildAt(i);
               if(!child) continue;
               var cname:String = child.name;
               if(cname == "AImain" || cname.indexOf("atm") != -1)
               {
                  if(child.visible)
                  {
                     child.visible = false;
                     hiddenList.push(child);
                  }
               }
               else if(child is MovieClip && cname != "bdmn")
               {
                  var childMc:MovieClip = child as MovieClip;
                  if(childMc.totalFrames >= 2)
                  {
                     if(childMc.visible)
                     {
                        childMc.visible = false;
                        hiddenList.push(childMc);
                     }
                  }
               }
            }
         }
         
         var bodyBounds:Rectangle = null;
         if(containerTarget != null)
         {
            var bdmn:DisplayObject = null;
            try { bdmn = containerTarget.getChildByName("bdmn"); } catch(e:Error) {}
            if(bdmn != null)
            {
               bodyBounds = bdmn.getBounds(this.target);
            }
         }
         if(bodyBounds == null || bodyBounds.isEmpty())
         {
            bodyBounds = this.target.getBounds(this.target);
         }
         if(bodyBounds == null || bodyBounds.isEmpty() || bodyBounds.width <= 0 || bodyBounds.height <= 0)
         {
            for each(var hc:DisplayObject in hiddenList)
            {
               hc.visible = true;
            }
            return;
         }
         
         var captureBounds:Rectangle = bodyBounds.clone();
         captureBounds.inflate(10, 4);
         
         var drawW:int = Math.ceil(captureBounds.width);
         var drawH:int = Math.ceil(captureBounds.height);
         if(drawW <= 0 || drawH <= 0)
         {
            for each(var hc2:DisplayObject in hiddenList)
            {
               hc2.visible = true;
            }
            return;
         }
         if(drawW > 400) drawW = 400;
         if(drawH > 400) drawH = 400;
         
         var bData:BitmapData = new BitmapData(drawW, drawH, true, 0);
         var drawMat:Matrix = new Matrix(1, 0, 0, 1, -captureBounds.x, -captureBounds.y);
         
         var ct:ColorTransform = new ColorTransform();
         if(this.r == 0 && this.g == 0 && this.b == 0)
         {
            ct.redMultiplier = 0;
            ct.greenMultiplier = 0;
            ct.blueMultiplier = 0;
            ct.alphaMultiplier = 0.85;
         }
         else
         {
            ct.redMultiplier = this.r / 255;
            ct.greenMultiplier = this.g / 255;
            ct.blueMultiplier = this.b / 255;
            ct.alphaMultiplier = 0.85;
         }
         
         try
         {
            bData.draw(this.target, drawMat, ct);
         }
         finally
         {
            for each(var restoreChild:DisplayObject in hiddenList)
            {
               restoreChild.visible = true;
            }
         }
         
         var shadowBmp:Bitmap = new Bitmap(bData);
         shadowBmp.smoothing = true;
         
         var shadowMat:Matrix = new Matrix();
         shadowMat.translate(captureBounds.x, captureBounds.y);
         
         var scaleFactorX:Number = this.target.scaleX;
         var isFacingLeft:Boolean = scaleFactorX < 0;
         var projScaleX:Number = scaleFactorX;
         var projScaleY:Number = -0.32 * Math.abs(this.target.scaleY);
         var skewX:Number = isFacingLeft ? 0.15 : -0.15;
         
         var floorY:Number = !isNaN(this.groundY) ? this.groundY : this.target.y;
         var airHeight:Number = Math.max(0, floorY - this.target.y);
         var airScaleFactor:Number = 1.0;
         var airAlphaFactor:Number = 1.0;
         if(airHeight > 0)
         {
            airScaleFactor = Math.max(0.4, 1.0 - airHeight / 600);
            airAlphaFactor = Math.max(0.2, 1.0 - airHeight / 400);
         }
         
         shadowMat.a = projScaleX * airScaleFactor;
         shadowMat.b = 0;
         shadowMat.c = skewX * Math.abs(projScaleX) * airScaleFactor;
         shadowMat.d = projScaleY * airScaleFactor;
         shadowMat.tx = this.target.x;
         shadowMat.ty = floorY;
         
         shadowBmp.transform.matrix = shadowMat;
         shadowBmp.alpha = this._alphaStart * airAlphaFactor;
         
         this.container.addChildAt(shadowBmp, 0);
         this._bps.push(shadowBmp);
      }
      
      private function removeBitmap(bmp:Bitmap) : void
      {
         if(!bmp) return;
         var idx:int = int(this._bps.indexOf(bmp));
         if(idx != -1)
         {
            this._bps.splice(idx, 1);
         }
         try
         {
            if(this.container && bmp.parent == this.container)
            {
               this.container.removeChild(bmp);
            }
         }
         catch(e:Error)
         {
         }
         if(bmp.bitmapData)
         {
            bmp.bitmapData.dispose();
         }
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
