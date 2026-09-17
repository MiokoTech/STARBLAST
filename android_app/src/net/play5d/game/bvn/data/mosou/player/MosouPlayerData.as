package net.play5d.game.bvn.data.mosou.player
{
   import net.play5d.game.bvn.ctrl.mosou_ctrls.MosouLogic;
   import net.play5d.game.bvn.data.ISaveData;
   import net.play5d.game.bvn.data.mosou.MosouModel;
   import net.play5d.game.bvn.data.mosou.MosouWorldMapVO;
   import net.play5d.game.bvn.data.mosou.MosouWorldMapAreaVO;
   import net.play5d.game.bvn.data.mosou.utils.MosouFighterFactory;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.utils.WrapInteger;
   
   public class MosouPlayerData implements ISaveData
   {
      public var userId:String;
      
      public var userName:String;
      
      private var _money:WrapInteger = new WrapInteger(0);
      
      private var _mapData:Vector.<MosouWorldMapPlayerVO> = new Vector.<MosouWorldMapPlayerVO>();
      
      private var _fighterData:Vector.<MosouFighterVO> = new Vector.<MosouFighterVO>();
      
      private var _fighterTeam:Vector.<MosouFighterVO> = new Vector.<MosouFighterVO>();
      
      private var _lastLogin:WrapInteger = new WrapInteger(0);
      
      private var _currentMapId:String = "map1";
      
      private var _currentAreaId:String = "p1";
      
      public function MosouPlayerData()
      {
         super();
      }
      
      public function init() : void
      {
         initMap();
         _money.setValue(3000);
         _fighterData.push(MosouFighterFactory.create("meirin"));
         _fighterData.push(MosouFighterFactory.create("flandre"));
         _fighterData.push(MosouFighterFactory.create("ibuki"));
         _fighterTeam = _fighterData.concat();
      }
      
      private function initMap() : void
      {
         trace("========== initMap ===================");
         var _loc2_:MosouWorldMapPlayerVO = new MosouWorldMapPlayerVO();
         _loc2_.id = _currentMapId;
         _mapData.push(_loc2_);
         var _loc1_:MosouWorldMapVO = MosouModel.I.getMap(_loc2_.id);
         for each(var m:MosouWorldMapAreaVO in _loc1_.areas)
         {
            if(!m.preOpens || m.preOpens.length < 1)
            {
               MosouLogic.I.openMapArea(_loc2_.id,m.id);
            }
         }
      }
      
      public function getFighterData() : Vector.<MosouFighterVO>
      {
         return _fighterData;
      }
      
      public function addFighter(param1:String) : MosouFighterVO
      {
         var _loc2_:MosouFighterVO = getFighterDataById(param1);
         if(_loc2_)
         {
            return _loc2_;
         }
         _loc2_ = MosouFighterFactory.create(param1);
         _fighterData.push(_loc2_);
         return _loc2_;
      }
      
      public function getFighterTeam() : Vector.<MosouFighterVO>
      {
         return _fighterTeam;
      }
      
      public function getFighterTeamIds() : Array
      {
         var _loc2_:int = 0;
         var _loc1_:Array = [];
         while(_loc2_ < _fighterTeam.length)
         {
            _loc1_.push(_fighterTeam[_loc2_].id);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function setFighterTeam(param1:int, param2:String) : void
      {
         var _loc3_:MosouFighterVO = getFighterDataById(param2);
         if(!_loc3_)
         {
            return;
         }
         _fighterTeam[param1] = _loc3_;
         GameEvent.dispatchEvent("MOSOU_FIGHTER_UPDATE");
      }
      
      public function setLeader(param1:MosouFighterVO) : void
      {
         var _loc3_:int = int(_fighterTeam.indexOf(param1));
         if(_loc3_ == -1)
         {
            return;
         }
         if(_loc3_ == 0)
         {
            return;
         }
         var _loc2_:Vector.<MosouFighterVO> = _fighterTeam.concat();
         switch(_loc3_ - 1)
         {
            case 0:
               _fighterTeam[2] = _loc2_[0];
               _fighterTeam[1] = _loc2_[2];
               _fighterTeam[0] = _loc2_[1];
               break;
            case 1:
               _fighterTeam[2] = _loc2_[1];
               _fighterTeam[1] = _loc2_[0];
               _fighterTeam[0] = _loc2_[2];
         }
         GameEvent.dispatchEvent("MOSOU_FIGHTER_UPDATE");
      }
      
      public function getLeader() : MosouFighterVO
      {
         return _fighterTeam[0];
      }
      
      public function getFighterDataById(id:String) : MosouFighterVO
      {
         for each(var i:MosouFighterVO in _fighterData)
         {
            if(i.id == id)
            {
               return i;
            }
         }
         return null;
      }
      
      public function getCurrentMap() : MosouWorldMapPlayerVO
      {
         return getMapById(_currentMapId);
      }
      
      public function getCurrentArea() : MosouWorldMapAreaPlayerVO
      {
         var _loc1_:MosouWorldMapPlayerVO = getCurrentMap();
         if(!_loc1_)
         {
            return null;
         }
         return _loc1_.getOpenArea(_currentAreaId);
      }
      
      public function setCurrentArea(param1:String) : void
      {
         _currentAreaId = param1;
      }
      
      public function getCurrentMapAreaById(param1:String) : MosouWorldMapAreaPlayerVO
      {
         var _loc2_:MosouWorldMapPlayerVO = getCurrentMap();
         if(!_loc2_)
         {
            return null;
         }
         return _loc2_.getOpenArea(param1);
      }
      
      public function getMapById(id:String) : MosouWorldMapPlayerVO
      {
         for each(var i:MosouWorldMapPlayerVO in _mapData)
         {
            if(i.id == id)
            {
               return i;
            }
         }
         return null;
      }
      
      public function getMoney() : int
      {
         return _money.getValue();
      }
      
      public function addMoney(param1:int) : void
      {
         var _loc2_:int = _money.getValue() + param1;
         _money.setValue(_loc2_);
         GameEvent.dispatchEvent("MONEY_UPDATE");
      }
      
      public function loseMoney(param1:int) : void
      {
         var _loc2_:int = _money.getValue() - param1;
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         _money.setValue(_loc2_);
         GameEvent.dispatchEvent("MONEY_UPDATE");
      }
      
      public function addFighterExp(param1:int) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < _fighterTeam.length)
         {
            if(_loc2_ == 0)
            {
               _fighterTeam[_loc2_].addExp(param1 * 2);
            }
            else
            {
               _fighterTeam[_loc2_].addExp(param1);
            }
            _loc2_++;
         }
      }
      
      public function login(param1:String = null, param2:String = null) : void
      {
         this.userId = param1;
         this.userName = param2;
         var _loc3_:int = int(new Date().getTime());
         _lastLogin.setValue(_loc3_);
      }
      
      public function toSaveObj() : Object
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:Object = {};
         _loc3_.userId = userId;
         _loc3_.userName = userName;
         _loc3_.money = _money.getValue();
         _loc3_.lastLogin = _lastLogin.getValue();
         _loc3_.mapData = [];
         _loc2_ = 0;
         while(_loc2_ < _mapData.length)
         {
            _loc1_ = _mapData[_loc2_].toSaveObj();
            _loc3_.mapData.push(_loc1_);
            _loc2_++;
         }
         _loc3_.fighterData = [];
         _loc2_ = 0;
         while(_loc2_ < _fighterData.length)
         {
            _loc1_ = _fighterData[_loc2_].toSaveObj();
            _loc3_.fighterData.push(_loc1_);
            _loc2_++;
         }
         _loc3_.currentMapId = _currentMapId;
         _loc3_.currentAreaId = _currentAreaId;
         _loc3_.fighterTeam = [];
         _loc2_ = 0;
         while(_loc2_ < _fighterTeam.length)
         {
            _loc3_.fighterTeam.push(_fighterTeam[_loc2_].id);
            _loc2_++;
         }
         return _loc3_;
      }
      
      public function readSaveObj(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:MosouWorldMapPlayerVO = null;
         var _loc2_:MosouFighterVO = null;
         var _loc6_:String = null;
         userId = param1.userId;
         userName = param1.userName;
         if(param1.money)
         {
            _money.setValue(param1.money);
         }
         if(param1.lastLogin)
         {
            _lastLogin.setValue(param1.lastLogin);
         }
         if(param1.mapData)
         {
            _mapData = new Vector.<MosouWorldMapPlayerVO>();
            _loc4_ = 0;
            while(_loc4_ < param1.mapData.length)
            {
               _loc3_ = param1.mapData[_loc4_];
               _loc5_ = new MosouWorldMapPlayerVO();
               _loc5_.readSaveObj(_loc3_);
               _mapData.push(_loc5_);
               _loc4_++;
            }
         }
         if(param1.fighterData)
         {
            _fighterData = new Vector.<MosouFighterVO>();
            _loc4_ = 0;
            while(_loc4_ < param1.fighterData.length)
            {
               _loc3_ = param1.fighterData[_loc4_];
               _loc2_ = new MosouFighterVO();
               _loc2_.readSaveObj(_loc3_);
               _fighterData.push(_loc2_);
               _loc4_++;
            }
         }
         if(param1.currentMapId)
         {
            _currentMapId = param1.currentMapId;
         }
         if(param1.currentAreaId)
         {
            _currentAreaId = param1.currentAreaId;
         }
         if(param1.fighterTeam)
         {
            _fighterTeam = new Vector.<MosouFighterVO>();
            _loc4_ = 0;
            while(_loc4_ < param1.fighterTeam.length)
            {
               _loc6_ = param1.fighterTeam[_loc4_];
               _loc2_ = getFighterDataById(_loc6_);
               if(_loc2_)
               {
                  _fighterTeam.push(_loc2_);
               }
               _loc4_++;
            }
         }
      }
   }
}

