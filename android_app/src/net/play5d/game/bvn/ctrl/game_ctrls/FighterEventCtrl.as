package net.play5d.game.bvn.ctrl.game_ctrls
{
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.data.fighter.FighterInputCmd;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.events.FighterEvent;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameSpriteUtil;
   import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class FighterEventCtrl extends BaseFighterEventCtrl
   {
      public function FighterEventCtrl()
      {
         super();
      }
      
      override public function initlize() : void
      {
         super.initlize();
         FighterEventDispatcher.addEventListener("DO_SPECIAL",addAssister);
         FighterEventDispatcher.addEventListener("HIT_TARGET",onHitTarget);
         FighterEventDispatcher.addEventListener("HURT_RESUME",onHurtResume);
         FighterEventDispatcher.addEventListener("DEAD",onDead);
         FighterEventDispatcher.addEventListener("IDLE",onIdle);
         FighterEventDispatcher.addEventListener("DIE",onDie);
      }
      
      private function addAssister(e:FighterEvent) : void
      {
         var fighter:FighterMain = e.fighter as FighterMain;
         if(fighter.actionState != 0 && fighter.actionState != 20)
         {
            return;
         }
         if(fighter.fzqi < 100)
         {
            return;
         }
         fighter.fzqi = 0;
         var trainEvt:FighterEvent = new FighterEvent(FighterEvent.DO_ACTION);
         trainEvt.params = {"input": FighterInputCmd.ASSIST};
         fighter.dispatchEvent(trainEvt);
         var group:GameRunFighterGroup = fighter.team.id == 1 ? GameCtrl.I.gameRunData.p1FighterGroup : GameCtrl.I.gameRunData.p2FighterGroup;
         var assister:Assister = group.currentAssister;
         assister.setOwner(fighter);
         assister.direct = fighter.direct;
         assister.x = fighter.x - 30 * assister.direct;
         assister.y = fighter.y;
         assister.onRemove = removeAssister;
         GameSpriteUtil.autoChangeSpColor(assister,fighter);
         GameCtrl.I.addGameSprite(e.fighter.team.id,assister);
         EffectCtrl.I.assisterEffect(assister);
         assister.goFight();
      }
      
      private function removeAssister(assister:Assister) : void
      {
         GameCtrl.I.removeGameSprite(assister);
      }
      
      private function onHitTarget(param1:FighterEvent) : void
      {
         addHits(param1.fighter as FighterMain,param1.params.target);
         if(GameMode.isAcrade() && param1.fighter.team.id == 1)
         {
            GameLogic.addScoreByHitTarget(param1.params.hitvo);
         }
      }
      
      private function onHurtResume(param1:FighterEvent) : void
      {
         removeHits(param1.fighter.id);
      }
      
      private function onDead(param1:FighterEvent) : void
      {
         removeHits(param1.fighter.id);
      }
      
      private function onIdle(param1:FighterEvent) : void
      {
         removeHits(param1.fighter.id);
      }
      
      private function addHits(param1:FighterMain, param2:IGameSprite) : void
      {
         var _loc4_:String = param2 && param2 is BaseGameSprite ? (param2 as BaseGameSprite).id : null;
         var _loc5_:int = 1;
         switch(param1.team.id - 1)
         {
            case 0:
               _loc5_ = 1;
               break;
            case 1:
               _loc5_ = 2;
         }
         var _loc3_:int = GameLogic.addHits(param1.id,_loc4_,_loc5_);
         if(_loc3_ > 1)
         {
            GameCtrl.I.gameState.gameUI.getUI().showHits(_loc3_,_loc5_);
         }
      }
      
      private function removeHits(param1:String) : void
      {
         var _loc2_:Object = GameLogic.getHitsObjByTargetId(param1);
         if(_loc2_)
         {
            GameCtrl.I.gameState.gameUI.getUI().hideHits(_loc2_.uiID);
         }
         GameLogic.clearHitsByTargetId(param1);
      }
      
      private function onDie(param1:FighterEvent) : void
      {
         GameCtrl.I.onFighterDie(param1.fighter as FighterMain);
      }
   }
}

