package net.play5d.game.bvn.mob.utils
{
   import flash.filesystem.File;
   import flash.system.Capabilities;
   import net.play5d.game.bvn.utils.ClassUtil;
   import net.play5d.kyo.loader.KyoURLoader;
   
   public class MultiLangUtils
   {
      private static var _instance:MultiLangUtils;
      
      private const LANG_DIR:String = "assets/language/";
      
      private const SEPARATOR:String = ".";
      
      private const ENGLISH_LANG:String = "en";
      
      public var lang:String;
      
      private var _langObj:Object;
      
      private var _cacheObj:Object;
      
      public function MultiLangUtils()
      {
         super();
      }
      
      public static function get I() : MultiLangUtils
      {
         if(_instance == null)
         {
            _instance = new MultiLangUtils();
         }
         return _instance;
      }
      
      public function getLangPath() : String
      {
         return "assets/language/" + lang + ".json";
      }
      
      public function initialize(param1:Function = null) : void
      {
         var back:Function = param1;
         var next:* = function():void
         {
            var langFile:File = File.applicationDirectory.resolvePath(getLangPath());
            if(!langFile.exists)
            {
               lang = "en";
               langFile = File.applicationDirectory.resolvePath(getLangPath());
               if(!langFile.exists)
               {
                  throw new Error("MultiLangUtils.initialize::中文语言文件不存在！");
               }
            }
            KyoURLoader.load(getLangPath(),function(param1:*):void
            {
               try
               {
                  _langObj = JSON.parse(param1);
               }
               catch(e:Error)
               {
                  throw new Error("MultiLangUtils.initialize::解析语言文件失败！");
               }
               if(back != null)
               {
                  back();
               }
            });
         };
         lang = Capabilities.language;
         next();
      }
      
      public function getLangText(param1:String) : String
      {
         if(_langObj == null)
         {
            return null;
         }
         if(_cacheObj == null)
         {
            _cacheObj = {};
         }
         if(_cacheObj[param1])
         {
            return _cacheObj[param1];
         }
         var _loc2_:Array = param1.split(".");
         var _loc3_:String = ClassUtil.continuousAccess(_langObj,_loc2_);
         if(_loc3_ == null)
         {
            return null;
         }
         _cacheObj[param1] = _loc3_;
         return _loc3_;
      }
      
      public function getLangObj() : Object
      {
         return _langObj;
      }
      
      public function get isEnglish() : Boolean
      {
         return lang == "en";
      }
   }
}

