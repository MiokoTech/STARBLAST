package net.play5d.game.bvn.mob.ctrls
{
   import com.adobe.crypto.MD5;
   import flash.filesystem.File;
   import net.play5d.game.bvn.mob.data.AdConfVO;
   import net.play5d.game.bvn.mob.data.VersionInfoVO;
   import net.play5d.game.bvn.mob.utils.FileUtils;
   import net.play5d.kyo.loader.KyoURLoader;
   
   public class GamePolyCtrl
   {
      private static var _i:GamePolyCtrl;
      
      private var _versionInfo:VersionInfoVO;
      
      private var _adConfList:Vector.<AdConfVO>;
      
      public function GamePolyCtrl()
      {
         super();
      }
      
      public static function get I() : GamePolyCtrl
      {
         if(!_i)
         {
            _i = new GamePolyCtrl();
         }
         return _i;
      }
      
      public function getVersion() : VersionInfoVO
      {
         return _versionInfo;
      }
      
      public function getAdConf() : Vector.<AdConfVO>
      {
         return _adConfList;
      }
      
      public function loadConfig(param1:Array, param2:Function) : void
      {
         var urls:Array = param1;
         var back:Function = param2;
         var loadNext:* = function():void
         {
            var url:String;
            if(urls.length < 1)
            {
               readLocalConfig();
               if(back != null)
               {
                  back();
               }
               return;
            }
            url = urls.shift();
            url += "?rand=" + int(Math.random() * 10000);
            trace("request::" + url);
            KyoURLoader.load(url,function(param1:String):void
            {
               if(!parseConfig(param1))
               {
                  loadNext();
                  return;
               }
               saveLocalConfig(param1);
               if(back != null)
               {
                  back();
               }
            },loadNext);
         };
         loadNext();
      }
      
      private function parseConfig(param1:String) : Boolean
      {
         var _loc9_:Object = null;
         var _loc4_:Object = null;
         var _loc8_:Array = null;
         var _loc7_:int = 0;
         var _loc10_:Object = null;
         var _loc3_:AdConfVO = null;
         if(!param1 || param1.length < 1)
         {
            return false;
         }
         var _loc2_:Array = param1.split("|");
         if(_loc2_.length != 2)
         {
            return false;
         }
         var _loc6_:String = _loc2_[0];
         var _loc5_:String = _loc2_[1];
         try
         {
            if(MD5.hash("$%_ST_%$" + _loc6_ + "$%_ED_%$") != _loc5_)
            {
               return false;
            }
            _loc9_ = JSON.parse(_loc6_);
            _loc4_ = _loc9_.VS;
            if(_loc4_)
            {
               _versionInfo = new VersionInfoVO();
               _versionInfo.version = _loc4_.V;
               _versionInfo.url = _loc4_.U;
               _versionInfo.info = _loc4_.I;
               _versionInfo.forceUpdate = _loc4_.F;
               _versionInfo.enabled = _loc4_.E;
            }
            _loc8_ = _loc9_.AD;
            if(_loc8_)
            {
               _adConfList = new Vector.<AdConfVO>();
               while(_loc7_ < _loc8_.length)
               {
                  _loc10_ = _loc8_[_loc7_];
                  _loc3_ = new AdConfVO();
                  _loc3_.code = _loc10_.C;
                  _loc3_.rank = _loc10_.P;
                  _loc3_.rate = _loc10_.R;
                  _loc3_.enabled = _loc10_.E;
                  _adConfList.push(_loc3_);
                  _loc7_++;
               }
            }
            return true;
         }
         catch(e:Error)
         {
            trace("GamePolyCtrl.parseConfig",e);
            var _loc14_:Boolean = false;
         }
         return _loc14_;
      }
      
      private function saveLocalConfig(param1:String) : void
      {
         var _loc2_:File = File.applicationStorageDirectory.resolvePath("bvnpoly.conf");
         FileUtils.writeFile(_loc2_.nativePath,param1);
      }
      
      private function readLocalConfig() : void
      {
         var _loc1_:File = File.applicationStorageDirectory.resolvePath("bvnpoly.conf");
         var _loc2_:String = FileUtils.readTextFile(_loc1_.nativePath);
         parseConfig(_loc2_);
      }
   }
}

