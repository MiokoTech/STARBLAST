package net.play5d.game.bvn.ui.fight
{
   import com.greensock.TweenLite;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.fighter.FighterActionState;
   import net.play5d.game.bvn.data.fighter.FighterInputCmd;
   import net.play5d.game.bvn.data.fighter.FighterSpecialFrame;
   import net.play5d.game.bvn.fighter.FighterMC;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.events.FighterEvent;
   import net.play5d.game.bvn.input.GameInputType;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.kyo.display.bitmap.BitmapFont;
   import net.play5d.kyo.display.bitmap.BitmapFontText;

   /**
    * Training mode input history UI.
    */
   public class TrainingInputHistoryUI extends Sprite
   {
      private static const BASE_Y:Number = 490;
      private static const TOP_Y:Number = 150;
      private static const LINE_GAP:Number = 34;
      private static const MAX_LAYERS_CUT:int = 1;
      private static const MAX_ITEMS:int = int((BASE_Y - TOP_Y) / LINE_GAP) - MAX_LAYERS_CUT + 1;
      private static const TEXT_SCALE:Number = 0.7;
      private static const MOVE_TIME:Number = 0.12;
      private static const FADE_TIME:Number = 0.5;
      private static const IDLE_HOLD_SEC:Number = 1;
      private static const COMBO_SEP:String = "-";
      private static const ATTACK_CHAR:String = FighterSpecialFrame.ATTACK.charAt(0);
      private static const SKILL_PREFIX:String = FighterSpecialFrame.SKILL_1.substr(0,2);
      private static const HIGHLIGHT_CT:ColorTransform = new ColorTransform(1,1,1,1,50,-30,-30,0);

      private static const ACTION_TEXT:Object = buildActionText();

      private var _inputType:String;
      private var _alignRight:Boolean;
      private var _font:BitmapFont;
      private var _items:Vector.<BitmapFontText>;
      private var _prevLeft:Boolean;
      private var _prevRight:Boolean;
      private var _idleHoldFrames:int;
      private var _idleHoldTimer:int;
      private var _boundFighter:FighterMain;
      private var _pushedThisFrame:Boolean;
      private var _prevActionState:int = -1;
      private var _comboOpen:Boolean;

      public function TrainingInputHistoryUI(param1:String, param2:Boolean = false)
      {
         super();
         _inputType = param1;
         _alignRight = param2;
         mouseEnabled = mouseChildren = false;

         _font = AssetManager.I.getFont("font1");
         _items = new Vector.<BitmapFontText>();
         _idleHoldFrames = IDLE_HOLD_SEC * GameConfig.FPS_GAME;
         _idleHoldTimer = 0;
         _prevLeft = false;
         _prevRight = false;
         _pushedThisFrame = false;
         _comboOpen = false;
      }

      private static function buildActionText() : Object
      {
         var map:Object = {};
         map[FighterSpecialFrame.SKILL_1] = FighterInputCmd.SKILL_1;
         map[FighterSpecialFrame.SKILL_2] = FighterInputCmd.SKILL_2;
         map[FighterSpecialFrame.ZHAO_1] = FighterInputCmd.ZHAO_1;
         map[FighterSpecialFrame.ZHAO_2] = FighterInputCmd.ZHAO_2;
         map[FighterSpecialFrame.ZHAO_3] = FighterInputCmd.ZHAO_3;
         map[FighterSpecialFrame.BISHA] = FighterInputCmd.BISHA;
         map[FighterSpecialFrame.BISHA_UP] = FighterInputCmd.BISHA_UP;
         map[FighterSpecialFrame.BISHA_SUPER] = FighterInputCmd.BISHA_SUPER;
         map[FighterSpecialFrame.BISHA_AIR] = FighterInputCmd.BISHA_AIR;
         map[FighterSpecialFrame.ATTACK_AIR] = FighterInputCmd.ATTACK_AIR;
         map[FighterSpecialFrame.SKILL_AIR] = FighterInputCmd.SKILL_AIR;
         map[FighterSpecialFrame.SKILL_AIR_W] = FighterInputCmd.SKILL_AIR_W;
         map[FighterSpecialFrame.SKILL_AIR_S] = FighterInputCmd.SKILL_AIR_S;
         map[FighterSpecialFrame.DASH] = FighterInputCmd.DASH;
         map[FighterSpecialFrame.JUMP] = FighterInputCmd.JUMP;
         map[FighterSpecialFrame.JUMP_DOWN] = FighterInputCmd.JUMP_DOWN;
         map[FighterSpecialFrame.BANKAI] = FighterInputCmd.BANKAI;
         map[FighterSpecialFrame.BANKAI_W] = FighterInputCmd.BANKAI_W;
         map[FighterSpecialFrame.BANKAI_S] = FighterInputCmd.BANKAI_S;
         return map;
      }

      public function render() : void
      {
         _pushedThisFrame = false;

         if(!GameCtrl.I || !GameCtrl.I.actionEnable)
         {
            syncPrevWithoutPush();
            unbindFighter();
            return;
         }

         bindFighter(getFighter());
         sampleMoveAndGuard();
         updateIdleClear();
      }

      public function destory() : void
      {
         unbindFighter();

         var i:int = 0;
         var txt:BitmapFontText = null;
         if(_items)
         {
            for(i = 0; i < _items.length; i++)
            {
               TweenLite.killTweensOf(_items[i]);
            }
            _items = null;
         }

         while(numChildren > 0)
         {
            txt = getChildAt(0) as BitmapFontText;
            removeChildAt(0);
            if(txt)
            {
               TweenLite.killTweensOf(txt);
               txt.dispose();
            }
         }

         _font = null;
      }

      public function destroy() : void
      {
         destory();
      }

      private function sampleMoveAndGuard() : void
      {
         var fighter:FighterMain = _boundFighter;
         var state:int = fighter ? fighter.actionState : -1;

         if(state == FighterActionState.NORMAL && _prevActionState != FighterActionState.NORMAL && _prevActionState != -1)
         {
            resetMoveEdges();
         }

         var leftDown:Boolean = GameInputer.left(_inputType,0);
         var rightDown:Boolean = GameInputer.right(_inputType,0);
         var canMove:Boolean = state == FighterActionState.NORMAL;

         if(canMove && leftDown && !_prevLeft)
         {
            pushText(FighterInputCmd.LEFT);
         }
         if(canMove && rightDown && !_prevRight)
         {
            pushText(FighterInputCmd.RIGHT);
         }

         _prevLeft = leftDown;
         _prevRight = rightDown;

         if(state == FighterActionState.DEFENCE_ING && _prevActionState != FighterActionState.DEFENCE_ING)
         {
            if(!GameInputer.dash(_inputType,0) && !(isLastText(FighterInputCmd.GHOST_DASH_S) && GameInputer.down(_inputType,0)))
            {
               pushText(FighterInputCmd.DEFENSE);
            }
         }

         _prevActionState = state;
      }

      private function updateIdleClear() : void
      {
         if(!_pushedThisFrame && isFighterStandIdle())
         {
            if(_idleHoldTimer < _idleHoldFrames)
            {
               _idleHoldTimer++;
            }
            if(_idleHoldTimer >= _idleHoldFrames)
            {
               clearAll();
               _idleHoldTimer = 0;
            }
         }
         else
         {
            _idleHoldTimer = 0;
         }
      }

      private function bindFighter(fighter:FighterMain) : void
      {
         if(_boundFighter == fighter)
         {
            return;
         }
         unbindFighter();
         _boundFighter = fighter;
         if(_boundFighter)
         {
            _boundFighter.addEventListener(FighterEvent.DO_ACTION,onDoAction);
            _boundFighter.addEventListener(FighterEvent.IDLE,onFighterIdle);
         }
      }

      private function unbindFighter() : void
      {
         if(!_boundFighter)
         {
            return;
         }
         _boundFighter.removeEventListener(FighterEvent.DO_ACTION,onDoAction);
         _boundFighter.removeEventListener(FighterEvent.IDLE,onFighterIdle);
         _boundFighter = null;
      }

      private function onFighterIdle(e:FighterEvent) : void
      {
         _comboOpen = false;
         resetMoveEdges();
      }

      private function onDoAction(e:FighterEvent) : void
      {
         if(!GameCtrl.I || !GameCtrl.I.actionEnable)
         {
            return;
         }

         var params:Object = e.params;
         var input:String = params ? (params.input as String) : null;
         var action:String = params ? (params.action as String) : null;
         var highlight:Boolean = params ? Boolean(params.highlight) : false;
         if(!action && _boundFighter && _boundFighter.getMC())
         {
            action = _boundFighter.getMC().currentFrameName;
         }

         var text:String = input ? input : actionToText(action);
         if(text)
         {
            pushText(text,highlight);
         }
      }

      private function syncPrevWithoutPush() : void
      {
         _prevLeft = GameInputer.left(_inputType,0);
         _prevRight = GameInputer.right(_inputType,0);

         var fighter:FighterMain = getFighter();
         _prevActionState = fighter ? fighter.actionState : -1;
      }

      private function resetMoveEdges() : void
      {
         _prevLeft = false;
         _prevRight = false;
      }

      private function getFighter() : FighterMain
      {
         if(!GameCtrl.I || !GameCtrl.I.gameRunData)
         {
            return null;
         }

         var group:GameRunFighterGroup = (_inputType == GameInputType.P2) ? GameCtrl.I.gameRunData.p2FighterGroup : GameCtrl.I.gameRunData.p1FighterGroup;
         return group ? group.currentFighter : null;
      }

      private function isFighterStandIdle() : Boolean
      {
         var fighter:FighterMain = _boundFighter;
         if(!fighter || fighter.actionState != FighterActionState.NORMAL)
         {
            return false;
         }

         var mc:FighterMC = fighter.getMC();
         return mc != null && mc.currentFrameName == FighterSpecialFrame.IDLE;
      }

      private function actionToText(action:String) : String
      {
         if(!action || action.length == 0)
         {
            return null;
         }
         if(action == FighterSpecialFrame.CATCH_1)
         {
            return getCatchSideLetter() + FighterInputCmd.ATTACK;
         }
         if(action == FighterSpecialFrame.CATCH_2)
         {
            return getCatchSideLetter() + FighterInputCmd.ZHAO_1;
         }

         var mapped:String = ACTION_TEXT[action] as String;
         if(mapped)
         {
            return mapped;
         }
         if(action.indexOf(ATTACK_CHAR) == 0 && action.indexOf(SKILL_PREFIX) != 0)
         {
            return FighterInputCmd.ATTACK;
         }

         return null;
      }

      private function getCatchSideLetter() : String
      {
         if(GameInputer.right(_inputType,0))
         {
            return FighterInputCmd.RIGHT;
         }
         if(GameInputer.left(_inputType,0))
         {
            return FighterInputCmd.LEFT;
         }
         if(_boundFighter && _boundFighter.direct > 0)
         {
            return FighterInputCmd.RIGHT;
         }

         return FighterInputCmd.LEFT;
      }

      private function pushText(text:String, highlight:Boolean = false) : void
      {
         if(!text || !_items)
         {
            return;
         }

         if(text == FighterInputCmd.GHOST_DASH_S)
         {
            removeTrailingText(FighterInputCmd.DEFENSE);
         }

         var moveOrGuard:Boolean = isMoveOrGuardText(text);
         if(moveOrGuard || highlight)
         {
            _comboOpen = false;
         }
         else if(_comboOpen && tryAppendCombo(text))
         {
            return;
         }

         while(_items.length >= MAX_ITEMS)
         {
            fadeOutOldest();
         }

         var txt:BitmapFontText = new BitmapFontText(_font);
         txt.text = text;
         txt.scaleX = txt.scaleY = TEXT_SCALE;
         if(highlight)
         {
            try
            {
               txt["colorTransform"](HIGHLIGHT_CT);
            }
            catch(e:Error)
            {
               txt.transform.colorTransform = HIGHLIGHT_CT;
            }
         }
         txt.x = _alignRight ? -txt.width : 0;
         txt.y = BASE_Y;
         addChild(txt);
         _items.push(txt);

         _idleHoldTimer = 0;
         _pushedThisFrame = true;
         _comboOpen = !moveOrGuard && !highlight;

         layoutItems(true);
      }

      private function tryAppendCombo(text:String) : Boolean
      {
         if(!_items || _items.length == 0)
         {
            return false;
         }

         var last:BitmapFontText = _items[_items.length - 1];
         if(!last || isMoveOrGuardText(last.text))
         {
            return false;
         }

         last.text = last.text + COMBO_SEP + text;
         last.scaleX = last.scaleY = TEXT_SCALE;
         last.x = _alignRight ? -last.width : 0;
         _idleHoldTimer = 0;
         _pushedThisFrame = true;

         return true;
      }

      private static function isMoveOrGuardText(s:String) : Boolean
      {
         return s == FighterInputCmd.LEFT || s == FighterInputCmd.RIGHT || s == FighterInputCmd.DEFENSE;
      }

      private function removeTrailingText(match:String) : void
      {
         if(!_items || _items.length == 0)
         {
            return;
         }

         var last:BitmapFontText = _items[_items.length - 1];
         if(!last || last.text != match)
         {
            return;
         }

         _items.pop();
         TweenLite.killTweensOf(last);
         disposeItem(last);
         layoutItems(false);
      }

      private function isLastText(match:String) : Boolean
      {
         if(!_items || _items.length == 0)
         {
            return false;
         }

         var last:BitmapFontText = _items[_items.length - 1];
         return last != null && last.text == match;
      }

      private function clearAll() : void
      {
         if(!_items || _items.length == 0)
         {
            return;
         }

         var fading:Vector.<BitmapFontText> = _items;
         _items = new Vector.<BitmapFontText>();
         _comboOpen = false;

         var i:int = 0;
         for(i = 0; i < fading.length; i++)
         {
            fadeOutItem(fading[i]);
         }
      }

      private function fadeOutItem(txt:BitmapFontText) : void
      {
         TweenLite.killTweensOf(txt);
         TweenLite.to(txt,FADE_TIME,{
            "alpha":0,
            "onComplete":function():void
            {
               disposeItem(txt);
            }
         });
      }

      private function layoutItems(animate:Boolean) : void
      {
         var n:int = _items.length;
         var i:int = 0;
         var txt:BitmapFontText = null;
         var ty:Number = NaN;
         for(i = 0; i < n; i++)
         {
            txt = _items[i];
            ty = BASE_Y - (n - 1 - i) * LINE_GAP;
            TweenLite.killTweensOf(txt);
            if(animate)
            {
               TweenLite.to(txt,MOVE_TIME,{"y":ty});
            }
            else
            {
               txt.y = ty;
            }
         }
      }

      private function fadeOutOldest() : void
      {
         if(_items.length == 0)
         {
            return;
         }
         fadeOutItem(_items.shift());
      }

      private function disposeItem(txt:BitmapFontText) : void
      {
         if(!txt)
         {
            return;
         }
         TweenLite.killTweensOf(txt);
         if(txt.parent)
         {
            txt.parent.removeChild(txt);
         }
         txt.dispose();
      }
   }
}
