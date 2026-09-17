package net.play5d.game.bvn.fighter.utils
{
   import flash.display.DisplayObject;
   import flash.geom.Rectangle;
   
   public class McAreaCacher
   {
      
      private var _idCache:Object = {};
      
      private var _frameCache:Object = {};
      
      public var name:String;
      
      public function McAreaCacher(param1:String)
      {
         super();
         this.name = param1;
      }
      
      public function destory() : void
      {
         _idCache = null;
         _frameCache = null;
      }
      
      public function areaFrameDefined(param1:int) : Boolean
      {
         return _frameCache[param1] !== undefined;
      }
      
      public function getAreaByFrame(param1:int) : Object
      {
         return _frameCache[param1];
      }
      
      public function cacheAreaByFrame(param1:int, param2:Object) : void
      {
         _frameCache[param1] = param2;
      }
      
      public function getAreaByDisplay(param1:DisplayObject) : Object
      {
         var _loc2_:String = getDisplayCacheId(param1);
         if(_idCache[_loc2_])
         {
            return _idCache[_loc2_];
         }
         return null;
      }
      
      public function cacheAreaByDisplay(param1:DisplayObject, param2:Rectangle, param3:Object = null) : Object
      {
         var _loc7_:String = getDisplayCacheId(param1);
         var _loc4_:String = param1.name;
         var _loc6_:Object = {};
         _loc6_.name = _loc4_;
         _loc6_.area = param2;
         if(param3)
         {
            for(var _loc5_:String in param3)
            {
               _loc6_[_loc5_] = param3[_loc5_];
            }
         }
         _idCache[_loc7_] = _loc6_;
         return _loc6_;
      }
      
      private function getDisplayCacheId(param1:DisplayObject) : String
      {
         return param1.name + "_" + param1.x + "," + param1.y + "," + param1.width + "," + param1.height + "," + param1.rotation;
      }
   }
}

