package net.play5d.game.bvn.state
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   
   public class GameCamera
   {
      public var tweenSpd:int;
      
      public var stageSize:Point;
      
      public var focusX:Boolean = true;
      
      public var focusY:Boolean;
      
      public var offsetX:Number = 0;
      
      public var offsetY:Number = 0;
      
      public var autoZoom:Boolean = false;
      
      public var autoZoomMin:Number = 1;
      
      public var autoZoomMax:Number = 3;
      
      private var _zoom:Number = 1;
      
      private var _noTweenRect:Rectangle;
      
      private var _stage:DisplayObject;
      
      private var _stageBounds:Rectangle;
      
      private var _rect:Rectangle;
      
      private var _focus:Array;
      
      private var _point:Point;
      
      private var _stageScale:Number = 1;
      
      private var _fbR:Rectangle;
      
      private var _foffsetX:Number = 0;
      
      private var _foffsetY:Number = 0;
      
      private var _screenSize:Point;
      
      public function GameCamera(param1:DisplayObject, param2:Point, param3:Point = null, param4:Boolean = false)
      {
         super();
         _stage = param1;
         _rect = new Rectangle(0,0,param2.x,param2.y);
         _noTweenRect = new Rectangle(0,0,param2.x,param2.y);
         _screenSize = new Point(param2.x,param2.y);
         if(param4)
         {
            _fbR = new Rectangle();
         }
         this.stageSize = param3;
         if(!this.stageSize)
         {
            setStageSizeFromDisplay(_stage);
         }
         setStageBounds();
      }
      
      public function getScreenRect(param1:Boolean = false) : Rectangle
      {
         return param1 ? _rect : _noTweenRect;
      }
      
      public function updateNow() : void
      {
         var _loc1_:Number = tweenSpd;
         tweenSpd = 0;
         render();
         tweenSpd = _loc1_;
      }
      
      public function setStageBounds(param1:Rectangle = null) : void
      {
         if(!param1)
         {
            _stageBounds = _stage.getBounds(_stage);
         }
         else
         {
            _stageBounds = param1;
         }
         setZoom(_zoom);
      }
      
      public function setStageSizeFromDisplay(param1:DisplayObject) : void
      {
         stageSize = new Point(param1.width / param1.scaleX + _stageBounds.x,param1.height / param1.scaleY + _stageBounds.y);
      }
      
      public function getZoom(param1:Boolean = false) : Number
      {
         return param1 ? _stageScale : _zoom;
      }
      
      public function setZoom(param1:Number) : void
      {
         _zoom = param1;
         _noTweenRect.width = _screenSize.x / _zoom;
         _noTweenRect.height = _screenSize.y / _zoom;
         _foffsetX = _screenSize.x / 2 / _zoom;
         _foffsetY = _screenSize.y / 2 / _zoom;
         if(_fbR)
         {
            _fbR.x = _stageBounds.x * _zoom;
            _fbR.y = _stageBounds.y * _zoom;
            _fbR.width = _stageBounds.width - _screenSize.x / _zoom;
            _fbR.height = _stageBounds.height - _screenSize.y / _zoom;
         }
      }
      
      public function focus(param1:Array, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         _focus = param1;
         _point = _focus.length > 1 ? new Point() : null;
         if(param2)
         {
            _loc3_ = tweenSpd;
            tweenSpd = 0;
            render();
            tweenSpd = _loc3_;
         }
      }
      
      public function move(param1:Number, param2:Number) : void
      {
         _focus = null;
         _point = new Point(param1,param2);
      }
      
      public function moveCenter() : void
      {
         _focus = null;
         _point = new Point(stageSize.x / 2,stageSize.y / 2);
      }
      
      public function render() : void
      {
         if(!_focus && !_point)
         {
            return;
         }
         if(_focus.length > 1)
         {
            renderTwo(_focus[0],_focus[_focus.length - 1]);
         }
         if(focusX)
         {
            renderX();
         }
         if(focusY)
         {
            renderY();
         }
         if(_stageScale != _zoom)
         {
            renderZoom();
         }
         applySet();
      }
      
      private function applySet() : void
      {
         if(GameConfig.PIXEL_STYLE_MODE)
         {
            _rect.x = Math.round(_rect.x);
            _rect.y = Math.round(_rect.y);
         }
         _stage.scrollRect = _rect;
         _stage.scaleX = _stage.scaleY = _stageScale;
      }
      
      private function renderTwo(param1:DisplayObject, param2:DisplayObject) : void
      {
         var _loc3_:* = null;
         var _loc9_:* = null;
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc11_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc8_:Number = 0;
         var _loc7_:Number = 0;
         if(focusX)
         {
            if(param1.x < param2.x)
            {
               _loc9_ = param1;
               _loc3_ = param2;
            }
            else
            {
               _loc9_ = param2;
               _loc3_ = param1;
            }
            _loc8_ = _loc3_.x - _loc9_.x;
            _point.x = _loc9_.x + _loc8_ / 2;
         }
         if(focusY)
         {
            if(param1.y < param2.y)
            {
               _loc5_ = param1;
               _loc4_ = param2;
            }
            else
            {
               _loc5_ = param2;
               _loc4_ = param1;
            }
            _loc7_ = _loc4_.y - _loc5_.y;
            _point.y = _loc5_.y + _loc7_ / 2;
         }
         if(autoZoom)
         {
            _loc11_ = _zoom;
            _loc10_ = _zoom;
            if(focusX)
            {
               _loc11_ = _screenSize.x / _loc8_ * 0.8;
            }
            if(focusY)
            {
               _loc10_ = _screenSize.y / _loc7_ * 0.8;
            }
            _loc6_ = Math.min(_loc11_,_loc10_);
            renderAutoZoom(_loc6_);
         }
      }
      
      private function renderAutoZoom(param1:Number) : void
      {
         if(param1 < autoZoomMin)
         {
            param1 = autoZoomMin;
         }
         if(param1 > autoZoomMax)
         {
            param1 = autoZoomMax;
         }
         setZoom(param1);
      }
      
      private function renderX() : void
      {
         var _loc1_:Number = NaN;
         _loc1_ = Number(!!_point ? _point.x : _focus[0].x);
         _loc1_ -= _foffsetX + offsetX;
         setX(_loc1_);
      }
      
      private function renderY() : void
      {
         var _loc1_:Number = NaN;
         _loc1_ = Number(!!_point ? _point.y : _focus[0].y);
         _loc1_ -= _foffsetY + offsetY;
         setY(_loc1_);
      }
      
      public function setX(param1:Number) : void
      {
         if(_fbR)
         {
            if(param1 < _fbR.x)
            {
               param1 = _fbR.x;
            }
            if(param1 > _fbR.width)
            {
               param1 = _fbR.width;
            }
         }
         _noTweenRect.x = param1;
         if(tweenSpd > 1)
         {
            _rect.x += (param1 - _rect.x) / tweenSpd;
         }
         else
         {
            _rect.x = param1;
         }
      }
      
      public function setY(param1:Number) : void
      {
         if(_fbR)
         {
            if(param1 < _fbR.y)
            {
               param1 = _fbR.y;
            }
            if(param1 > _fbR.height)
            {
               param1 = _fbR.height;
            }
         }
         _noTweenRect.y = param1;
         if(tweenSpd > 1)
         {
            _rect.y += (param1 - _rect.y) / tweenSpd;
         }
         else
         {
            _rect.y = param1;
         }
      }
      
      private function renderZoom() : void
      {
         if(_zoom <= 0)
         {
            throw new Error("zoom 不能 <= 0 !");
         }
         if(tweenSpd > 1)
         {
            _stageScale += (_zoom - _stageScale) / tweenSpd;
         }
         else
         {
            _stageScale = _zoom;
         }
         _rect.width = _screenSize.x / _stageScale + 1 >> 0;
         _rect.height = _screenSize.y / _stageScale + 1 >> 0;
      }
   }
}

