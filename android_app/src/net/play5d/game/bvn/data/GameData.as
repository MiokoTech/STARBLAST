package net.play5d.game.bvn.data
{
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.mosou.MosouFighterModel;
   import net.play5d.game.bvn.data.mosou.MosouFighterSellVO;
   import net.play5d.game.bvn.data.mosou.MosouMissionVO;;
   import net.play5d.game.bvn.data.mosou.MosouModel;
   import net.play5d.game.bvn.data.mosou.MosouWorldMapVO;
   import net.play5d.game.bvn.data.mosou.MosouWorldMapAreaVO;
   import net.play5d.game.bvn.data.mosou.player.MosouPlayerData;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.kyo.loader.KyoURLoader;

   public class GameData
   {
      private static var _i:GameData;
      public var config:ConfigVO = new ConfigVO();
      public var mosouData:MosouPlayerData = new MosouPlayerData();

      public var p1Select:SelectVO;
      public var p2Select:SelectVO;
      public var selectMap:String;
      public var score:int = 0;
      public var winnerId:String;
      public var isFristRun:Boolean = true;
      
      private var _externalSelectFighterIDs:Array = [];

      private const SAVE_ID:String = "BVN_STARBLAST";
      private const __MOSOU_DATA_ENABLED:Boolean = true;

      public function GameData()
      {
         super();
      }

      public static function get I() : GameData
      {
         if(!_i)
         {
            _i = new GameData();
         }
         return _i;
      }
      public function loadConfig(param1:Function, param2:Function = null) : void
      {
         var back:Function = param1;
         var fail:Function = param2;
         var loadFighterBack:* = function(param1:XML):void
         {
            FighterModel.I.initByXML(param1);
            loadExternalCharacterConfig();
            AssetManager.I.loadXML("data/assist.xml",loadAssetsBack,loadAssisterFail);
         };
         var loadAssetsBack:* = function(param1:XML):void
         {
            AssisterModel.I.initByXML(param1);
            AssetManager.I.loadXML("data/select.xml",loadSelectBack,loadSelectFail);
         };
         var loadSelectBack:* = function(param1:XML):void
         {
            setSelectData(param1);
            AssetManager.I.loadXML("data/map.xml",loadMapBack,loadMapFail);
         };
         var loadMapBack:* = function(param1:XML):void
         {
            MapModel.I.initByXML(param1);
            AssetManager.I.loadXML("data/mission.xml",loadMissionBack,loadMissionFail);
         };
         var loadMissionBack:* = function(param1:String):void
         {
            MessionModel.I.initByXML(new XML(param1));
            MosouModel.I.loadMapData(loadMosouDataBack,loadMosouFail);
         };
         var loadMosouDataBack:* = function():void
         {
            MosouFighterModel.I.init();
            validateSelect();
            validateMissionData();
            validateMosouData();
            if(back != null)
            {
               back();
            }
         };
         var loadFighterFail:* = function():void
         {
            Debugger.log("读取人物数据出错");
            if(fail != null)
            {
               fail("读取人物数据出错");
            }
         };
         var loadAssisterFail:* = function():void
         {
            Debugger.log("读取辅助角色数据出错");
            if(fail != null)
            {
               fail("读取辅助角色数据出错");
            }
         };
         var loadSelectFail:* = function():void
         {
            Debugger.log("读取选人场景数据出错");
            if(fail != null)
            {
               fail("读取选人场景数据出错");
            }
         };
         var loadMapFail:* = function():void
         {
            Debugger.log("读取地图场景数据出错");
            if(fail != null)
            {
               fail("读取地图场景数据出错");
            }
         };
         var loadMissionFail:* = function():void
         {
            Debugger.log("读取关卡数据出错");
            if(fail != null)
            {
               fail("读取关卡数据出错");
            }
         };
         var loadMosouFail:* = function():void
         {
            Debugger.log("读取无双数据出错");
            if(fail != null)
            {
               fail("读取无双数据出错");
            }
         };
         AssetManager.I.loadXML("data/fighter.xml",loadFighterBack,loadFighterFail);
      }
      
      public function initData() : void
      {
         GameData.I.loadOptionsData();
      }
      
      public function saveData() : void
      {
         var _loc1_:Object = {};
         _loc1_.id = "BVN_STARBLAST";
         _loc1_.config = config.toSaveObj();
         _loc1_.mosou = mosouData.toSaveObj();
         GameInterface.instance.saveGame(_loc1_);
      }
      
      public function saveOptionsData() : void
      {
         var _loc1_:Object = {};
         _loc1_.config = config.toSaveObj();
         GameInterface.instance.saveOptions(_loc1_);
      }
      
      public function loadSaveData() : void
      {
         var _loc1_:Object = GameInterface.instance.loadGame();
         if(_loc1_.mosou)
         {
            mosouData.init();
            mosouData.readSaveObj(_loc1_.mosou);
         }
      }
      
      public function loadOptionsData() : void
      {
         var _loc1_:Object = GameInterface.instance.loadOptions();
         if(_loc1_ == null)
         {
            return;
         }
         config.readSaveObj(_loc1_.config);
      }
      
      public function loadSelect(param1:String) : void
      {
         var url:String = param1;
         AssetManager.I.loadXML(url,function(param1:XML):void
         {
            setSelectData(param1);
         },function():void
         {
            trace("loadSelect error!");
         });
      }
      
      public function loadDebugSelect(param1:String) : void
      {
         var url:String = param1;
         KyoURLoader.load(url,function(param1:String):void
         {
            var _loc2_:XML = new XML(param1);
            setSelectData(_loc2_);
         },function():void
         {
            trace("loadSelect error!");
         });
      }
      
      public function setSelectData(param1:XML) : void
      {
         loadExternalCharacterConfig();
         config.select_config.setByXML(param1);
         applyExternalFightersToSelectConfig();
      }
      
      private function loadExternalCharacterConfig() : void
      {
         _externalSelectFighterIDs = [];
         
         // 2. Load standard STARBLAST external characters
         var externalConfigResult:ExternalCharacterConfigResult = null;
         try
         {
            externalConfigResult = ExternalCharacterConfigLoader.loadFromInternalStorage();
         }
         catch(e:Error)
         {
            trace("GameData.loadExternalCharacterConfig",e);
            return;
         }
         if(!externalConfigResult)
         {
            return;
         }
         for each(var externalFighterData:FighterVO in externalConfigResult.fighterList)
         {
            FighterModel.I.addOrReplaceFighter(externalFighterData);
         }
         _externalSelectFighterIDs = _externalSelectFighterIDs.concat(externalConfigResult.selectFighterIDs);
      }
      
      private function applyExternalFightersToSelectConfig() : void
      {
         var selectConfig:SelectCharListConfigVO = config.select_config.charList;
         if(!selectConfig || !selectConfig.list || !_externalSelectFighterIDs || _externalSelectFighterIDs.length < 1)
         {
            return;
         }
         var existingFighterMap:Object = {};
         var selectItem:SelectCharListItemVO = null;
         for each(selectItem in selectConfig.list)
         {
            if(selectItem.fighterID)
            {
               existingFighterMap[selectItem.fighterID] = true;
            }
            if(selectItem.moreFighterIDs && selectItem.moreFighterIDs.length > 0)
            {
               for each(var moreFighterID:String in selectItem.moreFighterIDs)
               {
                  existingFighterMap[moreFighterID] = true;
               }
            }
         }
         var pendingFighterIDs:Array = [];
         for each(var externalFighterID:String in _externalSelectFighterIDs)
         {
            if(!externalFighterID || existingFighterMap[externalFighterID])
            {
               continue;
            }
            if(FighterModel.I.getFighter(externalFighterID) == null)
            {
               continue;
            }
            pendingFighterIDs.push(externalFighterID);
            existingFighterMap[externalFighterID] = true;
         }
         if(pendingFighterIDs.length < 1)
         {
            return;
         }
         for each(selectItem in selectConfig.list)
         {
            if(pendingFighterIDs.length < 1)
            {
               break;
            }
            if(!selectItem.fighterID || selectItem.fighterID.length < 1)
            {
               selectItem.fighterID = pendingFighterIDs.shift();
            }
         }
         if(pendingFighterIDs.length < 1)
         {
            return;
         }
         var gridColumnCount:int = selectConfig.HCount > 0 ? selectConfig.HCount : resolveSelectGridColumnCount(selectConfig.list);
         if(gridColumnCount < 1)
         {
            gridColumnCount = 1;
         }
         var gridRowCount:int = selectConfig.VCount > 0 ? selectConfig.VCount : resolveSelectGridRowCount(selectConfig.list);
         if(gridRowCount < 1)
         {
            gridRowCount = 1;
         }
         var pendingCount:int = pendingFighterIDs.length;
         var pendingIndex:int = 0;
         while(pendingIndex < pendingCount)
         {
            var slotX:int = pendingIndex % gridColumnCount;
            var slotY:int = gridRowCount + int(pendingIndex / gridColumnCount);
            selectConfig.list.push(new SelectCharListItemVO(slotX,slotY,pendingFighterIDs[pendingIndex]));
            pendingIndex++;
         }
         var appendedRowCount:int = int((pendingCount - 1) / gridColumnCount) + 1;
         selectConfig.VCount = gridRowCount + appendedRowCount;
      }
      
      private function resolveSelectGridColumnCount(selectItemList:Array) : int
      {
         var maxX:int = -1;
         for each(var selectItem:SelectCharListItemVO in selectItemList)
         {
            if(selectItem && selectItem.x > maxX)
            {
               maxX = selectItem.x;
            }
         }
         return maxX + 1;
      }
      
      private function resolveSelectGridRowCount(selectItemList:Array) : int
      {
         var maxY:int = -1;
         for each(var selectItem:SelectCharListItemVO in selectItemList)
         {
            if(selectItem && selectItem.y > maxY)
            {
               maxY = selectItem.y;
            }
         }
         return maxY + 1;
      }
      
      private function validateSelect() : void
      {
         var missFighters:Array  = [];
        var missAssisters:Array = [];

        var s:SelectCharListItemVO;
        var f:String;
        var fighter:FighterVO;
        for each(s in config.select_config.charList.list) {
           for each(f in s.getAllFighterIDs()) {
              fighter = FighterModel.I.getFighter(f);
              if (fighter == null) {
                 if (missFighters.indexOf(f) == -1) {
                    missFighters.push(f);
                 }
              }
           }
        }
        for each(s in config.select_config.assistList.list) {
           for each(f in s.getAllFighterIDs()) {
                fighter = AssisterModel.I.getAssister(f);
                if (fighter == null) {
                    if (missAssisters.indexOf(f) == -1) {
                        missAssisters.push(f);
                    }
                }
            }
        }

        if (missFighters.length > 0 || missAssisters.length > 0) {
            var msg:String = '';
            if (missFighters.length > 0) {
                msg += 'fighter : ' + missFighters.join(' , ') + ' ; ';
            }
            if (missAssisters.length > 0) {
                msg += 'assister : ' + missAssisters.join(' , ') + ' ; ';
            }
            throw new Error("select.xml验证失败！ [" + msg + "]");
         }
      }
      
      private function validateMissionData() : void
      {
         var _loc4_:* = undefined;
         var _loc7_:FighterVO = null;
         var _loc11_:MapVO = null;
         var _loc12_:FighterVO = null;
         var _loc1_:String = null;
         var _loc8_:Array = [];
         var _loc6_:Array = [];
         var _loc9_:Array = [];
         var _loc3_:Array = MessionModel.I.getAllMissions();
         for each(var _loc10_:MessionVO in _loc3_)
         {
            _loc4_ = _loc10_.stageList;
            for each(var _loc2_:MessionStageVO in _loc4_)
            {
               for each(var _loc5_:String in _loc2_.fighters)
               {
                  _loc7_ = FighterModel.I.getFighter(_loc5_);
                  if(_loc7_ == null)
                  {
                     if(_loc8_.indexOf(_loc5_) == -1)
                     {
                        _loc8_.push(_loc5_);
                     }
                  }
               }
               _loc11_ = MapModel.I.getMap(_loc2_.map);
               if(_loc11_ == null)
               {
                  if(_loc6_.indexOf(_loc2_.map) == -1)
                  {
                     _loc6_.push(_loc2_.map);
                  }
               }
               _loc12_ = AssisterModel.I.getAssister(_loc2_.assister);
               if(_loc12_ == null)
               {
                  if(_loc9_.indexOf(_loc2_.assister) == -1)
                  {
                     _loc9_.push(_loc2_.assister);
                  }
               }
            }
         }
         if(_loc8_.length > 0 || _loc9_.length > 0 || _loc6_.length > 0)
         {
            _loc1_ = "";
            if(_loc8_.length > 0)
            {
               _loc1_ += "fighter : " + _loc8_.join(" , ") + " ; ";
            }
            if(_loc9_.length > 0)
            {
               _loc1_ += "assister : " + _loc9_.join(" , ") + " ; ";
            }
            if(_loc6_.length > 0)
            {
               _loc1_ += "map : " + _loc6_.join(" , ") + " ; ";
            }
            throw new Error("mission.xml验证失败！ [" + _loc1_ + "]");
         }
      }
      
      private function validateMosouData() : void
      {
         var mapObj:Object = MosouModel.I.getAllMap();
         for (var i:String in mapObj)
         {
            var mwv:MosouWorldMapVO = mapObj[i];
            for each(var a:MosouWorldMapAreaVO in mwv.areas)
            {
                for each(var mv:MosouMissionVO in a.missions)
                {
                   var mosouId:String = mwv.id + ' - ' + a.id + ' - ' + mv.id;
                   var map:MapVO = MapModel.I.getMap(mv.map);
                   if (map == null)
                   {
                      throw new Error("mosou[" + mosouId + "]验证失败！未找到map: " + mv.map);
                   }
                   var ememies:Array = mv.getAllEnemieIds();
                   for each(var f:String in ememies)
                   {
                      var fighter:FighterVO = FighterModel.I.getFighter(f);
                      if (fighter == null)
                      {
                         throw new Error("mosou[" + mosouId + "]验证失败！未找到fighter: " +f );
                      }
                   }
                }
            }
         }
         var missFighters:Array = [];
         var fighters:Vector.<MosouFighterSellVO> = MosouFighterModel.I.fighters;
         for each(var s:MosouFighterSellVO in fighters)
         {
            var fv:FighterVO = FighterModel.I.getFighter(s.id);
            if (!fv && missFighters.indexOf(s.id) == -1)
            {
                missFighters.push(s.id);
            }
         }
         if (missFighters.length > 0)
         {
            var msg:String = "";
            if (missFighters.length > 0)
            {
                msg += "fighter : " + missFighters.join(" , ") + " ; ";
            }
            throw new Error("FighterModel 验证失败！ [" + msg + "]");
         }
      }
   }
}

