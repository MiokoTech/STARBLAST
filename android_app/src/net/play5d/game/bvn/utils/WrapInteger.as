package net.play5d.game.bvn.utils
{
   public class WrapInteger
   {
      private static var _rndArr:Array = [1,2,3,4,5,6,7,8,9];
      
      private var _w:int;
      
      private var _offset:int;
      
      public function WrapInteger(param1:int)
      {
         super();
         _offset = Math.floor(Math.random() * _rndArr.length);
         _w = param1 ^ _rndArr[_offset];
      }
      
      public function setValue(param1:int) : void
      {
         _offset = Math.floor(Math.random() * _rndArr.length);
         _w = param1 ^ _rndArr[_offset];
      }
      
      public function getValue() : int
      {
         return _w ^ _rndArr[_offset];
      }
      
      public function toString() : String
      {
         var _loc1_:* = _w ^ _rndArr[_offset];
         return _loc1_.toString();
      }
   }
}

