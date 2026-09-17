package net.play5d.game.bvn.data
{
   import flash.geom.Point;
   
   public class SelectCharListItemVO
   {
      public var x:int;
      
      public var y:int;
      
      public var fighterID:String;
      
      public var offset:Point;
      
      public var moreFighterIDs:Array;
      
      public function SelectCharListItemVO(param1:int, param2:int, param3:String, param4:Point = null)
      {
         super();
         this.x = param1;
         this.y = param2;
         this.fighterID = param3;
         this.offset = param4;
      }
      
      public function getAllFighterIDs() : Array
      {
         var _loc1_:Array = [];
         if(fighterID)
         {
            _loc1_.push(fighterID);
         }
         if(moreFighterIDs && moreFighterIDs.length > 0)
         {
            _loc1_ = _loc1_.concat(moreFighterIDs);
         }
         return _loc1_;
      }
   }
}

