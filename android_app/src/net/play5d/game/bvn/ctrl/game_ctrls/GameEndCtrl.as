package net.play5d.game.bvn.ctrl.game_ctrls
{
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.StateCtrl;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.GameRunDataVO;
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.fight.FightUI;
   
   public class GameEndCtrl
   {
      public static var SHOW_CONTINUE:Boolean = false;
      
      private var _winner:FighterMain;
      
      private var _loser:FighterMain;
      
      private var _step:int;
      
      private var _isRender:Boolean;
      
      private var _holdFrame:int;
      
      private var _drawGame:Boolean;
      
      public function GameEndCtrl()
      {
         super();
      }
      
      public function initlize(param1:FighterMain, param2:FighterMain) : void
      {
         GameCtrl.I.gameRunData.setAllowLoseHP(false);
         _winner = param1;
         _loser = param2;
         _step = 0;
         _isRender = true;
      }
      
      public function drawGame() : void
      {
         GameCtrl.I.gameRunData.setAllowLoseHP(false);
         _drawGame = true;
         _step = 0;
         _isRender = true;
      }
      
      public function destory() : void
      {
         _winner = null;
         _loser = null;
      }
      
      public function render() : Boolean
      {
         if(!_isRender)
         {
            return false;
         }
         if(_holdFrame-- > 0)
         {
            return false;
         }
         if(_drawGame)
         {
            return renderDrawGame();
         }
         return renderEND();
      }
      
      private function renderDrawGame() : Boolean
      {
         switch(_step)
         {
            case 0:
               GameUI.I.getUI().showEnd(function():void
               {
                  _holdFrame = 0;
               },{"drawGame":true});
               _step = 1;
               _holdFrame = 10 * GameConfig.FPS_GAME;
               break;
            case 1:
               _step = 2;
               _holdFrame = 1 * GameConfig.FPS_GAME;
               if(SHOW_CONTINUE)
               {
                  _holdFrame = 600 * GameConfig.FPS_GAME;
                  (GameUI.I.getUI() as FightUI).showContinue(function():void
                  {
                     _holdFrame = 0;
                  });
               }
               break;
            default:
               break;
            case 2:
               _isRender = false;
               GameUI.I.getUI().clearStartAndEnd();
               return true;
         }
         return false;
      }
      
      private function renderEND() : Boolean
      {
         var rundata:GameRunDataVO;
         var winner:FighterMain;
         var timeRate:Number;
         var addHPMax:int;
         var addHP:int;
         switch(_step)
         {
            case 0:
               GameUI.I.getUI().showEnd(function():void
               {
                  _holdFrame = 0;
               },{
                  "winner":_winner,
                  "loser":_loser
               });
               _step = 1;
               _holdFrame = 10 * GameConfig.FPS_GAME;
               break;
            case 1:
               if(!FighterActionState.isAllowWinState(_winner.actionState))
               {
                  return false;
               }
               _winner.win();
               _holdFrame = 3 * GameConfig.FPS_GAME;
               _step = 2;
               rundata = GameCtrl.I.gameRunData;
               winner = rundata.lastWinner;
               if(GameMode.isTeamMode() || GameMode.currentMode == 30)
               {
                  timeRate = rundata.gameTime == -1 ? 1 : rundata.gameTime / rundata.gameTimeMax;
                  addHPMax = winner.hpMax * 0.2;
                  addHP = addHPMax * timeRate;
                  if(addHP < winner.hpMax * 0.05)
                  {
                     addHP = winner.hpMax * 0.05;
                  }
                  winner.hp += addHP;
               }
               rundata.lastWinnerHp = winner.hp;
               if(SHOW_CONTINUE)
               {
                  _holdFrame = 600 * GameConfig.FPS_GAME;
                  (GameUI.I.getUI() as FightUI).showContinue(function():void
                  {
                     _holdFrame = 0;
                  });
               }
               break;
            case 2:
               _step = 22;
               _winner = null;
               _loser = null;
               StateCtrl.I.transIn(function():void
               {
                  _step = 3;
               },false);
               break;
            default:
               break;
            case 3:
               _isRender = false;
               GameUI.I.getUI().clearStartAndEnd();
               GameUI.I.getUI().fadOut(false);
               return true;
         }
         return false;
      }
      
      public function skip() : void
      {
         if(SHOW_CONTINUE)
         {
            return;
         }
         if(_step == 2)
         {
            _holdFrame = 0;
         }
      }
   }
}

