package net.play5d.game.bvn.state
{
   import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.ctrl.StateCtrl;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.bitmap.BitmapFontText;
   import net.play5d.kyo.stage.Istage;
   import net.play5d.kyo.utils.KyoTimeout;
   
   public class GameOverState implements Istage
   {
      private var _ui:MovieClip;
      
      private var _arrow:MovieClip;
      
      private var _arrowSelected:String;
      
      private var _keyInited:Boolean;
      
      private var _keyEnabled:Boolean = true;
      
      private var _char:FighterMain;
      
      private var _btns:Array = [];
      
      public function GameOverState()
      {
         super();
         StateCtrl.I.clearTrans();
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.gameover,ResUtils.GAME_OVER);
         _ui.gotoAndStop(1);
      }
      
      public function showContinue() : void
      {
         _ui.addEventListener("complete",showContinueComplete,false,0,true);
         _ui.gotoAndPlay("continue");
         addChar();
         SoundCtrl.I.BGM(AssetManager.I.getSound("continue"));
      }
      
      private function showContinueComplete(param1:Event) : void
      {
         _ui.removeEventListener("complete",showContinueComplete);
         initBtn("btn_yes");
         initBtn("btn_no");
         initArrow("btn_yes");
      }
      
      private function initBtn(param1:String) : void
      {
         var _loc2_:Sprite = _ui.getChildByName(param1) as Sprite;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.buttonMode = true;
         _loc2_.addEventListener("mouseOver",btnMouseHandler);
         _loc2_.addEventListener("click",btnMouseHandler);
         _btns.push(_loc2_);
      }
      
      private function btnMouseHandler(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = param1.currentTarget as DisplayObject;
         switch(param1.type)
         {
            case "mouseOver":
               setArrow(_loc2_.name);
               break;
            case "click":
               _arrowSelected = _loc2_.name;
               selectHandler();
         }
      }
      
      private function render() : void
      {
         if(!_keyEnabled)
         {
            return;
         }
         if(GameInputer.left("MENU",1))
         {
            setArrow("btn_yes");
         }
         if(GameInputer.right("MENU",1))
         {
            setArrow("btn_no");
         }
         if(GameInputer.select("MENU",1))
         {
            selectHandler();
         }
      }
      
      private function selectHandler() : void
      {
         switch(_arrowSelected)
         {
            case "btn_yes":
               showContYes();
               break;
            case "btn_no":
               showContNo();
               break;
            case "btn_back":
               MainGame.I.goLogo();
         }
         SoundCtrl.I.sndConfrim();
      }
      
      private function initArrow(param1:String = null) : void
      {
         if(!_arrow)
         {
            _arrow = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui,"select_arrow_mc");
            _ui.addChild(_arrow);
         }
         if(param1)
         {
            setArrow(param1);
         }
         GameRender.add(render);
         GameInputer.focus();
         _keyEnabled = true;
      }
      
      private function removeArrow() : void
      {
         if(_arrow)
         {
            try
            {
               _ui.removeChild(_arrow);
            }
            catch(e:Error)
            {
            }
            _arrow = null;
         }
         _keyEnabled = false;
      }
      
      private function setArrow(param1:String) : void
      {
         _arrowSelected = param1;
         var _loc2_:DisplayObject = _ui.getChildByName(param1);
         if(_loc2_)
         {
            _arrow.x = _loc2_.x;
            _arrow.y = _loc2_.y;
            SoundCtrl.I.sndSelect();
         }
      }
      
      private function addChar() : void
      {
         var fighter:FighterMain = null;
         var charContainer:Sprite = _ui.getChildByName("ct_char") as Sprite;
         if(charContainer)
         {
            try
            {
               fighter = GameCtrl.I.gameRunData.continueLoser;
               if(fighter)
               {
                  fighter.scale = 3;
                  fighter.x = 0;
                  fighter.y = 0;
                  fighter.setVelocity(0,0);
                  fighter.setVec2(0,0);
                  fighter.isInAir = false;
                  fighter.isTouchBottom = true;
                  fighter.renderSelf();
                  fighter.lose();
                  charContainer.addChild(fighter.mc);
                  _char = fighter;
               }
            }
            catch(e:Error)
            {
               trace(e);
            }
         }
         else
         {
            KyoTimeout.setFrameout(addChar,2);
         }
      }
      
      private function showContYes() : void
      {
         _ui.addEventListener("complete",showContYesComplete,false,0,true);
         _ui.gotoAndPlay("continue_yes");
         _keyEnabled = false;
         try
         {
            _char.idle();
         }
         catch(e:Error)
         {
            trace(e);
         }
         removeArrow();
      }
      
      private function showContYesComplete(param1:Event) : void
      {
         _ui.removeEventListener("complete",showContYesComplete);
         GameLogic.loseScoreByContinue();
         MainGame.I.goSelect();
      }
      
      private function showContNo() : void
      {
         _ui.addEventListener("complete",showContNoComplete,false,0,true);
         _ui.gotoAndPlay("continue_no");
         removeArrow();
      }
      
      private function showContNoComplete(param1:Event) : void
      {
         _ui.removeEventListener("complete",showContNoComplete);
         showGameOver();
      }
      
      public function showGameOver() : void
      {
         _ui.addEventListener("complete",gameOverComplete,false,0,true);
         _ui.gotoAndPlay("gameover");
         SoundCtrl.I.playSwcSound(snd_gameover);
         SoundCtrl.I.BGM(null);
         addScore();
      }
      
      private function addScore() : void
      {
         var _loc2_:BitmapFontText = null;
         var _loc1_:Sprite = _ui.getChildByName("ct_score") as Sprite;
         if(_loc1_)
         {
            _loc2_ = new BitmapFontText(AssetManager.I.getFont("font1"));
            _loc2_.text = "SCORE " + GameData.I.score;
            _loc2_.x = -_loc2_.width / 2;
            _loc1_.addChild(_loc2_);
         }
         else
         {
            KyoTimeout.setFrameout(addScore,1);
         }
      }
      
      private function gameOverComplete(param1:Event) : void
      {
         _ui.removeEventListener("complete",gameOverComplete);
         GameEvent.dispatchEvent("GAME_OVER");
         initBtn("btn_back");
         initArrow("btn_back");
      }
      
      public function get display() : DisplayObject
      {
         return _ui;
      }
      
      public function build() : void
      {
      }
      
      public function afterBuild() : void
      {
         GameEvent.dispatchEvent("GAME_OVER_CONTINUE");
      }
      
      public function destory(param1:Function = null) : void
      {
         GameRender.remove(render);
         if(_btns)
         {
            for each(var   b:DisplayObject in _btns)
            {
               b.removeEventListener("mouseOver",btnMouseHandler);
               b.removeEventListener("click",btnMouseHandler);
            }
            _btns = null;
         }
         if(_char)
         {
            try
            {
               _char.mc.parent.removeChild(_char.mc);
            }
            catch(e:Error)
            {
            }
            _char = null;
         }
         GameCtrl.I.gameRunData.continueLoser = null;
         GameCtrl.I.destory();
      }
   }
}

