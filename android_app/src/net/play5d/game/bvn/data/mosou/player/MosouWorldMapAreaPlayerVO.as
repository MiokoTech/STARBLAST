package net.play5d.game.bvn.data.mosou.player
{
   import net.play5d.game.bvn.data.ISaveData;
   
   public class MosouWorldMapAreaPlayerVO implements ISaveData
   {
      public var id:String;
      
      public var name:String;
      
      private var _passedMissions:Vector.<MosouMissionPlayerVO> = new Vector.<MosouMissionPlayerVO>();
      
      public function MosouWorldMapAreaPlayerVO()
      {
         super();
      }
      
      public function passMission(param1:String, param2:int = 1) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc4_:MosouMissionPlayerVO = getPassedMission(param1);
         if(!_loc4_)
         {
            _loc3_ = true;
            _loc4_ = new MosouMissionPlayerVO();
            _loc4_.id = param1;
            _passedMissions.push(_loc4_);
         }
         _loc4_.stars = param2;
         return _loc3_;
      }
      
      public function getPassedMission(param1:String) : MosouMissionPlayerVO
      {
         var _loc2_:int = 0;
         while(_loc2_ < _passedMissions.length)
         {
            if(_passedMissions[_loc2_].id == param1)
            {
               return _passedMissions[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      public function getLastPassedMission() : MosouMissionPlayerVO
      {
         if(_passedMissions.length < 1)
         {
            return null;
         }
         return _passedMissions[_passedMissions.length - 1];
      }
      
      public function getPassedMissionAmount() : int
      {
         return _passedMissions.length;
      }
      
      public function toSaveObj() : Object
      {
         var _loc1_:int = 0;
         var _loc2_:Object = {};
         _loc2_.id = id;
         _loc2_.name = name;
         _loc2_.missions = [];
         while(_loc1_ < _passedMissions.length)
         {
            _loc2_.missions.push(_passedMissions[_loc1_].toSaveObj());
            _loc1_++;
         }
         return _loc2_;
      }
      
      public function readSaveObj(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MosouMissionPlayerVO = null;
         id = param1.id;
         name = param1.name;
         _passedMissions = new Vector.<MosouMissionPlayerVO>();
         if(param1.missions)
         {
            while(_loc2_ < param1.missions.length)
            {
               _loc3_ = new MosouMissionPlayerVO();
               _loc3_.readSaveObj(param1.missions[_loc2_]);
               _passedMissions.push(_loc3_);
               _loc2_++;
            }
         }
      }
   }
}

