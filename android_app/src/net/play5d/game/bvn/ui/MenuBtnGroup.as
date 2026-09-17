package net.play5d.game.bvn.ui
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.geom.Point;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.MessionModel;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.mob.views.ViewManager;

   public class MenuBtnGroup extends Sprite
   {
      public var enabled:Boolean = true;
      protected var _btnConfig:Array;
      protected var _xadd:Number = 0;
      protected var _yadd:Number = 0;
      public var _btnIndex:int;
      private var _startPoint:Point;
      private var _btnHeight:Number = 0;
      public var _btns:Array = [];
      private var _inputType:String = "MENU";
      private var _showIngChildrenBtn:MenuBtn;
      public var onHoverChange:Function;

      public function get showIngChildrenBtn():MenuBtn
      {
         return _showIngChildrenBtn;
      }

      private var _setCharacter:SetChar;

      public function MenuBtnGroup()
      {
         super();
      }

      public function destory() : void
      {
         GameRender.remove(render);
         for each(var b:MenuBtn in _btns) {
            b.dispose();
         }
         _btns = null;
      }

      public function restoreInputAfterSubmenu(parentBtn:MenuBtn = null, childLabel:String = null):void
      {
         try { GameRender.add(this.render); } catch(e:Error) {}
         this.enabled = true;

         if (parentBtn) {
            var childPresent:Boolean = false;
            for (var i:int = 0; i < parentBtn.children.length; i++) {
               var childBtn:MenuBtn = parentBtn.children[i];
               if (childBtn.ui && childBtn.ui.parent == this) {
                  childPresent = true;
                  break;
               }
            }

            if (!childPresent) {
               this._showIngChildrenBtn = parentBtn;
               this.setBtns(true, false, true, parentBtn.children);
               parentBtn.openChild();
            } else {
               this._showIngChildrenBtn = parentBtn;
               parentBtn.openChild();
            }

            var idx:int = 0;
            if (childLabel != null) {
               for (i = 0; i < parentBtn.children.length; i++) {
                  if (parentBtn.children[i].label == childLabel) {
                     idx = i;
                     break;
                  }
               }
            }
            this._btnIndex = idx;
            this.hoverBtn(parentBtn.children[idx]);
         } else {
            if (this._btns && this._btns.length > 0) {
               if (this._btnIndex < 0 || this._btnIndex >= this._btns.length) this._btnIndex = 0;
               this.hoverBtn(this._btns[this._btnIndex]);
               this.setBtns(true, true, false, this._btns);
            }
         }
      }

      public function fadIn(duration:Number = 0.5, itemDelay:Number = 0.05) : void
      {
         for (var i:int; i < _btns.length; i++) {
            var b:MenuBtn = _btns[i];
            b.ui.scaleX   = 0.01;
            TweenLite.to(b.ui, duration, {scaleX: 1, delay: i * itemDelay, ease: Back.easeOut});
         }
      }

      public function build() : void
      {
         _startPoint = new Point(x, y);

         _btnConfig = GameInterface.instance.getGameMenu();
         for (var i:int; i < _btnConfig.length; i++) {
            var o:Object = _btnConfig[i];
            addMenuBtn(o);
         }

         setBtns(true, false, false, _btns);
         hoverBtn(_btns[0]);
         this.y += 50;
         GameRender.add(render);
      }

      private function addMenuBtn(o:Object, isChild:Boolean = false) : MenuBtn
      {
         var b:MenuBtn = new MenuBtn(o.txt, o.cn, o.value_cn, o.func);

         if (!isChild) {
            b.index = _btns.length;
            _btns.push(b);
            if (_btnHeight == 0) {
                _btnHeight = b.height;
            }
         }
         var children:Array = o.children;
         if (children) {
            b.children = [];
            for (var j:int = 0; j < children.length; j++) {
                var o2:Object  = children[j];
                var cb:MenuBtn = addMenuBtn(o2, true);
                b.children.push(cb);
                cb.childMode();
                cb.index = j;
            }
         }
         return b;
      }

      public function hoverBtn(btn:MenuBtn) : void
      {
         var b:MenuBtn;
         for (var i:int = 0; i < _btns.length; i++) {
            b = _btns[i];
            if (b == btn) {
               b.hover();
               _btnIndex = i;
            }
            else {
               b.normal();
            }
         }
         if (_showIngChildrenBtn) {
            var children:Array = _showIngChildrenBtn.children;
            for (var j:int = 0; j < children.length; j++) {
               b = children[j];
               if (b == btn) {
                  b.hover();
                  _btnIndex = j;
               }
               else {
                  b.normal();
               }
            }
         }
         if (onHoverChange != null && btn != null) {
            onHoverChange(btn, _btnIndex, _showIngChildrenBtn != null);
         }
      }

      protected function selectBtn(target:MenuBtn) : void
      {
         var func:Function = null;
         var callFunc:Function = null;

         if (target.children) {
            toogleChildren(target);
            return;
         }
         if (Boolean(target.func)) {
            func = target.func;
         } else {
            func = this.getFucByLabel(target.label);
         }
         callFunc = function():void
         {
            if (func != null) {
               func();
            }
            enabled = true;
         };
         enabled = false;
         target.select(callFunc);
      }

      private function getFucByLabel(param1:String) : Function
      {
         var func:Function = null;
         var label:String = param1;
         var self:MenuBtnGroup = this;
         switch(label)
         {
            case "SINGLE ACRADE":
               func = function():void
               {
                  GameMode.currentMode = 20;
                  MessionModel.I.reset();
                  if(GameConfig.SHOW_HOW_TO_PLAY)
                  {
                     MainGame.I.goHowToPlay();
                  }
                  else
                  {
                     MainGame.I.goSelect();
                  }
               };
               break;
            case "SINGLE VS PEOPLE":
               func = function():void
               {
                  GameMode.currentMode = 21;
                  MainGame.I.goSelect();
               };
               break;
            case "VS CPU":
               func = function():void
               {
                  GameMode.currentMode = GameMode.VS_CPU
                  try { GameRender.remove(self.render); } catch(err:Error) {}
                  self.enabled = false;
                  ViewManager.I.setChar(self, self._showIngChildrenBtn, label);
               };
               break;
            case "WATCH":
               func = function():void
               {
                  GameMode.currentMode = GameMode.WATCH;

                  try { GameRender.remove(self.render); } catch(err:Error) {}
                  self.enabled = false;
                  var layout:SetChar = new SetChar(self, self._showIngChildrenBtn, label);
                  RootSprite.I.addChildToGameSprite(layout);
               };
               break;
            case "SURVIVAL":
               func = function():void
               {
                  GameMode.currentMode = 30;
                  MessionModel.I.reset();
                  MainGame.I.goSelect();
               };
               break;
            case "NETWORK":
               func = function():void
               {
                  GameMode.currentMode = 57;
               };
               break;
            case "OPTION":
               func = function():void
               {
                  MainGame.I.goOption();
               };
               break;
            case "TRAINING":
               func = function():void
               {
                  GameMode.currentMode = GameMode.TRAINING;
                  MainGame.I.goSelect();
               };
               break;
            case "CREDITS":
               func = function():void
               {
                  MainGame.I.goCredits();
               };
         }
         return func;
      }

      private function toogleChildren(btn:MenuBtn) : void
      {
         if (_showIngChildrenBtn) {
            var isSame:Boolean = btn == _showIngChildrenBtn;
            if (!isSame) {
                var _btnMenu:* = isSame[0];
                removeChild(_btnMenu.ui);
                _showIngChildrenBtn.normal();
            }
            closeChildren(isSame);
            if (isSame) return;
         }
         _showIngChildrenBtn = btn;
         setBtns(true, false, true, btn.children);
         btn.openChild();
         hoverBtn(btn.children[0]);
      }

      private function closeChildren(isSetBtn:Boolean) : void
      {
         var children:Array = _showIngChildrenBtn.children;
         for (var i:int = 0; i < children.length; i++) {
            var b:MenuBtn = children[i];
            try {
               removeChild(b.ui);
            }
            catch(e:Error) {
            }
         }
         _showIngChildrenBtn.closeChild();
         _showIngChildrenBtn = null;
         if (isSetBtn) {
            setBtns(true, true, false, _btns);
         }
      }

      private function setBtns(_addChild:Boolean, tween:Boolean, removesCh:Boolean, btnMenu:Array) : void
      {
         var xyz:Number = 0;
         var yxz:Number = 0;
         for (var i:int; i < _btns.length; i++) {
            var b:MenuBtn = _btns[i];
            if(removesCh)
            {
               removeChild(b.ui);
            }
         }
         if(btnMenu)
         {
            for (var j:int; j < btnMenu.length; j++) {
               var cb:MenuBtn = btnMenu[j];
               cb.ui.x = xyz;
               cb.ui.y = yxz;
               if(tween) {
                  TweenLite.to(cb.ui, 0.2, {scaleX : 1, delay : j * 0.04, ease : Back.easeOut});
               }
               if(_addChild) {
                  addChild(cb.ui);
               }
               xyz += _xadd;
               yxz += cb.height + _yadd;
            }
         }
      }

      private function render() : void
      {
         if(!enabled) return;

         if(GameUI.showingDialog()) return;

         var btns:Array = !!_showIngChildrenBtn ? _showIngChildrenBtn.children : _btns;
         if (GameInputer.up(_inputType, 1)) {
            --_btnIndex;
            if (_btnIndex < 0) {
               _btnIndex = btns.length - 1;
            }
               hoverBtn(btns[_btnIndex]);
         }
         if (GameInputer.down(_inputType, 1)) {
            ++_btnIndex;
            if (_btnIndex > btns.length - 1) {
               _btnIndex = 0;
            }
            hoverBtn(btns[_btnIndex]);
         }
         if (GameInputer.jump(_inputType, 1)) {
            selectBtn(btns[_btnIndex]);
         }
         if(GameInputer.dash("MENU", 1)) {
            if(_showIngChildrenBtn) {
               _btnIndex = _showIngChildrenBtn.index;
               closeChildren(true);
            }
         }
      }
   }
}

