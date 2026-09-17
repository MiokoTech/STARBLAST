package net.play5d.game.bvn.mob.utils
{
   import net.play.ane.umeng.UmengANE;
   
   public class UMengAneManager
   {
      private static var _i:UMengAneManager;
      
      private var _umeng:UmengANE;
      
      public function UMengAneManager()
      {
         super();
      }
      
      public static function get I() : UMengAneManager
      {
         if(!_i)
         {
            _i = new UMengAneManager();
         }
         return _i;
      }
      
      public function initlize(param1:String, param2:String) : void
      {
         _umeng = new UmengANE();
         _umeng.setLogEnabled(false);
         _umeng.preInit(param1,param2);
         _umeng.init(param1,param2,false);
      }
      
      public function onDeactive() : void
      {
         if(_umeng)
         {
            _umeng.onPause();
         }
      }
      
      public function onActive() : void
      {
         if(_umeng)
         {
            _umeng.onResume();
         }
      }
      
      public function sendEvent(param1:String) : void
      {
         if(_umeng)
         {
            trace("[[* UMENG.EVENT *]] ::" + param1);
            _umeng.onEvent(param1);
         }
      }
      
      public function sendEventParam(param1:String, param2:String) : void
      {
         if(_umeng)
         {
            trace("[[* UMENG.EVENT *]] ::" + param1);
            _umeng.onEventParam(param1,param2);
         }
      }
   }
}

