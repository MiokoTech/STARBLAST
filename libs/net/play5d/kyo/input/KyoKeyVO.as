package net.play5d.kyo.input
{
   public class KyoKeyVO
   {
      public var name:String;
      
      public var code:int;
      
      public var isDown:Boolean;
      
      public function KyoKeyVO(param1:String, param2:int)
      {
         super();
         this.name = param1;
         this.code = param2;
      }
      
      public function toString() : String
      {
         return this.name;
      }
      
      public function clone() : KyoKeyVO
      {
         return new KyoKeyVO(this.name,this.code);
      }
   }
}

