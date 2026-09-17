package net.play5d.game.bvn.mob.ads.utils
{
   public class AdEventListener
   {
      private var _listenMap:Object = {};
      
      public function AdEventListener()
      {
         super();
      }
      
      public function listen(param1:String, param2:Function) : void
      {
         if(_listenMap[param1])
         {
            throw Error(param1 + "已侦听，仅支持侦听一次！");
         }
         _listenMap[param1] = param2;
      }
      
      private function doFunction(param1:String, param2:IAd, param3:String = null) : void
      {
         if(_listenMap[param1])
         {
            _listenMap[param1](param2,param3,param1);
         }
      }
      
      public function onInitOK(param1:IAd) : void
      {
         doFunction("INIT_OK",param1);
      }
      
      public function onInitFail(param1:IAd) : void
      {
         doFunction("INIT_FAIL",param1);
      }
      
      public function onShow(param1:IAd, param2:String) : void
      {
         doFunction("SHOW",param1,param2);
      }
      
      public function onClose(param1:IAd, param2:String) : void
      {
         doFunction("CLOSE",param1,param2);
      }
      
      public function onClick(param1:IAd, param2:String) : void
      {
         doFunction("CLICK",param1,param2);
      }
      
      public function onError(param1:IAd, param2:String) : void
      {
         doFunction("ERROR",param1,param2);
      }
   }
}

