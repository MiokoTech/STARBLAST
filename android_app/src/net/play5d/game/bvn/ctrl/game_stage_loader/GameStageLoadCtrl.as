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
      
      public function getMapMc(param1:String) : MovieClip
      {
         return _mapCache[param1];
      }
      
      public function loadGame(param1:Array, param2:Array, param3:Array, param4:Array, param5:Function = null) : void
      {
         var _loc14_:* = null;
         var _loc7_:MapVO = null;
         var _loc11_:FighterVO = null;
         var _loc13_:FighterVO = null;
         var _loc12_:BgmVO = null;
         _loadStep = 0;
         _loadStepLength = 0;
         var _loc8_:Vector.<MapVO> = null;
         var _loc9_:Vector.<FighterVO> = null;
         var _loc10_:Vector.<FighterVO> = null;
         var _loc6_:Vector.<BgmVO> = null;
         _loadStepLength++;
         if(param1)
         {
            param1 = unique(param1);
            _loc8_ = new Vector.<MapVO>();
            for each(_loc14_ in param1)
            {
               _loc7_ = MapModel.I.getMap(_loc14_);
               if(!_loc7_)
               {
                  throw new Error("获取地图数据失败！");
               }
               _loc8_.push(_loc7_);
            }
         }
         _loadStepLength++;
         if(param2)
         {
            param2 = unique(param2);
            _loc9_ = new Vector.<FighterVO>();
            for each(_loc14_ in param2)
            {
               _loc11_ = FighterModel.I.getFighter(_loc14_);
               if(!_loc11_)
               {
                  throw new Error("获取角色数据失败！");
               }
               _loc9_.push(_loc11_);
            }
         }
         _loadStepLength++;
         if(param3)
         {
            param3 = unique(param3);
            _loc10_ = new Vector.<FighterVO>();
            for each(_loc14_ in param3)
            {
               _loc13_ = AssisterModel.I.getAssister(_loc14_);
               if(!_loc13_)
               {
                  throw new Error("获取辅助角色数据失败！");
               }
               _loc10_.push(_loc13_);
            }
         }
         _loadStepLength++;
         if(param4)
         {
            param4 = unique(param4);
            _loc6_ = new Vector.<BgmVO>();
            for each(_loc14_ in param4)
            {
               _loc12_ = FighterModel.I.getFighterBGM(_loc14_);
               if(!_loc12_)
               {
                  _loc12_ = MapModel.I.getMapBGM(_loc14_);
               }
               if(!_loc12_)
               {
                  _loc12_ = FighterModel.I.getFighterBGM(_loc14_);
               }
               if(!_loc12_)
               {
                  _loc12_ = FighterModel.I.getBossBGM(_loc14_);
               }
               if(_loc12_)
               {
                  _loc6_.push(_loc12_);
               }
            }
         }
         _loadMapDatas = _loc8_;
         _loadFighterDatas = _loc9_;
         _loadAssisterDatas = _loc10_;
         _loadBgmDatas = _loc6_;
         _loadFinishBack = param5;
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
            GameLoader.loadSWF(lv.url,loadSucc,loadFail,onLoadProcess);
         };
         _loadingType = 0;
         loadAssets(maps,load,callback);
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
