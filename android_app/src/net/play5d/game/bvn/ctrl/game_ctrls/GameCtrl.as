package net.play5d.game.bvn.ctrl.game_ctrls
{
   import flash.geom.ColorTransform;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.GameLoader;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.ctrl.mosou_ctrls.MosouCtrl;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.GameRunDataVO;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.data.MessionModel;
   import net.play5d.game.bvn.data.TeamMap;
   import net.play5d.game.bvn.data.TeamVO;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.factory.GameRunFactory;
   import net.play5d.game.bvn.fighter.FighterAttacker;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.ctrler.FighterAICtrl;
   import net.play5d.game.bvn.fighter.ctrler.FighterKeyCtrl;
   import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.game.bvn.map.MapMain;
   import net.play5d.game.bvn.state.GameState;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.utils.KeyBoarder;
   
   public class GameCtrl
   {
      private static var _i:GameCtrl;
      
      public var gameState:GameState;
      
      public const gameRunData:GameRunDataVO = new GameRunDataVO();
      
      public var actionEnable:Boolean = false;
      
      public var autoStartAble:Boolean = true;
      
      public var autoEndRoundAble:Boolean = true;
      
      private var _teamMap:TeamMap = new TeamMap();
      
      private var _startCtrl:GameStartCtrl;
      
      private var _fighterEventCtrl:FighterEventCtrl;
      
      private var _trainingCtrl:TrainingCtrler;
      
      private var _mainLogicCtrl:GameMainLogicCtrler;
      
      private var _endCtrl:GameEndCtrl;
      
      private var _mosouCtrl:MosouCtrl;
      
      private var _isRenderGame:Boolean = true;
      
      private var _isPauseGame:Boolean;
      
      private var _gameRunning:Boolean;
      
      private var _renderTimeFrame:int;
      
      private var _renderAnimateGap:int = 0;
      
      private var _renderAnimateFrame:int = 0;
      
      public var fightFinished:Boolean;
      
      private var _gameStartAndPause:Boolean;
      
      public var slowRate:Number = 0;
      
      public function GameCtrl()
      {
         super();
      }
      
      public static function get I() : GameCtrl
      {
         if(!_i)
         {
            _i = new GameCtrl();
         }
         return _i;
      }
      
      public function getAttacker(param1:String, param2:int) : FighterAttacker
      {
         if(_mosouCtrl)
         {
            return _mosouCtrl.getFighterEventCtrl().getAttacker(param1,param2);
         }
         return _fighterEventCtrl.getAttacker(param1,param2);
      }
      
      public function setRenderHit(param1:Boolean) : void
      {
         if(_mainLogicCtrl)
         {
            _mainLogicCtrl.renderHit = param1;
         }
      }
      
      public function getMosouCtrl() : MosouCtrl
      {
         return _mosouCtrl;
      }
      
      public function getTeamMap() : TeamMap
      {
         return _teamMap;
      }
      
      public function getFighterByData(param1:FighterVO) : FighterMain
      {
         return this.gameState.getFighterByData(param1);
      }
      
      public function initlize(param1:GameState) : void
      {
         this.gameState = param1;
         _isPauseGame = false;
         _isRenderGame = true;
         _gameRunning = true;
         _gameStartAndPause = false;
         if(!_mosouCtrl)
         {
            _fighterEventCtrl = new FighterEventCtrl();
            _fighterEventCtrl.initlize();
         }
         _renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / 30) - 1;
         KeyBoarder.focus();
      }
      
      private function renderPause() : void
      {
         if(_startCtrl || _endCtrl)
         {
            if(GameInputer.back(1) || GameInputer.select("MENU",1))
            {
               if(_startCtrl)
               {
                  _startCtrl.skip();
               }
               if(_endCtrl)
               {
                  _endCtrl.skip();
               }
            }
            return;
         }
         if(GameInputer.back(1))
         {
            if(GameUI.showingConfrim())
            {
               GameUI.cancelConfrim();
               return;
            }
            if(GameUI.showingAlert())
            {
               GameUI.closeAlert();
               return;
            }
            if(_isPauseGame)
            {
               resume(true);
            }
            else
            {
               pause(true);
            }
         }
      }
      
      public function destory() : void
      {
         GameRender.remove(render);
         GameLogic.clear();
         GameInputer.clearInput();
         if(_fighterEventCtrl)
         {
            _fighterEventCtrl.destory();
            _fighterEventCtrl = null;
         }
         if(_mainLogicCtrl)
         {
            _mainLogicCtrl.destory();
            _mainLogicCtrl = null;
         }
         if(_trainingCtrl)
         {
            _trainingCtrl.destory();
            _trainingCtrl = null;
         }
         if(_startCtrl)
         {
            _startCtrl.destory();
            _startCtrl = null;
         }
         if(_endCtrl)
         {
            _endCtrl.destory();
            _endCtrl = null;
         }
         if(gameState)
         {
            gameState = null;
         }
         if(_mosouCtrl)
         {
            _mosouCtrl.destory();
            _mosouCtrl = null;
         }
         gameRunData.p1FighterGroup.destory();
         gameRunData.p2FighterGroup.destory();
         gameRunData.clear();
         GameLoader.dispose();
         _gameRunning = false;
      }
      
      public function getEnemyTeam(param1:IGameSprite) : TeamVO
      {
         if(param1.team)
         {
            switch(param1.team.id - 1)
            {
               case 0:
                  return _teamMap.getTeam(2);
               case 1:
                  return _teamMap.getTeam(1);
            }
         }
         return null;
      }
      
      public function addGameSprite(param1:int, param2:IGameSprite, param3:int = -1) : void
      {
         if(param3 != -1)
         {
            gameState.addGameSpriteAt(param2,param3);
         }
         else
         {
            gameState.addGameSprite(param2);
         }
         var _loc4_:TeamVO = _teamMap.getTeam(param1);
         if(_loc4_)
         {
            param2.team = _loc4_;
            _loc4_.addChild(param2);
            if(param2 is FighterMain)
            {
               (param2 as FighterMain).targetTeams = _teamMap.getOtherTeams(param1);
            }
         }
         else
         {
            Debugger.log("GameCtrl.addGameSprite :: team is null!");
         }
      }
      
      public function removeGameSprite(param1:IGameSprite, param2:Boolean = false) : void
      {
         gameState.removeGameSprite(param1);
         var _loc3_:TeamVO = param1.team;
         if(_loc3_)
         {
            _loc3_.removeChild(param1);
         }
         param1.destory(param2);
      }
      
      public function startGame() : void
      {
         if(!autoStartAble)
         {
            return;
         }
         fightFinished = false;
         doStartGame();
      }
      
      public function startMosouGame() : void
      {
         if(!autoStartAble)
         {
            return;
         }
         fightFinished = false;
         _isPauseGame = false;
         GameInputer.enabled = true;
         initTeam();
         _mosouCtrl.buildGame();
         GameRender.add(render);
      }
      
      public function doStartGame() : void
      {
         _isPauseGame = false;
         GameInputer.enabled = true;
         gameRunData.reset();
         initTeam();
         buildGame();
         GameEvent.dispatchEvent("GAME_START");
         GameRender.add(render);
      }
      
      private function buildGame() : void
      {
         var _loc2_:ColorTransform = null;
         if(GameMode.currentMode == 24 || GameMode.currentMode == 25)
         {
            gameRunData.p1FighterGroup.currentFighter = GameRunFactory.createFighterByData(gameRunData.p1FighterGroup.fighter1,"1");
            gameRunData.p2FighterGroup.currentFighter = GameRunFactory.createFighterByData(gameRunData.p2FighterGroup.fighter1,"2");
            gameRunData.p2FighterGroup.nextFighter2 = GameRunFactory.createFighterByData(gameRunData.p2FighterGroup.fighter2,"2");
            var _loc8_:FighterMain = gameRunData.p2FighterGroup.nextFighter2;
         }
         else if(GameMode.currentMode == 14 || GameMode.currentMode == 15)
         {
            gameRunData.p1FighterGroup.currentFighter = GameRunFactory.createFighterByData(gameRunData.p1FighterGroup.fighter1,"1");
            gameRunData.p2FighterGroup.currentFighter = GameRunFactory.createFighterByData(gameRunData.p2FighterGroup.fighter1,"2");
            gameRunData.p1FighterGroup.nextFighter1 = GameRunFactory.createFighterByData(gameRunData.p1FighterGroup.fighter2,"1");
            gameRunData.p2FighterGroup.nextFighter2 = GameRunFactory.createFighterByData(gameRunData.p2FighterGroup.fighter2,"2");
            var _loc5_:FighterMain = gameRunData.p1FighterGroup.nextFighter1;
            _loc8_ = gameRunData.p2FighterGroup.nextFighter2;
         }
         else
         {
            gameRunData.p1FighterGroup.currentFighter = GameRunFactory.createFighterByData(gameRunData.p1FighterGroup.fighter1,"1");
            gameRunData.p2FighterGroup.currentFighter = GameRunFactory.createFighterByData(gameRunData.p2FighterGroup.fighter1,"2");
         }
         gameRunData.p1FighterGroup.currentAssister = GameRunFactory.createAssisterByData(gameRunData.p1FighterGroup.assister,"1");
         gameRunData.p2FighterGroup.currentAssister = GameRunFactory.createAssisterByData(gameRunData.p2FighterGroup.assister,"2");
         var _loc1_:FighterMain = gameRunData.p1FighterGroup.currentFighter;
         var _loc3_:FighterMain = gameRunData.p2FighterGroup.currentFighter;
         if(GameMode.currentMode == 40)
         {
            _trainingCtrl = new TrainingCtrler();
            _trainingCtrl.initlize([_loc1_,_loc3_]);
            gameRunData.gameTimeMax = -1;
         }
         var _loc4_:MapMain = GameRunFactory.createMapByData(gameRunData.map);
         if(!_loc1_ || !_loc3_ || !_loc4_)
         {
            throw new Error("创建游戏失败");
         }
         if(_loc1_.data.id == _loc3_.data.id)
         {
            _loc2_ = new ColorTransform();
            _loc2_.greenOffset = -85;
            _loc3_.colorTransform = _loc2_;
         }
         else
         {
            _loc3_.colorTransform = null;
         }
         addFighter(_loc1_,1);
         addFighter(_loc3_,2);
         if(GameMode.currentMode == 24 || GameMode.currentMode == 25)
         {
            addFighter(_loc8_,2);
         }
         if(GameMode.currentMode == 14 || GameMode.currentMode == 15)
         {
            addFighter(_loc5_,3);
            addFighter(_loc8_,2);
         }
         _loc4_.initlize();
         gameState.initFight(gameRunData.p1FighterGroup,gameRunData.p2FighterGroup,_loc4_);
         GameLogic.initGameLogic(_loc4_,gameState.camera);
         initMainLogic();
         if(GameMode.currentMode == 40)
         {
            actionEnable = true;
            GameUI.I.fadIn();
            SoundCtrl.I.smartPlayGameBGM("map");
         }
         if(GameMode.currentMode == 14 || GameMode.currentMode == 15)
         {
            initStart();
            _startCtrl.start2v2(_loc1_,_loc5_,_loc3_,_loc8_);
         }
         else
         {
            initStart();
            _startCtrl.start1v1(_loc1_,_loc3_);
         }
         GameInterface.instance.afterBuildGame();
      }
      
      public function addFighter(param1:FighterMain, param2:int) : void
      {
         var _loc3_:IFighterActionCtrl = null;
         if(!param1)
         {
            return;
         }
         switch(param2 - 1)
         {
            case 0:
               if(GameMode.isWatch())
               {
                  _loc3_ = createFighterAICtrl(param1);
                  break;
               }
               _loc3_ = createPlayerKeyCtrl("P1",param1);
               break;
            case 1:
               if(GameMode.isVsCPU(false) || GameMode.isAcrade())
               {
                  _loc3_ = createFighterAICtrl(param1);
                  break;
               }
               _loc3_ = createPlayerKeyCtrl("P2",param1);
               break;
            case 2:
               _loc3_ = createFighterAICtrl(param1);
         }
         if(param2 == 3)
         {
            param2 = 1;
         }
          if(gameState && gameState.getMap())
          {
             var currentMap:MapMain = gameState.getMap();
             var scX:Number = (currentMap && currentMap.stageCoord) ? currentMap.stageCoord.x : 640;
             var scY:Number = (currentMap && currentMap.stageCoord) ? currentMap.stageCoord.y : 360;
             param1.updateScale(currentMap.isJSONMap, scX, scY);
          }
         param1.initlize();
         param1.setActionCtrl(_loc3_);
         addGameSprite(param2,param1);
         FighterEventDispatcher.dispatchEvent(param1,"BIRTH");
      }

      private function createPlayerKeyCtrl(inputType:String, fighter:FighterMain) : IFighterActionCtrl
      {
         var keyCtrl:FighterKeyCtrl = new FighterKeyCtrl();
         keyCtrl.inputType = inputType;
         keyCtrl.classicMode = GameData.I.config.keyInputMode == 1;
         return keyCtrl;
      }
      
      private function createFighterAICtrl(fighter:FighterMain) : FighterAICtrl
      {
         var fighterAICtrl:FighterAICtrl = new FighterAICtrl();
         fighterAICtrl.AILevel = resolveFighterAILevel(fighter);
         fighterAICtrl.fighter = fighter;
         return fighterAICtrl;
      }
      
      private function resolveFighterAILevel(fighter:FighterMain) : int
      {
         var configuredLevel:int = 0;
         if(fighter && fighter.data && fighter.data.aiLevelOverride > 0)
         {
            return fighter.data.aiLevelOverride;
         }
         if(GameData.I && GameData.I.config)
         {
            configuredLevel = GameData.I.config.difficulty;
         }
         if(configuredLevel > 0)
         {
            return configuredLevel;
         }
         if(MessionModel.I && MessionModel.I.AI_LEVEL > 0)
         {
            return MessionModel.I.AI_LEVEL;
         }
         return 3;
      }
      
      public function removeFighter(param1:FighterMain, param2:Boolean = false) : void
      {
         if(!param1)
         {
            return;
         }
         removeGameSprite(param1,param2);
      }
      
      public function startNextRound() : void
      {
         doBuildNextRound(GameMode.isTeamMode());
      }
      
      private function buildNextRound(param1:Boolean) : void
      {
         doBuildNextRound(param1);
      }
      
      private function doBuildNextRound(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         gameState.resetFight(gameRunData.p1FighterGroup,gameRunData.p2FighterGroup);
         _startCtrl = new GameStartCtrl(gameState);
         if(param1)
         {
            if(gameRunData.lastWinner)
            {
               gameRunData.lastWinner.hp = gameRunData.lastWinnerHp;
            }
            _loc2_ = -1;
            if(gameRunData.lastWinnerTeam)
            {
               _loc2_ = gameRunData.lastWinnerTeam.id == 1 ? 2 : 1;
            }
            _startCtrl.start1v1(gameRunData.p1FighterGroup.currentFighter,gameRunData.p2FighterGroup.currentFighter,_loc2_);
         }
         else
         {
            _startCtrl.startNextRound();
         }
         gameRunData.isDrawGame = false;
         GameEvent.dispatchEvent("ROUND_START");
      }
      
      public function fightFinish() : void
      {
         fightFinished = true;
         if(GameMode.isAcrade())
         {
            if(gameRunData.lastWinnerTeam.id == 1)
            {
               if(MessionModel.I.missionAllComplete())
               {
                  trace("通关！");
                  MainGame.I.goCongratulations();
               }
               else
               {
                  trace("下一关");
                  GameData.I.winnerId = gameRunData.p1FighterGroup.currentFighter.data.id;
                  MainGame.I.goWinner();
               }
            }
            else
            {
               trace("跳转是否继续");
               gameRunData.continueLoser = gameRunData.p1FighterGroup.currentFighter;
               MainGame.I.goContinue();
            }
         }
         if(GameMode.isVsCPU() || GameMode.isVsPeople())
         {
            trace("返回选人");
            GameEvent.dispatchEvent("GAME_END");
            MainGame.I.goSelect();
         }
      }
      
      public function initStart() : GameStartCtrl
      {
         _startCtrl = new GameStartCtrl(GameCtrl.I.gameState);
         actionEnable = false;
         return _startCtrl;
      }
      
      public function initMainLogic() : void
      {
         _mainLogicCtrl = new GameMainLogicCtrler();
         _mainLogicCtrl.initlize(gameState,_teamMap);
      }
      
      private function initTeam() : void
      {
         _teamMap.clear();
         var _loc1_:Array = GameMode.getTeams();
         for each(var _loc2_:Object in _loc1_)
         {
            _teamMap.add(new TeamVO(_loc2_.id,_loc2_.name));
         }
      }
      
      public function pause(param1:Boolean = false) : void
      {
         if(!_gameRunning)
         {
            return;
         }
         if(param1 && !_isPauseGame)
         {
            if(_startCtrl || _endCtrl || _mosouCtrl && _mosouCtrl.getGameFinished())
            {
               _gameStartAndPause = true;
               return;
            }
            GameEvent.dispatchEvent("PAUSE_GAME");
            _isPauseGame = true;
            GameUI.I.getUI().pause();
         }
         _isRenderGame = false;
      }
      
      public function resume(param1:Boolean = false) : void
      {
         if(!_gameRunning)
         {
            return;
         }
         _gameStartAndPause = false;
         if(param1 && _isPauseGame)
         {
            if(GameUI.I.getUI().resume())
            {
               GameEvent.dispatchEvent("RESUME_GAME");
               _isPauseGame = false;
            }
         }
         KeyBoarder.focus();
         _isRenderGame = true;
      }
      
      public function gameEnd(param1:FighterMain, param2:FighterMain) : void
      {
         if(!autoEndRoundAble)
         {
            return;
         }
         if(_endCtrl)
         {
            return;
         }
         doGameEnd(param1,param2);
      }
      
      public function doGameEnd(param1:FighterMain, param2:FighterMain) : void
      {
         gameRunData.lastWinnerTeam = param1.team;
         gameRunData.lastWinner = param1;
         gameRunData.lastLoserData = param2.data;
         gameRunData.lastLoserQi = param2.qi;
         switch(param1.team.id - 1)
         {
            case 0:
               if(GameMode.currentMode == 24 || GameMode.currentMode == 14 || GameMode.currentMode == 15 || GameMode.currentMode == 25)
               {
                  var _loc4_:FighterMain = gameRunData.p2FighterGroup.currentFighter;
                  var _loc5_:FighterMain = gameRunData.p2FighterGroup.nextFighter2;
                  if(!(_loc4_.hp <= 0 && _loc5_.hp <= 0))
                  {
                     return;
                  }
                  gameRunData.p1Wins++;
               }
               else
               {
                  gameRunData.p1Wins++;
               }
               if(param2.hp <= 0 && GameMode.isAcrade())
               {
                  GameLogic.addScoreByKO();
               }
               break;
            case 1:
               if(GameMode.currentMode == 14 || GameMode.currentMode == 15)
               {
                  var _loc9_:FighterMain = gameRunData.p1FighterGroup.currentFighter;
                  var _loc3_:FighterMain = gameRunData.p1FighterGroup.nextFighter1;
                  if(!(_loc9_.hp <= 0 && _loc3_.hp <= 0))
                  {
                     return;
                  }
                  gameRunData.p2Wins++;
               }
               else
               {
                  gameRunData.p2Wins++;
               }
         }
         _endCtrl = new GameEndCtrl();
         _endCtrl.initlize(param1,param2);
         actionEnable = false;
         GameEvent.dispatchEvent("ROUND_END");
      }
      
      private function render() : void
      {
         var _loc2_:Boolean = false;
         var _loc1_:Boolean = false;
         renderPause();
         if(_isPauseGame)
         {
            return;
         }
         EffectCtrl.I.render();
         gameState.render();
         if(!_isRenderGame)
         {
            return;
         }
         checkRenderAnimate();
         if(_mainLogicCtrl)
         {
            _mainLogicCtrl.render();
         }
         if(_startCtrl)
         {
            actionEnable = false;
            _loc2_ = _startCtrl.render();
            if(_loc2_)
            {
               _startCtrl.destory();
               _startCtrl = null;
               actionEnable = true;
               gameRunData.setAllowLoseHP(true);
               if(_gameStartAndPause)
               {
                  pause(true);
                  _gameStartAndPause = false;
               }
            }
         }
         if(_endCtrl)
         {
            _loc1_ = _endCtrl.render();
            if(_loc1_)
            {
               _endCtrl.destory();
               _endCtrl = null;
               runNext();
            }
         }
         if(_trainingCtrl)
         {
            _trainingCtrl.render();
         }
         if(_mosouCtrl)
         {
            _mosouCtrl.render();
         }
      }
      
      private function checkRenderAnimate() : void
      {
         if(_renderAnimateGap > 0)
         {
            if(_renderAnimateFrame++ >= _renderAnimateGap)
            {
               _renderAnimateFrame = 0;
               renderAnimate();
            }
         }
         else
         {
            renderAnimate();
         }
      }
      
      private function renderAnimate() : void
      {
         if(_mainLogicCtrl)
         {
            _mainLogicCtrl.renderAnimate();
         }
         if(_mosouCtrl)
         {
            _mosouCtrl.renderAnimate();
         }
         if(actionEnable && !_startCtrl && !_endCtrl && !_mosouCtrl)
         {
            renderGameTime();
         }
      }
      
      private function renderGameTime() : void
      {
         if(gameRunData.gameTimeMax != -1)
         {
            if(++_renderTimeFrame > 30)
            {
               _renderTimeFrame = 0;
               gameRunData.gameTime--;
               if(gameRunData.gameTime <= 0)
               {
                  fightTimeover();
               }
            }
         }
      }
      
      private function fightTimeover() : void
      {
         trace("time over!!!");
         actionEnable = false;
         var _loc2_:FighterMain = gameRunData.p1FighterGroup.currentFighter;
         var _loc1_:FighterMain = gameRunData.p2FighterGroup.currentFighter;
         gameRunData.isTimerOver = true;
         if(_loc2_.hp == _loc1_.hp)
         {
            drawGame();
            return;
         }
         if(_loc2_.hp > _loc1_.hp)
         {
            gameEnd(_loc2_,_loc1_);
         }
         else
         {
            gameEnd(_loc1_,_loc2_);
         }
      }
      
      public function drawGame() : void
      {
         if(_endCtrl)
         {
            return;
         }
         gameRunData.lastWinnerTeam = null;
         gameRunData.lastWinner = null;
         gameRunData.isDrawGame = true;
         _endCtrl = new GameEndCtrl();
         _endCtrl.drawGame();
         actionEnable = false;
         GameEvent.dispatchEvent("ROUND_END");
      }
      
      private function runNext() : void
      {
         trace("GameMode.currentMode",GameMode.currentMode);
         gameRunData.nextRound();
         if(GameMode.isTeamMode())
         {
            if(startNextTeamFight())
            {
               buildNextRound(true);
               gameRunData.lastWinner = null;
               return;
            }
         }
         if(GameMode.isSingleMode())
         {
            if(gameRunData.p1Wins < 2 && gameRunData.p2Wins < 2)
            {
               buildNextRound(false);
               gameRunData.lastWinner = null;
               return;
            }
         }
         fightFinish();
      }
      
      private function startNextTeamFight() : Boolean
      {
         var _loc1_:FighterVO = null;
         var _loc2_:FighterVO = null;
         if(gameRunData.isDrawGame)
         {
            _loc1_ = gameRunData.p1FighterGroup.getNextFighter();
            _loc2_ = gameRunData.p2FighterGroup.getNextFighter();
            if(!_loc1_ && !_loc2_)
            {
               return true;
            }
            if(_loc1_ && !_loc2_)
            {
               gameRunData.lastWinnerTeam = gameRunData.p1FighterGroup.currentFighter.team;
               return false;
            }
            if(!_loc1_ && _loc2_)
            {
               gameRunData.lastWinnerTeam = gameRunData.p2FighterGroup.currentFighter.team;
               return false;
            }
            nextFighter(gameRunData.p1FighterGroup);
            nextFighter(gameRunData.p2FighterGroup);
            return true;
         }
         switch(gameRunData.lastWinnerTeam.id - 1)
         {
            case 0:
               return nextFighter(gameRunData.p2FighterGroup);
            case 1:
               return nextFighter(gameRunData.p1FighterGroup);
            default:
               gameRunData.lastWinnerTeam = null;
               return true;
         }
      }
      
      private function nextFighter(param1:GameRunFighterGroup) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         var _loc4_:TeamVO = param1.currentFighter.team;
         var _loc3_:FighterVO = param1.getNextFighter();
         if(!_loc3_)
         {
            return false;
         }
         var _loc2_:FighterMain = GameRunFactory.createFighterByData(_loc3_,_loc4_.id.toString());
         if(!_loc2_)
         {
            return false;
         }
         if(gameRunData.lastLoserData)
         {
            if(gameRunData.lastLoserData.comicType == _loc2_.data.comicType)
            {
               _loc2_.qi = gameRunData.lastLoserQi + 100;
               if(_loc2_.qi > _loc2_.qiMax)
               {
                  _loc2_.qi = _loc2_.qiMax;
               }
            }
         }
         removeFighter(param1.currentFighter,true);
         param1.currentFighter = _loc2_;
         addFighter(param1.currentFighter,_loc4_.id);
         return true;
      }
      
      public function slow(param1:Number) : void
      {
         slowRate = param1;
         var _loc2_:Number = 30 / param1;
         setAnimateFPS(_loc2_);
         _mainLogicCtrl.setSpeedPlus(GameConfig.SPEED_PLUS_DEFAULT / param1);
         gameState.camera.tweenSpd = 2.5 * param1;
      }
      
      public function slowResume() : void
      {
         slowRate = 0;
         setAnimateFPS(30);
         _mainLogicCtrl.setSpeedPlus(GameConfig.SPEED_PLUS_DEFAULT);
         gameState.camera.tweenSpd = 2.5;
      }
      
      private function setAnimateFPS(param1:Number) : void
      {
         _renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / param1) - 1;
         _renderAnimateFrame = 0;
      }
      
      public function onFighterDie(param1:FighterMain) : void
      {
         var _loc2_:FighterMain = null;
         var _loc4_:TeamVO = GameCtrl.I.getEnemyTeam(param1);
         if(_loc4_)
         {
            for each(var _loc3_:IGameSprite in _loc4_.children)
            {
               if(_loc3_ is FighterMain)
               {
                  _loc2_ = _loc3_ as FighterMain;
                  break;
               }
            }
         }
         GameCtrl.I.gameEnd(_loc2_,param1);
      }
      
      public function initMosouGame() : void
      {
         _mosouCtrl = new MosouCtrl();
         _mosouCtrl.initalize();
      }
   }
}

