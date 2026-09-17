package net.play5d.kyo.utils
{
   import flash.display.Stage;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.utils.Timer;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   
   public class WebUtils
   {
      private static var _url:String;
      
      public function WebUtils()
      {
         super();
      }
      
      public static function getURL(param1:String, param2:String = "_blank") : void
      {
         var url:String = param1;
         var target:String = param2;
         if(!url)
         {
            trace("getURL: url is null");
            return;
         }
         try
         {
            navigateToURL(new URLRequest(url),target);
         }
         catch(e:Error)
         {
            trace(e);
         }
      }
      
      public static function addJSCallBack(param1:String, param2:Function, param3:String = null, param4:TextField = null) : void
      {
         var timer:Timer = null;
         var functionName:String = param1;
         var closure:Function = param2;
         var jsReady:String = param3;
         var debugTxt:TextField = param4;
         if(jsReady == null)
         {
            try
            {
               ExternalInterface.addCallback(functionName,closure);
            }
            catch(e:Error)
            {
               trace(e);
            }
         }
         else
         {
            timer = new Timer(100);
            timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
            {
               var jsVar:Boolean = false;
               var e:TimerEvent = param1;
               try
               {
                  jsVar = ExternalInterface.call(jsReady);
               }
               catch(e:Error)
               {
                  trace(e);
                  timer.stop();
                  timer = null;
               }
               if(debugTxt != null)
               {
                  debugTxt.text = jsVar.toString();
               }
               if(jsVar)
               {
                  addJSCallBack(functionName,closure);
                  timer.stop();
                  timer = null;
               }
            });
            timer.start();
         }
      }
      
      public static function checkLockedURL(... rest) : Boolean
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         for each(_loc2_ in rest)
         {
            if(_loc2_ is Array)
            {
               for each(_loc3_ in _loc2_)
               {
                  if(!checkURL(_loc3_))
                  {
                     return false;
                  }
               }
            }
            else if(!checkURL(_loc2_ as String))
            {
               return false;
            }
         }
         return true;
      }
      
      private static function checkURL(param1:String) : Boolean
      {
         var s:int = 0;
         var e:int = 0;
         var url:String = param1;
         if(_url == null)
         {
            try
            {
               _url = ExternalInterface.call("eval","window.location.href");
            }
            catch(e:Error)
            {
               trace(e);
               return false;
            }
            s = _url.indexOf("//") + 2;
            e = int(_url.indexOf("/",s));
            e = e == -1 ? int.MAX_VALUE : e - s;
            _url = _url.substr(s,e);
         }
         return _url.indexOf(url) != -1;
      }
      
      public static function getParameters(param1:Stage, param2:String, param3:Function, param4:int = 0) : void
      {
         var loadint:int = 0;
         var loadTimes:int = 0;
         var loadp:Function = null;
         var stage:Stage = param1;
         var checkVar:String = param2;
         var back:Function = param3;
         var timeout:int = param4;
         loadp = function():void
         {
            var _loc1_:Object = stage.loaderInfo.parameters[checkVar];
            if(loadTimes > 0)
            {
               --loadTimes;
            }
            if(Boolean(_loc1_) || loadTimes == 0)
            {
               clearInterval(loadint);
               if(back != null)
               {
                  back(stage.loaderInfo.parameters);
               }
            }
         };
         loadint = int(setInterval(loadp,300));
         loadTimes = timeout == 0 ? -1 : int(Math.ceil(timeout / 300));
      }
      
      public static function getLocalUrl(param1:Stage) : String
      {
         var _loc2_:String = param1.loaderInfo.url;
         var _loc3_:int = int(_loc2_.lastIndexOf("/"));
         return _loc2_.substr(0,_loc3_ + 1);
      }
      
      public static function replaceUrl(param1:String, param2:String, param3:String) : String
      {
         var _loc4_:String = param1.replace(param2,param2 + param3);
         return _loc4_.replace(param3 + "http://","http://");
      }
      
      public static function getUrlFloder(param1:String) : String
      {
         var _loc2_:int = int(param1.lastIndexOf("/"));
         return param1.substr(0,_loc2_ + 1);
      }
      
      public static function getLocalFloder(param1:String) : String
      {
         var _loc2_:int = int(param1.lastIndexOf("\\"));
         return param1.substr(0,_loc2_ + 1);
      }
      
      public static function getFileName(param1:Stage) : String
      {
         var _loc2_:String = param1.loaderInfo.url;
         var _loc3_:int = int(_loc2_.lastIndexOf("/"));
         return _loc2_.substr(_loc3_ + 1);
      }
      
      public static function getStageUrlFloder(param1:Stage) : String
      {
         var _loc2_:String = param1.loaderInfo.url;
         return getUrlFloder(_loc2_);
      }
      
      public static function refresh() : void
      {
         getURL("javascript:location.reload();","_self");
      }
      
      public static function alert(param1:String) : void
      {
         getURL("javascript:alert(\"" + param1 + "\");","_self");
      }
   }
}

