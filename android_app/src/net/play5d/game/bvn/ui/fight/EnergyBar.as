package net.play5d.game.bvn.ui.fight
{
   import flash.display.DisplayObject;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class EnergyBar
   {
      private var _ui:*;
      
      private var _fighter:FighterMain;
      
      private var _bar:InsBar;
      
      private var _renderFlash:Boolean;
      
      private var _renderFlashInt:int;
      
      public function EnergyBar(param1:*)
      {
         super();
         _ui = param1;
         _bar = new InsBar(_ui.barmc.bar);
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
      }
      
      public function render() : void
      {
         _bar.rate = _fighter.energy / _fighter.energyMax;
         if(_fighter.energyOverLoad)
         {
            _bar.overLoad();
         }
         else if(_bar.rate < 0.3)
         {
            _bar.flash();
         }
         else
         {
            _bar.normal();
         }
         _bar.render();
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
