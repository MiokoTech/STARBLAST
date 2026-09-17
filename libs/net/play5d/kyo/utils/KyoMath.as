package net.play5d.kyo.utils
{
   import flash.geom.Point;
   
   public class KyoMath
   {
      private static const DEGTORAD:Number = Math.PI / 180;
      
      public function KyoMath()
      {
         super();
      }
      
      public static function fixRange(param1:Number, param2:Number, param3:Number) : Number
      {
         if(param1 < param2)
         {
            return param2;
         }
         if(param1 > param3)
         {
            return param3;
         }
         return param1;
      }
      
      public static function inRange(param1:Number, param2:Number, param3:Number) : Boolean
      {
         return param1 >= param2 && param1 <= param3;
      }
      
      public static function decimal(param1:Number, param2:int, param3:Function = null) : Number
      {
         param3 ||= Math.round;
         var _loc4_:int = Math.pow(10,param2);
         return param3(param1 * _loc4_) / _loc4_;
      }
      
      public static function average(... rest) : Number
      {
         var _loc2_:Array = rest[0] is Array ? rest[0] : rest;
         var _loc3_:Number = sum(_loc2_);
         return _loc3_ / _loc2_.length;
      }
      
      public static function sum(... rest) : Number
      {
         var _loc4_:Number = NaN;
         var _loc2_:Array = rest[0] is Array ? rest[0] : rest;
         var _loc3_:Number = 0;
         for each(_loc4_ in _loc2_)
         {
            _loc3_ += _loc4_;
         }
         return _loc3_;
      }
      
      public static function getAngleByPoints(param1:Point, param2:Point) : int
      {
         var _loc3_:Number = param2.x - param1.x;
         var _loc4_:Number = param2.y - param1.y;
         var _loc5_:Number = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
         var _loc6_:Number = Math.acos(_loc3_ / _loc5_);
         var _loc7_:Number = 180 / (Math.PI / _loc6_);
         if(_loc4_ < 0)
         {
            return -_loc7_;
         }
         return _loc7_;
      }
      
      public static function getDistanceByPoints(param1:Point, param2:Point) : Number
      {
         var _loc3_:Number = param1.x - param2.x;
         var _loc4_:Number = param1.y - param2.y;
         return Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
      }
      
      public static function getPointByRadians(param1:Point, param2:Number, param3:Number = 1) : Point
      {
         var _loc4_:Point = new Point();
         _loc4_.x = param1.x * Math.cos(param2) - param1.y * Math.sin(param2) * param3;
         _loc4_.y = param1.x * Math.sin(param2) + param1.y * Math.cos(param2) * param3;
         return _loc4_;
      }
      
      public static function asRadians(param1:Number) : Number
      {
         return param1 * DEGTORAD;
      }
      
      public static function velocityFromAngle(param1:int, param2:int, param3:Boolean = true) : Point
      {
         var _loc4_:Number = param3 ? asRadians(param1) : param1;
         var _loc5_:Point = new Point();
         _loc5_.x = int(Math.cos(_loc4_) * param2);
         _loc5_.y = int(Math.sin(_loc4_) * param2);
         return _loc5_;
      }
   }
}

