package net.play5d.game.bvn.ctrl.game_ctrls
{
   import flash.display.Sprite;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.ctrl.StateCtrl;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.state.GameState;
   import net.play5d.game.bvn.ui.GameUI;
   
   public class GameStartCtrl
   {
      private var _state:GameState;
      
      private var _p1:FighterMain;
      
      private var _p2:FighterMain;
      
      private var _p1_1:FighterMain;
      
      private var _p2_2:FighterMain;
      
      private var _isStart1v1:Boolean;
      
      private var _isStart2v2:Boolean;
      
      private var _isStartNextRound:Boolean;
      
      private var _isStartMosou:Boolean;
      
      private var _step:int;
      
      private var _holdFrame:int;
      
      private var _uiPlaying:Boolean;
      
      private var _introTeamId:int = -1;
      
      private var _mousouFinish:Boolean = false;
      
      private var _playP1Intro:Boolean = true;
      
      private var _playP2Intro:Boolean = true;
      
      private var _p1IntroStarted:Boolean = false;
      
      private var _p2IntroStarted:Boolean = false;
      
      private var _introLetterboxTop:Sprite;
      
      private var _introLetterboxBottom:Sprite;
      
      private var _introLetterboxCurrentHeight:Number = 0;
      
      private var _introLetterboxTargetHeight:Number = 0;
      
      private var _introLetterboxMaxHeight:Number = 0;
      
      public function GameStartCtrl(param1:GameState)
      {
         super();
         _state = param1;
      }
      
      public function destory() : void
      {
         setFightUIVisible(true);
         removeIntroLetterbox();
         _p1 = null;
         _p2 = null;
         _p1_1 = null;
         _p2_2 = null;
         _state = null;
      }
      
      public function render() : Boolean
      {
         renderIntroLetterbox();
         if(_isStart1v1)
         {
            return renderStart1v1();
         }
         if(_isStart2v2)
         {
            return renderStart2v2();
         }
         if(_isStartNextRound)
         {
            return renderNextRound();
         }
         if(_isStartMosou)
         {
            return renderStartMosou();
         }
         return false;
      }
      
      private function renderStartMosou() : Boolean
      {
         return _mousouFinish;
      }
      
      public function start1v1(player1:FighterMain, player2:FighterMain, introTeamId:int = -1) : void
      {
         _p1 = player1;
         _p2 = player2;
         _p1_1 = null;
         _p2_2 = null;
         _isStart1v1 = true;
         _introTeamId = introTeamId;
         _playP1Intro = shouldPlayIntroForTeam(1);
         _playP2Intro = shouldPlayIntroForTeam(2);
         _p1IntroStarted = false;
         _p2IntroStarted = false;
         switch(introTeamId - 1)
         {
            case 0:
               SoundCtrl.I.smartPlayGameBGM(player1.data.id);
               break;
            case 1:
               SoundCtrl.I.smartPlayGameBGM(player2.data.id);
               break;
            default:
               SoundCtrl.I.smartPlayGameBGM(player2.data.id);
         }
         preRenderStart();
      }
      
      public function start2v2(player1:FighterMain, player1Sub:FighterMain, player2:FighterMain, player2Sub:FighterMain, introTeamId:int = -1) : void
      {
         _p1 = player1;
         _p1_1 = player1Sub;
         _p2 = player2;
         _p2_2 = player2Sub;
         _isStart2v2 = true;
         _introTeamId = introTeamId;
         _p1IntroStarted = false;
         _p2IntroStarted = false;
         switch(introTeamId - 1)
         {
            case 0:
               SoundCtrl.I.smartPlayGameBGM(player1.data.id);
               SoundCtrl.I.smartPlayGameBGM(player1Sub.data.id);
               break;
            case 1:
               SoundCtrl.I.smartPlayGameBGM(player2.data.id);
               SoundCtrl.I.smartPlayGameBGM(player2Sub.data.id);
               break;
            default:
               SoundCtrl.I.smartPlayGameBGM(player2.data.id);
               SoundCtrl.I.smartPlayGameBGM(player2Sub.data.id);
         }
         preRenderStart();
      }
      
      public function startMosou() : void
      {
         _isStartMosou = true;
         _mousouFinish = false;
         setIntroLetterboxVisible(false,true);
         GameUI.I.getUI().showStart(function():void
         {
            _mousouFinish = true;
         });
      }
      
      private function preRenderStart() : void
      {
         setIntroFightersVisible(false);
         setFightUIVisible(false);
         setIntroLetterboxVisible(true,false);
         _step = -1;
         StateCtrl.I.transOut(function():void
         {
            _step = 0;
         },true);
      }
      
      private function shouldPlayIntroForTeam(teamId:int) : Boolean
      {
         return _introTeamId == -1 || _introTeamId == teamId;
      }
      
      private function holdSeconds(seconds:Number) : void
      {
         _holdFrame = int(seconds * GameConfig.FPS_GAME);
         if(_holdFrame < 1)
         {
            _holdFrame = 1;
         }
      }
      
      private function isIntroPlaying(fighter:FighterMain) : Boolean
      {
         return fighter != null && fighter.actionState == 60;
      }
      
      private function refreshFaceDirection() : void
      {
         if(_p1 == null || _p2 == null)
         {
            return;
         }
         _p1.direct = _p1.x <= _p2.x ? 1 : -1;
         _p2.direct = _p2.x >= _p1.x ? -1 : 1;
      }
      
      private function focusFaceoff() : void
      {
         _state.cameraResume();
         if(_state.camera)
         {
            _state.camera.tweenSpd = 2;
         }
      }
      
      private function renderStart1v1() : Boolean
      {
         if(_uiPlaying)
         {
            return false;
         }
         if(_holdFrame-- > 0)
         {
            return false;
         }
         refreshFaceDirection();
         switch(_step)
         {
            case 0:
               focusFaceoff();
               holdSeconds(0.18);
               _step = 1;
               break;
            case 1:
               if(_playP1Intro)
               {
                  setFighterVisible(_p1,true);
                  _state.cameraFocusOne(_p1.getDisplay());
                  _p1.sayIntro();
                  _p1IntroStarted = true;
                  _step = 2;
               }
               else
               {
                  setFighterVisible(_p1,true);
                  _step = 3;
               }
               break;
            case 2:
               if(_p1IntroStarted && isIntroPlaying(_p1))
               {
                  return false;
               }
               holdSeconds(0.08);
               _step = 3;
               break;
            case 3:
               if(_playP2Intro)
               {
                  setFighterVisible(_p2,true);
                  _state.cameraFocusOne(_p2.getDisplay());
                  _p2.sayIntro();
                  _p2IntroStarted = true;
                  _step = 4;
               }
               else
               {
                  setFighterVisible(_p2,true);
                  _step = 5;
               }
               break;
            case 4:
               if(_p2IntroStarted && isIntroPlaying(_p2))
               {
                  return false;
               }
               holdSeconds(0.08);
               _step = 5;
               break;
            case 5:
               focusFaceoff();
               holdSeconds(0.14);
               _step = 6;
               break;
            case 6:
               setIntroFightersVisible(true);
               setFightUIVisible(true);
               setIntroLetterboxVisible(false,false);
               _uiPlaying = true;
               _state.gameUI.getUI().showStart(function():void
               {
                  _uiPlaying = false;
               });
               _step = 7;
               break;
            case 7:
               _p1 = null;
               _p2 = null;
               return true;
         }
         return false;
      }
      
      private function renderStart2v2() : Boolean
      {
         if(_uiPlaying)
         {
            return false;
         }
         if(_holdFrame-- > 0)
         {
            return false;
         }
         switch(_step)
         {
            case 0:
               focusFaceoff();
               holdSeconds(0.16);
               _step = 1;
               break;
            case 1:
               setIntroFightersVisible(true);
               _p1.sayIntro();
               _p2.sayIntro();
               _p1_1.sayIntro();
               _p2_2.sayIntro();
               _step = 2;
               break;
            case 2:
               if(isIntroPlaying(_p1) || isIntroPlaying(_p1_1) || isIntroPlaying(_p2) || isIntroPlaying(_p2_2))
               {
                  return false;
               }
               focusFaceoff();
               holdSeconds(0.1);
               _step = 3;
               break;
            case 3:
               _state.cameraResume();
               holdSeconds(0.06);
               _step = 4;
               break;
            case 4:
               setIntroFightersVisible(true);
               setFightUIVisible(true);
               setIntroLetterboxVisible(false,false);
               _uiPlaying = true;
               _state.gameUI.getUI().showStart(function():void
               {
                  _uiPlaying = false;
               });
               _step = 5;
               break;
            case 5:
               _p1 = null;
               _p1_1 = null;
               _p2 = null;
               _p2_2 = null;
               return true;
         }
         return false;
      }
      
      public function startNextRound() : void
      {
         _isStartNextRound = true;
         _uiPlaying = true;
         setFightUIVisible(true);
         setIntroLetterboxVisible(false,true);
         StateCtrl.I.transOut(null,true);
         _state.gameUI.getUI().showStart(function():void
         {
            _uiPlaying = false;
         });
      }
      
      public function skip() : void
      {
         if(_isStart1v1)
         {
            if(_step < 6)
            {
               StateCtrl.I.quickTrans();
               _state.cameraResume();
               _uiPlaying = false;
               _step = 7;
               _state.gameUI.getUI().fadIn(true);
               _p1.idle();
               _p2.idle();
               setIntroFightersVisible(true);
               _holdFrame = 0.5 * GameConfig.FPS_GAME;
               setFightUIVisible(true);
               setIntroLetterboxVisible(false,true);
            }
         }
         if(_isStart2v2)
         {
            if(_step < 4)
            {
               StateCtrl.I.quickTrans();
               _state.cameraResume();
               _uiPlaying = false;
               _step = 5;
               _state.gameUI.getUI().fadIn(true);
               _p1.idle();
               _p1_1.idle();
               _p2.idle();
               _p2_2.idle();
               setIntroFightersVisible(true);
               _holdFrame = 0.5 * GameConfig.FPS_GAME;
               setFightUIVisible(true);
               setIntroLetterboxVisible(false,true);
            }
         }
         if(_isStartNextRound)
         {
         }
      }
      
      private function setIntroLetterboxVisible(showLetterbox:Boolean, immediately:Boolean) : void
      {
         if(showLetterbox)
         {
            ensureIntroLetterbox();
            _introLetterboxTargetHeight = _introLetterboxMaxHeight;
         }
         else
         {
            _introLetterboxTargetHeight = 0;
         }
         if(immediately)
         {
            _introLetterboxCurrentHeight = _introLetterboxTargetHeight;
            drawIntroLetterbox();
         }
      }
      
      private function setFighterVisible(fighter:FighterMain, visible:Boolean) : void
      {
         if(fighter == null)
         {
            return;
         }
         var fighterDisplay:Object = fighter.getDisplay();
         if(fighterDisplay != null)
         {
            fighterDisplay.visible = visible;
         }
      }
      
      private function setIntroFightersVisible(visible:Boolean) : void
      {
         setFighterVisible(_p1,visible);
         setFighterVisible(_p2,visible);
         setFighterVisible(_p1_1,visible);
         setFighterVisible(_p2_2,visible);
      }
      
      private function ensureIntroLetterbox() : void
      {
         if(_state == null)
         {
            return;
         }
         if(_introLetterboxTop == null)
         {
            _introLetterboxTop = new Sprite();
            _introLetterboxTop.mouseChildren = false;
            _introLetterboxTop.mouseEnabled = false;
         }
         if(_introLetterboxBottom == null)
         {
            _introLetterboxBottom = new Sprite();
            _introLetterboxBottom.mouseChildren = false;
            _introLetterboxBottom.mouseEnabled = false;
         }
         if(!_state.contains(_introLetterboxTop))
         {
            _state.addChild(_introLetterboxTop);
         }
         if(!_state.contains(_introLetterboxBottom))
         {
            _state.addChild(_introLetterboxBottom);
         }
         _introLetterboxMaxHeight = Math.max(38,int(GameConfig.GAME_SIZE.y * 0.13));
      }
      
      private function renderIntroLetterbox() : void
      {
         if(_introLetterboxTop == null || _introLetterboxBottom == null)
         {
            return;
         }
         var heightDiff:Number = _introLetterboxTargetHeight - _introLetterboxCurrentHeight;
         if(Math.abs(heightDiff) <= 0.4)
         {
            if(_introLetterboxCurrentHeight != _introLetterboxTargetHeight)
            {
               _introLetterboxCurrentHeight = _introLetterboxTargetHeight;
               drawIntroLetterbox();
            }
            return;
         }
         _introLetterboxCurrentHeight += heightDiff * 0.32;
         drawIntroLetterbox();
      }
      
      private function drawIntroLetterbox() : void
      {
         if(_introLetterboxTop == null || _introLetterboxBottom == null)
         {
            return;
         }
         var barHeight:Number = _introLetterboxCurrentHeight;
         var gameWidth:Number = GameConfig.GAME_SIZE.x;
         var gameHeight:Number = GameConfig.GAME_SIZE.y;
         _introLetterboxTop.graphics.clear();
         _introLetterboxBottom.graphics.clear();
         if(barHeight <= 0.5)
         {
            _introLetterboxTop.visible = false;
            _introLetterboxBottom.visible = false;
            return;
         }
         _introLetterboxTop.visible = true;
         _introLetterboxBottom.visible = true;
         _introLetterboxTop.y = 0;
         _introLetterboxTop.graphics.beginFill(0,1);
         _introLetterboxTop.graphics.drawRect(0,0,gameWidth,barHeight);
         _introLetterboxTop.graphics.endFill();
         _introLetterboxBottom.y = gameHeight - barHeight;
         _introLetterboxBottom.graphics.beginFill(0,1);
         _introLetterboxBottom.graphics.drawRect(0,0,gameWidth,barHeight);
         _introLetterboxBottom.graphics.endFill();
      }
      
      private function removeIntroLetterbox() : void
      {
         if(_introLetterboxTop && _introLetterboxTop.parent)
         {
            _introLetterboxTop.parent.removeChild(_introLetterboxTop);
         }
         if(_introLetterboxBottom && _introLetterboxBottom.parent)
         {
            _introLetterboxBottom.parent.removeChild(_introLetterboxBottom);
         }
         _introLetterboxTop = null;
         _introLetterboxBottom = null;
         _introLetterboxCurrentHeight = 0;
         _introLetterboxTargetHeight = 0;
         _introLetterboxMaxHeight = 0;
      }
      
      private function setFightUIVisible(visible:Boolean) : void
      {
         if(_state == null || _state.gameUI == null)
         {
            return;
         }
         var gameUIDisplay:Object = _state.gameUI.getUIDisplay();
         if(gameUIDisplay != null)
         {
            gameUIDisplay.visible = visible;
         }
      }
      
      private function renderNextRound() : Boolean
      {
         return _uiPlaying == false;
      }
   }
}

