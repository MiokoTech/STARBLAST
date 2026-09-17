package net.play5d.game.bvn.state
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.ctrl.StateCtrl;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.ctrl.game_stage_loader.GameStageLoadCtrl;
   import net.play5d.game.bvn.ctrl.mosou_ctrls.MosouLogic;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.MapModel;
   import net.play5d.game.bvn.data.mosou.MosouMissionVO;
   import net.play5d.game.bvn.data.mosou.MosouModel;
   import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.stage.Istage;
   
   public class LoadingMosouState implements Istage
   {
      private var _ui:MovieClip;
      
      private var _destoryed:Boolean;
      
      private var _sltUI:MovieClip;
      
      public function LoadingMosouState()
      {
         super();
      }
      
      public function get display() : DisplayObject
      {
         return _ui;
      }
      
      public function build() : void
      {
         GameEvent.dispatchEvent("MOSOU_LOADING_START");
         GameRender.add(render);
         GameInputer.focus();
         GameInputer.enabled = true;
         SoundCtrl.I.BGM(AssetManager.I.getSound("loading"));
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.fight,"loading_fight_mc");
         _sltUI = _ui.sltui;
      }
      
      private function startLoad() : void
      {
         var _loc7_:int = 0;
         var _loc2_:Array = [];
         var _loc9_:Array = [];
         var _loc3_:Array = null;
         var _loc5_:Array = [];
         var _loc1_:MosouMissionVO = MosouModel.I.currentMission;
         _loc2_.push(_loc1_.map);
         var _loc4_:Vector.<MosouFighterVO> = GameData.I.mosouData.getFighterTeam();
         while(_loc7_ < _loc4_.length)
         {
            _loc9_.push(_loc4_[_loc7_].id);
            _loc7_++;
         }
         var _loc6_:Array = _loc1_.getAllEnemieIds();
         _loc9_ = _loc9_.concat(_loc6_);
         var _loc8_:Array = _loc1_.getBossIds();
         _loc5_.push(_loc1_.map,_loc9_[0],_loc8_);
         _loc5_.push("boss_naruto","boss_bleach");
         GameStageLoadCtrl.I.init(onLoadProcess,onLoadError);
         GameStageLoadCtrl.I.loadGame(_loc2_,_loc9_,_loc3_,_loc5_,onLoadFinish);
      }
      
      private function onLoadProcess(param1:String, param2:Number) : void
      {
         _sltUI.bar.txt.text = param1;
         _sltUI.bar.bar.scaleX = param2;
         GameEvent.dispatchEvent("MOSOU_LOADING",{
            "msg":param1,
            "process":param2
         });
      }
      
      private function onLoadError(param1:String) : void
      {
         Debugger.errorMsg(param1);
      }
      
      private function onLoadFinish() : void
      {
         initGameRunData();
         StateCtrl.I.transIn(MainGame.I.goMosouGame,false);
         GameEvent.dispatchEvent("MOSOU_LOADING_FINISH");
      }
      
      private function render() : void
      {
         if(GameInputer.back(1))
         {
            if(GameUI.showingDialog())
            {
               GameUI.cancelConfrim();
            }
            else
            {
               GameUI.confrim("BACK TITLE?","返回到主菜单？",MainGame.I.goMenu);
               GameEvent.dispatchEvent("CONFRIM_BACK_MENU");
            }
         }
      }
      
      private function initGameRunData() : void
      {
         var _loc1_:MosouMissionVO = MosouModel.I.currentMission;
         GameCtrl.I.initMosouGame();
         GameCtrl.I.getMosouCtrl().gameRunData.koNum = 0;
         MosouLogic.I.clearHits();
         GameCtrl.I.getMosouCtrl().gameRunData.gameTimeMax = _loc1_.time * 30;
         GameCtrl.I.getMosouCtrl().gameRunData.gameTime = _loc1_.time * 30;
         var _loc2_:Vector.<MosouFighterVO> = GameData.I.mosouData.getFighterTeam();
         GameCtrl.I.gameRunData.p1FighterGroup.fighter1 = FighterModel.I.getFighter(_loc2_[0].id);
         GameCtrl.I.gameRunData.p1FighterGroup.fighter2 = FighterModel.I.getFighter(_loc2_[1].id);
         GameCtrl.I.gameRunData.p1FighterGroup.fighter3 = FighterModel.I.getFighter(_loc2_[2].id);
         GameCtrl.I.gameRunData.map = MapModel.I.getMap(_loc1_.map);
      }
      
      public function afterBuild() : void
      {
         StateCtrl.I.transOut(startLoad);
      }
      
      public function destory(param1:Function = null) : void
      {
         _destoryed = true;
         SoundCtrl.I.BGM(null);
         GameInputer.clearInput();
         GameRender.remove(render);
         GameUI.closeConfrim();
      }
   }
}

