package net.play5d.game.bvn.ui.select
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import com.greensock.easing.Quad;
   import com.greensock.easing.Quart;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.GradientType;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.MapModel;
   import net.play5d.game.bvn.data.MapVO;
   import net.play5d.game.bvn.ui.UIUtils;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.BitmapText;
   import net.play5d.kyo.utils.KyoRandom;

   public class MapSelectUI extends Sprite
   {
      public var enabled:Boolean = false;
      public var inputType:String;

      private var _bgContainer:Sprite;
      private var _blueBackdrop:Shape;

      private var _centerCard:Sprite;
      private var _centerPicContainer:Sprite;
      private var _centerCardMask:Shape;
      private var _centerCardBorder:Shape;

      private var _leftCard:Sprite;
      private var _leftPicContainer:Sprite;
      private var _leftCardMask:Shape;
      private var _leftCardBorder:Shape;

      private var _rightCard:Sprite;
      private var _rightPicContainer:Sprite;
      private var _rightCardMask:Shape;
      private var _rightCardBorder:Shape;

      private var _leftArrow:DisplayObject;
      private var _rightArrow:DisplayObject;
      private var _leftHit:Sprite;
      private var _rightHit:Sprite;

      private var _titleTxt:BitmapText;
      private var _stageNameTxt:BitmapText;
      private var _dividerLine:Shape;

      private var _maps:Array;
      private var _curId:int;
      private var _picCache:Object = {};

      private var _prevListener:Function;
      private var _nextListener:Function;
      private var _confrimListener:Function;

      private static const CARD_W:Number = 100;
      private static const CARD_H:Number = 240;
      private static const CARD_X:Number = 590;
      private static const CARD_Y:Number = 175;

      private static const SIDE_CARD_W:Number = 88;
      private static const SIDE_CARD_H:Number = 210;
      private static const LEFT_CARD_X:Number = 432;
      private static const LEFT_CARD_Y:Number = 190;
      private static const RIGHT_CARD_X:Number = 760;
      private static const RIGHT_CARD_Y:Number = 190;

      private static const ARROW_Y:Number = 280;
      private static const LEFT_ARROW_X:Number = 550;
      private static const RIGHT_ARROW_X:Number = 718;

      public function MapSelectUI()
      {
         super();
         build();
      }

      public function addMouseEvents(prevListener:Function, nextListener:Function, confirmListener:Function) : void
      {
         _prevListener = prevListener;
         _nextListener = nextListener;
         _confrimListener = confirmListener;

         if(GameConfig.TOUCH_MODE)
         {
            _leftHit.addEventListener("touchTap", touchHandler);
            _rightHit.addEventListener("touchTap", touchHandler);
            _leftCard.addEventListener("touchTap", touchHandler);
            _rightCard.addEventListener("touchTap", touchHandler);
            _centerCard.addEventListener("touchTap", touchHandler);
         }
         else
         {
            _leftHit.addEventListener("mouseOver", mouseHandler);
            _rightHit.addEventListener("mouseOver", mouseHandler);
            _leftCard.addEventListener("mouseOver", mouseHandler);
            _rightCard.addEventListener("mouseOver", mouseHandler);
            _centerCard.addEventListener("mouseOver", mouseHandler);
            _leftHit.addEventListener("click", mouseHandler);
            _rightHit.addEventListener("click", mouseHandler);
            _leftCard.addEventListener("click", mouseHandler);
            _rightCard.addEventListener("click", mouseHandler);
            _centerCard.addEventListener("click", mouseHandler);
         }
      }

      private function touchHandler(e:TouchEvent) : void
      {
         if(!enabled) return;
         switch(e.currentTarget)
         {
            case _leftHit:
            case _leftCard:
               if(_prevListener != null) _prevListener();
               break;
            case _rightHit:
            case _rightCard:
               if(_nextListener != null) _nextListener();
               break;
            case _centerCard:
               if(_confrimListener != null) _confrimListener();
               break;
         }
         SoundCtrl.I.sndConfrim();
      }

      private function mouseHandler(e:MouseEvent) : void
      {
         if(!enabled) return;
         if(e.type == "mouseOver")
         {
            SoundCtrl.I.sndSelect();
            return;
         }
         switch(e.currentTarget)
         {
            case _leftHit:
            case _leftCard:
               if(_prevListener != null) _prevListener();
               break;
            case _rightHit:
            case _rightCard:
               if(_nextListener != null) _nextListener();
               break;
            case _centerCard:
               if(_confrimListener != null) _confrimListener();
               break;
         }
         SoundCtrl.I.sndConfrim();
      }

      private function build() : void
      {
         _maps = MapModel.I.getAllMaps();

         _blueBackdrop = new Shape();
         var hMatrix:Matrix = new Matrix();
         hMatrix.createGradientBox(1280, 390, Math.PI / 2, 0, 95);
         _blueBackdrop.graphics.beginGradientFill(
            GradientType.LINEAR,
            [0x061832, 0x092244, 0x041122],
            [0.45, 0.60, 0.45],
            [0, 128, 255],
            hMatrix
         );
         _blueBackdrop.graphics.drawRect(0, 95, 1280, 390);
         _blueBackdrop.graphics.endFill();

         _blueBackdrop.graphics.lineStyle(1, 0x00d8ff, 0.45);
         _blueBackdrop.graphics.moveTo(0, 95);
         _blueBackdrop.graphics.lineTo(1280, 95);

         _blueBackdrop.graphics.lineStyle(1, 0x00d8ff, 0.50);
         _blueBackdrop.graphics.moveTo(0, 485);
         _blueBackdrop.graphics.lineTo(1280, 485);

         var vMatrix:Matrix = new Matrix();
         vMatrix.createGradientBox(540, 465, Math.PI / 2, 370, 95);
         _blueBackdrop.graphics.lineStyle(0, 0, 0);
         _blueBackdrop.graphics.beginGradientFill(
            GradientType.LINEAR,
            [0x0b2d5c, 0x041328],
            [0.72, 0.88],
            [0, 255],
            vMatrix
         );
         _blueBackdrop.graphics.moveTo(370, 95);
         _blueBackdrop.graphics.lineTo(910, 95);
         _blueBackdrop.graphics.lineTo(640, 560);
         _blueBackdrop.graphics.lineTo(370, 95);
         _blueBackdrop.graphics.endFill();

         _blueBackdrop.graphics.lineStyle(2, 0x00d8ff, 0.85);
         _blueBackdrop.graphics.moveTo(370, 95);
         _blueBackdrop.graphics.lineTo(640, 560);
         _blueBackdrop.graphics.lineTo(910, 95);

         _blueBackdrop.graphics.lineStyle(1, 0x00d8ff, 0.35);
         _blueBackdrop.graphics.moveTo(385, 105);
         _blueBackdrop.graphics.lineTo(640, 545);
         _blueBackdrop.graphics.lineTo(895, 105);

         _blueBackdrop.graphics.lineStyle(2, 0x00d8ff, 0.85);
         _blueBackdrop.graphics.moveTo(610, 545);
         _blueBackdrop.graphics.lineTo(640, 568);
         _blueBackdrop.graphics.lineTo(670, 545);

         _blueBackdrop.graphics.lineStyle(1.5, 0x00d8ff, 0.60);
         _blueBackdrop.graphics.moveTo(622, 562);
         _blueBackdrop.graphics.lineTo(640, 580);
         _blueBackdrop.graphics.lineTo(658, 562);

         var glowMatrix:Matrix = new Matrix();
         glowMatrix.createGradientBox(520, 150, 0, 380, 20);
         _blueBackdrop.graphics.lineStyle(0, 0, 0);
         _blueBackdrop.graphics.beginGradientFill(
            GradientType.RADIAL,
            [0x00d8ff, 0x003366],
            [0.30, 0],
            [0, 255],
            glowMatrix
         );
         _blueBackdrop.graphics.drawEllipse(380, 20, 520, 150);
         _blueBackdrop.graphics.endFill();
         _blueBackdrop.x = -640;
         _blueBackdrop.y = -290;

         _bgContainer = new Sprite();
         _bgContainer.x = 640;
         _bgContainer.y = 290;
         _bgContainer.addChild(_blueBackdrop);
         _bgContainer.cacheAsBitmap = true;
         addChild(_bgContainer);

         _titleTxt = new BitmapText(true, 0xffffff, [new GlowFilter(0x00d8ff, 0.85, 8, 8, 2.5)]);
         UIUtils.formatText(_titleTxt.textfield, {
            "color": 0xffffff,
            "size": 22,
            "bold": true,
            "align": "center"
         });
         _titleTxt.width = 1280;
         _titleTxt.text = "Stage Select";
         _titleTxt.x = 0;
         _titleTxt.y = 110;
         addChild(_titleTxt);

         _dividerLine = new Shape();
         _dividerLine.graphics.lineStyle(1.5, 0x00d8ff, 0.8);
         _dividerLine.graphics.moveTo(240, 485);
         _dividerLine.graphics.lineTo(1040, 485);
         _dividerLine.x = -640;
         _dividerLine.y = -290;
         _bgContainer.addChild(_dividerLine);

         _leftCard = new Sprite();
         _leftCard.x = LEFT_CARD_X;
         _leftCard.y = LEFT_CARD_Y;
         _leftCard.alpha = 0.45;
         _leftCard.buttonMode = true;

         _leftPicContainer = new Sprite();
         _leftCard.addChild(_leftPicContainer);

         _leftCardMask = new Shape();
         _leftCardMask.graphics.beginFill(0xffffff);
         _leftCardMask.graphics.drawRoundRect(0, 0, SIDE_CARD_W, SIDE_CARD_H, 6, 6);
         _leftCardMask.graphics.endFill();
         _leftCard.addChild(_leftCardMask);
         _leftPicContainer.mask = _leftCardMask;

         _leftCardBorder = new Shape();
         _leftCardBorder.graphics.lineStyle(1.5, 0x00d8ff, 0.6);
         _leftCardBorder.graphics.drawRoundRect(0, 0, SIDE_CARD_W, SIDE_CARD_H, 6, 6);
         _leftCard.addChild(_leftCardBorder);
         addChild(_leftCard);

         _rightCard = new Sprite();
         _rightCard.x = RIGHT_CARD_X;
         _rightCard.y = RIGHT_CARD_Y;
         _rightCard.alpha = 0.45;
         _rightCard.buttonMode = true;

         _rightPicContainer = new Sprite();
         _rightCard.addChild(_rightPicContainer);

         _rightCardMask = new Shape();
         _rightCardMask.graphics.beginFill(0xffffff);
         _rightCardMask.graphics.drawRoundRect(0, 0, SIDE_CARD_W, SIDE_CARD_H, 6, 6);
         _rightCardMask.graphics.endFill();
         _rightCard.addChild(_rightCardMask);
         _rightPicContainer.mask = _rightCardMask;

         _rightCardBorder = new Shape();
         _rightCardBorder.graphics.lineStyle(1.5, 0x00d8ff, 0.6);
         _rightCardBorder.graphics.drawRoundRect(0, 0, SIDE_CARD_W, SIDE_CARD_H, 6, 6);
         _rightCard.addChild(_rightCardBorder);
         addChild(_rightCard);

         _centerCard = new Sprite();
         _centerCard.x = CARD_X;
         _centerCard.y = CARD_Y;
         _centerCard.buttonMode = true;

         _centerPicContainer = new Sprite();
         _centerCard.addChild(_centerPicContainer);

         _centerCardMask = new Shape();
         _centerCardMask.graphics.beginFill(0xffffff);
         _centerCardMask.graphics.drawRoundRect(0, 0, CARD_W, CARD_H, 6, 6);
         _centerCardMask.graphics.endFill();
         _centerCard.addChild(_centerCardMask);
         _centerPicContainer.mask = _centerCardMask;

         _centerCardBorder = new Shape();
         _centerCardBorder.graphics.lineStyle(2, 0x00eaff, 1.0);
         _centerCardBorder.graphics.drawRoundRect(0, 0, CARD_W, CARD_H, 6, 6);
         _centerCard.addChild(_centerCardBorder);
         addChild(_centerCard);

         try
         {
            _leftArrow = ResUtils.I.createDisplayObject(ResUtils.swfLib.select, "select_arrow_left");
         }
         catch(e:Error) {}

         if(!_leftArrow)
         {
            var fallbackLeft:Shape = new Shape();
            fallbackLeft.graphics.beginFill(0x2ee4cc);
            fallbackLeft.graphics.moveTo(14, 0);
            fallbackLeft.graphics.lineTo(0, 15);
            fallbackLeft.graphics.lineTo(14, 30);
            fallbackLeft.graphics.lineTo(20, 26);
            fallbackLeft.graphics.lineTo(8, 15);
            fallbackLeft.graphics.lineTo(20, 4);
            fallbackLeft.graphics.endFill();
            _leftArrow = fallbackLeft;
         }
         _leftArrow.x = LEFT_ARROW_X;
         _leftArrow.y = ARROW_Y;
         addChild(_leftArrow);

         _leftHit = new Sprite();
         _leftHit.graphics.beginFill(0, 0);
         _leftHit.graphics.drawRect(-15, -15, 50, 60);
         _leftHit.graphics.endFill();
         _leftHit.x = _leftArrow.x;
         _leftHit.y = _leftArrow.y;
         _leftHit.buttonMode = true;
         addChild(_leftHit);

         try
         {
            _rightArrow = ResUtils.I.createDisplayObject(ResUtils.swfLib.select, "select_arrow_right");
         }
         catch(e:Error) {}

         if(!_rightArrow)
         {
            var fallbackRight:Shape = new Shape();
            fallbackRight.graphics.beginFill(0x2ee4cc);
            fallbackRight.graphics.moveTo(6, 0);
            fallbackRight.graphics.lineTo(20, 15);
            fallbackRight.graphics.lineTo(6, 30);
            fallbackRight.graphics.lineTo(0, 26);
            fallbackRight.graphics.lineTo(12, 15);
            fallbackRight.graphics.lineTo(0, 4);
            fallbackRight.graphics.endFill();
            _rightArrow = fallbackRight;
         }
         _rightArrow.x = RIGHT_ARROW_X;
         _rightArrow.y = ARROW_Y;
         addChild(_rightArrow);

         _rightHit = new Sprite();
         _rightHit.graphics.beginFill(0, 0);
         _rightHit.graphics.drawRect(-15, -15, 50, 60);
         _rightHit.graphics.endFill();
         _rightHit.x = _rightArrow.x;
         _rightHit.y = _rightArrow.y;
         _rightHit.buttonMode = true;
         addChild(_rightHit);

         _stageNameTxt = new BitmapText(true, 0xffffff, [new GlowFilter(0x001122, 1, 4, 4, 4)]);
         UIUtils.formatText(_stageNameTxt.textfield, {
            "color": 0xffffff,
            "size": 20,
            "bold": true,
            "align": "center"
         });
         _stageNameTxt.width = 1280;
         _stageNameTxt.x = 0;
         _stageNameTxt.y = 445;
         addChild(_stageNameTxt);

         showMap(0);

         _bgContainer.scaleY = 0;
         _centerCard.alpha = 0;
         _leftCard.alpha = 0;
         _rightCard.alpha = 0;
         _leftArrow.alpha = 0;
         _rightArrow.alpha = 0;
         _titleTxt.alpha = 0;
         _stageNameTxt.alpha = 0;
      }

      public function destory() : void
      {
         _prevListener = null;
         _nextListener = null;
         _confrimListener = null;

         TweenLite.killTweensOf(_centerCard);
         TweenLite.killTweensOf(_leftCard);
         TweenLite.killTweensOf(_rightCard);
         TweenLite.killTweensOf(_leftArrow);
         TweenLite.killTweensOf(_rightArrow);
         TweenLite.killTweensOf(_titleTxt);
         TweenLite.killTweensOf(_stageNameTxt);
         if(_bgContainer)
         {
            TweenLite.killTweensOf(_bgContainer);
            if(_bgContainer.parent) _bgContainer.parent.removeChild(_bgContainer);
            _bgContainer = null;
         }

         if(_leftHit)
         {
            _leftHit.removeEventListener("touchTap", touchHandler);
            _leftHit.removeEventListener("mouseOver", mouseHandler);
            _leftHit.removeEventListener("click", mouseHandler);
            if(_leftHit.parent) _leftHit.parent.removeChild(_leftHit);
            _leftHit = null;
         }
         if(_rightHit)
         {
            _rightHit.removeEventListener("touchTap", touchHandler);
            _rightHit.removeEventListener("mouseOver", mouseHandler);
            _rightHit.removeEventListener("click", mouseHandler);
            if(_rightHit.parent) _rightHit.parent.removeChild(_rightHit);
            _rightHit = null;
         }
         if(_leftCard)
         {
            _leftCard.removeEventListener("touchTap", touchHandler);
            _leftCard.removeEventListener("mouseOver", mouseHandler);
            _leftCard.removeEventListener("click", mouseHandler);
            if(_leftCard.parent) _leftCard.parent.removeChild(_leftCard);
            _leftCard = null;
         }
         if(_rightCard)
         {
            _rightCard.removeEventListener("touchTap", touchHandler);
            _rightCard.removeEventListener("mouseOver", mouseHandler);
            _rightCard.removeEventListener("click", mouseHandler);
            if(_rightCard.parent) _rightCard.parent.removeChild(_rightCard);
            _rightCard = null;
         }
         if(_centerCard)
         {
            _centerCard.removeEventListener("touchTap", touchHandler);
            _centerCard.removeEventListener("mouseOver", mouseHandler);
            _centerCard.removeEventListener("click", mouseHandler);
            if(_centerCard.parent) _centerCard.parent.removeChild(_centerCard);
            _centerCard = null;
         }
         if(_titleTxt)
         {
            _titleTxt.destory();
            _titleTxt = null;
         }
         if(_stageNameTxt)
         {
            _stageNameTxt.destory();
            _stageNameTxt = null;
         }
         if(_dividerLine && _dividerLine.parent)
         {
            _dividerLine.parent.removeChild(_dividerLine);
            _dividerLine = null;
         }
         if(_blueBackdrop && _blueBackdrop.parent)
         {
            _blueBackdrop.parent.removeChild(_blueBackdrop);
            _blueBackdrop = null;
         }
         if(_leftArrow && _leftArrow.parent)
         {
            _leftArrow.parent.removeChild(_leftArrow);
            _leftArrow = null;
         }
         if(_rightArrow && _rightArrow.parent)
         {
            _rightArrow.parent.removeChild(_rightArrow);
            _rightArrow = null;
         }
         if(_centerCardMask && _centerCardMask.parent)
         {
            _centerCardMask.parent.removeChild(_centerCardMask);
            _centerCardMask = null;
         }
         if(_centerCardBorder && _centerCardBorder.parent)
         {
            _centerCardBorder.parent.removeChild(_centerCardBorder);
            _centerCardBorder = null;
         }
         if(_centerPicContainer)
         {
            _centerPicContainer.removeChildren();
            _centerPicContainer = null;
         }
         if(_leftCardMask && _leftCardMask.parent)
         {
            _leftCardMask.parent.removeChild(_leftCardMask);
            _leftCardMask = null;
         }
         if(_leftCardBorder && _leftCardBorder.parent)
         {
            _leftCardBorder.parent.removeChild(_leftCardBorder);
            _leftCardBorder = null;
         }
         if(_leftPicContainer)
         {
            _leftPicContainer.removeChildren();
            _leftPicContainer = null;
         }
         if(_rightCardMask && _rightCardMask.parent)
         {
            _rightCardMask.parent.removeChild(_rightCardMask);
            _rightCardMask = null;
         }
         if(_rightCardBorder && _rightCardBorder.parent)
         {
            _rightCardBorder.parent.removeChild(_rightCardBorder);
            _rightCardBorder = null;
         }
         if(_rightPicContainer)
         {
            _rightPicContainer.removeChildren();
            _rightPicContainer = null;
         }
         _picCache = null;
         if(this.parent)
         {
            try { this.parent.removeChild(this); } catch(e:Error) {}
         }
      }

      public function select(onSelect:Function) : void
      {
         var selectedMap:MapVO = _maps[_curId];
         if(selectedMap)
         {
            while(selectedMap.id == "random")
            {
               selectedMap = KyoRandom.getRandomInArray(_maps);
            }
            GameData.I.selectMap = selectedMap.id;
            enabled = false;
            if(onSelect != null)
            {
               onSelect();
            }
         }
      }

      public function playOpenAnimation(onComplete:Function = null) : void
      {
         alpha = 1;
         enabled = false;

         resetCardPositions();
         if(_titleTxt)
         {
            _titleTxt.y = 95;
            _titleTxt.alpha = 0;
         }
         if(_stageNameTxt)
         {
            _stageNameTxt.y = 460;
            _stageNameTxt.alpha = 0;
         }
         if(_leftArrow)
         {
            _leftArrow.x = LEFT_ARROW_X - 25;
            _leftArrow.alpha = 0;
         }
         if(_rightArrow)
         {
            _rightArrow.x = RIGHT_ARROW_X + 25;
            _rightArrow.alpha = 0;
         }
         if(_leftCard)
         {
            _leftCard.x = CARD_X;
            _leftCard.alpha = 0;
         }
         if(_rightCard)
         {
            _rightCard.x = CARD_X;
            _rightCard.alpha = 0;
         }
         if(_centerCard)
         {
            _centerCard.filters = [];
            _centerCard.scaleX = 0.15;
            _centerCard.scaleY = 0.15;
            _centerCard.x = 632.5;
            _centerCard.y = 277;
            _centerCard.alpha = 0;
         }

         if(_bgContainer)
         {
            _bgContainer.scaleX = 1;
            _bgContainer.scaleY = 0;
            _bgContainer.alpha = 1;
            TweenLite.to(_bgContainer, 0.24, {
               "scaleY": 1,
               "ease": Quart.easeOut,
               "onComplete": function():void
               {
                  playCardsAppear(onComplete);
               }
            });
         }
         else
         {
            playCardsAppear(onComplete);
         }
      }

      private function playCardsAppear(onComplete:Function = null) : void
      {
         if(_titleTxt)
         {
            TweenLite.to(_titleTxt, 0.28, {
               "y": 110,
               "alpha": 1,
               "delay": 0.04,
               "ease": Quad.easeOut
            });
         }
         if(_stageNameTxt)
         {
            TweenLite.to(_stageNameTxt, 0.28, {
               "y": 445,
               "alpha": 1,
               "delay": 0.08,
               "ease": Quad.easeOut
            });
         }
         if(_leftArrow)
         {
            TweenLite.to(_leftArrow, 0.30, {
               "x": LEFT_ARROW_X,
               "alpha": 1,
               "delay": 0.08,
               "ease": Back.easeOut
            });
         }
         if(_rightArrow)
         {
            TweenLite.to(_rightArrow, 0.30, {
               "x": RIGHT_ARROW_X,
               "alpha": 1,
               "delay": 0.08,
               "ease": Back.easeOut
            });
         }

         if(_centerCard)
         {
            TweenLite.to(_centerCard, 0.35, {
               "scaleX": 1,
               "scaleY": 1,
               "x": CARD_X,
               "y": CARD_Y,
               "alpha": 1,
               "ease": Back.easeOut,
               "onComplete": function():void
               {
                  if(_centerCard)
                  {
                     _centerCard.filters = [new GlowFilter(0x00d8ff, 0.6, 10, 10, 2)];
                  }
                  enabled = true;
                  if(onComplete != null)
                  {
                     onComplete();
                  }
               }
            });
         }
         else
         {
            enabled = true;
            if(onComplete != null)
            {
               onComplete();
            }
         }

         if(_leftCard)
         {
            TweenLite.to(_leftCard, 0.32, {
               "x": LEFT_CARD_X,
               "alpha": 0.45,
               "ease": Quad.easeOut,
               "delay": 0.06
            });
         }

         if(_rightCard)
         {
            TweenLite.to(_rightCard, 0.32, {
               "x": RIGHT_CARD_X,
               "alpha": 0.45,
               "ease": Quad.easeOut,
               "delay": 0.06
            });
         }
      }

      public function prev() : void
      {
         var targetId:int = _curId - 1;
         if(targetId < 0)
         {
            targetId = _maps.length - 1;
         }
         animateSlide(targetId, true);
      }

      public function next() : void
      {
         var targetId:int = _curId + 1;
         if(targetId > _maps.length - 1)
         {
            targetId = 0;
         }
         animateSlide(targetId, false);
      }

      private function animateSlide(targetId:int, isPrev:Boolean) : void
      {
         if(!_maps || _maps.length == 0) return;

         TweenLite.killTweensOf(_centerCard);
         TweenLite.killTweensOf(_leftCard);
         TweenLite.killTweensOf(_rightCard);

         var duration:Number = 0.16;

         if(isPrev)
         {
            if(_leftArrow)
            {
               _leftArrow.x = LEFT_ARROW_X - 6;
               TweenLite.to(_leftArrow, 0.15, {"x": LEFT_ARROW_X, "ease": Quad.easeOut});
            }
            TweenLite.to(_centerCard, duration, {
               "x": RIGHT_CARD_X,
               "y": RIGHT_CARD_Y,
               "alpha": 0.45,
               "ease": Quad.easeOut
            });
            TweenLite.to(_leftCard, duration, {
               "x": CARD_X,
               "y": CARD_Y,
               "alpha": 1,
               "ease": Quad.easeOut
            });
            TweenLite.to(_rightCard, duration * 0.7, {
               "x": RIGHT_CARD_X + 40,
               "alpha": 0,
               "ease": Quad.easeIn
            });
         }
         else
         {
            if(_rightArrow)
            {
               _rightArrow.x = RIGHT_ARROW_X + 6;
               TweenLite.to(_rightArrow, 0.15, {"x": RIGHT_ARROW_X, "ease": Quad.easeOut});
            }
            TweenLite.to(_centerCard, duration, {
               "x": LEFT_CARD_X,
               "y": LEFT_CARD_Y,
               "alpha": 0.45,
               "ease": Quad.easeOut
            });
            TweenLite.to(_rightCard, duration, {
               "x": CARD_X,
               "y": CARD_Y,
               "alpha": 1,
               "ease": Quad.easeOut
            });
            TweenLite.to(_leftCard, duration * 0.7, {
               "x": LEFT_CARD_X - 40,
               "alpha": 0,
               "ease": Quad.easeIn
            });
         }

         TweenLite.delayedCall(duration, function():void
         {
            showMap(targetId);
            resetCardPositions();
         });

         if(_stageNameTxt)
         {
            _stageNameTxt.alpha = 0;
            TweenLite.to(_stageNameTxt, 0.15, {"alpha": 1, "ease": Quad.easeOut});
         }
      }

      private function resetCardPositions() : void
      {
         if(_titleTxt)
         {
            _titleTxt.y = 110;
            _titleTxt.alpha = 1;
         }
         if(_stageNameTxt)
         {
            _stageNameTxt.y = 445;
            _stageNameTxt.alpha = 1;
         }
         if(_leftArrow)
         {
            _leftArrow.x = LEFT_ARROW_X;
            _leftArrow.alpha = 1;
         }
         if(_rightArrow)
         {
            _rightArrow.x = RIGHT_ARROW_X;
            _rightArrow.alpha = 1;
         }
         if(_centerCard)
         {
            _centerCard.x = CARD_X;
            _centerCard.y = CARD_Y;
            _centerCard.scaleX = 1;
            _centerCard.scaleY = 1;
            _centerCard.alpha = 1;
         }
         if(_leftCard)
         {
            _leftCard.x = LEFT_CARD_X;
            _leftCard.y = LEFT_CARD_Y;
            _leftCard.scaleX = 1;
            _leftCard.scaleY = 1;
            _leftCard.alpha = 0.45;
         }
         if(_rightCard)
         {
            _rightCard.x = RIGHT_CARD_X;
            _rightCard.y = RIGHT_CARD_Y;
            _rightCard.scaleX = 1;
            _rightCard.scaleY = 1;
            _rightCard.alpha = 0.45;
         }
      }

      private function showMap(mapIndex:int) : void
      {
         if(!_maps || _maps.length == 0) return;
         if(mapIndex < 0) mapIndex = _maps.length - 1;
         if(mapIndex >= _maps.length) mapIndex = 0;
         _curId = mapIndex;

         var prevId:int = (_curId - 1 < 0) ? _maps.length - 1 : _curId - 1;
         var nextId:int = (_curId + 1 >= _maps.length) ? 0 : _curId + 1;

         fillCard(_centerPicContainer, _maps[_curId], CARD_W, CARD_H);
         fillCard(_leftPicContainer, _maps[prevId], SIDE_CARD_W, SIDE_CARD_H);
         fillCard(_rightPicContainer, _maps[nextId], SIDE_CARD_W, SIDE_CARD_H);

         if(_stageNameTxt)
         {
            var curMap:MapVO = _maps[_curId];
            var mapName:String = curMap ? curMap.name : "";
            _stageNameTxt.text = "Stage " + (_curId + 1) + ": " + mapName;
         }
      }

      private function fillCard(container:Sprite, mapVO:MapVO, cardW:Number, cardH:Number) : void
      {
         if(!container) return;
         container.removeChildren();
         if(!mapVO) return;

         try
         {
            var mapPic:DisplayObject = getPic(mapVO);
            if(!mapPic) return;

            var dispObj:DisplayObject;
            if(mapPic is Bitmap)
            {
               var bmpData:BitmapData = (mapPic as Bitmap).bitmapData;
               if(bmpData)
               {
                  var newBmp:Bitmap = new Bitmap(bmpData);
                  newBmp.smoothing = true;
                  dispObj = newBmp;
               }
               else
               {
                  dispObj = mapPic;
               }
            }
            else
            {
               dispObj = mapPic;
            }

            if(dispObj && dispObj.width > 0 && dispObj.height > 0)
            {
               dispObj.scaleX = 1;
               dispObj.scaleY = 1;
               var scale:Number = cardH / dispObj.height;
               if(scale * dispObj.width < cardW)
               {
                  scale = cardW / dispObj.width;
               }
               dispObj.scaleX = scale;
               dispObj.scaleY = scale;
               dispObj.x = (cardW - dispObj.width) / 2;
               dispObj.y = (cardH - dispObj.height) / 2;
            }
            container.addChild(dispObj);
         }
         catch(err:Error) {}
      }

      private function getPic(mapVO:MapVO) : DisplayObject
      {
         if(!_picCache) _picCache = {};
         var cachedPic:DisplayObject = _picCache[mapVO.id];
         if(cachedPic)
         {
            return cachedPic;
         }
         cachedPic = AssetManager.I.getMapPic(mapVO);
         if(cachedPic)
         {
            _picCache[mapVO.id] = cachedPic;
         }
         return cachedPic;
      }
   }
}
