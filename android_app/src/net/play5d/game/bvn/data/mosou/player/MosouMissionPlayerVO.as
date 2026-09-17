package net.play5d.game.bvn.data.mosou.player
{
   import net.play5d.game.bvn.data.ISaveData;
   
   public class MosouMissionPlayerVO implements ISaveData
   {
      public var id:String;
      
      public var stars:int = 0;
      
      public function MosouMissionPlayerVO()
      {
         super();
      }
      
      public function toSaveObj() : Object
      {
         var _loc1_:Object = {};
         _loc1_.id = id;
         _loc1_.stars = stars;
         return _loc1_;
      }
      
      public function readSaveObj(param1:Object) : void
      {
         id = param1.id;
         stars = param1.stars;
      }
   }
}

