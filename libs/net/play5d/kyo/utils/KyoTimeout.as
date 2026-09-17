package net.play5d.kyo.utils
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class KyoTimeout
   {
      public static var _root:DisplayObject;
      
      private static var _functions:Vector.<Object>;
      
      public function KyoTimeout()
      {
         super();
      }
      
      public static function init(param1:Sprite) : void
      {
         _root = param1;
         _functions = new Vector.<Object>();
      }
      
      public static function setFrameout(param1:Function, param2:int, ... rest) : void
      {
         _functions.push({
            "func":param1,
            "frame":param2,
            "param":rest
         });
         setLisnter();
      }
      
      public static function setTimeout(param1:Function, param2:int, ... rest) : void
      {
         var _loc4_:int = Math.ceil(param2 / 1000 * _root.stage.frameRate);
         var _loc5_:Array = [param1,_loc4_].concat(rest);
         setFrameout.apply(null,_loc5_);
      }
      
      private static function setLisnter() : void
      {
         _root.removeEventListener(Event.ENTER_FRAME,onEnterframe);
         _root.addEventListener(Event.ENTER_FRAME,onEnterframe);
      }
      
      private static function onEnterframe(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Function = null;
         var _loc6_:Array = null;
         var _loc3_:int = int(_functions.length);
         if(_loc3_ < 1)
         {
            _root.removeEventListener(Event.ENTER_FRAME,onEnterframe);
            return;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _functions[_loc2_];
            if(!_loc4_)
            {
               _functions.splice(_loc2_,1);
               _loc2_ = 0;
               _loc3_ = int(_functions.length);
            }
            else
            {
               _loc5_ = _loc4_.func;
               _loc6_ = _loc4_.param;
               if(_loc4_.frame-- <= 0)
               {
                  if(Boolean(_loc6_) && _loc6_.length > 0)
                  {
                     _loc5_.apply(null,_loc6_);
                  }
                  else
                  {
                     _loc5_();
                  }
                  _functions[_loc2_] = null;
               }
            }
            _loc2_++;
         }
      }
   }
}

