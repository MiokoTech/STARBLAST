package net.play5d.game.bvn.state
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.stage.Istage;
   
   public class GameLoadingState implements Istage
   {
      private var _ui:MovieClip;
      
      private var _initBack:Function;
      
      private var _initFail:Function;
      
      public function GameLoadingState()
      {
         super();
      }
      
      public function get display() : DisplayObject
      {
         return _ui;
      }
      
      public function build() : void
      {
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.loadGame,"loading_cover_mc");
      }
      
      public function loadGame(param1:Function, param2:Function) : void
      {
         _initBack = param1;
         _initFail = param2;
         if(AssetManager.I.needPreLoad())
         {
            AssetManager.I.loadPreLoad(loadPreloadBack,loadPreloadFail,loadPreloadProcess);
            msg(GetLangText("loading.preload.message.resources"));
         }
         else
         {
            loadPreloadBack();
         }
      }
      
      private function loadPreloadBack() : void
      {
         GameData.I.loadConfig(loadConfigBack,loadConfigFail);
         msg(GetLangText("loading.preload.message.loading_config"));
      }
      
      private function loadPreloadFail(param1:String = null) : void
      {
         Debugger.log(GetLangText("loading.preload.message.resources_fail"),param1);
         msg(GetLangText("loading.preload.message.resources_fail"));
         if(_initFail != null)
         {
            _initFail(param1);
         }
      }
      
      private function loadPreloadProcess(param1:Number) : void
      {
         if(param1 > 1)
         {
            param1 = 1;
         }
         _ui.bar.bar.scaleX = param1;
      }
      
      private function loadConfigFail(param1:String) : void
      {
         Debugger.log(GetLangText("loading.preload.message.loading_config"),param1);
         msg(GetLangText("loading.preload.message.loading_config_fail"));
         if(_initFail != null)
         {
            _initFail(param1);
         }
      }
      
      private function loadConfigBack() : void
      {
         AssetManager.I.loadBasic(loadAssetBack,loadAssetProcess);
         msg(GetLangText("loading.preload.message.loading_game"));
      }
      
      private function loadAssetProcess(param1:Number, param2:String, param3:int, param4:int) : void
      {
         if(param1 > 1)
         {
            param1 = 1;
         }
         _ui.bar.bar.scaleX = param1;
         var _loc5_:String = GetLangText("loading.preload.message.loading_assets") + param2 + "(" + param3 + "/" + param4 + ")";
         msg(_loc5_);
         GameEvent.dispatchEvent("LOADING_GAME",{
            "msg":_loc5_,
            "process":param1,
            "step":param3,
            "totalStep":param4
         });
      }
      
      private function loadAssetBack() : void
      {
         if(_initBack != null)
         {
            _initBack();
            _initBack = null;
         }
         _initFail = null;
      }
      
      public function afterBuild() : void
      {
      }
      
      public function destory(param1:Function = null) : void
      {
         if(_ui != null)
         {
            _ui.removeChildren();
            _ui = null;
         }
      }
      
      private function msg(param1:String) : void
      {
         _ui.bar.txt.text = param1;
      }
   }
}

