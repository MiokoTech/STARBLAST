package net.play5d.game.bvn.data
{
   public class SelectVO
   {
      public var fighter1:String;
      
      public var fighter2:String;
      
      public var fighter3:String;
      
      public var fuzhu:String;
      
      public function SelectVO()
      {
         super();
      }
      
      public function getSelectFighters() : Array
      {
         var _loc1_:Array = [];
         if(fighter1)
         {
            _loc1_.push(fighter1);
         }
         if(fighter2)
         {
            _loc1_.push(fighter2);
         }
         if(fighter3)
         {
            _loc1_.push(fighter3);
         }
         return _loc1_;
      }
      
      public function isSelected(param1:String) : Boolean
      {
         return fighter1 == param1 || fighter2 == param1 || fighter3 == param1;
      }
      
      public function toString() : String
      {
         return JSON.stringify({"select":{
            "fighter1":fighter1,
            "fighter2":fighter2,
            "fighter3":fighter3,
            "fuzhu":fuzhu
         }});
      }
   }
}

