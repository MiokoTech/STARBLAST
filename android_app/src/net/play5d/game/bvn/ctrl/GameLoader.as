package net.play5d.game.bvn.ctrl
{
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.system.ApplicationDomain;
   import net.play5d.game.bvn.data.AssisterModel;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.MapModel;
   import net.play5d.game.bvn.data.MapVO;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.map.MapMain;
   
   public class GameLoader
   {
      private static var _fighterCache:Object = {};
      
      private static var _loadedSwfCache:Vector.<Loader> = new Vector.<Loader>();
      
      public function GameLoader()
      {
         super();
      }
      
      public static function loadAndCacheFighter(param1:String, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         var fv:FighterVO;
         var fighterId:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         var loadComplete:* = function(param1:Loader):void
         {
            var _loc3_:ApplicationDomain = null;
            var _loc2_:Object = null;
            var _loc4_:FighterCacheVO = new FighterCacheVO();
            _loc4_.loader = param1;
            _loc4_.fighterData = fv;
            _fighterCache[fighterId] = _loc4_;
            try
            {
               _loc3_ = param1.contentLoaderInfo.applicationDomain;
               _loc2_ = _loc3_.getDefinition("main_mc");
               _loc4_.MainClass = _loc2_ as Class;
            }
            catch(e:Error)
            {
               trace("loadFighter",e);
            }
            if(back != null)
            {
               back();
            }
         };
         if(_fighterCache[fighterId])
         {
            if(back != null)
            {
               back();
            }
            return;
         }
         fv = FighterModel.I.getFighter(fighterId,true);
         if(!fv)
         {
            trace("GameLoader.loadFighter :: ID不存在:",fighterId);
            if(fail != null)
            {
               fail("角色ID错误");
            }
            return;
         }
         loadSWF(fv.fileUrl,loadComplete,fail,process);
      }
      
      public static function loadFighter(param1:String, param2:Function, param3:Function = null, param4:Function = null, param5:Object = null) : void
      {
         var fighterId:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         var customBackParam:Object = param5;
         var loadComplete:* = function():void
         {
            result = createCacheFighter(fighterId);
            if(back != null)
            {
               if(customBackParam)
               {
                  back(result,customBackParam);
               }
               else
               {
                  back(result);
               }
            }
         };
         var result:FighterMain = createCacheFighter(fighterId);
         if(result)
         {
            if(back != null)
            {
               if(customBackParam)
               {
                  back(result,customBackParam);
               }
               else
               {
                  back(result);
               }
            }
            return;
         }
         loadAndCacheFighter(fighterId,loadComplete,fail,process);
      }
      
      public static function createCacheFighter(param1:String) : FighterMain
      {
         var _loc2_:MovieClip = null;
         var _loc3_:FighterCacheVO = _fighterCache[param1];
         if(!_loc3_)
         {
            return null;
         }
         if(_loc3_.MainClass)
         {
            _loc2_ = new _loc3_.MainClass();
         }
         else
         {
            _loc2_ = _loc3_.loader.content as MovieClip;
         }
         var _loc4_:FighterMain = new FighterMain(_loc2_);
         _loc4_.data = _loc3_.fighterData;
         return _loc4_;
      }
      
      public static function loadAssister(param1:String, param2:Function, param3:Function = null, param4:Function = null, param5:Object = null) : void
      {
         var fighterId:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         var customBackParam:Object = param5;
         var loadComplete:* = function(param1:Loader):void
         {
            var _loc2_:Assister = new Assister(param1.content as MovieClip);
            _loc2_.data = fv;
            if(back != null)
            {
               if(customBackParam)
               {
                  back(_loc2_,customBackParam);
               }
               else
               {
                  back(_loc2_);
               }
               back = null;
            }
         };
         var fv:FighterVO = AssisterModel.I.getAssister(fighterId,true);
         if(!fv)
         {
            trace("GameLoader.loadAssister :: ID不存在:",fighterId);
            if(fail != null)
            {
               fail("角色ID错误");
            }
            return;
         }
         loadSWF(fv.fileUrl,loadComplete,fail,process);
      }
      
      public static function loadMap(param1:String, param2:Function, param3:Function = null, param4:Function = null, param5:Object = null) : void
      {
         var mapId:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         var customBackParam:Object = param5;
         var loadComplete:* = function(param1:Loader):void
         {
            var _loc2_:MapMain = new MapMain(param1.content as Sprite);
            _loc2_.data = mv;
            if(back != null)
            {
               if(customBackParam)
               {
                  back(_loc2_,customBackParam);
               }
               else
               {
                  back(_loc2_);
               }
               back = null;
            }
         };
         var mv:MapVO = MapModel.I.getMap(mapId);
         if(!mv)
         {
            trace("GameLoader.loadMap :: ID不存在:",mapId);
            if(fail != null)
            {
               fail("场景ID错误");
            }
            return;
         }
         loadSWF(mv.fileUrl,loadComplete,fail,process);
      }
      
      public static function dispose() : void
      {
         var _loc1_:FighterCacheVO = null;
         var _loc3_:Loader = null;
         for(var _loc2_:String in _fighterCache)
         {
            _loc1_ = _fighterCache[_loc2_];
            _loc1_.fighterData = null;
            _loc1_.MainClass = null;
            _loc1_.loader = null;
         }
         while(_loadedSwfCache.length)
         {
            _loc3_ = _loadedSwfCache.shift();
            try
            {
               _loc3_.unloadAndStop(true);
            }
            catch(e:Error)
            {
               trace("GameLoader ::",e);
               _loc3_.unload();
            }
         }
         _fighterCache = {};
      }
      
      public static function loadSWF(param1:String, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         var url:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         var loadComplete:* = function(param1:Loader):void
         {
            _loadedSwfCache.push(param1);
            if(back != null)
            {
               back(param1);
               back = null;
            }
         };
         var loadIOError:* = function():void
         {
            Debugger.log("GameLoader.loadSWF :: 找不到文件:",url);
            if(fail != null)
            {
               fail("加载场景文件错误");
            }
         };
         AssetManager.I.loadSWF(url,loadComplete,loadIOError,process);
      }
   }
}

import flash.display.Loader;
import net.play5d.game.bvn.data.FighterVO;

class FighterCacheVO
{
   public var loader:Loader;
   
   public var MainClass:Class;
   
   public var fighterData:FighterVO;
   
   public function FighterCacheVO()
   {
      super();
   }
}
