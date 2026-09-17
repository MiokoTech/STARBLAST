package net.play5d.game.bvn.views.effects
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.utils.getTimer;
   import net.play5d.game.bvn.GameConfig;
   
   public class ShineEffectView extends Bitmap
   {
      public var onRemove:Function;
      
      public var isActive:Boolean = true;
      
      private var _loseAlpha:Number = 1;
      
      private var _alpha:int;
      
      private var _renderGap:int = 0;
      
      private var _renderFrame:int;
      
      private var _isDestoryed:Boolean;
      
      private var _startTimer:int;
      
      private var _frameTime:int;
      
      private const _skipFrameRate:Number = 1.2;
      
      public function ShineEffectView()
      {
         super(null,"never",false);
      }
      
      public function destory() : void
      {
         _isDestoryed = true;
         if(isActive)
         {
            removeSelf();
         }
         if(this.bitmapData)
         {
            this.bitmapData.dispose();
            this.bitmapData = null;
         }
      }
      
      public function destroy() : void
      {
         destory();
      }
      
      public function init(param1:uint = 16777215, param2:Number = 0.2) : void
      {
         var w:int = int(GameConfig.GAME_SIZE.x / 10);
         var h:int = int(GameConfig.GAME_SIZE.y / 10);
         if(!this.bitmapData || this.bitmapData.width != w || this.bitmapData.height != h)
         {
            if(this.bitmapData)
            {
               this.bitmapData.dispose();
            }
            this.bitmapData = new BitmapData(w,h,false,param1);
         }
         else
         {
            this.bitmapData.fillRect(this.bitmapData.rect,param1);
         }
         this.width = GameConfig.GAME_SIZE.x;
         this.height = GameConfig.GAME_SIZE.y;
         isActive = true;
         var _loc3_:Number = 8388607;
         if(param1 > _loc3_)
         {
            this.blendMode = "add";
         }
         else
         {
            this.blendMode = "darken";
            param2 *= 0.8;
         }
         this.alpha = param2;
         _alpha = param2 * 100;
         _renderFrame = 0;
         _renderGap = Math.ceil(GameConfig.FPS_GAME / GameConfig.FPS_SHINE_EFFECT) - 1;
         _startTimer = 0;
         _loseAlpha = _renderGap + 1;
         _frameTime = 1000 / GameConfig.FPS_SHINE_EFFECT;
      }
      
      public function render() : void
      {
         if(_isDestoryed)
         {
            return;
         }
         if(_renderGap > 0)
         {
            _renderFrame++;
            if(_renderFrame % _renderGap != 0)
            {
               return;
            }
         }
         skipFrame();
         _alpha -= _loseAlpha;
         if(_alpha <= 5)
         {
            removeSelf();
         }
         else
         {
            this.alpha = _alpha * 0.01;
         }
      }
      
      private function skipFrame() : void
      {
         var _loc3_:int = 0;
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         if(_startTimer != 0)
         {
            _loc3_ = getTimer() - _startTimer;
            _loc1_ = _loc3_ / _frameTime;
            if(_loc1_ > 1.2)
            {
               _loc2_ = Math.ceil(_loseAlpha * _loc1_);
               if(_loseAlpha < _loc2_)
               {
                  _loseAlpha = _loc2_;
               }
            }
         }
         _startTimer = getTimer();
      }
      
      public function removeSelf() : void
      {
         isActive = false;
         if(bitmapData)
         {
            bitmapData.dispose();
            bitmapData = null;
         }
         if(this.parent)
         {
            try
            {
               this.parent.removeChild(this);
            }
            catch(e:Error)
            {
            }
         }
         if(onRemove != null)
         {
            onRemove(this);
         }
      }
   }
}

