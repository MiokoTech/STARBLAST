package net.play5d.game.bvn.ui.mosou
{
   import flash.display.DisplayObject;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class MosouEnergyBar
   {
      private var _ui:*;
      
      private var _fighter:FighterMain;
      
      private var _bar:InsBar;
      
      private var _txt:InsTxt;
      
      private var _renderFlash:Boolean;
      
      private var _renderFlashInt:int;
      
      public function MosouEnergyBar(param1:*)
      {
         super();
         _ui = param1;
         _bar = new InsBar(_ui.bar);
         _txt = new InsTxt(_ui.energy_txtmc);
      }
      
      public function get ui() : DisplayObject
      {
         return _ui;
      }
      
      public function destory() : void
      {
         _fighter = null;
      }
      
      public function setFighter(param1:FighterMain) : void
      {
         _fighter = param1;
         if(param1.data)
         {
            _txt.setType(param1.data.comicType);
         }
      }
      
      public function render() : void
      {
         _bar.rate = _fighter.energy / _fighter.energyMax;
         if(_fighter.energyOverLoad)
         {
            _bar.overLoad();
            _txt.overLoad();
         }
         else if(_bar.rate < 0.3)
         {
            _bar.flash();
            _txt.flash();
         }
         else
         {
            _bar.normal();
            _txt.normal();
         }
         _bar.render();
         _txt.render();
      }
   }
}

import flash.display.MovieClip;

class InsBar
{
   public var rate:Number = 1;
   
   private var _mc:MovieClip;
   
   private var _curRate:Number = 1;
   
   private var _isOverLoad:Boolean;
   
   private var _isFlash:Boolean;
   
   private var _renderFlashInt:int;
   
   private var _renderFlashFrame:int = 2;
   
   public function InsBar(param1:MovieClip)
   {
      super();
      _mc = param1;
   }
   
   public function render() : void
   {
      var _loc1_:Number = rate - _mc.scaleX;
      if(Math.abs(_loc1_) < 0.01)
      {
         _mc.scaleX = rate;
      }
      else
      {
         _mc.scaleX += _loc1_ * 0.4;
      }
      if(_isFlash)
      {
         renderFlash();
      }
   }
   
   private function renderFlash() : void
   {
      if(++_renderFlashInt > 2)
      {
         _renderFlashInt = 0;
         _mc.gotoAndStop(_renderFlashFrame);
         _renderFlashFrame = _renderFlashFrame == 1 ? 2 : 1;
      }
   }
   
   public function normal() : void
   {
      if(!_isOverLoad && !_isFlash)
      {
         return;
      }
      _isOverLoad = false;
      _isFlash = false;
      _mc.gotoAndStop(1);
   }
   
   public function flash() : void
   {
      if(_isFlash)
      {
         return;
      }
      _isFlash = true;
      _renderFlashInt = 0;
      _renderFlashFrame = 2;
   }
   
   public function overLoad() : void
   {
      if(_isOverLoad)
      {
         return;
      }
      _isOverLoad = true;
      _isFlash = false;
      _mc.gotoAndStop(2);
   }
}

class InsTxt
{
   private var _mc:MovieClip;
   
   private var _isOverLoad:Boolean;
   
   private var _isFlash:Boolean;
   
   private var _renderFlashInt:int;
   
   private var _renderFlashFrame:int;
   
   public function InsTxt(param1:MovieClip)
   {
      super();
      _mc = param1;
   }
   
   public function setDirect(param1:int) : void
   {
      _mc.scaleX = param1 > 0 ? 1 : -1;
   }
   
   public function setType(param1:int) : void
   {
      switch(param1)
      {
         case 0:
            _mc.gotoAndStop(1);
            break;
         case 1:
            _mc.gotoAndStop(2);
      }
   }
   
   public function render() : void
   {
      if(_isFlash)
      {
         renderFlash();
      }
   }
   
   private function renderFlash() : void
   {
      if(!_mc.mc)
      {
         return;
      }
      if(++_renderFlashInt > 2)
      {
         _renderFlashInt = 0;
         _mc.mc.gotoAndStop(_renderFlashFrame);
         _renderFlashFrame = _renderFlashFrame == 1 ? 2 : 1;
      }
   }
   
   public function normal() : void
   {
      if(!_isOverLoad && !_isFlash)
      {
         return;
      }
      _isOverLoad = false;
      _isFlash = false;
      if(_mc.mc)
      {
         _mc.mc.gotoAndStop(1);
      }
   }
   
   public function flash() : void
   {
      if(_isFlash)
      {
         return;
      }
      _isFlash = true;
      _renderFlashInt = 0;
      _renderFlashFrame = 2;
   }
   
   public function overLoad() : void
   {
      if(_isOverLoad)
      {
         return;
      }
      _isOverLoad = true;
      _isFlash = false;
      if(_mc.mc)
      {
         _mc.mc.gotoAndStop(2);
      }
   }
}
