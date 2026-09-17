package net.play5d.game.bvn.ui.fight
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.kyo.utils.KyoUtils;

   public class QiBar
   {
      private var _ui:*;
      private var _fighter:FighterMain;
      private var _bar:InsBar;
      private var _qiRate:Number = 0;
      private var _fzRate:Number = 0;
      private var _orgPose:Point;
      private var _tweenSpd:Number = 0.5;
      private var _moveFin:Boolean = true;
      private var _moveType:int = 0;
      private var _isFadIn:Boolean;
      private var _isRenderAnimate:Boolean;
      private var _faceBp:Bitmap;

      public function QiBar(ui:*)
      {
         super();
         _ui = ui;
         _bar = new InsBar(_ui.barmc);
         _orgPose = new Point(_ui.x,_ui.y);
         _ui.addEventListener("complete",uiPlayComplete);
         if(GameUI.BITMAP_UI)
         {
            _ui.gotoAndStop("fadin_fin");
            _ui.visible = false;
         }
      }

      public function destory() : void
      {
         if(_ui)
         {
            _ui.removeEventListener("complete",uiPlayComplete);
            _ui.gotoAndStop("destory");
            _ui = null;
         }
         if(_faceBp)
         {
            _faceBp.bitmapData.dispose();
            _faceBp = null;
         }
         _fighter = null;
      }

      private function uiPlayComplete(param1:Event) : void
      {
         if(_isFadIn)
         {
            _ui.visible = true;
            setCacheBitmap(true);
         }
         else
         {
            _ui.visible = false;
         }
      }

      public function setFighter(fighter:FighterMain, fuzhu:Assister = null) : void
      {
         _fighter = fighter;
      }

      private function setCacheBitmap(param1:Boolean) : void
      {
         if(GameUI.BITMAP_UI)
         {
            return;
         }
         _ui.facemc.cacheAsBitmap = param1;
      }

      public function setDirect(param1:int) : void
      {
         _bar.setDirect(param1);
      }

      public function render() : void
      {
         _qiRate = _fighter.qi / 100;
         var maxQiRate:Number = _fighter.qiMax / 100;
         if(maxQiRate < 1)
         {
            maxQiRate = 1;
         }
         if(_qiRate > maxQiRate)
         {
            _qiRate = maxQiRate;
         }
         var curQiProc:Number = _bar.getProcess();
         var diff:Number = _qiRate - curQiProc;
         if(Math.abs(diff) < 0.01)
         {
            _bar.setProcess(_qiRate);
         }
         else
         {
            _bar.setProcess(curQiProc + diff * 0.4);
         }
      }

      public function renderAnimate() : void
      {
         if(!_isRenderAnimate)
         {
            return;
         }
         var _loc1_:String = _ui.currentFrameLabel;
         if(_loc1_ == "fadin_fin" || _loc1_ == "fadout_fin")
         {
            _isRenderAnimate = false;
            return;
         }
         _ui.nextFrame();
      }

      public function fadIn(param1:Boolean = true) : void
      {
         if(_isFadIn)
         {
            return;
         }
         _isFadIn = true;
         _ui.visible = true;
         if(GameUI.BITMAP_UI)
         {
            return;
         }
         if(param1)
         {
            setCacheBitmap(false);
            _ui.gotoAndStop("fadin");
            _isRenderAnimate = true;
         }
         else
         {
            _ui.gotoAndStop("fadin_fin");
            setCacheBitmap(true);
         }
      }

      public function fadOut(param1:Boolean = true) : void
      {
         if(!_isFadIn)
         {
            return;
         }
         _isFadIn = false;
         if(GameUI.BITMAP_UI)
         {
            _ui.visible = false;
            return;
         }
         if(param1)
         {
            _ui.gotoAndStop("fadout");
            _isRenderAnimate = true;
            setCacheBitmap(false);
         }
         else
         {
            _ui.visible = false;
         }
      }

      public function moveTo(x:Number, y:Number, scale:Number) : void
      {
         if(_moveType == 1)
         {
            if(_moveFin)
            {
               return;
            }
         }
         else
         {
            _moveType = 1;
            _moveFin = false;
         }
         moving(x, y, scale);
      }

      public function moveResume() : void
      {
         if(_moveType == 0)
         {
            if(_moveFin)
            {
               return;
            }
         }
         else
         {
            _moveType = 0;
            _moveFin = false;
         }
         moving(_orgPose.x,_orgPose.y,1);
      }

      private function moving(x:Number, y:Number, scale:Number) : void
      {
         if(Math.abs(x - _ui.x) < 2 && Math.abs(y - _ui.y) < 2 && Math.abs(scale - _ui.scaleX) < 0.2)
         {
            _ui.x = x;
            _ui.y = y;
            _ui.scaleX = _ui.scaleY = scale;
            _moveFin = true;
         }
         _ui.x += (x - _ui.x) * _tweenSpd;
         _ui.y += (y - _ui.y) * _tweenSpd;
         _ui.scaleX += (scale - _ui.scaleX) * _tweenSpd;
         _ui.scaleY = _ui.scaleX;
      }

      public function setPosAndScale(x:Number, y:Number, scale:Number) : void
      {
         _ui.x = x;
         _ui.y = y;
         _ui.scaleX = scale;
         _ui.scaleY = scale;
      }
   }
}

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Rectangle;
import net.play5d.game.bvn.GameConfig;

internal class InsBar
{
   private var _ui:*;
   private var _process:Number = 0;

   public function InsBar(ui:*)
   {
      super();
      _ui = ui;
      setProcess(0);
   }

   public function get ui() : DisplayObject
   {
      return _ui;
   }

   public function getProcess() : Number
   {
      return _process;
   }

   public function setProcess(v:Number) : void
   {
      _process = v;
      var maxProcess:int = GameConfig.BISHA_ENERGY_MAX;
      if(maxProcess < 1)
      {
         maxProcess = 1;
      }
      if(_process > maxProcess)
      {
         _process = maxProcess;
      }

      var fullWidth:Number = 271;
      var perCountWidth:Number = fullWidth / maxProcess;

      var count:int = int(_process);
      var remainder:Number = _process - count;
      var barWidth:Number = (count * perCountWidth) + (remainder * perCountWidth);


      _ui.bar.bar1.visible = true;
      _ui.bar.bar1.scaleX = 1;
      _ui.bar.bar1.scrollRect = new Rectangle(0, 0, barWidth, _ui.bar.bar1.height);

      _ui.bar.bar2.visible = false;
      _ui.bar.bar3.visible = false;
      _ui.bar.bar4.visible = false;

      var frame:int = count + 1;
      if(frame < 1)
      {
         frame = 1;
      }
      if(frame > _ui.txtmc.totalFrames)
      {
         frame = _ui.txtmc.totalFrames;
      }
      _ui.txtmc.gotoAndStop(frame);
   }

   public function setDirect(param1:int) : void
   {
      _ui.txtmc.scaleX = param1 > 0 ? 1 : -1;
   }
}

internal class InsFzBar
{
   private var _ui:*;
   private var _process:Number = 0;
   private var _scroll:Rectangle;
   private var _height:Number;

   public function InsFzBar(ui:*)
   {
      super();
      _ui = ui;
      var bounds:Rectangle = _ui.barmc.getBounds(_ui.barmc);
      _scroll = new Rectangle(0, 0, _ui.barmc.width, _ui.barmc.height);
      _height = _scroll.height;
      _ui.barmc.scaleY = -1;
      _ui.barmc.y = _ui.barmc.height;
   }

   public function get ui() : DisplayObject
   {
      return _ui;
   }

   public function getProcess() : Number
   {
      return _process;
   }

   public function setProcess(param1:Number) : void
   {
      _process = param1;
      _scroll.height = param1 * _height;
      _ui.barmc.scrollRect = _scroll;
   }
}
