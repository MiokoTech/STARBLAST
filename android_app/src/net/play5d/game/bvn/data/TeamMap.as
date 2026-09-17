package net.play5d.game.bvn.data
{
   public class TeamMap
   {
      public var teams:Vector.<TeamVO> = new Vector.<TeamVO>();
      
      private var _teamObj:Object = {};
      
      public function TeamMap()
      {
         super();
      }
      
      public function clear() : void
      {
         _teamObj = {};
      }
      
      public function getTeam(param1:int) : TeamVO
      {
         return _teamObj[param1];
      }
      
      public function getOtherTeams(param1:int) : Vector.<TeamVO>
      {
         var _loc2_:Vector.<TeamVO> = new Vector.<TeamVO>();
         for each(var _loc3_:TeamVO in _teamObj)
         {
            if(_loc3_.id != param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function add(param1:TeamVO) : void
      {
         _teamObj[param1.id] = param1;
         refreshTeams();
      }
      
      public function remove(param1:TeamVO) : void
      {
         delete _teamObj[param1.id];
         refreshTeams();
      }
      
      private function refreshTeams() : void
      {
         teams = new Vector.<TeamVO>();
         for each(var _loc1_:TeamVO in _teamObj)
         {
            if(_loc1_)
            {
               teams.push(_loc1_);
            }
         }
      }
   }
}

