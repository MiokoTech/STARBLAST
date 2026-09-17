package net.play5d.game.bvn.views.effects
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.filters.BitmapFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.data.TeamVO;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.kyo.utils.KyoUtils;
   
   public class BitmapFilterView implements IGameSprite
   {
      private var _bitmap:Bitmap;
      
      public var target:BaseGameSprite;
      
      private var _filter:BitmapFilter;
      
      private var _filterOffset:Point;
      
      private var _isDestoryed:Boolean;
      
      private var _bitmapFrame:int;
      
      private var _targetDisplay:DisplayObject;
      
      private var _targetBounds:Rectangle;
      
      private var _targetFighter:FighterMain;
      
      private var _isActive:Boolean;
      
      public function BitmapFilterView(param1:BaseGameSprite, param2:BitmapFilter, param3:Point = null)
      {
         super();
         _bitmap = new Bitmap(null,"auto",false);
         this.target = param1;
         if(param1 is FighterMain)
         {
            _targetFighter = param1 as FighterMain;
         }
         _targetDisplay = param1.getDisplay();
         _filter = param2;
         _filterOffset = param3;
      }
      
      public function get colorTransform() : ColorTransform
      {
         return null;
      }
      
      public function set colorTransform(param1:ColorTransform) : void
      {
      }
      
      public function getActive() : Boolean
      {
         return _isActive;
      }
      
      public function setActive(param1:Boolean) : void
      {
         _isActive = param1;
      }
      
      public function setVolume(param1:Number) : void
      {
      }
      
      public function update(param1:BitmapFilter, param2:Point = null) : void
      {
         _filter = param1;
         _filterOffset = param2;
      }
      
      public function renderAnimate() : void
      {
      }
      
      public function render() : void
      {
         if(!target || !_targetDisplay)
         {
            return;
         }
         if(_isDestoryed)
         {
            return;
         }
         renderBitmapData();
         _bitmap.scaleX = _targetDisplay.scaleX;
         _bitmap.scaleY = _targetDisplay.scaleY;
         if(target.direct > 0)
         {
            _bitmap.x = _targetDisplay.x - _filterOffset.x + _targetBounds.x;
         }
         else
         {
            _bitmap.x = _targetDisplay.x + _filterOffset.x - _targetBounds.x;
         }
         _bitmap.y = _targetDisplay.y - _filterOffset.y + _targetBounds.y;
      }
      
      private function renderBitmapData() : void
      {
         var _loc1_:int = 0;
         if(_targetFighter)
         {
            _loc1_ = _targetFighter.getMC().getCurrentFrameCount();
            if(_loc1_ == _bitmapFrame)
            {
               return;
            }
            _bitmapFrame = _loc1_;
         }
         if(_bitmap.bitmapData)
         {
            _bitmap.bitmapData.dispose();
            _bitmap.bitmapData = null;
         }
         _bitmap.bitmapData = KyoUtils.drawBitmapFilter(_targetDisplay,_filter,true,_filterOffset);
         _targetBounds = _targetDisplay.getBounds(_targetDisplay);
      }
      
      public function isDestoryed() : Boolean
      {
         return _isDestoryed;
      }
      
      public function getDisplay() : DisplayObject
      {
         return _bitmap;
      }
      
      public function get direct() : int
      {
         return target.direct;
      }
      
      public function set direct(param1:int) : void
      {
      }
      
      public function get x() : Number
      {
         return _bitmap.x;
      }
      
      public function set x(param1:Number) : void
      {
         _bitmap.x = param1;
      }
      
      public function get y() : Number
      {
         return _bitmap.y;
      }
      
      public function set y(param1:Number) : void
      {
         _bitmap.y = param1;
      }
      
      public function get team() : TeamVO
      {
         return null;
      }
      
      public function set team(param1:TeamVO) : void
      {
      }
      
      public function hit(param1:HitVO, param2:IGameSprite) : void
      {
      }
      
      public function beHit(param1:HitVO, param2:Rectangle = null) : void
      {
      }
      
      public function getArea() : Rectangle
      {
         return null;
      }
      
      public function getBodyArea() : Rectangle
      {
         return null;
      }
      
      public function getCurrentHits() : Array
      {
         return null;
      }
      
      public function allowCrossMapXY() : Boolean
      {
         return true;
      }
      
      public function allowCrossMapBottom() : Boolean
      {
         return true;
      }
      
      public function getIsTouchSide() : Boolean
      {
         return false;
      }
      
      public function setIsTouchSide(param1:Boolean) : void
      {
      }
      
      public function setSpeedRate(param1:Number) : void
      {
      }
      
      public function destory(param1:Boolean = true) : void
      {
         if(param1)
         {
            if(_bitmap.bitmapData)
            {
               _bitmap.bitmapData.dispose();
               _bitmap.bitmapData = null;
            }
            _isDestoryed = true;
            this.target = null;
            _filter = null;
            _filterOffset = null;
            _targetFighter = null;
            _targetBounds = null;
            _targetDisplay = null;
         }
      }
   }
}

