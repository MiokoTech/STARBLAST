package net.play5d.kyo.utils
{
   public class ArrayMap
   {
      private var _o:Object;
      
      private var _arr:Array;
      
      public function ArrayMap()
      {
         super();
         this._o = {};
         this._arr = [];
      }
      
      public function get length() : int
      {
         return this._arr.length;
      }
      
      public function push(param1:Object, param2:*) : void
      {
         this._o[param1] = param2;
         this._arr.push(param2);
      }
      
      public function getItemByIndex(param1:int) : *
      {
         return this._arr[param1];
      }
      
      public function getItemById(param1:Object) : *
      {
         return this._o[param1];
      }
      
      public function removeItemById(param1:Object) : void
      {
         if(!this._o[param1])
         {
            return;
         }
         var _loc2_:int = int(this._arr.indexOf(this._o[param1]));
         if(_loc2_ != -1)
         {
            this._arr.splice(_loc2_,1);
         }
         delete this._o[param1];
      }
   }
}

