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
   import net.play5d.game.bvn.data.AssisterModel;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.data.MapModel;
   import net.play5d.game.bvn.data.SelectVO;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.select.SelectIndexUI;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.stage.Istage;
   
   public class LoadingState implements Istage
   {
      public static var AUTO_START_GAME:Boolean = true;
      private var _ui:MovieClip;
      private var _sltUI:MovieClip;
      private var _destoryed:Boolean;
      private var _loadFin:Boolean;
      private var _selectIndexUI:SelectIndexUI;
      private var _gameFinished:Boolean;

      public function LoadingState()
      {
         super();
      }

      public function get display() : DisplayObject
      {
         return _ui;
      }

      public function p1SelectFinish() : Boolean
      {
         return _selectIndexUI.p1Finish();
      }

      public function p2SelectFinish() : Boolean
      {
         return _selectIndexUI.p2Finish();
      }

      public function selectFinish() : Boolean
      {
         return _selectIndexUI.isFinish();
      }

      public function getSort() : Array
      {
         return [_selectIndexUI.getP1Order(),_selectIndexUI.getP2Order()];
      }

      public function setOrder(param1:int, param2:Array) : void
      {
         if(param1 == 1)
         {
            _selectIndexUI.setP1Order(param2);
         }
         if(param1 == 2)
         {
            _selectIndexUI.setP2Order(param2);
         }
      }

      public function build() : void
      {
         GameEvent.dispatchEvent("FIGHT_LOADING_START");
         GameRender.add(render);
         GameInputer.focus();
         GameInputer.enabled = true;
         SoundCtrl.I.BGM(AssetManager.I.getSound("loading"));
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.loadGame,"loading_fight_mc") as MovieClip;
         _sltUI = _ui.sltui;
         _selectIndexUI = new SelectIndexUI();
         _selectIndexUI.onFinish = finish;
         _sltUI.addChild(_selectIndexUI);
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
         if(!GameUI.showingDialog() && GameInputer.jump("P1",1))
         {
            GameUI.confrim("BACK TITLE?","返回到主菜单？",MainGame.I.goMenu);
            GameEvent.dispatchEvent("CONFRIM_BACK_MENU");
         }
      }
      
      private function onLoadProcess(param1:String, param2:Number) : void
      {
         _sltUI.bar.txt.text = param1;
         _sltUI.bar.bar.scaleX = param2;
      }
      
      private function onLoadError(param1:String) : void
      {
         Debugger.errorMsg(param1);
      }
      
      private function onLoadFinish() : void
      {
         _loadFin = true;
         finish();
      }
      
      private function finish() : void
      {
         if(_destoryed)
         {
            return;
         }
         if(!_selectIndexUI.isFinish() || !_loadFin)
         {
            return;
         }
         if(!AUTO_START_GAME)
         {
            return;
         }
         if(_gameFinished)
         {
            return;
         }
         _gameFinished = true;
         if(GameUI.showingDialog())
         {
            GameUI.cancelConfrim();
         }
         var _loc1_:Array = _selectIndexUI.getP1Order();
         var _loc2_:Array = _selectIndexUI.getP2Order();
         gotoGame(_loc1_,_loc2_);
      }
      
      public function gotoGame(param1:Array, param2:Array) : void
      {
         var p1Group:GameRunFighterGroup = GameCtrl.I.gameRunData.p1FighterGroup;
         var p2Group:GameRunFighterGroup = GameCtrl.I.gameRunData.p2FighterGroup;
         p1Group.fighter1 = FighterModel.I.getFighter(param1[0],true);
         p1Group.fighter2 = FighterModel.I.getFighter(param1[1],true);
         p1Group.fighter3 = FighterModel.I.getFighter(param1[2],true);
         p1Group.assister = GameData.I.config.assisterPartner && GameData.I.p1Select.fuzhu ? AssisterModel.I.getAssister(GameData.I.p1Select.fuzhu,true) : null;
         p2Group.fighter1 = FighterModel.I.getFighter(param2[0],true);
         p2Group.fighter2 = FighterModel.I.getFighter(param2[1],true);
         p2Group.fighter3 = FighterModel.I.getFighter(param2[2],true);
         p2Group.assister = GameData.I.config.assisterPartner && GameData.I.p2Select.fuzhu ? AssisterModel.I.getAssister(GameData.I.p2Select.fuzhu,true) : null;
         GameCtrl.I.gameRunData.map = MapModel.I.getMap(GameData.I.selectMap);
         GameEvent.dispatchEvent("FIGHT_LOADING_FINISH");
         StateCtrl.I.transIn(MainGame.I.goGame,false);
      }
      
      public function afterBuild() : void
      {
         StateCtrl.I.transOut(startLoad);
      }
      
      private function startLoad() : void
      {
         var maps:Array = [];
         var fighters:Array = [];
         var assisters:Array = [];
         var bgms:Array = [];
         maps.push(GameData.I.selectMap);
         var p1Select:SelectVO = GameData.I.p1Select;
         fighters.push(p1Select.fighter1,p1Select.fighter2,p1Select.fighter3);
         var p2Select:SelectVO = GameData.I.p2Select;
         fighters.push(p2Select.fighter1,p2Select.fighter2,p2Select.fighter3);
         if(GameData.I.config.assisterPartner)
         {
            if(p1Select.fuzhu) assisters.push(p1Select.fuzhu);
            if(p2Select.fuzhu) assisters.push(p2Select.fuzhu);
         }
         bgms = fighters.concat([GameData.I.selectMap]);
         GameStageLoadCtrl.I.init(onLoadProcess,onLoadError);
         GameStageLoadCtrl.I.loadGame(maps,fighters,assisters,bgms,onLoadFinish);
         GameEvent.dispatchEvent("FIGHT_LOADING");
      }
      
      public function destory(param1:Function = null) : void
      {
         _destoryed = true;
         if(_selectIndexUI)
         {
            _selectIndexUI.destory();
            _selectIndexUI = null;
         }
         SoundCtrl.I.BGM(null);
         GameInputer.clearInput();
         GameRender.remove(render);
         GameUI.closeConfrim();
      }
   }
}

