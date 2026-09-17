package net.play5d.game.bvn.ui.select
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.FighterVO;

   public class CircleSlotUI extends Sprite
   {
      private var _isP1:Boolean;
      private var _radius:Number;
      private var _customColor:uint;
      private var _faceContainer:Sprite;
      private var _maskShape:Shape;

      public function CircleSlotUI(isP1:Boolean, radius:Number = 24, customColor:uint = 0)
      {
         super();
         _isP1 = isP1;
         _radius = radius;
         _customColor = customColor;
         mouseChildren = false;
         mouseEnabled = false;
         buildEmpty();
      }

      private function buildEmpty() : void
      {
         graphics.clear();
         graphics.beginFill(0x041122, 0.7);
         graphics.drawCircle(0, 0, _radius);
         graphics.endFill();

         var lineColor:uint = _customColor != 0 ? _customColor : (_isP1 ? 0x00d8ff : 0xff8800);
         graphics.lineStyle(1.5, lineColor, 0.45);
         graphics.drawCircle(0, 0, _radius);
         filters = [new GlowFilter(lineColor, 0.4, 6, 6, 1.5)];

         if(!_faceContainer)
         {
            _faceContainer = new Sprite();
            addChild(_faceContainer);
         }

         if(!_maskShape)
         {
            _maskShape = new Shape();
            _maskShape.graphics.beginFill(0xffffff);
            _maskShape.graphics.drawCircle(0, 0, _radius - 1);
            _maskShape.graphics.endFill();
            addChild(_maskShape);
            _faceContainer.mask = _maskShape;
         }
      }

      public function clearFighter() : void
      {
         if(_faceContainer)
         {
            _faceContainer.removeChildren();
         }
         buildEmpty();
      }

      public function setFighter(fighter:FighterVO) : void
      {
         if(!fighter)
         {
            clearFighter();
            return;
         }
         _faceContainer.removeChildren();

         try
         {
            var faceObj:DisplayObject = AssetManager.I.getFighterFaceBar(fighter);
            if(!faceObj)
            {
               faceObj = AssetManager.I.getFighterFace(fighter);
            }
            if(faceObj && faceObj is Bitmap)
            {
               var bmpData:BitmapData = (faceObj as Bitmap).bitmapData;
               if(bmpData)
               {
                  var bmp:Bitmap = new Bitmap(bmpData);
                  bmp.smoothing = true;
                  var scale:Number = (_radius * 2) / Math.min(bmp.width, bmp.height);
                  bmp.scaleX = scale;
                  bmp.scaleY = scale;
                  bmp.x = -bmp.width / 2;
                  bmp.y = -bmp.height / 2;
                  _faceContainer.addChild(bmp);
               }
            }
         }
         catch(err:Error) {}

         graphics.clear();
         graphics.beginFill(0x041122, 0.85);
         graphics.drawCircle(0, 0, _radius);
         graphics.endFill();

         var activeColor:uint = _customColor != 0 ? _customColor : (_isP1 ? 0x00eaff : 0xffaa00);
         graphics.lineStyle(2.5, activeColor, 1.0);
         graphics.drawCircle(0, 0, _radius);
         filters = [new GlowFilter(activeColor, 0.85, 8, 8, 2.5)];

         TweenLite.from(this, 0.28, {
            "scaleX": 0.2,
            "scaleY": 0.2,
            "alpha": 0.3,
            "ease": Back.easeOut
         });
      }

      public function destory() : void
      {
         TweenLite.killTweensOf(this);
         if(_faceContainer)
         {
            _faceContainer.removeChildren();
            _faceContainer = null;
         }
         if(_maskShape && _maskShape.parent)
         {
            _maskShape.parent.removeChild(_maskShape);
            _maskShape = null;
         }
         if(this.parent)
         {
            try { this.parent.removeChild(this); } catch(e:Error) {}
         }
      }
   }
}
