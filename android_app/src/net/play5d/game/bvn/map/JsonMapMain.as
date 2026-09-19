package net.play5d.game.bvn.map
{
   import flash.display.Bitmap;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.PerspectiveProjection;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.GameQuailty;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.interfaces.IGameSprite;

   public class JsonMapMain extends MapMain
   {
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

      public function JsonMapMain(mapDisplay:Sprite = null)
      {
         super(mapDisplay);
      }

      override public function get isJSONMap() : Boolean
      {
         return true;
      }

      override public function get localScaleX() : Number
      {
         return _localScaleX;
      }

      override public function get localScaleY() : Number
      {
         return _localScaleY;
      }

      override public function get stageHalfWidth() : Number
      {
         return _stageHalfWidth;
      }

      override public function get stageCoord() : Point
      {
         return _stageCoord ? _stageCoord.clone() : new Point(640, 360);
      }

      override public function getStageSize() : Point
      {
         return new Point(_stageWidth, GameConfig.GAME_SIZE.y);
      }

      override public function initlize() : void
      {
      }

      public function initByJSON(stageConfig:Object, bitmapCache:Object) : void
      {
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
         var maxViewHalfSpan:Number = (GameConfig.GAME_SIZE.x * 0.5) / zoomOutScale;
         var cameraTravelRange:Number = (boundRight - boundLeft) * _localScaleX;
         _stageWidth = cameraTravelRange + maxViewHalfSpan * 2.0;
         _stageHalfWidth = _stageWidth * 0.5;

         left = _stageHalfWidth + boundLeft * _localScaleX - maxViewHalfSpan;
         right = _stageHalfWidth + boundRight * _localScaleX + maxViewHalfSpan;

         var zoffset:Number = 320;
         if(stageConfig.stageinfo && stageConfig.stageinfo.zoffset != undefined)
         {
            zoffset = Number(stageConfig.stageinfo.zoffset);
            var zLink:int = stageConfig.stageinfo.zoffsetlink != undefined ? int(stageConfig.stageinfo.zoffsetlink) : -1;
            if(zoffset <= 0 && zLink >= 0 && _jsonLayers)
            {
               for each(var lConf:Object in _jsonLayers)
               {
                  if(lConf && (lConf.ctrl_id == zLink || lConf.id == ("bg_" + zLink)))
                  {
                     if(lConf.start && lConf.start.length > 1)
                     {
                        zoffset += Number(lConf.start[1]);
                     }
                     break;
                  }
               }
            }
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
            if(stageConfig.shadow.xshear != undefined) shadowXShear = Number(stageConfig.shadow.xshear);
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

         var proj:PerspectiveProjection = new PerspectiveProjection();
         proj.projectionCenter = new Point(GameConfig.GAME_SIZE.x * 0.5, GameConfig.GAME_SIZE.y * 0.5);
         var flen:Number = 600.0;
         if(stageConfig.camera && stageConfig.camera.flength != undefined)
         {
            flen = Number(stageConfig.camera.flength);
         }
         if(flen > 0)
         {
            proj.focalLength = flen;
         }
         bgContainer.transform.perspectiveProjection = proj;
         frontContainer.transform.perspectiveProjection = proj;

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

            var sinTickXVal:int = 0;
            if(layerConfig.sin_x && layerConfig.sin_x.length >= 3 && layerConfig.sin_x[1] > 0)
            {
               sinTickXVal = int(int(layerConfig.sin_x[1]) * Number(layerConfig.sin_x[2]) / 360.0) % int(layerConfig.sin_x[1]);
            }
            var sinTickYVal:int = 0;
            if(layerConfig.sin_y && layerConfig.sin_y.length >= 3 && layerConfig.sin_y[1] > 0)
            {
               sinTickYVal = int(int(layerConfig.sin_y[1]) * Number(layerConfig.sin_y[2]) / 360.0) % int(layerConfig.sin_y[1]);
            }

            var winArr:Array = layerConfig.window as Array;
            var maskWinArr:Array = layerConfig.maskwindow as Array;

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
               "tileSpacingX": (layerConfig.tilespacing && layerConfig.tilespacing.length > 0) ? int(layerConfig.tilespacing[0]) : 0,
               "tileSpacingY": (layerConfig.tilespacing && layerConfig.tilespacing.length > 1) ? int(layerConfig.tilespacing[1]) : 0,
               "velX": (layerConfig.velocity && layerConfig.velocity.length > 0) ? Number(layerConfig.velocity[0]) : 0,
               "velY": (layerConfig.velocity && layerConfig.velocity.length > 1) ? Number(layerConfig.velocity[1]) : 0,
               "sin_x": layerConfig.sin_x || null,
               "sin_y": layerConfig.sin_y || null,
               "velPosX": 0.0,
               "velPosY": 0.0,
               "sinTickX": sinTickXVal,
               "sinTickY": sinTickYVal,
               "axisX": layerConfig.axis_x != undefined ? Number(layerConfig.axis_x) : 0,
               "axisY": layerConfig.axis_y != undefined ? Number(layerConfig.axis_y) : 0,
               "actionno": actionnoVal,
               "curFrameIdx": 0,
               "curFrameTick": 0,
               "curAngle": 0.0,
               "xangle": layerConfig.xangle != undefined ? Number(layerConfig.xangle) : 0.0,
               "yangle": layerConfig.yangle != undefined ? Number(layerConfig.yangle) : 0.0,
               "hasCustomMatrix": false,
               "hasCustomMatrix3D": false,
               "actionFrames": null,
               "flip": layerConfig.flip ? String(layerConfig.flip).toUpperCase() : "",
               "xshear": layerConfig.xshear != undefined ? Number(layerConfig.xshear) : 0.0,
               "positionlink": (layerConfig.positionlink == true || layerConfig.positionlink == 1),
               "linkIndex": layerConfig.link_idx != undefined ? int(layerConfig.link_idx) : -1,
               "windowArr": winArr,
               "maskWindowArr": maskWinArr,
               "windowDeltaX": (layerConfig.windowdelta && layerConfig.windowdelta.length > 0) ? Number(layerConfig.windowdelta[0]) : 0.0,
               "windowDeltaY": (layerConfig.windowdelta && layerConfig.windowdelta.length > 1) ? Number(layerConfig.windowdelta[1]) : 0.0,
               "maskSprite": null,
               "lastSinOffX": 0.0,
               "lastSinOffY": 0.0,
               "lastFinalX": GameConfig.GAME_SIZE.x * 0.5,
               "lastFinalY": 0.0
            };

            if((winArr && winArr.length >= 4) || (maskWinArr && maskWinArr.length >= 4))
            {
               var maskSpr:Sprite = new Sprite();
               if(layerData.layerno == 1)
               {
                  frontContainer.addChild(maskSpr);
               }
               else
               {
                  bgContainer.addChild(maskSpr);
               }
               layerSprite.mask = maskSpr;
               layerData.maskSprite = maskSpr;
            }

            if(layerData.actionno != -1 && _actionMap[String(layerData.actionno)])
            {
               layerData.actionFrames = _actionMap[String(layerData.actionno)] as Array;
               if(layerData.actionFrames && layerData.actionFrames.length > 0)
               {
                  var initActFrame:Object = layerData.actionFrames[0];
                  if(initActFrame)
                  {
                     if(initActFrame.group == -1 || !initActFrame.img_ref)
                     {
                        bmpDisplay.visible = false;
                     }
                     else if(initActFrame.img_ref && _bitmapCache[initActFrame.img_ref])
                     {
                        var initBmp:Bitmap = _bitmapCache[initActFrame.img_ref] as Bitmap;
                        if(initBmp && bmpDisplay.bitmapData != initBmp.bitmapData)
                        {
                           bmpDisplay.bitmapData = initBmp.bitmapData;
                        }
                        bmpDisplay.visible = true;
                     }
                     if(initActFrame.flip)
                     {
                        layerData.flip = String(initActFrame.flip).toUpperCase();
                     }
                     if(initActFrame.axis_x != undefined)
                     {
                        layerData.axisX = Number(initActFrame.axis_x);
                     }
                     if(initActFrame.axis_y != undefined)
                     {
                        layerData.axisY = Number(initActFrame.axis_y);
                     }
                     if(initActFrame.trans)
                     {
                        applyLayerTransparency(layerSprite, initActFrame.trans, initActFrame.alpha);
                     }
                  }
               }
            }
            else
            {
               applyLayerTransparency(layerSprite, layerConfig.trans, layerConfig.alpha);
            }

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

      override public function render(cameraX:Number, cameraY:Number, cameraZoom:Number) : void
      {
         var gameSprites:Vector.<IGameSprite> = gameState ? gameState.getGameSprites() : null;
         if(!gameSprites || gameSprites.length < 1)
         {
            return;
         }
         renderJSONMap(cameraX, cameraY, gameSprites);
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
         var effectiveCamY:Number = (cameraZoom > 0.01) ? (baseCamY / cameraZoom) : baseCamY;

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
                     if(nextFrame.group == -1 || !nextFrame.img_ref)
                     {
                        layerData.bitmap.visible = false;
                     }
                     else if(nextFrame.img_ref && _bitmapCache[nextFrame.img_ref])
                     {
                        var nextBmp:Bitmap = _bitmapCache[nextFrame.img_ref] as Bitmap;
                        if(nextBmp && layerData.bitmap.bitmapData != nextBmp.bitmapData)
                        {
                           layerData.bitmap.bitmapData = nextBmp.bitmapData;
                        }
                        layerData.bitmap.visible = true;
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

               var activeFrame:Object = frames[layerData.curFrameIdx];
               if(activeFrame)
               {
                  var targetFrame:Object = frames[(layerData.curFrameIdx + 1) % frames.length];
                  var progress:Number = (ticks > 0) ? (Number(layerData.curFrameTick) / Number(ticks)) : 0;
                  if(activeFrame.interpolate_blend || (targetFrame && targetFrame.interpolate_blend))
                  {
                     var curSrcA:Number = activeFrame.src_alpha != undefined ? Number(activeFrame.src_alpha) : 256.0;
                     var nextSrcA:Number = (targetFrame && targetFrame.src_alpha != undefined) ? Number(targetFrame.src_alpha) : curSrcA;
                     var interpA:Number = curSrcA + (nextSrcA - curSrcA) * progress;
                     layerData.sprite.alpha = Math.min(1.0, Math.max(0.0, interpA / 256.0));
                     if(activeFrame.trans && activeFrame.trans != "none")
                     {
                        if(activeFrame.trans.indexOf("as") == 0 || activeFrame.trans == "a" || activeFrame.trans == "add")
                        {
                           layerData.sprite.blendMode = BlendMode.ADD;
                        }
                     }
                  }

                  if(activeFrame.interpolate_angle || (targetFrame && targetFrame.interpolate_angle))
                  {
                     var curFrameAngle:Number = activeFrame.angle != undefined ? Number(activeFrame.angle) : 0.0;
                     var nextFrameAngle:Number = (targetFrame && targetFrame.angle != undefined) ? Number(targetFrame.angle) : curFrameAngle;
                     layerData.curAngle = curFrameAngle + (nextFrameAngle - curFrameAngle) * progress;
                  }
                  else if(activeFrame.angle != undefined)
                  {
                     layerData.curAngle = Number(activeFrame.angle);
                  }
                  else
                  {
                     layerData.curAngle = 0.0;
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

            if(layerData.positionlink && layerData.linkIndex >= 0 && layerData.linkIndex < _jsonLayerDataList.length)
            {
               var parentLayer:Object = _jsonLayerDataList[layerData.linkIndex];
               if(parentLayer)
               {
                  sinOffX += Number(parentLayer.lastSinOffX || 0);
                  sinOffY += Number(parentLayer.lastSinOffY || 0);
               }
            }
            layerData.lastSinOffX = sinOffX;
            layerData.lastSinOffY = sinOffY;

            var zoomDeltaX:Number = (layerData.config.zoomdelta && layerData.config.zoomdelta.length > 0) ? Number(layerData.config.zoomdelta[0]) : layerData.deltaX;
            var zoomDeltaY:Number = (layerData.config.zoomdelta && layerData.config.zoomdelta.length > 1) ? Number(layerData.config.zoomdelta[1]) : ((layerData.config.zoomdelta && layerData.config.zoomdelta.length > 0) ? Number(layerData.config.zoomdelta[0]) : layerData.deltaY);
            var zoomScaleX:Number = cameraZoom + (1.0 - cameraZoom) * (1.0 - zoomDeltaX);
            var zoomScaleY:Number = cameraZoom + (1.0 - cameraZoom) * (1.0 - zoomDeltaY);

            var scaleDeltaX:Number = (layerData.config.scaledelta && layerData.config.scaledelta.length > 0) ? Number(layerData.config.scaledelta[0]) : 0.0;
            var scaleDeltaY:Number = (layerData.config.scaledelta && layerData.config.scaledelta.length > 1) ? Number(layerData.config.scaledelta[1]) : 0.0;
            var scaleStartX:Number = Number(layerData.scaleStartX);
            var rawScaleX:Number = scaleStartX + scaleDeltaX * baseCamX * layerData.deltaX;
            var dynamicScaleX:Number = Math.abs(rawScaleX);
            if(dynamicScaleX < 0.01) dynamicScaleX = 0.01;

            var baseScaleY:Number = Math.abs(layerData.scaleStartY);
            var dynamicScaleY:Number = baseScaleY + scaleDeltaY * baseCamY * layerData.deltaY;
            if(dynamicScaleY < 0.01) dynamicScaleY = 0.01;

            var totalScaleX:Number = _localScaleX * dynamicScaleX * zoomScaleX;
            var totalScaleY:Number = _localScaleY * dynamicScaleY * zoomScaleY;

            var isFlippedH:Boolean = (layerData.flip && layerData.flip.indexOf("H") != -1) || (rawScaleX < 0);
            var isFlippedV:Boolean = (layerData.flip && layerData.flip.indexOf("V") != -1) || (layerData.scaleStartY < 0);

            var bmpW:Number = (layerData.bitmap && layerData.bitmap.bitmapData) ? layerData.bitmap.bitmapData.width : Number(layerData.config.width || 0);
            var bmpH:Number = (layerData.bitmap && layerData.bitmap.bitmapData) ? layerData.bitmap.bitmapData.height : Number(layerData.config.height || 0);

            var effectiveAxisX:Number = isFlippedH ? (bmpW - layerData.axisX) : layerData.axisX;
            var effectiveAxisY:Number = isFlippedV ? (bmpH - layerData.axisY) : layerData.axisY;

            var layerStageX:Number = layerData.startX - baseCamX * layerData.deltaX + layerData.velPosX + sinOffX - effectiveAxisX * dynamicScaleX;
            var layerStageY:Number = layerData.startY - effectiveCamY * layerData.deltaY + layerData.velPosY + sinOffY;

            var screenCenterX:Number = GameConfig.GAME_SIZE.x * 0.5;
            var finalX:Number = screenCenterX + layerStageX * (_localScaleX * zoomScaleX);
            var yBase:Number = _localScaleY * (layerStageY - effectiveAxisY * dynamicScaleY);
            var finalY:Number = playerBottom + (yBase - playerBottom) * zoomScaleY;

            if(layerData.maskSprite)
            {
               var winRect:Array = (layerData.windowArr && layerData.windowArr.length >= 4) ? layerData.windowArr : layerData.maskWindowArr;
               if(winRect && winRect.length >= 4)
               {
                  var isMaskWindow:Boolean = (layerData.windowArr == null && layerData.maskWindowArr != null);
                  var rawX1:Number = Number(winRect[0]);
                  var rawY1:Number = Number(winRect[1]);
                  var rawX2:Number = Number(winRect[2]);
                  var rawY2:Number = Number(winRect[3]);
                  var winW:Number = isMaskWindow ? (rawX2 - rawX1) : (rawX2 - rawX1 + 1);
                  var winH:Number = isMaskWindow ? (rawY2 - rawY1) : (rawY2 - rawY1 + 1);

                  var winDrawX:Number = screenCenterX + (rawX1 - baseCamX * layerData.windowDeltaX) * (_localScaleX * zoomScaleX);
                  var winDrawY:Number = playerBottom + (_localScaleY * (rawY1 - baseCamY * layerData.windowDeltaY) - playerBottom) * zoomScaleY;

                  layerData.maskSprite.graphics.clear();
                  layerData.maskSprite.graphics.beginFill(0xFF0000, 1.0);
                  layerData.maskSprite.graphics.drawRect(winDrawX, winDrawY, winW * (_localScaleX * zoomScaleX), winH * (_localScaleY * zoomScaleY));
                  layerData.maskSprite.graphics.endFill();
               }
            }

            if(layerData.type == "parallax" && layerData.bitmap && layerData.bitmap.bitmapData)
            {
               layerData.bitmap.visible = false;
               layerData.sprite.scaleX = 1.0;
               layerData.sprite.scaleY = 1.0;
               layerData.sprite.x = 0;
               layerData.sprite.y = 0;
               layerData.sprite.graphics.clear();

               var pWidthArr:Array = layerData.config.parallax_width as Array;
               var pXScaleArr:Array = layerData.config.parallax_xscale as Array;
               var topRatio:Number = 1.0;
               var botRatio:Number = 1.0;
               if(pWidthArr && pWidthArr.length >= 2 && bmpW > 0)
               {
                  topRatio = Number(pWidthArr[0]) / bmpW;
                  botRatio = Number(pWidthArr[1]) / bmpW;
               }
               else if(pXScaleArr && pXScaleArr.length >= 2)
               {
                  topRatio = Number(pXScaleArr[0]);
                  botRatio = Number(pXScaleArr[1]);
               }

               var deltaTop:Number = (layerData.config.delta && layerData.config.delta.length > 0) ? Number(layerData.config.delta[0]) : layerData.deltaX;
               var deltaBot:Number = (layerData.config.delta && layerData.config.delta.length > 1) ? Number(layerData.config.delta[1]) : layerData.deltaX;

               var yscaleStartVal:Number = layerData.config.yscalestart != undefined ? Number(layerData.config.yscalestart) : 100.0;
               var yscaleDeltaVal:Number = layerData.config.yscaledelta != undefined ? Number(layerData.config.yscaledelta) : 0.0;
               var ysdelta:Number = yscaleStartVal + yscaleDeltaVal * effectiveCamY;
               if(yscaleStartVal * ysdelta < 0) ysdelta = -ysdelta;
               if(Math.abs(ysdelta) < 0.01) ysdelta = 0.01;
               var uniformScaleY:Number = (100.0 / ysdelta) * Math.abs(layerData.scaleStartY);

               var xofs:Number = 0.0;
               if(pWidthArr && pWidthArr.length >= 2 && bmpW > 0)
               {
                  var topW:Number = Number(pWidthArr[0]);
                  var xscale0:Number = topW / bmpW;
                  var scaleStartX_abs:Number = Math.abs(layerData.scaleStartX);
                  xofs = scaleStartX_abs * ((-topW * 0.5) + layerData.axisX * xscale0);
               }

               var numSlices:int = 32;
               var sliceH:Number = bmpH / numSlices;
               var sliceMatrix:Matrix = new Matrix();

               var linkOffX:Number = 0.0;
               var linkOffY:Number = 0.0;
               if(layerData.positionlink && layerData.linkIndex >= 0 && layerData.linkIndex < _jsonLayerDataList.length)
               {
                  var pLink:Object = _jsonLayerDataList[layerData.linkIndex];
                  if(pLink)
                  {
                     linkOffX = Number(pLink.lastFinalX || 0) - screenCenterX;
                     linkOffY = Number(pLink.lastFinalY || 0) - finalY;
                  }
               }
               layerData.lastFinalX = finalX;
               layerData.lastFinalY = finalY;

               var totalBaseScaleY:Number = _localScaleY * uniformScaleY * zoomScaleY;
               var destSliceH:Number = sliceH * totalBaseScaleY + 0.6;

               var xsoffset:Number = layerData.xshear * effectiveAxisY * _localScaleY * zoomScaleY;

               var sliceIdx:int = 0;
               var accumY:Number = finalY + linkOffY;
               while(sliceIdx < numSlices)
               {
                  var tRatio:Number = Number(sliceIdx) / Number(numSlices - 1);

                  var curRatioX:Number = topRatio + (botRatio - topRatio) * tRatio;
                  var curDeltaX:Number = deltaTop + (deltaBot - deltaTop) * tRatio;

                  var curZoomDeltaX:Number = (layerData.config.zoomdelta && layerData.config.zoomdelta.length > 0) ? Number(layerData.config.zoomdelta[0]) : curDeltaX;
                  var curZoomScaleX:Number = cameraZoom + (1.0 - cameraZoom) * (1.0 - curZoomDeltaX);
                  var curTotalScaleX:Number = _localScaleX * dynamicScaleX * curZoomScaleX * curRatioX;

                  var curLayerStageX:Number = layerData.startX + xofs - (baseCamX + linkOffX / _localScaleX) * curDeltaX + layerData.velPosX + sinOffX;
                  var curSliceFinalX:Number = screenCenterX + curLayerStageX * (_localScaleX * curZoomScaleX);

                  sliceMatrix.identity();
                  sliceMatrix.scale(isFlippedH ? -curTotalScaleX : curTotalScaleX, isFlippedV ? -totalBaseScaleY : totalBaseScaleY);

                  if(layerData.xshear != 0)
                  {
                     sliceMatrix.c = -layerData.xshear * (isFlippedH ? -curTotalScaleX : curTotalScaleX);
                  }

                  var transX:Number = isFlippedH ? (curSliceFinalX + (bmpW - effectiveAxisX) * curTotalScaleX) : (curSliceFinalX - effectiveAxisX * curTotalScaleX);
                  if(layerData.xshear != 0)
                  {
                     transX += xsoffset;
                  }
                  var transY:Number = isFlippedV ? (finalY + linkOffY + bmpH * totalBaseScaleY) : (finalY + linkOffY);
                  sliceMatrix.translate(transX, transY);

                  layerData.sprite.graphics.beginBitmapFill(layerData.bitmap.bitmapData, sliceMatrix, true, true);
                  layerData.sprite.graphics.drawRect(0, accumY, GameConfig.GAME_SIZE.x, destSliceH);
                  layerData.sprite.graphics.endFill();

                  accumY += destSliceH;
                  sliceIdx++;
               }
            }
            else if(layerData.tileX != 0 || layerData.tileY != 0)
            {
               if(layerData.bitmap && layerData.bitmap.bitmapData)
               {
                  layerData.bitmap.visible = false;
                  layerData.sprite.scaleX = 1.0;
                  layerData.sprite.scaleY = 1.0;
                  layerData.sprite.x = 0;
                  layerData.sprite.y = 0;
                  layerData.sprite.graphics.clear();

                   var tileSpacingVal:Number = Number(layerData.tileSpacingX);
                   var stridePixels:Number = bmpW;
                   if(tileSpacingVal > 0)
                   {
                      if(layerData.actionno != -1)
                      {
                         stridePixels = tileSpacingVal;
                      }
                      else
                      {
                         stridePixels = bmpW + tileSpacingVal;
                      }
                   }

                   if(tileSpacingVal > 0 && Math.abs(stridePixels - bmpW) > 0.01)
                   {
                      var drawTileW:Number = bmpW * totalScaleX;
                      var tileStrideX:Number = stridePixels * totalScaleX;
                      if(tileStrideX <= 0) tileStrideX = drawTileW;
                      if(tileStrideX > 0)
                      {
                         var startDrawX:Number = finalX % tileStrideX;
                         while(startDrawX > -drawTileW) startDrawX -= tileStrideX;
                         var curTileX:Number = startDrawX;
                         while(curTileX < GameConfig.GAME_SIZE.x)
                         {
                            var singleTileMat:Matrix = new Matrix();
                            singleTileMat.scale(isFlippedH ? -totalScaleX : totalScaleX, isFlippedV ? -totalScaleY : totalScaleY);
                            if(layerData.xshear != 0)
                            {
                               singleTileMat.c = -layerData.xshear * (isFlippedH ? -totalScaleX : totalScaleX);
                            }
                            singleTileMat.translate(isFlippedH ? (curTileX + bmpW * totalScaleX) : curTileX, isFlippedV ? (finalY + bmpH * totalScaleY) : finalY);
                            layerData.sprite.graphics.beginBitmapFill(layerData.bitmap.bitmapData, singleTileMat, false, true);
                            layerData.sprite.graphics.drawRect(curTileX, finalY, drawTileW, bmpH * totalScaleY);
                            layerData.sprite.graphics.endFill();
                            curTileX += tileStrideX;
                         }
                      }
                   }
                   else
                   {
                      var fillMatrix:Matrix = new Matrix();
                      fillMatrix.scale(isFlippedH ? -totalScaleX : totalScaleX, isFlippedV ? -totalScaleY : totalScaleY);
                      if(layerData.xshear != 0)
                      {
                         fillMatrix.c = -layerData.xshear * (isFlippedH ? -totalScaleX : totalScaleX);
                      }
                      fillMatrix.translate(isFlippedH ? (finalX + bmpW * totalScaleX) : finalX, isFlippedV ? (finalY + bmpH * totalScaleY) : finalY);
                      layerData.sprite.graphics.beginBitmapFill(layerData.bitmap.bitmapData, fillMatrix, true, true);
                      var rectX:Number = layerData.tileX != 0 ? 0 : finalX;
                      var rectY:Number = layerData.tileY != 0 ? 0 : finalY;
                      var rectW:Number = layerData.tileX != 0 ? GameConfig.GAME_SIZE.x : (bmpW * totalScaleX);
                      var rectH:Number = layerData.tileY != 0 ? GameConfig.GAME_SIZE.y : (bmpH * totalScaleY);
                      layerData.sprite.graphics.drawRect(rectX, rectY, rectW, rectH);
                      layerData.sprite.graphics.endFill();
                   }
                }
             }
             else
             {
                if(layerData.bitmap)
                {
                   layerData.bitmap.visible = true;
                }
                var drawPosX:Number = isFlippedH ? (finalX + bmpW * totalScaleX) : finalX;
                var drawPosY:Number = isFlippedV ? (finalY + bmpH * totalScaleY) : finalY;
                var hasAngle:Boolean = layerData.curAngle != undefined && layerData.curAngle != 0;
                var has3D:Boolean = (layerData.xangle != undefined && layerData.xangle != 0) || (layerData.yangle != undefined && layerData.yangle != 0);

                if(has3D)
                {
                   var pivotX3D:Number = finalX + effectiveAxisX * totalScaleX;
                   var pivotY3D:Number = finalY + effectiveAxisY * totalScaleY;
                   var curAngleDeg3D:Number = hasAngle ? Number(layerData.curAngle) : 0;
                   var mat3D:Matrix3D = new Matrix3D();
                   mat3D.appendScale(isFlippedH ? -totalScaleX : totalScaleX, isFlippedV ? -totalScaleY : totalScaleY, 1.0);
                   mat3D.appendTranslation(drawPosX - pivotX3D, drawPosY - pivotY3D, 0);
                   if(layerData.xangle != 0) mat3D.appendRotation(Number(layerData.xangle), Vector3D.X_AXIS);
                   if(layerData.yangle != 0) mat3D.appendRotation(Number(layerData.yangle), Vector3D.Y_AXIS);
                   if(hasAngle) mat3D.appendRotation(curAngleDeg3D, Vector3D.Z_AXIS);
                   mat3D.appendTranslation(pivotX3D, pivotY3D, 0);
                   layerData.sprite.transform.matrix3D = mat3D;
                   layerData.hasCustomMatrix3D = true;
                }
                else if(layerData.xshear != 0 || hasAngle)
                {
                   if(layerData.hasCustomMatrix3D)
                   {
                      layerData.sprite.transform.matrix = new Matrix();
                      layerData.hasCustomMatrix3D = false;
                   }
                   var curAngleDeg:Number = hasAngle ? Number(layerData.curAngle) : 0;
                   var mat:Matrix = new Matrix();
                   mat.scale(isFlippedH ? -totalScaleX : totalScaleX, isFlippedV ? -totalScaleY : totalScaleY);
                   if(layerData.xshear != 0)
                   {
                      mat.c = -layerData.xshear * (isFlippedH ? -totalScaleX : totalScaleX);
                   }
                   if(hasAngle)
                   {
                      var pivotX:Number = finalX + effectiveAxisX * totalScaleX;
                      var pivotY:Number = finalY + effectiveAxisY * totalScaleY;
                      mat.translate(drawPosX - pivotX, drawPosY - pivotY);
                      mat.rotate(curAngleDeg * Math.PI / 180.0);
                      mat.translate(pivotX, pivotY);
                   }
                   else
                   {
                      mat.translate(drawPosX, drawPosY);
                   }
                   layerData.sprite.transform.matrix = mat;
                   layerData.hasCustomMatrix = true;
                }
                else
                {
                   if(layerData.hasCustomMatrix3D)
                   {
                      layerData.sprite.transform.matrix = new Matrix();
                      layerData.hasCustomMatrix3D = false;
                   }
                   if(layerData.hasCustomMatrix)
                   {
                      layerData.sprite.transform.matrix = new Matrix();
                      layerData.hasCustomMatrix = false;
                   }
                   layerData.sprite.scaleX = isFlippedH ? -totalScaleX : totalScaleX;
                   layerData.sprite.scaleY = isFlippedV ? -totalScaleY : totalScaleY;
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
               case "sinx":
                  if(ctrl.value && ctrl.value is Array && (ctrl.value as Array).length >= 2)
                  {
                     var valSinX:Array = ctrl.value as Array;
                     layerData.sin_x = [Number(valSinX[0]), Number(valSinX[1]), valSinX.length >= 3 ? Number(valSinX[2]) : 0];
                     if(valSinX.length >= 3 && Number(valSinX[1]) > 0)
                     {
                        layerData.sinTickX = int(int(valSinX[1]) * Number(valSinX[2]) / 360.0) % int(valSinX[1]);
                     }
                  }
                  break;
               case "siny":
                  if(ctrl.value && ctrl.value is Array && (ctrl.value as Array).length >= 2)
                  {
                     var valSinY:Array = ctrl.value as Array;
                     layerData.sin_y = [Number(valSinY[0]), Number(valSinY[1]), valSinY.length >= 3 ? Number(valSinY[2]) : 0];
                     if(valSinY.length >= 3 && Number(valSinY[1]) > 0)
                     {
                        layerData.sinTickY = int(int(valSinY[1]) * Number(valSinY[2]) / 360.0) % int(valSinY[1]);
                     }
                  }
                  break;
               case "palfx":
                  if(ctrl.mul || ctrl.add)
                  {
                     var colorTrans:ColorTransform = new ColorTransform();
                     if(ctrl.mul && ctrl.mul is Array && (ctrl.mul as Array).length >= 3)
                     {
                        colorTrans.redMultiplier = Number(ctrl.mul[0]) / 256.0;
                        colorTrans.greenMultiplier = Number(ctrl.mul[1]) / 256.0;
                        colorTrans.blueMultiplier = Number(ctrl.mul[2]) / 256.0;
                     }
                     if(ctrl.add && ctrl.add is Array && (ctrl.add as Array).length >= 3)
                     {
                        colorTrans.redOffset = Number(ctrl.add[0]);
                        colorTrans.greenOffset = Number(ctrl.add[1]);
                        colorTrans.blueOffset = Number(ctrl.add[2]);
                     }
                     if(layerData.sprite)
                     {
                        layerData.sprite.transform.colorTransform = colorTrans;
                     }
                  }
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
         if(trans == "add" || trans == "addalpha")
         {
            target.blendMode = BlendMode.ADD;
            if(alphaArr && alphaArr.length > 0)
            {
               target.alpha = Math.min(1.0, Math.max(0.0, Number(alphaArr[0]) / 256.0));
            }
            else
            {
               target.alpha = 1.0;
            }
            return;
         }
         if(trans == "add1")
         {
            target.blendMode = BlendMode.ADD;
            target.alpha = 0.5;
            return;
         }
         if(trans == "sub")
         {
            target.blendMode = BlendMode.SUBTRACT;
            if(alphaArr && alphaArr.length > 0)
            {
               target.alpha = Math.min(1.0, Math.max(0.0, Number(alphaArr[0]) / 256.0));
            }
            else
            {
               target.alpha = 1.0;
            }
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
            target.blendMode = BlendMode.NORMAL;
            target.alpha = Math.min(1.0, Math.max(0.0, Number(alphaArr[0]) / 256.0));
            return;
         }
         target.blendMode = BlendMode.NORMAL;
         target.alpha = 1.0;
      }

      override public function destory() : void
      {
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
         _stageControllers = null;
         _stageCoord = null;

         super.destory();
      }
   }
}
