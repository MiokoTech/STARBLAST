package net.play5d.game.bvn.ui.dialog.select
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import net.play5d.game.bvn.GameConfig;
   
   public class DotsGroupUI extends Sprite
   {
      private var _dotArr:Array;
      
      public var onDotClick:Function;
      
      public function DotsGroupUI()
      {
         super();
      }
      
      public function update(param1:int) : void
      {
         var _loc3_:int = 0;
         var _loc2_:DotItemUI = null;
         _dotArr = [];
         while(_loc3_ < param1)
         {
            _loc2_ = new DotItemUI();
            _loc2_.page = _loc3_ + 1;
            addChild(_loc2_.getUI());
            _dotArr.push(_loc2_);
            _loc2_.getUI().x = _loc3_ * 40;
            if(GameConfig.TOUCH_MODE)
            {
               _loc2_.getUI().addEventListener("touchTap",touchHandler);
            }
            else
            {
               _loc2_.getUI().addEventListener("click",mouseHandler);
            }
            if(_loc3_ == 0)
            {
               _loc2_.focus(true);
            }
            _loc3_++;
         }
      }
      
      public function updateByPage(param1:int) : void
      {
         for each(var d:DotItemUI in _dotArr)
         {
            d.focus(d.page == param1);
         }
      }
      
      public function destory() : void
      {
         for each(var d:DotItemUI in _dotArr)
         {
            d.getUI().removeEventListener("touchTap",touchHandler);
            d.getUI().removeEventListener("click",mouseHandler);
         }
      }
      
      private function mouseHandler(param1:MouseEvent) : void
      {
         doClick(param1.currentTarget);
      }
      
      private function touchHandler(param1:TouchEvent) : void
      {
         doClick(param1.currentTarget);
      }
      
      private function doClick(param1:Object) : void
      {
         if(onDotClick == null)
         {
            return;
         }
         var _loc3_:DisplayObject = param1 as DisplayObject;
         for each(var d:DotItemUI in _dotArr)
         {
            if(d.getUI() == _loc3_)
            {
               onDotClick(d.page);
            }
         }
      }
   }
}

