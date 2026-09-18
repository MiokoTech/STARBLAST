package net.play5d.game.bvn.map
{
   import flash.display.Bitmap;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.GameQuailty;
   import net.play5d.game.bvn.data.GameData;
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
      
      public var cameraStartX:Number = 0;
      public var cameraStartY:Number = 0;
      public var cameraBoundLeft:Number = -500;
      public var cameraBoundRight:Number = 500;
      public var cameraBoundHigh:Number = -1000;
      public var cameraBoundLow:Number = 0;
      public var cameraVerticalFollow:Number = 0.9;
      public var cameraFloorTension:Number = 0;
      public var cameraTension:Number = 60;
      public var cameraZoomMin:Number = NaN;
      public var cameraZoomMax:Number = NaN;
      public var cameraStartZoom:Number = NaN;
      
      public var p1Facing:int = 1;
      public var p2Facing:int = -1;
      public var p3Facing:int = 1;
      public var p4Facing:int = -1;
      public var screenLeft:Number = 10;
      public var screenRight:Number = 10;
      
      public var stageAutoTurn:Boolean = true;
      public var stageResetBG:Boolean = false;
      public var stageHires:Boolean = false;
      
      public var shadowIntensity:Number = 128;
      public var shadowColor:uint = 0x000000;
      public var shadowYScale:Number = 0.2;
      public var shadowFadeRange:Array = null;
      
      public var reflectionIntensity:Number = 0;
      
      public var bgMusic:String = null;
      public var bgmVolume:Number = 100;
      public var bgmLoopStart:int = 0;
      public var bgmLoopEnd:int = 0;
      
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
      private var _jsonLayerDataList:Array = [];
      private var _bitmapCache:Object = null;
      private var _actionMap:Object = null;
      private var _stageControllers:Array = [];
      private var _stageTick:int = 0;
      private var _localScaleX:Number = 1.0;
      private var _localScaleY:Number = 1.0;
      private var _stageCoord:Point = new Point(640, 360);
      private var _stageWidth:Number = 1280.0;
      private var _stageHalfWidth:Number = 640.0;
      private var _baseZOffset:Number = 320.0;
      
      public function MapMain(mapDisplay:Sprite = null)
      {
         super();
         mapMc = mapDisplay;
      }

      public function initByJSON(stageConfig:Object, bitmapCache:Object) : void
      {
         _isJSONMap = true;
         _jsonLayers = stageConfig.layers || [];
         _bitmapCache = bitmapCache || {};
         _actionMap = stageConfig.actions || {};
         _stageControllers = stageConfig.controllers || stageConfig.bgctrls || [];
         _stageTick = 0;
         _jsonLayerDataList = [];
         
         var localcoord:Array = [1280, 720];
         if(stageConfig.stageinfo && stageConfig.stageinfo.localcoord)
         {
            localcoord = stageConfig.stageinfo.localcoord;
         }
         var scW:Number = (localcoord && localcoord.length > 0 && localcoord[0] > 0) ? Number(localcoord[0]) : 1280.0;
         var scH:Number = (localcoord && localcoord.length > 1 && localcoord[1] > 0) ? Number(localcoord[1]) : 720.0;
         _stageCoord = new Point(scW, scH);
         _localScaleX = 1280.0 / scW;
         _localScaleY = 720.0 / scH;
         
         var boundLeft:Number = -500;
         var boundRight:Number = 500;
         if(stageConfig.camera)
         {
            if(stageConfig.camera.startx != undefined) cameraStartX = Number(stageConfig.camera.startx);
            if(stageConfig.camera.starty != undefined) cameraStartY = Number(stageConfig.camera.starty);
            if(stageConfig.camera.boundleft != undefined) boundLeft = cameraBoundLeft = Number(stageConfig.camera.boundleft);
            if(stageConfig.camera.boundright != undefined) boundRight = cameraBoundRight = Number(stageConfig.camera.boundright);
            if(stageConfig.camera.boundhigh != undefined) cameraBoundHigh = Number(stageConfig.camera.boundhigh) * _localScaleY;
            if(stageConfig.camera.boundlow != undefined) cameraBoundLow = Number(stageConfig.camera.boundlow) * _localScaleY;
            if(stageConfig.camera.verticalfollow != undefined) cameraVerticalFollow = Number(stageConfig.camera.verticalfollow);
            if(stageConfig.camera.floortension != undefined) cameraFloorTension = Number(stageConfig.camera.floortension) * _localScaleY;
            if(stageConfig.camera.tension != undefined) cameraTension = Number(stageConfig.camera.tension) * _localScaleX;
            if(stageConfig.camera.zoomout != undefined) cameraZoomMin = Number(stageConfig.camera.zoomout);
            if(stageConfig.camera.zoomin != undefined) cameraZoomMax = Number(stageConfig.camera.zoomin);
            if(stageConfig.camera.startzoom != undefined) cameraStartZoom = Number(stageConfig.camera.startzoom);
         }
         
         var zoomOutScale:Number = (!isNaN(cameraZoomMin) && cameraZoomMin > 0) ? cameraZoomMin : 1.0;
         var maxViewHalfSpan:Number = 640.0 / zoomOutScale;
         var cameraTravelRange:Number = (boundRight - boundLeft) * _localScaleX;
         _stageWidth = cameraTravelRange + maxViewHalfSpan * 2.0;
         _stageHalfWidth = _stageWidth * 0.5;
         
         left = _stageHalfWidth + boundLeft * _localScaleX - maxViewHalfSpan;
         right = _stageHalfWidth + boundRight * _localScaleX + maxViewHalfSpan;
         
         var zoffset:Number = 320;
         if(stageConfig.stageinfo && stageConfig.stageinfo.zoffset != undefined)
         {
            zoffset = Number(stageConfig.stageinfo.zoffset);
         }
         else if(stageConfig.player && stageConfig.player.zoffset != undefined)
         {
            zoffset = Number(stageConfig.player.zoffset);
         }
         _baseZOffset = zoffset;
         playerBottom = zoffset * _localScaleY;
         bottom = 720.0;
         if(playerBottom > bottom)
         {
            bottom = playerBottom;
         }
         
         var p1StartX:Number = -170;
         var p1StartY:Number = 0;
         var p2StartX:Number = 170;
         var p2StartY:Number = 0;
         if(stageConfig.playerinfo)
         {
            if(stageConfig.playerinfo.p1startx != undefined) p1StartX = Number(stageConfig.playerinfo.p1startx);
            if(stageConfig.playerinfo.p1starty != undefined) p1StartY = Number(stageConfig.playerinfo.p1starty);
            if(stageConfig.playerinfo.p1facing != undefined) p1Facing = int(stageConfig.playerinfo.p1facing);
            if(stageConfig.playerinfo.p2startx != undefined) p2StartX = Number(stageConfig.playerinfo.p2startx);
            if(stageConfig.playerinfo.p2starty != undefined) p2StartY = Number(stageConfig.playerinfo.p2starty);
            if(stageConfig.playerinfo.p2facing != undefined) p2Facing = int(stageConfig.playerinfo.p2facing);
            if(stageConfig.playerinfo.p3facing != undefined) p3Facing = int(stageConfig.playerinfo.p3facing);
            if(stageConfig.playerinfo.p4facing != undefined) p4Facing = int(stageConfig.playerinfo.p4facing);
            if(stageConfig.playerinfo.leftbound != undefined && stageConfig.playerinfo.rightbound != undefined)
            {
               var pLeftBound:Number = _stageHalfWidth + Number(stageConfig.playerinfo.leftbound) * _localScaleX;
               var pRightBound:Number = _stageHalfWidth + Number(stageConfig.playerinfo.rightbound) * _localScaleX;
               if(pLeftBound > left) left = pLeftBound;
               if(pRightBound < right) right = pRightBound;
            }
         }
         p1pos = new Point(_stageHalfWidth + p1StartX * _localScaleX, playerBottom + p1StartY * _localScaleY);
         p2pos = new Point(_stageHalfWidth + p2StartX * _localScaleX, playerBottom + p2StartY * _localScaleY);
         
         if(stageConfig.bound)
         {
            if(stageConfig.bound.screenleft != undefined) screenLeft = Number(stageConfig.bound.screenleft) * _localScaleX;
            if(stageConfig.bound.screenright != undefined) screenRight = Number(stageConfig.bound.screenright) * _localScaleX;
         }
         
         if(stageConfig.stageinfo)
         {
            if(stageConfig.stageinfo.autoturn != undefined) stageAutoTurn = Boolean(stageConfig.stageinfo.autoturn);
            if(stageConfig.stageinfo.resetBG != undefined) stageResetBG = Boolean(stageConfig.stageinfo.resetBG);
            if(stageConfig.stageinfo.hires != undefined) stageHires = Boolean(stageConfig.stageinfo.hires);
         }
         
         if(stageConfig.shadow)
         {
            if(stageConfig.shadow.intensity != undefined) shadowIntensity = Number(stageConfig.shadow.intensity);
            if(stageConfig.shadow.color && stageConfig.shadow.color.length >= 3)
            {
               shadowColor = (uint(stageConfig.shadow.color[0]) << 16) | (uint(stageConfig.shadow.color[1]) << 8) | uint(stageConfig.shadow.color[2]);
            }
            if(stageConfig.shadow.yscale != undefined) shadowYScale = Number(stageConfig.shadow.yscale);
            if(stageConfig.shadow.fade_range) shadowFadeRange = stageConfig.shadow.fade_range;
         }
         
         if(stageConfig.reflection)
         {
            if(stageConfig.reflection.intensity != undefined) reflectionIntensity = Number(stageConfig.reflection.intensity);
         }
         
         if(stageConfig.music)
         {
            if(stageConfig.music.bgmusic != undefined) bgMusic = String(stageConfig.music.bgmusic);
            if(stageConfig.music.bgmvolume != undefined) bgmVolume = Number(stageConfig.music.bgmvolume);
            if(stageConfig.music.bgmloopstart != undefined) bgmLoopStart = int(stageConfig.music.bgmloopstart);
            if(stageConfig.music.bgmloopend != undefined) bgmLoopEnd = int(stageConfig.music.bgmloopend);
         }
         
         var bgContainer:Sprite = new Sprite();
         var frontContainer:Sprite = new Sprite();
         
         bgLayer = new MapLayer(bgContainer);
         frontLayer = new MapLayer(frontContainer);
         mapLayer = new MapLayer(new Sprite());
         
         if(!mapMc) mapMc = new Sprite();
         mapMc.addChild(bgLayer);
         mapMc.addChild(frontLayer);
         
         for each(var layerConfig:Object in _jsonLayers)
         {
            if(!layerConfig) continue;
            
            var imgRef:String = layerConfig.img_ref;
            var bmpSource:Bitmap = _bitmapCache[imgRef] as Bitmap;
            
            var layerSprite:Sprite = new Sprite();
            var bmpDisplay:Bitmap = new Bitmap(bmpSource ? bmpSource.bitmapData : null);
            bmpDisplay.smoothing = !GameConfig.PIXEL_STYLE_MODE && GameData.I.config.quality == GameQuailty.BEST;
            layerSprite.addChild(bmpDisplay);
            
            var actionnoVal:int = (layerConfig.actionno != undefined && layerConfig.actionno != null) ? int(layerConfig.actionno) : -1;
            var scaleStartX:Number = 1.0;
            var scaleStartY:Number = 1.0;
            if(layerConfig.scalestart && layerConfig.scalestart.length >= 2)
            {
               scaleStartX = Number(layerConfig.scalestart[0]);
               scaleStartY = Number(layerConfig.scalestart[1]);
            }
            var ctrlIdVal:int = layerConfig.ctrl_id != undefined ? int(layerConfig.ctrl_id) : -1;
            
            var layerData:Object = {
               "sprite": layerSprite,
               "bitmap": bmpDisplay,
               "config": layerConfig,
               "name": layerConfig.name || "",
               "type": layerConfig.type || "normal",
               "layerno": layerConfig.layerno != undefined ? int(layerConfig.layerno) : 0,
               "startX": (layerConfig.start && layerConfig.start.length > 0) ? Number(layerConfig.start[0]) : 0,
               "startY": (layerConfig.start && layerConfig.start.length > 1) ? Number(layerConfig.start[1]) : 0,
               "deltaX": (layerConfig.delta && layerConfig.delta.length > 0) ? Number(layerConfig.delta[0]) : 1,
               "deltaY": (layerConfig.delta && layerConfig.delta.length > 1) ? Number(layerConfig.delta[1]) : 1,
               "scaleStartX": scaleStartX,
               "scaleStartY": scaleStartY,
               "ctrlId": ctrlIdVal,
               "tileX": (layerConfig.tile && layerConfig.tile.length > 0) ? int(layerConfig.tile[0]) : 0,
               "tileY": (layerConfig.tile && layerConfig.tile.length > 1) ? int(layerConfig.tile[1]) : 0,
               "velX": (layerConfig.velocity && layerConfig.velocity.length > 0) ? Number(layerConfig.velocity[0]) : 0,
               "velY": (layerConfig.velocity && layerConfig.velocity.length > 1) ? Number(layerConfig.velocity[1]) : 0,
               "sin_x": layerConfig.sin_x || null,
               "sin_y": layerConfig.sin_y || null,
               "velPosX": 0.0,
               "velPosY": 0.0,
               "sinTickX": 0,
               "sinTickY": 0,
               "axisX": layerConfig.axis_x != undefined ? Number(layerConfig.axis_x) : 0,
               "axisY": layerConfig.axis_y != undefined ? Number(layerConfig.axis_y) : 0,
               "actionno": actionnoVal,
               "curFrameIdx": 0,
               "curFrameTick": 0,
               "actionFrames": null,
               "flip": layerConfig.flip ? String(layerConfig.flip).toUpperCase() : ""
            };
            
            if(layerData.actionno != -1 && _actionMap[String(layerData.actionno)])
            {
               layerData.actionFrames = _actionMap[String(layerData.actionno)] as Array;
               if(layerData.actionFrames && layerData.actionFrames.length > 0)
               {
                  var initActFrame:Object = layerData.actionFrames[0];
                  if(initActFrame && initActFrame.flip)
                  {
                     layerData.flip = String(initActFrame.flip).toUpperCase();
                  }
               }
            }
            
            applyLayerTransparency(layerSprite, layerConfig.trans, layerConfig.alpha);
            
            if(layerData.layerno == 1)
            {
               frontContainer.addChild(layerSprite);
            }
            else
            {
               bgContainer.addChild(layerSprite);
            }
            
            _jsonLayerDataList.push(layerData);
         }
         
         var defaultFloor:FloorVO = new FloorVO();
         defaultFloor.xFrom = left - 2000;
         defaultFloor.xTo = right + 2000;
         defaultFloor.y = playerBottom;
         _floors = [defaultFloor];
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
         if(_bitmapCache)
         {
            for(var cacheKey:String in _bitmapCache)
            {
               delete _bitmapCache[cacheKey];
            }
            _bitmapCache = null;
         }
         _actionMap = null;
         _jsonLayerDataList = null;
         _jsonLayers = null;
         _stageCoord = null;
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
         if(_isJSONMap)
         {
            return new Point(_stageWidth, GameConfig.GAME_SIZE.y);
         }
         return new Point(mapLayer.width,GameConfig.GAME_SIZE.y);
      }
      
      public function getMapBottomDistance() : Number
      {
         return bottom - playerBottom;
      }
      
      public function get isJSONMap() : Boolean
      {
         return _isJSONMap;
      }
      
      public function get localScaleX() : Number
      {
         return _localScaleX;
      }
      
      public function get localScaleY() : Number
      {
         return _localScaleY;
      }
      
      public function get stageHalfWidth() : Number
      {
         return _stageHalfWidth;
      }
      
      public function get stageCoord() : Point
      {
         return _stageCoord ? _stageCoord.clone() : new Point(640, 360);
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
         if(!_jsonLayerDataList || _jsonLayerDataList.length == 0)
         {
            return;
         }
         
         updateStageControllers();
         
         var cameraZoom:Number = (gameState && gameState.camera) ? gameState.camera.getZoom(true) : 1.0;
         var camCenterX:Number = (gameState && gameState.camera) ? gameState.camera.getStageCamCenterX() : _stageHalfWidth;
         var baseCamX:Number = (camCenterX - _stageHalfWidth) / _localScaleX;
         var camFollowY:Number = (gameState && gameState.camera) ? gameState.camera.getStageCamFollowY() : 0;
         var baseCamY:Number = -camFollowY / _localScaleY;
         
         for each(var layerData:Object in _jsonLayerDataList)
         {
            if(!layerData)
            {
               continue;
            }
            
            var frames:Array = layerData.actionFrames as Array;
            if(frames && frames.length > 0)
            {
               layerData.curFrameTick++;
               var curFrame:Object = frames[layerData.curFrameIdx];
               var ticks:int = (curFrame && curFrame.ticks > 0) ? int(curFrame.ticks) : 1;
               if(layerData.curFrameTick >= ticks)
               {
                  layerData.curFrameTick = 0;
                  layerData.curFrameIdx = (layerData.curFrameIdx + 1) % frames.length;
                  var nextFrame:Object = frames[layerData.curFrameIdx];
                  if(nextFrame)
                  {
                     if(nextFrame.img_ref && _bitmapCache[nextFrame.img_ref])
                     {
                        var nextBmp:Bitmap = _bitmapCache[nextFrame.img_ref] as Bitmap;
                        if(nextBmp && layerData.bitmap.bitmapData != nextBmp.bitmapData)
                        {
                           layerData.bitmap.bitmapData = nextBmp.bitmapData;
                        }
                     }
                     if(nextFrame.trans)
                     {
                        applyLayerTransparency(layerData.sprite, nextFrame.trans, nextFrame.alpha);
                     }
                     if(nextFrame.axis_x != undefined)
                     {
                        layerData.axisX = Number(nextFrame.axis_x);
                     }
                     if(nextFrame.axis_y != undefined)
                     {
                        layerData.axisY = Number(nextFrame.axis_y);
                     }
                     if(nextFrame.flip != undefined)
                     {
                        layerData.flip = String(nextFrame.flip).toUpperCase();
                     }
                  }
               }
            }
            
            layerData.velPosX += layerData.velX;
            layerData.velPosY += layerData.velY;
            
            var sinOffX:Number = 0;
            if(layerData.sin_x && layerData.sin_x.length >= 2 && layerData.sin_x[1] > 0)
            {
               var loopTimeX:int = int(layerData.sin_x[1]);
               sinOffX = Number(layerData.sin_x[0]) * Math.sin(2 * Math.PI * layerData.sinTickX / loopTimeX);
               layerData.sinTickX = (layerData.sinTickX + 1) % loopTimeX;
            }
            
            var sinOffY:Number = 0;
            if(layerData.sin_y && layerData.sin_y.length >= 2 && layerData.sin_y[1] > 0)
            {
               var loopTimeY:int = int(layerData.sin_y[1]);
               sinOffY = Number(layerData.sin_y[0]) * Math.sin(2 * Math.PI * layerData.sinTickY / loopTimeY);
               layerData.sinTickY = (layerData.sinTickY + 1) % loopTimeY;
            }
            
            var zoomDeltaX:Number = (layerData.config.zoomdelta && layerData.config.zoomdelta.length > 0) ? Number(layerData.config.zoomdelta[0]) : layerData.deltaX;
            var zoomDeltaY:Number = (layerData.config.zoomdelta && layerData.config.zoomdelta.length > 1) ? Number(layerData.config.zoomdelta[1]) : layerData.deltaY;
            var zoomScaleX:Number = cameraZoom + (1.0 - cameraZoom) * (1.0 - zoomDeltaX);
            var zoomScaleY:Number = cameraZoom + (1.0 - cameraZoom) * (1.0 - zoomDeltaY);
            
            var totalScaleX:Number = _localScaleX * layerData.scaleStartX * zoomScaleX;
            var totalScaleY:Number = _localScaleY * layerData.scaleStartY * zoomScaleY;
            
            var isFlippedH:Boolean = (layerData.flip && layerData.flip.indexOf("H") != -1);
            var isFlippedV:Boolean = (layerData.flip && layerData.flip.indexOf("V") != -1);
            
            var bmpW:Number = (layerData.bitmap && layerData.bitmap.bitmapData) ? layerData.bitmap.bitmapData.width : Number(layerData.config.width || 0);
            var bmpH:Number = (layerData.bitmap && layerData.bitmap.bitmapData) ? layerData.bitmap.bitmapData.height : Number(layerData.config.height || 0);
            
            var effectiveAxisX:Number = isFlippedH ? (bmpW - layerData.axisX) : layerData.axisX;
            var effectiveAxisY:Number = isFlippedV ? (bmpH - layerData.axisY) : layerData.axisY;
            
            var layerStageX:Number = layerData.startX - baseCamX * layerData.deltaX + layerData.velPosX + sinOffX - effectiveAxisX * layerData.scaleStartX;
            var layerStageY:Number = layerData.startY - baseCamY * layerData.deltaY + layerData.velPosY + sinOffY;
            
            var finalX:Number = 640.0 + layerStageX * (_localScaleX * zoomScaleX);
            var yBase:Number = _localScaleY * (layerStageY - effectiveAxisY * layerData.scaleStartY);
            var finalY:Number = playerBottom + (yBase - playerBottom) * zoomScaleY;
            
            if(layerData.tileX != 0 || layerData.tileY != 0)
            {
               if(layerData.bitmap && layerData.bitmap.bitmapData)
               {
                  layerData.bitmap.visible = false;
                  layerData.sprite.scaleX = 1.0;
                  layerData.sprite.scaleY = 1.0;
                  layerData.sprite.x = 0;
                  layerData.sprite.y = 0;
                  var fillMatrix:Matrix = new Matrix();
                  fillMatrix.scale(isFlippedH ? -totalScaleX : totalScaleX, isFlippedV ? -totalScaleY : totalScaleY);
                  fillMatrix.translate(isFlippedH ? (finalX + bmpW * totalScaleX) : finalX, isFlippedV ? (finalY + bmpH * totalScaleY) : finalY);
                  layerData.sprite.graphics.clear();
                  layerData.sprite.graphics.beginBitmapFill(layerData.bitmap.bitmapData, fillMatrix, true, true);
                  var rectX:Number = layerData.tileX != 0 ? 0 : finalX;
                  var rectY:Number = layerData.tileY != 0 ? 0 : finalY;
                  var rectW:Number = layerData.tileX != 0 ? 1280 : (bmpW * totalScaleX);
                  var rectH:Number = layerData.tileY != 0 ? 720 : (bmpH * totalScaleY);
                  layerData.sprite.graphics.drawRect(rectX, rectY, rectW, rectH);
                  layerData.sprite.graphics.endFill();
               }
            }
            else
            {
               if(layerData.bitmap)
               {
                  layerData.bitmap.visible = true;
               }
               layerData.sprite.scaleX = isFlippedH ? -totalScaleX : totalScaleX;
               layerData.sprite.scaleY = isFlippedV ? -totalScaleY : totalScaleY;
               var drawPosX:Number = isFlippedH ? (finalX + bmpW * totalScaleX) : finalX;
               var drawPosY:Number = isFlippedV ? (finalY + bmpH * totalScaleY) : finalY;
               if(GameConfig.PIXEL_STYLE_MODE)
               {
                  layerData.sprite.x = Math.floor(drawPosX);
                  layerData.sprite.y = Math.floor(drawPosY);
               }
               else
               {
                  layerData.sprite.x = drawPosX;
                  layerData.sprite.y = drawPosY;
               }
            }
         }
      }
      
      private function updateStageControllers() : void
      {
         if(!_stageControllers || _stageControllers.length == 0)
         {
            return;
         }
         
         for each(var ctrl:Object in _stageControllers)
         {
            if(!ctrl)
            {
               continue;
            }
            
            var timeSpec:Array = ctrl.time as Array;
            var startTime:int = (timeSpec && timeSpec.length > 0) ? int(timeSpec[0]) : 0;
            var endTime:int = (timeSpec && timeSpec.length > 1) ? int(timeSpec[1]) : 0;
            var loopTime:int = (timeSpec && timeSpec.length > 2) ? int(timeSpec[2]) : -1;
            
            if(startTime < 0 || (loopTime >= 0 && startTime >= loopTime))
            {
               continue;
            }
            if(loopTime > 0 && endTime > loopTime)
            {
               endTime = loopTime;
            }
            
            var isActive:Boolean = false;
            if(_stageTick >= startTime)
            {
               if(loopTime > 0)
               {
                  var duration:int = endTime - startTime;
                  if((_stageTick - startTime) % loopTime <= duration)
                  {
                     isActive = true;
                  }
               }
               else if(_stageTick <= endTime)
               {
                  isActive = true;
               }
            }
            
            if(isActive)
            {
               applyStageController(ctrl);
            }
         }
         _stageTick++;
      }
      
      private function applyStageController(ctrl:Object) : void
      {
         var targetCtrlId:int = ctrl.ctrl_id != undefined ? int(ctrl.ctrl_id) : -1;
         var ctrlType:String = ctrl.type ? String(ctrl.type).toLowerCase() : "";
         
         for each(var layerData:Object in _jsonLayerDataList)
         {
            if(!layerData)
            {
               continue;
            }
            if(targetCtrlId != -1 && layerData.ctrlId != targetCtrlId)
            {
               continue;
            }
            
            switch(ctrlType)
            {
               case "velset":
                  if(ctrl.x != undefined) layerData.velX = Number(ctrl.x);
                  if(ctrl.y != undefined) layerData.velY = Number(ctrl.y);
                  break;
               case "veladd":
                  if(ctrl.x != undefined) layerData.velX += Number(ctrl.x);
                  if(ctrl.y != undefined) layerData.velY += Number(ctrl.y);
                  break;
               case "posset":
                  if(ctrl.x != undefined) layerData.velPosX = Number(ctrl.x);
                  if(ctrl.y != undefined) layerData.velPosY = Number(ctrl.y);
                  break;
               case "posadd":
                  if(ctrl.x != undefined) layerData.velPosX += Number(ctrl.x);
                  if(ctrl.y != undefined) layerData.velPosY += Number(ctrl.y);
                  break;
               case "visible":
                  if(ctrl.value != undefined && layerData.sprite)
                  {
                     layerData.sprite.visible = (int(ctrl.value) != 0);
                  }
                  break;
               case "enable":
                  if(ctrl.value != undefined)
                  {
                     layerData.enabled = (int(ctrl.value) != 0);
                  }
                  break;
               case "anim":
                  if(ctrl.value != undefined)
                  {
                     var animNo:int = int(ctrl.value);
                     if(_actionMap && _actionMap[String(animNo)])
                     {
                        layerData.actionFrames = _actionMap[String(animNo)] as Array;
                        layerData.curFrameIdx = 0;
                        layerData.curFrameTick = 0;
                     }
                  }
                  break;
            }
         }
      }
      
      private function applyLayerTransparency(target:DisplayObject, trans:String, alphaArr:Array) : void
      {
         if(!target)
         {
            return;
         }
         if(!trans || trans == "none")
         {
            target.blendMode = BlendMode.NORMAL;
            target.alpha = 1.0;
            return;
         }
         if(trans == "add")
         {
            target.blendMode = BlendMode.ADD;
            target.alpha = 1.0;
            return;
         }
         if(trans == "sub")
         {
            target.blendMode = BlendMode.SUBTRACT;
            target.alpha = 1.0;
            return;
         }
         if(trans.indexOf("as") == 0)
         {
            var dIdx:int = trans.indexOf("d");
            if(dIdx != -1)
            {
               var srcA:Number = Number(trans.substring(2, dIdx));
               target.blendMode = BlendMode.ADD;
               target.alpha = Math.min(1.0, Math.max(0.0, srcA / 256.0));
               return;
            }
         }
         if(alphaArr && alphaArr.length > 0)
         {
            target.alpha = Math.min(1.0, Math.max(0.0, Number(alphaArr[0]) / 256.0));
            if(trans == "addalpha" || trans == "add1")
            {
               target.blendMode = BlendMode.ADD;
            }
            return;
         }
         target.blendMode = BlendMode.NORMAL;
         target.alpha = 1.0;
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
