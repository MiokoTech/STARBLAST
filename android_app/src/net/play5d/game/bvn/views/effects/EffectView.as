package net.play5d.game.bvn.views.effects
{
   import flash.display.Bitmap;
   import flash.geom.Point;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.BitmapDataCacheVO;
   import net.play5d.game.bvn.data.EffectVO;
   import net.play5d.game.bvn.fighter.LocalCoordManager;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.kyo.utils.KyoMath;
   
   public class EffectView
   {
      public var display:Bitmap;
      
      public var autoRemove:Boolean = true;
      
      public var loopPlay:Boolean = false;
      
      public var holdFrame:int = -1;
      
      public var isActive:Boolean = true;
      
      protected var _target:IGameSprite;
      
      private var _onRemoveFuncs:Array;
      
      private var _isDestoryed:Boolean;
      
      protected var _data:EffectVO;
      
      private var _bitmapDatas:Vector.<BitmapDataCacheVO>;
      
      private var _frameLabels:Object;
      
      private var _orgX:Number = 0;
      
      private var _orgY:Number = 0;
      
      private var _curFrame:int;
      
      private var _rotation:int;
      
      private var _direct:int;
      
      public function EffectView(param1:EffectVO)
      {
         super();
         _data = param1;
         display = new Bitmap();
         display.blendMode = param1.blendMode;
         display.smoothing = EffectCtrl.EFFECT_SMOOTHING;
         _bitmapDatas = param1.bitmapDataCache;
         _frameLabels = param1.frameLabelCache;
      }
      
      public function setTarget(param1:IGameSprite) : void
      {
         _target = param1;
      }
      
      public function setPos(param1:Number, param2:Number) : void
      {
         _orgX = param1;
         _orgY = param2;
      }
      
      public function start(param1:Number = 0, param2:Number = 0, param3:int = 1, param4:Boolean = true) : void
      {
         _orgX = param1;
         _orgY = param2;
         _direct = _rotation != 0 ? 1 : param3;
         var effScale:Number = 1.0;
         if(LocalCoordManager.isLocalCoordMode())
         {
            if(!_data || _data.className != "kobg_effect_mc")
            {
               effScale = LocalCoordManager.getScale();
            }
         }
         display.scaleX = _direct * effScale;
         display.scaleY = effScale;
         _curFrame = 0;
         if(_data.randRotate)
         {
            randRotate();
         }
         if(param4 && _data.sound)
         {
            SoundCtrl.I.playEffectSound(_data.sound);
         }
         renderDisplay();
         isActive = true;
      }
      
      public function destory() : void
      {
         _isDestoryed = true;
         if(isActive)
         {
            removeSelf();
         }
         display = null;
      }
      
      public function gotoAndPlay(frame:Object) : void
      {
         if(frame is int)
         {
            _curFrame = int(frame);
         }
         if(frame is String)
         {
            for(var i:String in _frameLabels)
            {
               if(_frameLabels[i] == frame)
               {
                  _curFrame = int(i);
               }
            }
         }
      }
      
      private function randRotate() : void
      {
         _rotation = Math.random() * 360;
         display.rotation = _rotation;
         var effScale:Number = LocalCoordManager.getScale();
         display.scaleX = effScale;
         display.scaleY = effScale;
      }
      
      public function render() : void
      {
      }
      
      public function renderAnimate() : void
      {
         if(_isDestoryed)
         {
            return;
         }
         var _loc1_:Boolean = false;
         if(loopPlay)
         {
            if(_curFrame == _bitmapDatas.length - 1)
            {
               _curFrame = 0;
            }
         }
         else if(autoRemove)
         {
            if(_curFrame == _bitmapDatas.length - 1)
            {
               if(holdFrame == -1)
               {
                  removeSelf();
                  _loc1_ = true;
               }
               else
               {
                  _curFrame = 0;
               }
            }
            if(holdFrame != -1)
            {
               if(holdFrame-- <= 0)
               {
                  removeSelf();
                  _loc1_ = true;
               }
            }
         }
         if(!_loc1_)
         {
            renderFrameLabel();
            renderDisplay();
            _curFrame++;
         }
      }
      
      private function renderDisplay() : void
      {
         var rad:Number = NaN;
         var offsetPt:Point = null;
         var cacheVO:BitmapDataCacheVO = _bitmapDatas[_curFrame];
         if(cacheVO == null)
         {
            display.bitmapData = null;
         }
         else
         {
            display.bitmapData = cacheVO.bitmapData;
            var effScale:Number = LocalCoordManager.getScale();
            if(_rotation != 0)
            {
               rad = KyoMath.asRadians(_rotation);
               offsetPt = KyoMath.getPointByRadians(new Point(cacheVO.offsetX * effScale, cacheVO.offsetY * effScale), rad);
               display.x = _orgX + offsetPt.x;
               display.y = _orgY + offsetPt.y;
            }
            else
            {
               display.x = _orgX + cacheVO.offsetX * _direct * effScale;
               display.y = _orgY + cacheVO.offsetY * effScale;
            }
         }
      }
      
      private function renderFrameLabel() : void
      {
         var _loc1_:String = _frameLabels[_curFrame];
         var _loc2_:* = _loc1_;
         if("loop" === _loc2_)
         {
            gotoAndPlay(1);
         }
      }
      
      public function remove() : void
      {
         removeSelf();
      }
      
      public function addRemoveBack(param1:Function) : void
      {
         if(!_onRemoveFuncs)
         {
            _onRemoveFuncs = [];
         }
         if(_onRemoveFuncs.indexOf(param1) != -1)
         {
            return;
         }
         _onRemoveFuncs.push(param1);
      }
      
      private function removeSelf() : void
      {
         isActive = false;
         for each(var i:Function in _onRemoveFuncs)
         {
            i(this);
         }
         _onRemoveFuncs = null;
         if(display && display.parent)
         {
            display.parent.removeChild(display);
         }
      }
   }
}

