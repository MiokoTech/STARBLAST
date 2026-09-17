package net.play5d.game.bvn.utils
{
   import flash.utils.ByteArray;
   import net.play5d.kyo.loader.KyoLoaderLite;
   
   public class GameSafeKeeper
   {
      private static var _i:GameSafeKeeper;
      
      private var _fileSaveMap:Object;
      
      private var _configFailed:Boolean;
      
      private var _failFileMap:Object = {};
      
      private var _fileFailed:Boolean;
      
      private const KEY:String = "Wo&Ye@bu!Neng(889^Yang%a!Po!xO!bB)_(";
      
      private const IV:String = "#$@!#%^cscscsDDW*><1998AZSfdxx##(x_x)###2";
      
      public function GameSafeKeeper()
      {
         super();
      }
      
      public static function get I() : GameSafeKeeper
      {
         if(!_i)
         {
            _i = new GameSafeKeeper();
         }
         return _i;
      }
      
      public function loadConfigure(param1:Function, param2:Function = null) : void
      {
         var succ:Function = param1;
         var fail:Function = param2;
         var succBack:* = function(param1:ByteArray):void
         {
            var _loc2_:String = null;
            var _loc3_:Object = null;
            try
            {
               _loc2_ = GameEncriptUtils.decryptAES(param1,"Wo&Ye@bu!Neng(889^Yang%a!Po!xO!bB)_(","#$@!#%^cscscsDDW*><1998AZSfdxx##(x_x)###2");
               _loc3_ = JSON.parse(_loc2_);
               _fileSaveMap = _loc3_;
               if(succ != null)
               {
                  succ();
               }
            }
            catch(e:Error)
            {
               if(fail != null)
               {
                  fail(e);
               }
            }
         };
         var failBack:* = function(param1:* = null):void
         {
            trace("loadSafeFile fail:",param1);
            _configFailed = true;
            if(fail != null)
            {
               fail();
            }
         };
         KyoLoaderLite.loadBytes("assets/.md5",succBack,failBack);
      }
      
      public function getConfigFailed() : Boolean
      {
         return _configFailed;
      }
      
      public function getFailed() : Boolean
      {
         return _fileFailed;
      }
      
      public function getConfigOrFileFailed() : Boolean
      {
         return _configFailed || _fileFailed;
      }
      
      public function checkFile(param1:String, param2:ByteArray) : Boolean
      {
         if(_configFailed || !_fileSaveMap)
         {
            return false;
         }
         if(_failFileMap[param1])
         {
            trace("checkFile Error :: not match! ",param1);
            return false;
         }
         if(param1.indexOf("assets") == 0)
         {
            param1 = param1.substr(7);
         }
         var _loc4_:String = _fileSaveMap[param1];
         if(!_loc4_)
         {
            trace("checkFile Error :: md5 not found! ",param1);
            return false;
         }
         var _loc3_:String = GameEncriptUtils.getFileMD5(param2);
         if(_loc4_ == _loc3_)
         {
            return true;
         }
         trace("checkFile Error :: md5 not match! ",param1);
         _failFileMap[param1] = 1;
         _fileFailed = true;
         return false;
      }
   }
}

