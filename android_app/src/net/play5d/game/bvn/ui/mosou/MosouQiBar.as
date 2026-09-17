package net.play5d.game.bvn.ui.mosou
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class MosouQiBar
   {
      private var _ui:Sprite;
      
      private var _fighter:FighterMain;
      
      private var _qiRate:Number = 0;
      
      private var _orgPose:Point;
      
      private var _tweenSpd:Number = 0.5;
      
      private var _moveFin:Boolean = true;
      
      private var _moveType:int = 0;
      
      private var _isFadIn:Boolean;
      
      private var _isRenderAnimate:Boolean;
      
      private var _faceBp:Bitmap;
      
      private var _bar1:DisplayObject;
      
      private var _bar2:DisplayObject;
      
      private var _bar3:DisplayObject;
      
      private var _maxBar:MovieClip;
      
      private var _maxPlaying:Boolean;
      
      private var _process:Number = 0;
      
      public function MosouQiBar(param1:Sprite)
      {
         super();
         _ui = param1;
         _bar1 = _ui.getChildByName("bar1");
         _bar2 = _ui.getChildByName("bar2");
         _bar3 = _ui.getChildByName("bar3");
         _maxBar = _ui.getChildByName("maxmc") as MovieClip;
         _maxBar.gotoAndStop(1);
         _maxBar.visible = false;
      }
      
      public function setFighter(param1:FighterMain) : void
      {
         _fighter = param1;
      }
      
      public function render() : void
      {
         _qiRate = _fighter.qi / 100;
         if(_qiRate > 3)
         {
            _qiRate = 3;
         }
         var _loc2_:Number = _process;
         var _loc1_:Number = _qiRate - _loc2_;
         if(Math.abs(_loc1_) < 0.01)
         {
            _loc2_ = _qiRate;
         }
         else
         {
            _loc2_ += _loc1_ * 0.4;
         }
         if(_loc2_ < 0.0001)
         {
            _loc2_ = 0.0001;
         }
         setProcess(_loc2_);
      }
      
      public function setProcess(param1:Number) : void
      {
         _process = param1;
         _maxBar.visible = param1 >= 3;
         if(_maxBar.visible)
         {
            _bar1.visible = _bar2.visible = _bar3.visible = false;
            if(!_maxPlaying)
            {
               _maxBar.gotoAndPlay(2);
               _maxPlaying = true;
            }
         }
         else
         {
            if(_maxPlaying)
            {
               _maxBar.gotoAndPlay(1);
               _maxPlaying = false;
            }
            _bar1.visible = param1 > 0;
            _bar2.visible = param1 > 1;
            _bar3.visible = param1 > 2;
         }
         if(param1 > 2)
         {
            _bar1.scaleX = _bar2.scaleX = 1;
            _bar3.scaleX = param1 - 2;
         }
         else if(param1 > 1)
         {
            _bar1.scaleX = 1;
            _bar2.scaleX = param1 - 1;
         }
         else
         {
            _bar1.scaleX = param1;
         }
      }
   }
}

