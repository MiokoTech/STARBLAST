package net.play5d.game.bvn.ctrl.game_stage_loader
{
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.system.ApplicationDomain;
   import flash.utils.setTimeout;
   import net.play5d.game.bvn.ctrl.GameLoader;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.AssisterModel;
   import net.play5d.game.bvn.data.BgmVO;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.MapModel;
   import net.play5d.game.bvn.data.MapVO;
   import flash.display.Bitmap;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.map.MapMain;
   
   public class GameStageLoadCtrl extends EventDispatcher
   {
      private static var _i:GameStageLoadCtrl;
      
      public static var IGORE_OLD_FIGHTER:Boolean = true;
      
      private var _loadingType:int;
      
      private var _fighterCache:Object;
      
      private var _assisterCache:Object;
      
      private var _mapCache:Object;
      
      private var _processCallBack:Function;
      
      private var _errorCallBack:Function;
      
      private var _loadStep:int;
      
      private var _loadStepLength:int;
      
      private var _curLoadStep:int;
      
      private var _curLoadStepLength:int;
      
      private var _curLoadName:String;
      
      private var _loadMapDatas:Vector.<MapVO>;
      
      private var _loadFighterDatas:Vector.<FighterVO>;
      
      private var _loadAssisterDatas:Vector.<FighterVO>;
      
      private var _loadBgmDatas:Vector.<BgmVO>;
      
      private var _loadFinishBack:Function;
      
      public function GameStageLoadCtrl()
      {
         super();
      }
      
      public static function get I() : GameStageLoadCtrl
      {
         if(!_i)
         {
            _i = new GameStageLoadCtrl();
         }
         return _i;
      }
      
      public function init(param1:Function = null, param2:Function = null) : void
      {
         _fighterCache = {};
         _assisterCache = {};
         _mapCache = {};
         _loadStep = 0;
         _curLoadStep = 0;
         _processCallBack = param1;
         _errorCallBack = param2;
      }
      
      public function dispose() : void
      {
         _fighterCache = null;
         _assisterCache = null;
         _mapCache = null;
      }
      
      public function getFighterMc(param1:String, param2:String) : MovieClip
      {
         var _loc5_:Class = null;
         var _loc3_:Object = _fighterCache[param1];
         if(!_loc3_)
         {
            return null;
         }
         if(_loc3_.mc && !_loc3_.domain)
         {
            return _loc3_.mc;
         }
         var _loc4_:ApplicationDomain = _loc3_.domain;
         if(!_loc4_)
         {
            return null;
         }
         try
         {
            _loc5_ = _loc4_.getDefinition("main_mc") as Class;
            return new _loc5_();
         }
         catch(e:Error)
         {
            if(param2 == "1" && _loc3_.mc != null)
            {
               return _loc3_.mc;
            }
            var _loc10_:* = _loc3_.mcSlave;
         }
         return _loc10_;
      }
      
      public function getAssisterMc(param1:String, param2:String) : MovieClip
      {
         var _loc5_:Class = null;
         var _loc3_:Object = _assisterCache[param1];
         var _loc4_:ApplicationDomain = _loc3_.domain;
         if(!_loc4_)
         {
            return null;
         }
         try
         {
            _loc5_ = _loc4_.getDefinition("main_mc") as Class;
            return new _loc5_();
         }
         catch(e:Error)
         {
            if(param2 == "1" && _loc3_.mc != null)
            {
               return _loc3_.mc;
            }
            var _loc10_:* = _loc3_.mcSlave;
         }
         return _loc10_;
      }
      
      public function getMapMc(param1:String) : *
      {
         return _mapCache[param1];
      }
      
      public function loadGame(mapIds:Array, fighterIds:Array, assisterIds:Array, bgmIds:Array, onFinish:Function = null) : void
      {
         var itemId:* = null;
         var mapVO:MapVO = null;
         var fighterVO:FighterVO = null;
         var assisterVO:FighterVO = null;
         var bgmVO:BgmVO = null;
         _loadStep = 0;
         _loadStepLength = 0;
         var mapDatas:Vector.<MapVO> = null;
         var fighterDatas:Vector.<FighterVO> = null;
         var assisterDatas:Vector.<FighterVO> = null;
         var bgmDatas:Vector.<BgmVO> = null;
         _loadStepLength++;
         if(mapIds)
         {
            mapIds = unique(mapIds);
            mapDatas = new Vector.<MapVO>();
            for each(itemId in mapIds)
            {
               mapVO = MapModel.I.getMap(itemId);
               if(!mapVO)
               {
                  throw new Error("获取地图数据失败！");
               }
               mapDatas.push(mapVO);
            }
         }
         _loadStepLength++;
         if(fighterIds)
         {
            fighterIds = unique(fighterIds);
            fighterDatas = new Vector.<FighterVO>();
            for each(itemId in fighterIds)
            {
               fighterVO = FighterModel.I.getFighter(itemId);
               if(!fighterVO)
               {
                  throw new Error("获取角色数据失败！");
               }
               fighterDatas.push(fighterVO);
            }
         }
         _loadStepLength++;
         if(assisterIds)
         {
            assisterIds = unique(assisterIds);
            assisterDatas = new Vector.<FighterVO>();
            for each(itemId in assisterIds)
            {
               if(!itemId)
               {
                  continue;
               }
               assisterVO = AssisterModel.I.getAssister(itemId);
               if(assisterVO)
               {
                  assisterDatas.push(assisterVO);
               }
            }
         }
         _loadStepLength++;
         if(bgmIds)
         {
            bgmIds = unique(bgmIds);
            bgmDatas = new Vector.<BgmVO>();
            for each(itemId in bgmIds)
            {
               bgmVO = FighterModel.I.getFighterBGM(itemId);
               if(!bgmVO)
               {
                  bgmVO = MapModel.I.getMapBGM(itemId);
               }
               if(!bgmVO)
               {
                  bgmVO = FighterModel.I.getFighterBGM(itemId);
               }
               if(!bgmVO)
               {
                  bgmVO = FighterModel.I.getBossBGM(itemId);
               }
               if(bgmVO)
               {
                  bgmDatas.push(bgmVO);
               }
            }
         }
         _loadMapDatas = mapDatas;
         _loadFighterDatas = fighterDatas;
         _loadAssisterDatas = assisterDatas;
         _loadBgmDatas = bgmDatas;
         _loadFinishBack = onFinish;
         _loadStep = 1;
         setTimeout(startLoadingMaps,300);
      }
      
      private function startLoadingMaps() : void
      {
         loadMaps(convertLoadAssets(_loadMapDatas,{
            "id":"id",
            "name":"name",
            "url":"fileUrl"
         }),function():void
         {
            setTimeout(startloadFighters,100);
         });
      }
      
      private function startloadFighters() : void
      {
         loadFighters(convertLoadAssets(_loadFighterDatas,{
            "id":"id",
            "name":"name",
            "url":"fileUrl"
         }),function():void
         {
            setTimeout(startloadAssisters,100);
         });
      }
      
      private function startloadAssisters() : void
      {
         loadAssisters(convertLoadAssets(_loadAssisterDatas,{
            "id":"id",
            "name":"name",
            "url":"fileUrl"
         }),function():void
         {
            setTimeout(startloadBGM,100);
         });
      }
      
      private function startloadBGM() : void
      {
         loadBgms(_loadBgmDatas,function():void
         {
            trace("All Finish");
            if(_loadFinishBack != null)
            {
               _loadFinishBack();
               _loadFinishBack = null;
            }
         });
      }
      
      private function loadMaps(param1:Vector.<LoadAssetVO>, param2:Function) : void
      {
         var maps:Vector.<LoadAssetVO> = param1;
         var callback:Function = param2;
         var load:* = function(param1:LoadAssetVO, param2:Function):void
         {
            var lv:LoadAssetVO = param1;
            var succBack:Function = param2;
            var loadSucc:* = function(param1:Loader):void
            {
               _mapCache[lv.url] = param1.content;
               disposeLoader(param1);
               succBack();
            };
            var loadFail:* = function(param1:String):void
            {
               onLoadError(param1);
            };
            
            if(lv.url && lv.url.indexOf(".json") != -1)
            {
               loadJSONStage(lv.url, succBack, loadFail);
               return;
            }
            GameLoader.loadSWF(lv.url,loadSucc,loadFail,onLoadProcess);
         };
         _loadingType = 0;
         loadAssets(maps,load,callback);
      }
      
      private function loadJSONStage(jsonUrl:String, succBack:Function, failBack:Function) : void
      {
         var baseDir:String = "";
         var lastSlash:int = Math.max(jsonUrl.lastIndexOf("/"), jsonUrl.lastIndexOf("\\"));
         if(lastSlash != -1)
         {
            baseDir = jsonUrl.substring(0, lastSlash + 1);
         }
         
         AssetManager.I.loadJSON(jsonUrl, function(stageConfig:Object):void
         {
            if(!stageConfig || !stageConfig.layers)
            {
               failBack("Format stage JSON tidak valid");
               return;
            }
            
            var layers:Array = stageConfig.layers as Array;
            var pendingImages:Array = [];
            var bitmapCache:Object = {};
            
            for each(var layer:Object in layers)
            {
               if(layer && layer.img_ref)
               {
                  if(pendingImages.indexOf(layer.img_ref) == -1)
                  {
                     pendingImages.push(layer.img_ref);
                  }
               }
            }
            
            if(stageConfig.actions)
            {
               for(var actionId:String in stageConfig.actions)
               {
                  var actionFrames:Array = stageConfig.actions[actionId] as Array;
                  if(actionFrames)
                  {
                     for each(var frameObj:Object in actionFrames)
                     {
                        if(frameObj && frameObj.img_ref)
                        {
                           if(pendingImages.indexOf(frameObj.img_ref) == -1)
                           {
                              pendingImages.push(frameObj.img_ref);
                           }
                        }
                     }
                  }
               }
            }
            
            if(pendingImages.length == 0)
            {
               var emptyMap:MapMain = new MapMain();
               emptyMap.initByJSON(stageConfig, bitmapCache);
               _mapCache[jsonUrl] = emptyMap;
               succBack();
               return;
            }
            
            var loadedCount:int = 0;
            var totalCount:int = pendingImages.length;
            var maxConcurrent:int = 6;
            var activeWorkers:int = 0;
            var queueIndex:int = 0;
            
            var spawnWorker:* = function():void
            {
               while(activeWorkers < maxConcurrent && queueIndex < pendingImages.length)
               {
                  var imgRef:String = pendingImages[queueIndex++];
                  activeWorkers++;
                  
                  (function(ref:String):void
                  {
                     var fullImgUrl:String = baseDir + ref;
                     AssetManager.I.loadBitmap(fullImgUrl, function(bmp:Bitmap):void
                     {
                        bitmapCache[ref] = bmp;
                        loadedCount++;
                        activeWorkers--;
                        onLoadProcess(loadedCount / totalCount);
                        checkFinish();
                     }, function():void
                     {
                        loadedCount++;
                        activeWorkers--;
                        checkFinish();
                     });
                  })(imgRef);
               }
            };
            
            var checkFinish:* = function():void
            {
               if(loadedCount >= totalCount)
               {
                  var mapInstance:MapMain = new MapMain();
                  mapInstance.initByJSON(stageConfig, bitmapCache);
                  _mapCache[jsonUrl] = mapInstance;
                  succBack();
                  return;
               }
               spawnWorker();
            };
            
            spawnWorker();
         }, function():void
         {
            failBack("Gagal memuat file stage JSON: " + jsonUrl);
         });
      }
      
      private function loadFighters(param1:Vector.<LoadAssetVO>, param2:Function) : void
      {
         var fighters:Vector.<LoadAssetVO> = param1;
         var callback:Function = param2;
         var load:* = function(param1:LoadAssetVO, param2:Function):void
         {
            var lv:LoadAssetVO = param1;
            var succBack:Function = param2;
            var loadSucc:* = function(param1:Loader):void
            {
               _fighterCache[lv.url] = {
                  "domain":param1.contentLoaderInfo.applicationDomain,
                  "mc":null
               };
               disposeLoader(param1);
               succBack();
            };
            var loadSucc2:* = function(param1:Loader):void
            {
               _fighterCache[lv.url] = {
                  "domain":param1.contentLoaderInfo.applicationDomain,
                  "mc":param1.content
               };
               disposeLoader(param1);
               GameLoader.loadSWF(lv.url,loadSucc3,loadFail,onLoadProcess);
            };
            var loadSucc3:* = function(param1:Loader):void
            {
               _fighterCache[lv.url].mcSlave = param1.content;
               disposeLoader(param1);
               succBack();
            };
            var loadFail:* = function(param1:String):void
            {
               onLoadError(param1);
            };
            if(IGORE_OLD_FIGHTER)
            {
               GameLoader.loadSWF(lv.url,loadSucc2,loadFail,onLoadProcess);
            }
            else
            {
               GameLoader.loadSWF(lv.url,loadSucc,loadFail,onLoadProcess);
            }
         };
         _loadingType = 1;
         loadAssets(fighters,load,callback);
      }
      
      private function loadAssisters(param1:Vector.<LoadAssetVO>, param2:Function) : void
      {
         var assissters:Vector.<LoadAssetVO> = param1;
         var callback:Function = param2;
         var load:* = function(param1:LoadAssetVO, param2:Function):void
         {
            var lv:LoadAssetVO = param1;
            var succBack:Function = param2;
            var loadSucc:* = function(param1:Loader):void
            {
               _assisterCache[lv.url] = {
                  "domain":param1.contentLoaderInfo.applicationDomain,
                  "mc":(IGORE_OLD_FIGHTER ? param1.content : null)
               };
               disposeLoader(param1);
               succBack();
            };
            var loadSucc2:* = function(param1:Loader):void
            {
               _assisterCache[lv.url] = {
                  "domain":param1.contentLoaderInfo.applicationDomain,
                  "mc":param1.content
               };
               disposeLoader(param1);
               GameLoader.loadSWF(lv.url,loadSucc3,onLoadError,onLoadProcess);
            };
            var loadSucc3:* = function(param1:Loader):void
            {
               _assisterCache[lv.url].mcSlave = param1.content;
               disposeLoader(param1);
               succBack();
            };
            var loadFail:* = function(param1:String):void
            {
               onLoadError(param1);
            };
            if(IGORE_OLD_FIGHTER)
            {
               GameLoader.loadSWF(lv.url,loadSucc2,loadFail,onLoadProcess);
            }
            else
            {
               GameLoader.loadSWF(lv.url,loadSucc,loadFail,onLoadProcess);
            }
         };
         _loadingType = 2;
         loadAssets(assissters,load,callback);
      }
      
      private function loadBgms(param1:Vector.<BgmVO>, param2:Function) : void
      {
         var bgms:Vector.<BgmVO> = param1;
         var callback:Function = param2;
         var succBack:* = function():void
         {
            _loadStep++;
            _curLoadName = null;
            callback();
         };
         if(!bgms)
         {
            callback();
            return;
         }
         _loadingType = 3;
         _curLoadStep = 0;
         _curLoadStepLength = 1;
         SoundCtrl.I.loadFightBGM(bgms,succBack,callback,onLoadProcess);
      }
      
      private function onLoadProcess(param1:Number) : void
      {
         var _loc4_:String = null;
         if(_processCallBack == null)
         {
            return;
         }
         switch(_loadingType)
         {
            case 0:
               _loc4_ = "场景地图";
               break;
            case 1:
               _loc4_ = "人物角色";
               break;
            case 2:
               _loc4_ = "辅助人物";
               break;
            case 3:
               _loc4_ = "BGM";
         }
         var _loc2_:String = "正在加载" + _loc4_;
         if(_curLoadName)
         {
            _loc2_ += " : " + _curLoadName;
         }
         _loc2_ += " (" + _loadStep + "/" + _loadStepLength + ")";
         var _loc3_:Number = (_curLoadStep + param1) / _curLoadStepLength;
         _processCallBack(_loc2_,_loc3_);
      }
      
      private function onLoadError(param1:String) : void
      {
         if(_errorCallBack != null)
         {
            _errorCallBack(param1);
         }
      }
      
      private function disposeLoader(param1:Loader) : void
      {
         try
         {
            param1.unloadAndStop(true);
         }
         catch(e:Error)
         {
            try
            {
               param1.unload();
            }
            catch(e2:Error)
            {
               trace(e2);
            }
            trace(e);
         }
      }
      
      private function unique(param1:*) : Array
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Array = [];
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            if(!(param1[_loc2_] === null || param1[_loc2_] === undefined))
            {
               _loc3_ = _loc2_ + 1;
               while(_loc3_ < param1.length)
               {
                  if(param1[_loc2_] == param1[_loc3_])
                  {
                     _loc2_++;
                  }
                  _loc3_++;
               }
               _loc4_.push(param1[_loc2_]);
            }
            _loc2_++;
         }
         return _loc4_;
      }
      
      private function loadAssets(param1:Vector.<LoadAssetVO>, param2:Function, param3:Function) : void
      {
         var currentAsset:LoadAssetVO;
         var assets:Vector.<LoadAssetVO> = param1;
         var loadFunc:Function = param2;
         var callback:Function = param3;
         var loadNext:* = function():void
         {
            if(assets.length < 1)
            {
               _loadStep++;
               _curLoadName = null;
               callback();
               return;
            }
            var _loc1_:LoadAssetVO = assets.shift();
            currentAsset = _loc1_;
            _curLoadName = _loc1_.name;
            loadFunc(_loc1_,loadSucess);
         };
         var loadSucess:* = function():void
         {
            _curLoadStep++;
            loadNext();
         };
         if(!assets)
         {
            callback();
            return;
         }
         _curLoadStep = 0;
         _curLoadStepLength = assets.length;
         loadNext();
      }
      
      private function convertLoadAssets(param1:*, param2:Object) : Vector.<LoadAssetVO>
      {
         var _loc6_:LoadAssetVO = null;
         var _loc8_:String = null;
         var _loc3_:Vector.<LoadAssetVO> = new Vector.<LoadAssetVO>();
         var _loc4_:Object = {};
         for each(var i:* in param1)
         {
            _loc6_ = new LoadAssetVO();
            for(var j:String in param2)
            {
               _loc8_ = param2[j];
               _loc6_[j] = i[_loc8_];
            }
            if(!_loc4_[_loc6_.url])
            {
               _loc4_[_loc6_.url] = _loc6_;
               _loc3_.push(_loc6_);
            }
         }
         return _loc3_;
      }
   }
}

class LoadAssetVO
{
   public var id:String;
   
   public var url:String;
   
   public var name:String;
   
   public function LoadAssetVO()
   {
      super();
   }
}
