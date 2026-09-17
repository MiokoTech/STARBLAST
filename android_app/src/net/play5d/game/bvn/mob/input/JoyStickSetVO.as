package net.play5d.game.bvn.mob.input
{
   public class JoyStickSetVO
   {
      public var id:int;
      
      public var value:Number = 0;
      
      public function JoyStickSetVO(param1:int, param2:Number = 1)
      {
         super();
         this.id = param1;
         this.value = param2;
      }
      
      public function readObj(param1:Object) : void
      {
         this.id = param1.id;
         this.value = param1.value;
      }
      
      public function toObj() : Object
      {
         var _loc1_:Object = {};
         _loc1_.id = this.id;
         _loc1_.value = this.value;
         return _loc1_;
      }
   }
}

