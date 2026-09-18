package net.play5d.game.bvn.state
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.fighter.LocalCoordManager;
   
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
      
      public var stageCameraMode:Boolean = false;
      public var stageBoundLeft:Number = -500;
      public var stageBoundRight:Number = 500;
      public var stageBoundHigh:Number = -1000;
      public var stageBoundLow:Number = 0;
      public var stageTension:Number = 60;
      public var stageFloorTension:Number = 0;
      public var stageVerticalFollow:Number = 0.9;
      public var stageZoomMin:Number = 0.68;
      public var stageZoomMax:Number = 0.75;
      public var stageStartZoom:Number = NaN;
      public var stageLocalScaleX:Number = 1.0;
      public var stageLocalScaleY:Number = 1.0;
      public var stagePlayerBottom:Number = 640.0;
      public var stageHalfWidth:Number = 640.0;
      
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
      
      public function setZoomInitial(param1:Number) : void
      {
         _zoom = param1;
         _stageScale = param1;
         _noTweenRect.width = _screenSize.x / _zoom;
         _noTweenRect.height = _screenSize.y / _zoom;
         _rect.width = _noTweenRect.width;
         _rect.height = _noTweenRect.height;
         _foffsetX = _screenSize.x / 2 / _zoom;
         _foffsetY = _screenSize.y / 2 / _zoom;
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
      
      private function renderTwo(p1Display:DisplayObject, p2Display:DisplayObject) : void
      {
         var rightObj:DisplayObject = null;
         var leftObj:DisplayObject = null;
         var bottomObj:DisplayObject = null;
         var topObj:DisplayObject = null;
         var zoomTargetX:Number = NaN;
         var zoomTargetY:Number = NaN;
         var targetZoom:Number = NaN;
         var distX:Number = 0;
         var distY:Number = 0;
         
         if(stageCameraMode)
         {
            var pLeftX:Number = Math.min(p1Display.x, p2Display.x);
            var pRightX:Number = Math.max(p1Display.x, p2Display.x);
            var playerDistX:Number = pRightX - pLeftX;
            _point.x = (pLeftX + pRightX) * 0.5;
            
            var pTopY:Number = Math.min(p1Display.y, p2Display.y);
            _point.y = pTopY;
            
            if(autoZoom)
            {
               var tensionX:Number = Math.max(0, stageTension * stageLocalScaleX);
               var targetSpanX:Number = playerDistX + tensionX * 2.0;
               var effectiveZoomMin:Number = stageZoomMin;
               var effectiveZoomMax:Number = stageZoomMax;
               if(effectiveZoomMin >= 1.0 && effectiveZoomMax <= 1.0)
               {
                  effectiveZoomMin = 0.625;
                  effectiveZoomMax = 1.0;
               }
               var idealZoom:Number = _screenSize.x / Math.max(targetSpanX, _screenSize.x / effectiveZoomMax);
               targetZoom = Math.min(Math.max(idealZoom, effectiveZoomMin), effectiveZoomMax);
               renderAutoZoom(targetZoom);
            }
            return;
         }
         
         if(focusX)
         {
            if(p1Display.x < p2Display.x)
            {
               leftObj = p1Display;
               rightObj = p2Display;
            }
            else
            {
               leftObj = p2Display;
               rightObj = p1Display;
            }
            distX = rightObj.x - leftObj.x;
            _point.x = leftObj.x + distX / 2;
         }
         if(focusY)
         {
            if(p1Display.y < p2Display.y)
            {
               topObj = p1Display;
               bottomObj = p2Display;
            }
            else
            {
               topObj = p2Display;
               bottomObj = p1Display;
            }
            distY = bottomObj.y - topObj.y;
            _point.y = topObj.y + distY / 2;
         }
         if(autoZoom)
         {
            zoomTargetX = _zoom;
            zoomTargetY = _zoom;
            var scaleRatio:Number = LocalCoordManager.isLocalCoordMode() ? LocalCoordManager.getScale() : 1;
            if(focusX)
            {
               zoomTargetX = (_screenSize.x / distX * 0.8) / scaleRatio;
            }
            if(focusY)
            {
               zoomTargetY = (_screenSize.y / distY * 0.8) / scaleRatio;
            }
            targetZoom = Math.min(zoomTargetX,zoomTargetY);
            renderAutoZoom(targetZoom);
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
         if(stageCameraMode)
         {
            var targetCenterX:Number = !!_point ? _point.x : _focus[0].x;
            setX(targetCenterX);
            return;
         }
         var _loc1_:Number = NaN;
         _loc1_ = Number(!!_point ? _point.x : _focus[0].x);
         _loc1_ -= _foffsetX + offsetX;
         setX(_loc1_);
      }
      
      private function renderY() : void
      {
         if(stageCameraMode)
         {
            var highestPlayerY:Number = !!_point ? _point.y : _focus[0].y;
            setY(highestPlayerY);
            return;
         }
         var _loc1_:Number = NaN;
         _loc1_ = Number(!!_point ? _point.y : _focus[0].y);
         _loc1_ -= _foffsetY + offsetY;
         setY(_loc1_);
      }
      
      public function setX(targetX:Number) : void
      {
         if(stageCameraMode)
         {
            var halfScreen:Number = (_screenSize.x * 0.5) / _zoom;
            var effectiveZoomMin:Number = (stageZoomMin > 0) ? stageZoomMin : _zoom;
            var extraPan:Number = 0;
            if(_zoom > effectiveZoomMin)
            {
               extraPan = (_screenSize.x * 0.5) * (1.0 / effectiveZoomMin - 1.0 / _zoom);
            }
            var minCenterStageX:Number = stageHalfWidth + stageBoundLeft * stageLocalScaleX - extraPan;
            var maxCenterStageX:Number = stageHalfWidth + stageBoundRight * stageLocalScaleX + extraPan;
            if(minCenterStageX > maxCenterStageX)
            {
               targetX = stageHalfWidth;
            }
            else
            {
               if(targetX < minCenterStageX)
               {
                  targetX = minCenterStageX;
               }
               if(targetX > maxCenterStageX)
               {
                  targetX = maxCenterStageX;
               }
            }
            var finalTargetRectX:Number = targetX - halfScreen;
            _noTweenRect.x = finalTargetRectX;
            if(tweenSpd > 1)
            {
               _rect.x += (finalTargetRectX - _rect.x) / tweenSpd;
            }
            else
            {
               _rect.x = finalTargetRectX;
            }
            return;
         }
         if(_fbR)
         {
            if(_fbR.width < _fbR.x)
            {
               targetX = (_fbR.x + _fbR.width) / 2;
            }
            else
            {
               if(targetX < _fbR.x)
               {
                  targetX = _fbR.x;
               }
               if(targetX > _fbR.width)
               {
                  targetX = _fbR.width;
               }
            }
         }
         _noTweenRect.x = targetX;
         if(tweenSpd > 1)
         {
            _rect.x += (targetX - _rect.x) / tweenSpd;
         }
         else
         {
            _rect.x = targetX;
         }
      }
      
      public function setY(targetY:Number) : void
      {
         if(stageCameraMode)
         {
            var jumpHeight:Number = Math.max(0, stagePlayerBottom - targetY);
            var floorTension:Number = Math.max(0, stageFloorTension * stageLocalScaleY);
            var camFollowY:Number = 0;
            if(jumpHeight > floorTension)
            {
               camFollowY = (jumpHeight - floorTension) * stageVerticalFollow;
            }
            var maxUpward:Number = Math.abs(stageBoundHigh) * stageLocalScaleY;
            if(camFollowY > maxUpward)
            {
               camFollowY = maxUpward;
            }
            var finalTargetRectY:Number = stagePlayerBottom - (stagePlayerBottom / _zoom) - camFollowY;
            _noTweenRect.y = finalTargetRectY;
            if(tweenSpd > 1)
            {
               _rect.y += (finalTargetRectY - _rect.y) / tweenSpd;
            }
            else
            {
               _rect.y = finalTargetRectY;
            }
            return;
         }
         if(_fbR)
         {
            if(_fbR.height < _fbR.y)
            {
               targetY = (_fbR.y + _fbR.height) / 2;
            }
            else
            {
               if(targetY < _fbR.y)
               {
                  targetY = _fbR.y;
               }
               if(targetY > _fbR.height)
               {
                  targetY = _fbR.height;
               }
            }
         }
         _noTweenRect.y = targetY;
         if(tweenSpd > 1)
         {
            _rect.y += (targetY - _rect.y) / tweenSpd;
         }
         else
         {
            _rect.y = targetY;
         }
      }
      
      public function getStageCamFollowY() : Number
      {
         if(!stageCameraMode)
         {
            return 0;
         }
         var groundRectY:Number = stagePlayerBottom - (stagePlayerBottom / _zoom);
         return groundRectY - _rect.y;
      }
      
      public function getStageCamCenterX() : Number
      {
         if(!stageCameraMode)
         {
            return stageHalfWidth;
         }
         var halfScreen:Number = (_screenSize.x * 0.5) / _zoom;
         return _rect.x + halfScreen;
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

