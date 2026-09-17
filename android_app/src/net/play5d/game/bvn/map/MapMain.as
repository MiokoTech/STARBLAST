package net.play5d.game.bvn.map
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.data.MapVO;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.game.bvn.state.GameState;
   import net.play5d.game.bvn.utils.LegacyResolutionAdapter;
   
   public class MapMain
   {
      private var _colorTransform:ColorTransform = new ColorTransform();
      
      public var mapLayer:MapLayer;
      
      public var frontLayer:MapLayer;
      
      public var frontFixLayer:MapLayer;
      
      public var bgLayer:MapLayer;
      
      public var p1pos:Point;
      
      public var p2pos:Point;
      
      public var left:Number = 0;
      
      public var right:Number = 0;
      
      public var bottom:Number = 0;
      
      public var playerBottom:Number = 0;
      
      public var mapMc:Sprite;
      
      public var data:MapVO;
      
      public var gameState:GameState;
      
      private var _defaultFrontPos:Point;
      
      private var _smoothing:Point = new Point();
      
      private var _floors:Array;
      
      private var _legacyScaleX:Number = 1;
      
      private var _legacyScaleY:Number = 1;
      
      private var _useLegacyScale:Boolean = false;

      private var _isJSONMap:Boolean = false;
      private var _jsonLayers:Array = [];
      
      public function MapMain(mapDisplay:Sprite = null)
      {
         super();
         mapMc = mapDisplay;
      }

      public function initByJSON(param1:Object, param2:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:MapLayer = null;
         _isJSONMap = true;
         _jsonLayers = param1.layers;
         left = param1.camera.boundleft;
         right = param1.camera.boundright;
         bottom = param1.camera.boundlow || 0;
         playerBottom = param1.player.zoffset;
         p1pos = new Point(param1.player.p1startx || -100, playerBottom);
         p2pos = new Point(param1.player.p2startx || 100, playerBottom);
         
         if(!mapMc) mapMc = new Sprite();
         
         for each(_loc3_ in _jsonLayers)
         {
            var bitmap:Bitmap = param2[_loc3_.img_ref];
            if(bitmap)
            {
               _loc4_ = new MapLayer(bitmap);
               _loc4_.name = _loc3_.name;
               _loc4_.x = _loc3_.start[0];
               _loc4_.y = _loc3_.start[1];
               _loc4_["deltaX"] = _loc3_.delta[0];
               _loc4_["deltaY"] = _loc3_.delta[1];
               
               if(_loc3_.layerno == 0) {
                  if(!bgLayer) bgLayer = _loc4_;
                  else if(!mapLayer) mapLayer = _loc4_;
                  else mapMc.addChild(_loc4_);
               } else {
                  frontLayer = _loc4_;
               }
            }
         }
         
         if(bgLayer) mapMc.addChild(bgLayer);
         if(mapLayer) mapMc.addChild(mapLayer);
         if(frontLayer) {
            _defaultFrontPos = new Point(frontLayer.x, frontLayer.y);
            mapMc.addChild(frontLayer);
         }
         
         _floors = []; // TODO: Implement JSON floors
      }
      
      public function destory() : void
      {
         if(mapMc)
         {
            try
            {
               mapMc.stopAllMovieClips();
               mapMc.removeChildren();
            }
            catch(e:Error)
            {
               trace(e);
            }
            mapMc = null;
         }
         if(mapLayer)
         {
            mapLayer.destory();
            mapLayer = null;
         }
         if(frontLayer)
         {
            frontLayer.destory();
            frontLayer = null;
         }
         if(frontFixLayer)
         {
            frontFixLayer.destory();
            frontFixLayer = null;
         }
         if(bgLayer)
         {
            bgLayer.destory();
            bgLayer = null;
         }
      }
      
      public function setVisible(value:Boolean) : void
      {
         if(false && value)
         {
            return;
         }
         if(mapLayer && mapLayer.enabled)
         {
            mapLayer.visible = value;
         }
         if(frontLayer && frontLayer.enabled)
         {
            frontLayer.visible = value;
         }
         if(frontFixLayer && frontFixLayer.enabled)
         {
            frontFixLayer.visible = value;
         }
         if(bgLayer && bgLayer.enabled)
         {
            bgLayer.visible = value;
         }
      }
      
      public function getSmoothing() : Point
      {
         return _smoothing;
      }
      
      public function setSmoothing(smoothX:Number = 0, smoothY:Number = 0) : void
      {
         _smoothing.x = smoothX;
         _smoothing.y = smoothY;
         if(mapLayer && mapLayer.enabled)
         {
            mapLayer.setSmoothing(smoothX,smoothY);
         }
         if(bgLayer && bgLayer.enabled)
         {
            bgLayer.setSmoothing(smoothX * 3,smoothY * 3);
         }
         if(frontLayer && frontLayer.enabled)
         {
            frontLayer.setSmoothing(smoothX * 2,smoothY * 2);
         }
         if(frontFixLayer && frontFixLayer.enabled)
         {
            frontFixLayer.setSmoothing(smoothX * 2,smoothY * 2);
         }
      }
      
      public function initlize() : void
      {
         if(_isJSONMap) return;
         var leftMarker:DisplayObject = mapMc.getChildByName("line_left");
         var rightMarker:DisplayObject = mapMc.getChildByName("line_right");
         var bottomMarker:DisplayObject = mapMc.getChildByName("line_bottom");
         var playerBottomMarker:DisplayObject = mapMc.getChildByName("line_player_bottom");
         var p1Marker:DisplayObject = mapMc.getChildByName("p1");
         var p2Marker:DisplayObject = mapMc.getChildByName("p2");
         var mapDisplay:DisplayObject = mapMc.getChildByName("map");
         var frontDisplay:DisplayObject = mapMc.getChildByName("front");
         var frontFixDisplay:DisplayObject = mapMc.getChildByName("front_fix");
         var bgDisplay:DisplayObject = mapMc.getChildByName("bg");
         var gameSize:Point = GameConfig.GAME_SIZE;
         if(leftMarker)
         {
            left = leftMarker.x;
         }
         if(rightMarker)
         {
            right = rightMarker.x;
         }
         if(bottomMarker)
         {
            bottom = bottomMarker.y;
         }
         if(playerBottomMarker)
         {
            playerBottom = playerBottomMarker.y;
         }
         if(p1Marker)
         {
            p1pos = new Point(p1Marker.x,p1Marker.y);
         }
         if(p2Marker)
         {
            p2pos = new Point(p2Marker.x,p2Marker.y);
         }
         var sourceMapWidth:Number = mapDisplay ? Math.abs(mapDisplay.width) : Math.abs(right - left);
         var sourceMapHeight:Number = bottom > 0 ? bottom : (!!mapDisplay ? Math.abs(mapDisplay.height) : 0);
         setupLegacyScale(sourceMapWidth,sourceMapHeight);
         applyLegacyScaleToBoundaries();
         applyLegacyScaleToPlayerMarkers();
         mapLayer = new MapLayer(mapDisplay);
         frontLayer = new MapLayer(frontDisplay);
         frontFixLayer = new MapLayer(frontFixDisplay);
         bgLayer = new MapLayer(bgDisplay);
         if(bgLayer.enabled)
         {
            applyLegacyScaleToLayer(bgLayer);
            bgLayer.normalize();
            mapMc.addChild(bgLayer);
         }
         var mapBottomOffset:Number = gameSize.y - bottom;
         if(mapLayer.enabled)
         {
            applyLegacyScaleToLayer(mapLayer);
            mapLayer.normalize();
            mapLayer.y += mapBottomOffset;
            mapMc.addChild(mapLayer);
         }
         if(frontLayer.enabled)
         {
            applyLegacyScaleToLayer(frontLayer);
            frontLayer.normalize();
            frontLayer.y += mapBottomOffset;
            _defaultFrontPos = new Point(frontLayer.x,frontLayer.y);
            mapMc.addChild(frontLayer);
         }
         if(frontFixLayer.enabled)
         {
            applyLegacyScaleToLayer(frontFixLayer);
            frontFixLayer.normalize();
            frontFixLayer.y += mapBottomOffset;
            mapMc.addChild(frontFixLayer);
         }
         playerBottom += mapBottomOffset;
         bottom += mapBottomOffset;
         if(p1pos)
         {
            p1pos.y += mapBottomOffset;
         }
         if(p2pos)
         {
            p2pos.y += mapBottomOffset;
         }
         initFloor(mapBottomOffset);
      }
      
      public function getStageSize() : Point
      {
         return new Point(mapLayer.width,GameConfig.GAME_SIZE.y);
      }
      
      public function getMapBottomDistance() : Number
      {
         return bottom - playerBottom;
      }
      
      private function initFloor(mapBottomOffset:Number) : void
      {
         _floors = [];
         var floorContainer:Sprite = mapMc.getChildByName("floor") as Sprite;
         if(!floorContainer)
         {
            return;
         }
         var floorIndex:int = 0;
         while(floorIndex < floorContainer.numChildren)
         {
            var floorDisplay:DisplayObject = floorContainer.getChildAt(floorIndex);
            if(floorDisplay)
            {
               var floorVO:FloorVO = new FloorVO();
               floorVO.xFrom = (floorContainer.x + floorDisplay.x) * _legacyScaleX;
               floorVO.xTo = (floorContainer.x + floorDisplay.x + floorDisplay.width) * _legacyScaleX;
               floorVO.y = (floorContainer.y + floorDisplay.y) * _legacyScaleY + mapBottomOffset;
               _floors.push(floorVO);
            }
            floorIndex++;
         }
      }
      
      public function getFloorHitTest(fromX:Number, toX:Number, y:Number) : FloorVO
      {
         var floorIndex:int = 0;
         while(floorIndex < _floors.length)
         {
            var floorVO:FloorVO = _floors[floorIndex];
            if(floorVO.hitTest(fromX,toX,y))
            {
               return floorVO;
            }
            floorIndex++;
         }
         return null;
      }
      
      public function render(cameraX:Number, cameraY:Number, cameraZoom:Number) : void
      {
         var gameSprites:Vector.<IGameSprite> = gameState.getGameSprites();
         if(!gameSprites || gameSprites.length < 1)
         {
            return;
         }
         
         if(_isJSONMap)
         {
            renderJSONMap(cameraX, cameraY, gameSprites);
            return;
         }

         if(frontLayer && frontLayer.enabled)
         {
            var stageCameraBottomY:Number = cameraY + bottom;
            var frontTargetX:Number = cameraX * 0.1 + _defaultFrontPos.x;
            var frontTargetY:Number = stageCameraBottomY * 0.1 + _defaultFrontPos.y;
            frontTargetY < _defaultFrontPos.y && (frontTargetY);
            if(GameConfig.PIXEL_STYLE_MODE)
            {
               frontLayer.x = Math.floor(frontTargetX);
               frontLayer.y = Math.floor(frontTargetY);
            }
            else
            {
               frontLayer.x = frontTargetX;
               frontLayer.y = frontTargetY;
            }
            frontLayer.renderOptical(gameSprites);
         }
         if(frontFixLayer && frontFixLayer.enabled)
         {
            frontFixLayer.renderOptical(gameSprites);
         }
      }
      
      private function renderJSONMap(cameraX:Number, cameraY:Number, gameSprites:Vector.<IGameSprite>) : void
      {
         if(bgLayer) renderLayerParallax(bgLayer, cameraX, cameraY, gameSprites);
         if(mapLayer) renderLayerParallax(mapLayer, cameraX, cameraY, gameSprites);
         if(frontLayer) renderLayerParallax(frontLayer, cameraX, cameraY, gameSprites);
      }
      
      private function renderLayerParallax(layer:MapLayer, cameraX:Number, cameraY:Number, gameSprites:Vector.<IGameSprite>) : void
      {
         var deltaX:Number = layer.hasOwnProperty("deltaX") ? layer["deltaX"] : 1;
         var deltaY:Number = layer.hasOwnProperty("deltaY") ? layer["deltaY"] : 1;
         
         var targetX:Number = cameraX * (1 - deltaX);
         var targetY:Number = cameraY * (1 - deltaY);
         
         if(GameConfig.PIXEL_STYLE_MODE)
         {
            layer.x = Math.floor(targetX);
            layer.y = Math.floor(targetY);
         }
         else
         {
            layer.x = targetX;
            layer.y = targetY;
         }
         
         if(layer == frontLayer || layer == frontFixLayer)
         {
            layer.renderOptical(gameSprites);
         }
      }
      
      private function setupLegacyScale(sourceMapWidth:Number, sourceMapHeight:Number) : void
      {
         _useLegacyScale = LegacyResolutionAdapter.shouldScaleLegacyMap(sourceMapWidth,sourceMapHeight);
         if(!_useLegacyScale)
         {
            _legacyScaleX = 1;
            _legacyScaleY = 1;
            return;
         }
         _legacyScaleX = LegacyResolutionAdapter.getScaleX();
         _legacyScaleY = LegacyResolutionAdapter.getScaleY();
      }
      
      private function applyLegacyScaleToBoundaries() : void
      {
         if(!_useLegacyScale)
         {
            return;
         }
         left *= _legacyScaleX;
         right *= _legacyScaleX;
         bottom *= _legacyScaleY;
         playerBottom *= _legacyScaleY;
      }
      
      private function applyLegacyScaleToPlayerMarkers() : void
      {
         if(!_useLegacyScale)
         {
            return;
         }
         if(p1pos)
         {
            p1pos.x *= _legacyScaleX;
            p1pos.y *= _legacyScaleY;
         }
         if(p2pos)
         {
            p2pos.x *= _legacyScaleX;
            p2pos.y *= _legacyScaleY;
         }
      }
      
      private function applyLegacyScaleToLayer(layer:MapLayer) : void
      {
         if(!_useLegacyScale || !layer || !layer.enabled)
         {
            return;
         }
         layer.x *= _legacyScaleX;
         layer.y *= _legacyScaleY;
         layer.scaleX *= _legacyScaleX;
         layer.scaleY *= _legacyScaleY;
      }
      
      public function setColorTransform(ct:ColorTransform) : void
      {
         if(!mapMc)
         {
            return;
         }
         mapMc.transform.colorTransform = ct;
      }
      
      public function resetColorTransform() : void
      {
         if(!mapMc)
         {
            return;
         }
         if(!_colorTransform)
         {
            _colorTransform = new ColorTransform();
         }
         mapMc.transform.colorTransform = _colorTransform;
      }
   }
}
