package net.play5d.game.bvn.data.mosou
{
   public class MosouWorldMapAreaVO
   {
      public var id:String;
      
      public var name:String;
      
      public var missions:Vector.<MosouMissionVO>;
      
      public var preOpens:Vector.<MosouWorldMapAreaVO>;
      
      public function MosouWorldMapAreaVO()
      {
         super();
      }
      
      public function building() : Boolean
      {
         return !missions || missions.length < 1;
      }
      
      public function getMission(param1:String) : MosouMissionVO
      {
         var _loc2_:int = 0;
         while(_loc2_ < missions.length)
         {
            if(missions[_loc2_].id == param1)
            {
               return missions[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      public function getNextMission(param1:String) : MosouMissionVO
      {
         var _loc3_:MosouMissionVO = getMission(param1);
         if(!_loc3_)
         {
            return null;
         }
         var _loc2_:int = int(missions.indexOf(_loc3_));
         if(_loc2_ == -1)
         {
            return null;
         }
         if(_loc2_ + 1 > missions.length - 1)
         {
            return null;
         }
         return missions[_loc2_ + 1];
      }
   }
}

