package net.play5d.game.bvn.ui.mosou
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.ui.ContinueBtn;
   import net.play5d.game.bvn.ui.IGameUI;
   import net.play5d.game.bvn.ui.MosouPauseDialog;
   import net.play5d.game.bvn.ui.fight.HitsUI;
   import net.play5d.game.bvn.ui.mosou.enemy.BossHpUI;
   import net.play5d.game.bvn.ui.mosou.enemy.EnemyHpUIGroup;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.utils.KyoTimeout;
   
   public class MosouUI implements IGameUI
   {
      private var _ui:MovieClip;
      
      private var _hpbar:MosouFightBarUI;
      
      private var _bossHpBar:BossHpUI;
      
      private var _enemyHpBarGroup:EnemyHpUIGroup;
      
      private var _timeUI:MosouTimeUI;
      
      private var _waveUI:MosouWaveUI;
      
      private var _KOUI:MousouKOsUI;
      
      private var _startAndKoMc:MovieClip;
      
      private var _startAndKoPos:Point;
      
      private var _hitsUI:HitsUI;
      
      private var _bosses:Vector.<FighterMain> = new Vector.<FighterMain>();
      
      private var _pauseDialog:MosouPauseDialog;
      
      public function MosouUI()
      {
         super();
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.mosou,"ui_mosou") as MovieClip;
         _hpbar = new MosouFightBarUI(_ui.hpbarmc);
         _bossHpBar = new BossHpUI(_ui.bosshp_mc);
         _bossHpBar.enabled(false);
         _timeUI = new MosouTimeUI(_ui.time_mc);
         _waveUI = new MosouWaveUI(_ui.wave_mc);
         _KOUI = new MousouKOsUI(_ui.kos_mc);
         _hitsUI = new HitsUI(_ui.hitsmc);
         _startAndKoMc = _ui.getChildByName("startKOmc") as MovieClip;
         _startAndKoPos = new Point(_startAndKoMc.x,_startAndKoMc.y);
         _enemyHpBarGroup = new EnemyHpUIGroup(_ui.ct_enemybar);
      }
      
      public function initlize(param1:GameRunFighterGroup) : void
      {
         _hpbar.setFighter(param1);
      }
      
      public function updateFighter() : void
      {
         _hpbar.updateFighters();
      }
      
      public function setBossHp(param1:FighterMain) : void
      {
         if(param1 != null)
         {
            if(_bosses.indexOf(param1) == -1)
            {
               _bosses.push(param1);
            }
            _enemyHpBarGroup.removeByFighter(param1);
            for each(var b:FighterMain in _bosses)
            {
               if(b != param1)
               {
                  _enemyHpBarGroup.updateFighter(b);
               }
            }
         }
         _bossHpBar.setFighter(param1);
      }
      
      public function updateBossHp() : void
      {
         var _loc2_:int = 0;
         for each(var b:FighterMain in _bosses)
         {
            if(!b.isAlive || !b.getActive())
            {
               _loc2_ = int(_bosses.indexOf(b));
               if(_loc2_ != -1)
               {
                  _bosses.splice(_loc2_,1);
               }
            }
         }
         if(_bosses.length < 1)
         {
            setBossHp(null);
         }
         else
         {
            setBossHp(_bosses[0]);
         }
      }
      
      public function setVolume(param1:Number) : void
      {
      }
      
      public function destory() : void
      {
         if(_pauseDialog)
         {
            _pauseDialog.destory();
            _pauseDialog = null;
         }
      }
      
      public function fadIn(param1:Boolean = true) : void
      {
      }
      
      public function fadOut(param1:Boolean = true) : void
      {
      }
      
      public function getUI() : DisplayObject
      {
         return _ui;
      }
      
      public function render() : void
      {
         _hpbar.render();
         _bossHpBar.render();
         _enemyHpBarGroup.render();
      }
      
      public function renderAnimate() : void
      {
         _hpbar.renderAnimate();
         _timeUI.renderAnimate();
         _waveUI.renderAnimate();
         renderStartAndKO();
      }
      
      private function renderStartAndKO() : void
      {
         if(!_startAndKoMc)
         {
            return;
         }
         var _loc1_:String = _startAndKoMc.currentFrameLabel;
         if(_loc1_)
         {
            if(_loc1_ == "stop")
            {
               return;
            }
            if(_loc1_.indexOf("go:") != -1)
            {
               playStartKO(_loc1_.split("go:")[1],false);
               return;
            }
         }
         _startAndKoMc.nextFrame();
      }
      
      public function showHits(param1:int, param2:int) : void
      {
         _hitsUI.show(param1);
      }
      
      public function hideHits(param1:int) : void
      {
         _hitsUI.hide();
      }
      
      public function updateKONum() : void
      {
         _KOUI.update();
      }
      
      private function playStartKO(param1:Object, param2:Boolean, param3:Point = null, param4:Number = 1) : void
      {
         if(param3)
         {
            _startAndKoMc.x = _startAndKoPos.x + param3.x;
            _startAndKoMc.y = _startAndKoPos.y + param3.y;
         }
         else
         {
            _startAndKoMc.x = _startAndKoPos.x;
            _startAndKoMc.y = _startAndKoPos.y;
         }
         _startAndKoMc.scaleX = _startAndKoMc.scaleY = param4;
         if(param2)
         {
            _startAndKoMc.gotoAndPlay(param1);
         }
         else
         {
            _startAndKoMc.gotoAndStop(param1);
         }
      }
      
      public function showStart(param1:Function = null, param2:Object = null) : void
      {
         var finishBack:Function = param1;
         var params:Object = param2;
         var completeHandler:* = function(param1:Event):void
         {
            _startAndKoMc.removeEventListener("complete",completeHandler);
            if(finishBack != null)
            {
               finishBack();
            }
         };
         trace("Mosou Start!!");
         playStartKO("mission_start",false);
         _startAndKoMc.addEventListener("complete",completeHandler);
      }
      
      public function showEnd(param1:Function = null, param2:Object = null) : void
      {
         trace("Mosou End!!");
      }
      
      public function showBossIn(param1:Function = null) : void
      {
         var finishBack:Function = param1;
         var completeHandler:* = function(param1:Event):void
         {
            _startAndKoMc.removeEventListener("complete",completeHandler);
            if(finishBack != null)
            {
               finishBack();
            }
         };
         playStartKO("boss_in",false);
         _startAndKoMc.addEventListener("complete",completeHandler);
      }
      
      public function showBossKO(param1:FighterMain, param2:Function = null) : void
      {
         var bsKO:Boolean;
         var p1:FighterMain;
         var boss:FighterMain = param1;
         var finishBack:Function = param2;
         var playKO2:* = function():void
         {
            _startAndKoMc.addEventListener("complete",koBack);
            playStartKO("boss_ko",false);
            SoundCtrl.I.playSwcSound(bsKO ? snd_ko_bs : snd_ko);
         };
         var koBack:* = function(param1:Event):void
         {
            EffectCtrl.I.freezeEnabled = true;
            GameCtrl.I.resume();
            if(finishBack != null)
            {
               finishBack();
            }
         };
         EffectCtrl.I.doEffectById("hit_end",boss.x,boss.y);
         EffectCtrl.I.shine(16777215,0.5);
         GameCtrl.I.gameState.cameraFocusOne(boss.getDisplay());
         EffectCtrl.I.freezeEnabled = false;
         GameCtrl.I.pause();
         bsKO = false;
         p1 = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
         if(p1.actionState == 12 || p1.actionState == 13)
         {
            bsKO = true;
            EffectCtrl.I.BGEffect("kobg",2);
         }
         EffectCtrl.I.slowDown(2,5000);
         EffectCtrl.I.shake(5,0,1.5);
         SoundCtrl.I.playSwcSound(snd_over_hit);
         KyoTimeout.setTimeout(playKO2,1000);
      }
      
      public function showWin(param1:Function = null) : void
      {
         var p1:FighterMain;
         var finishBack:Function = param1;
         var completeHandler:* = function(param1:Event):void
         {
            _startAndKoMc.removeEventListener("complete",completeHandler);
            if(GameConfig.SHOW_UI_STATUS == 1)
            {
               showContinue(finishBack);
            }
            else if(finishBack != null)
            {
               KyoTimeout.setTimeout(finishBack,4000);
            }
         };
         var offset:Point = GameConfig.SHOW_UI_STATUS == 1 ? new Point(0,-50) : null;
         var scale:Number = GameConfig.SHOW_UI_STATUS == 1 ? 0.8 : 1;
         playStartKO("mission_complete",false,offset);
         _startAndKoMc.addEventListener("complete",completeHandler);
         p1 = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
         GameCtrl.I.gameState.cameraFocusOne(p1.getDisplay());
         KyoTimeout.setTimeout(p1.win,1000);
      }
      
      private function showContinue(param1:Function) : void
      {
         var btn:ContinueBtn;
         var onClick:Function = param1;
         var onBtnClick:* = function(param1:ContinueBtn):void
         {
            onClick();
            param1.destory();
            try
            {
               _ui.removeChild(param1);
            }
            catch(e:Error)
            {
            }
         };
         if(!_ui)
         {
            return;
         }
         btn = new ContinueBtn();
         btn.x = 300;
         btn.y = 500;
         btn.onClick(onBtnClick);
         _ui.addChild(btn);
      }
      
      public function showLose(param1:Function = null) : void
      {
         var finishBack:Function = param1;
         var completeHandler:* = function(param1:Event):void
         {
            _startAndKoMc.removeEventListener("complete",completeHandler);
            if(GameConfig.SHOW_UI_STATUS == 1)
            {
               showContinue(finishBack);
            }
            else if(finishBack != null)
            {
               KyoTimeout.setTimeout(finishBack,3000);
            }
         };
         var offset:Point = GameConfig.SHOW_UI_STATUS == 1 ? new Point(-160,60) : null;
         var scale:Number = GameConfig.SHOW_UI_STATUS == 1 ? 0.7 : 1;
         playStartKO("mission_fail",false,offset,scale);
         _startAndKoMc.addEventListener("complete",completeHandler);
      }
      
      public function clearStartAndEnd() : void
      {
      }
      
      public function pause() : void
      {
         if(!_pauseDialog)
         {
            _pauseDialog = new MosouPauseDialog();
            _ui.addChild(_pauseDialog);
         }
         _pauseDialog.show();
      }
      
      public function resume() : Boolean
      {
         if(!_pauseDialog)
         {
            return true;
         }
         return _pauseDialog.hide();
      }
   }
}

