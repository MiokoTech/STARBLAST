package net.play5d.game.bvn.ui
{
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;

   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.ConfigVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   import net.play5d.game.bvn.mob.data.ScreenPadConfigVO;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.game.bvn.utils.TouchMoveEvent;
   import net.play5d.game.bvn.utils.TouchUtils;

   public class SetBtnGroup extends Sprite
   {
      public var keyEnable:Boolean = true;
      public var _isSubMenu:Boolean = false;
      public var startX:Number = 100;
      public var startY:Number = 50;
      public var endY:Number = 0;
      public var gap:Number = 75;
      public var direct:int = 1;
      public var gameInputType:String = "MENU";
      private var _btns:Vector.<SetBtn>;
      private var _arrow:MovieClip;
      private var _arrowIndex:int = -1;
      private var _scrollRect:Rectangle;

      private var _tabs:Array = ["SETTINGS", "CONFIG", "RULES"];
      private var _currentTabIndex:int = 0;
      private var _ui:MovieClip;

      private var _btnData:Array;
      private var _btnDisplayOffset:int = 0;
      private const MAX_VISIBLE_BTNS:int = 7;

      public function SetBtnGroup()
      {
         super();
         scaleX = scaleY = 1;
         TouchUtils.I.listenOneFinger(this, touchMoveHandler, false, true);
      }

      public function destory() : void
      {
         if(_btns)
         {
            for each(var b:SetBtn in _btns)
            {
               b.destory();
               b.removeEventListener(SetBtnEvent.OPTION_CHANGE, onChangeOption);
               b.removeEventListener(SetBtnEvent.SELECT, onSelect);
            }
            _btns = null;
         }
         GameRender.remove(render,this);
         TouchUtils.I.unlistenOneFinger(this);
      }

      private function updateScroll():void {
         this.scrollRect = _scrollRect;
      }

      private function touchMoveHandler(event:TouchMoveEvent):void {
         if (!_scrollRect) {
            return;
         }

         switch (event.type) {
         case TouchMoveEvent.TOUCH_MOVE:
            _scrollRect.y -= event.deltaY;
            updateScroll();
            break;
         case TouchMoveEvent.TOUCH_END:
            var toY:Number = -1;

            if (event.endY > event.startY) {
                if (_scrollRect.y < 0) {
                    toY = 0;
                }
            }
            else if (event.endY < event.startY) {
                var bh:Number     = endY != 0 ? endY : _scrollRect.height;
                var bottom:Number = GameConfig.GAME_SIZE.y - bh + 200;
                if (_scrollRect.y > bottom) {
                    toY = bottom;
                }
            }

            if (toY != -1) {
                TweenLite.to(_scrollRect, 0.2, {y: toY, onUpdate: updateScroll});
            }
            break;
         }
      }

      public function initMainSet() : void
      {
         initMainBtns();
         initArrow();
         GameRender.add(render,this);
         GameInputer.focus();
         GameInputer.enabled = true;
      }

      public function initKeySet() : void
      {
         setBtnData([{
            "label":"SET ALL",
            "cn":"设置全部"
         },{
            "label":"SET DEFAULT",
            "cn":"还原默认按键"
         },{
            "label":"APPLY",
            "cn":"应用"
         },{
            "label":"CANCEL",
            "cn":"取消"
         }]);
      }

      public function setBtnData(v:Array, defaultSelect:int = 0) : void
      {
         _btnData = v.concat();
         _btnDisplayOffset = 0;
         refreshVisibleBtns();
         if (!_arrow) initArrow();
         setArrowIndex(defaultSelect, true, false);
      }

      private function refreshVisibleBtns() : void
      {
         removeAllBtns();
         _btns = new Vector.<SetBtn>();

         var max:int = Math.min(_btnData.length, _btnDisplayOffset + MAX_VISIBLE_BTNS);
         var config:ConfigVO = GameData.I.config;

         for (var i:int = _btnDisplayOffset; i < max; i++) {
            var o:Object = _btnData[i];
            var btn:SetBtn = addBtn(o.label, o.cn, o.cn_y, o.options);
            if (o.select) btn.onSelect = o.select;

            btn.optionKey = o.optoinKey;
            if (o.optionValue != undefined) {
               btn.setOptionByValue(o.optionValue);
               btn.addEventListener(SetBtnEvent.OPTION_CHANGE, onOptionChange);
            }
            if (btn.optionKey) {
               btn.setOptionByValue(config.getValueByKey(btn.optionKey));
            }
         }
      }

      private function onOptionChange(e:SetBtnEvent) : void
      {
         var configPad:ScreenPadConfigVO = GameInterfaceManager.config.screenPadConfig;
         if (configPad.hasOwnProperty(e.optionKey)) {
            configPad.setValueByKey(e.optionKey, e.optionValue);
         } else {
            GameData.I.config.setValueByKey(e.optionKey, e.optionValue);
         }
      }

      private function initTabUI() : void
      {
         if (_ui && _ui.parent) {
            _ui.parent.removeChild(_ui);
            _ui = null;
         }
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting, "option_ui") as MovieClip;
         addChildAt(_ui, 0);
         var tab:String = _tabs[_currentTabIndex];
         _ui.gotoAndPlay(tab.toUpperCase());
      }

      public function initWithTab() : void
      {
         _currentTabIndex = 0;

         selectTabByIndex(_currentTabIndex);

         GameRender.add(render, this);
         GameInputer.focus();
         GameInputer.enabled = true;
      }

      public function initSimpleBtns(v:Array) : void
      {
         _btns = new Vector.<SetBtn>();
         var btn:SetBtn;
         var config:ConfigVO = GameData.I.config;
         for (var i:int; i < v.length; i++) {
            var o:Object = v[i];
            btn = addBtn(o.label, o.cn, o.cn_y, o.options);
            btn.optionKey = o.optoinKey;
            if (btn.optionKey) {
                btn.setOptionByValue(config.getValueByKey(btn.optionKey));
            }
         }

         if (!_arrow) initArrow();
         setArrowIndex(0, true, false);
         GameRender.add(render, this);
         GameInputer.focus();
         GameInputer.enabled = true;
      }

      private function selectTabByIndex(index:int) : void
      {
         if (index < 0) index = _tabs.length - 1;
         if (index >= _tabs.length) index = 0;

         _currentTabIndex = index;
         var tab:String = _tabs[index];

         initTabUI();

         switch (tab) {
            case "SETTINGS":
               var screenPadConfig:ScreenPadConfigVO = GameInterfaceManager.config.screenPadConfig;
               setBtnData([
                  { label: "Screenpad Layout", cn:"按键设置", cn_y: 200 },
                  { label: "Screenpad Opacity", cn:"默认", cn_y: 200,
                     options: [
                        { label: "0%", cn: "0", cn_y: 255, value: 0 },
                        { label: "10%", cn: "fps", cn_y: 255, value: 0.1 },
                        { label: "30%", cn: "fps", cn_y: 255, value: 0.3 },
                        { label: "50%", cn: "fps", cn_y: 255, value: 0.5 },
                        { label: "70%", cn: "fps", cn_y: 255, value: 0.7 },
                        { label: "100%", cn: "fps", cn_y: 255, value: 1 },
                     ],
                      optoinKey: "joyAlpha",
                      optionValue: screenPadConfig.joyAlpha
                  },
                  { label: "Screen Mode", cn: "Display", cn_y: 222,
                     options: [
                        { label: "Fill", cn: "Fill", cn_y: 255, value: 0 },
                        { label: "Center", cn: "Center", cn_y: 255, value: 1 }
                     ],
                     optoinKey:"screenMode"
                  },
                  { label: "Sprite Style", cn: "Display", cn_y: 222,
                     options: [
                        { label: "Localcoord", cn: "Localcoord", cn_y: 255, value: 0 },
                        { label: "Original", cn: "Original", cn_y: 255, value: 1 }
                     ],
                     optoinKey:"spriteStyle"
                  },
                  { label: "Character Shadow", cn: "Display", cn_y: 222,
                     options: [
                        { label: "Enabled", cn: "On", cn_y: 255, value: true },
                        { label: "Disabled", cn: "Off", cn_y: 255, value: false }
                     ],
                     optoinKey:"shadowEnabled"
                  },
                  { label: "Sound", cn: "Sound", cn_y: 255,
                     options: [
                        { label: "0%", cn: "sound 0%", cn_y: 255, value: 0 },
                        { label: "10%", cn: "sound 10%", cn_y: 255, value: 0.1 },
                        { label: "30%", cn: "sound 30%", cn_y: 255, value: 0.3 },
                        { label: "50%", cn: "sound 50%", cn_y: 255, value: 0.5 },
                        { label: "70%", cn: "sound 70%", cn_y: 255, value: 0.7 },
                        { label: "100%", cn: "sound 100%", cn_y: 255, value: 1 }
                     ],
                     optoinKey:"soundVolume"
                  },
                  { label: "BGM", cn: "Sound", cn_y: 255,
                     options: [
                        { label: "0%", cn: "sound 0%", cn_y: 255, value: 0 },
                        { label: "10%", cn: "sound 10%", cn_y: 255, value: 0.1 },
                        { label: "30%", cn: "sound 30%", cn_y: 255, value: 0.3 },
                        { label: "50%", cn: "sound 50%", cn_y: 255, value: 0.5 },
                        { label: "70%", cn: "sound 70%", cn_y: 255, value: 0.7 },
                        { label: "100%", cn: "sound 100%", cn_y: 255, value: 1 }
                     ],
                     optoinKey:"bgmVolume"
                  },
                  { label: "Framerate", cn: "fps", cn_y: 255,
                     options: [
                        { label: "30", cn: "fps", cn_y: 255, value: 30 },
                        { label: "60", cn: "fps", cn_y: 255, value: 60 }
                     ],
                     optoinKey:"frameRate"
                  },
                  { label: "Image Quality", cn: "fps", cn_y: 255,
                     options: [
                        { label: "Low", cn: "fps", cn_y: 255, value: "low" },
                        { label: "Medium", cn: "fps", cn_y: 255, value: "medium" },
                        { label: "High", cn: "fps", cn_y: 255, value: "high" }
                     ],
                     optoinKey:"quality"
                  },
                  { label: "Shine Effect", cn: "fps", cn_y: 255,
                     options: [
                        { label: "Low", cn: "fps", cn_y: 255, value: "low" },
                        { label: "Medium", cn: "fps", cn_y: 255, value: "medium" },
                        { label: "High", cn: "fps", cn_y: 255, value: "high" }
                     ],
                     optoinKey:"shineEffect"
                  },
                  { label: "Background Blur", cn: "fps", cn_y: 255,
                     options: [
                        { label: "Enabled", cn: "fps", cn_y: 255, value: true },
                        { label: "Disable", cn: "fps", cn_y: 255, value: false }
                     ],
                     optoinKey:"bgBlur"
                  },
                  { label: "APPLY", cn:"", cn_y: 200 }
               ]);
               break;
            case "CONFIG":
               setBtnData([
                  { label: "Game Difficulty", cn:"返回", cn_y: 200,
                     options: [
                        { label: "Easy", cn: "fps", cn_y: 255, value: 1 },
                        { label: "Normal", cn: "fps", cn_y: 255, value: 2 },
                        { label: "Hard", cn: "fps", cn_y: 255, value: 3 },
                        { label: "Very Hard", cn: "fps", cn_y: 255, value: 4 }
                     ],
                     optoinKey:"difficulty"
                  },
                  { label: "Life Point", cn:"返回", cn_y: 200,
                     options: [
                        { label: "50%", cn: "fps", cn_y: 255, value: 0.5 },
                        { label: "100%", cn: "fps", cn_y: 255, value: 1 },
                        { label: "200%", cn: "fps", cn_y: 255, value: 2 },
                        { label: "300%", cn: "fps", cn_y: 255, value: 3 },
                        { label: "500%", cn: "fps", cn_y: 255, value: 5 },
                        { label: "10000%", cn: "fps", cn_y: 255, value: 99 }
                     ],
                     optoinKey:"fighterHP"
                  },
                  { label: "Round Game", cn:"返回", cn_y: 200,
                     options: [
                        { label: "1", cn: "fps", cn_y: 255, value: 1 },
                        { label: "2", cn: "fps", cn_y: 255, value: 2 },
                        { label: "3", cn: "fps", cn_y: 255, value: 3 }
                     ],
                     optoinKey:"roundGame"
                  },
                  { label: "Time Set", cn:"返回", cn_y: 200,
                     options: [
                        { label: "30s", cn: "fps", cn_y: 255, value: 30 },
                        { label: "60s", cn: "fps", cn_y: 255, value: 60 },
                        { label: "90s", cn: "fps", cn_y: 255, value: 90 },
                        { label: "120s", cn: "fps", cn_y: 255, value: 120 },
                        { label: "150s", cn: "fps", cn_y: 255, value: 150 },
                        { label: "180s", cn: "fps", cn_y: 255, value: 180 },
                        { label: "∞", cn: "fps", cn_y: 255, value: -1 }
                     ],
                     optoinKey:"fightTime"
                  },
                  { label: "Assister Partner", cn:"返回", cn_y: 200,
                     options: [
                        { label: "Enabled", cn: "fps", cn_y: 255, value: true },
                        { label: "Disabled", cn: "fps", cn_y: 255, value: false }
                     ],
                     optoinKey:"assisterPartner"
                  },
                  { label: "Camera Zoom Speed", cn:"返回", cn_y: 200,
                     options: [
                        { label: "50%", cn: "fps", cn_y: 255, value: 0.5 },
                        { label: "60%", cn: "fps", cn_y: 255, value: 0.6 },
                        { label: "70%", cn: "fps", cn_y: 255, value: 0.7 },
                        { label: "80%", cn: "fps", cn_y: 255, value: 0.8 },
                        { label: "90%", cn: "fps", cn_y: 255, value: 0.9 },
                        { label: "100%", cn: "fps", cn_y: 255, value: 1 }
                     ],
                     optoinKey:"cameraZoomRate"
                  },
                  { label: "Camera Distance", cn:"返回", cn_y: 200,
                     options: [
                        { label: "Near", cn: "fps", cn_y: 255, value: 2.5 },
                        { label: "Normal", cn: "fps", cn_y: 255, value: 2 },
                        { label: "Far", cn: "fps", cn_y: 255, value: 1.5 }
                     ],
                     optoinKey:"cameraDistance"
                  },
                  { label: "Camera Style", cn:"返回", cn_y: 200,
                     options: [
                        { label: "BvN", cn: "fps", cn_y: 255, value: 0 },
                        { label: "STARBLAST", cn: "fps", cn_y: 255, value: 1 }
                     ],
                     optoinKey:"cameraStyle"
                  },
                  { label: "APPLY", cn:"", cn_y: 200 }
               ]);

              break;
            case "RULES":
               setBtnData([
                  { label: "Assister Partner", cn:"返回", cn_y: 200,
                     options: [
                        { label: "Enabled", cn: "fps", cn_y: 255, value: true },
                        { label: "Disabled", cn: "fps", cn_y: 255, value: false }
                     ],
                     optoinKey:"assisterPartner"
                  },
                  { label: "Bisha Energy Max", cn:"返回", cn_y: 200,
                     options: [
                        { label: "1", cn: "fps", cn_y: 255, value: 1 },
                        { label: "2", cn: "fps", cn_y: 255, value: 2 },
                        { label: "3", cn: "fps", cn_y: 255, value: 3 },
                        { label: "4", cn: "fps", cn_y: 255, value: 4 },
                        { label: "5", cn: "fps", cn_y: 255, value: 5 }
                     ],
                     optoinKey:"bishaEnergyMax"
                  },
                  { label: "Qi Gain Rate", cn:"返回", cn_y: 200,
                     options: [
                        { label: "1x", cn: "fps", cn_y: 255, value: 1 },
                        { label: "2x", cn: "fps", cn_y: 255, value: 2 },
                        { label: "3x", cn: "fps", cn_y: 255, value: 3 },
                        { label: "4x", cn: "fps", cn_y: 255, value: 4 },
                        { label: "5x", cn: "fps", cn_y: 255, value: 5 }
                     ],
                     optoinKey:"qiGainRate"
                  },
                  { label: "Assister Combo", cn:"返回", cn_y: 200,
                     options: [
                        { label: "Enabled", cn: "fps", cn_y: 255, value: 30 },
                        { label: "Disabled", cn: "fps", cn_y: 255, value: 60 }
                     ],
                     optoinKey:"repeatCombo"
                  },
                  { label: "Ghoststep Combo", cn:"返回", cn_y: 200,
                     options: [
                        { label: "Enabled", cn: "fps", cn_y: 255, value: 30 },
                        { label: "Disabled", cn: "fps", cn_y: 255, value: 60 }
                     ],
                     optoinKey:"repeatCombo"
                  },
                  { label: "Repeat Combo", cn:"返回", cn_y: 200,
                     options: [
                        { label: "Enabled", cn: "fps", cn_y: 255, value: 30 },
                        { label: "Disabled", cn: "fps", cn_y: 255, value: 60 }
                     ],
                     optoinKey:"repeatCombo"
                  },
                  { label: "Allow Wankai", cn:"返回", cn_y: 200,
                     options: [
                        { label: "Enabled", cn: "fps", cn_y: 255, value: 30 },
                        { label: "Disabled", cn: "fps", cn_y: 255, value: 60 }
                     ],
                     optoinKey:"repeatCombo"
                  },
                  { label: "Allow Ghoststep", cn:"返回", cn_y: 200,
                     options: [
                        { label: "Enabled", cn: "fps", cn_y: 255, value: 30 },
                        { label: "Disabled", cn: "fps", cn_y: 255, value: 60 }
                     ],
                     optoinKey:"repeatCombo"
                  },
                  { label: "Skill Duration", cn:"返回", cn_y: 200,
                     options: [
                        { label: "0.1s", cn: "fps", cn_y: 255, value: 30 },
                        { label: "0.5s", cn: "fps", cn_y: 255, value: 60 },
                        { label: "1s", cn: "fps", cn_y: 255, value: 60 }
                     ],
                     optoinKey:"repeatCombo"
                  },
                  { label: "APPLY", cn:"", cn_y: 200 }
               ]);
               break;
         }

         if (_btns.length > 0) _btns[0].hover();
      }

      private function removeAllBtns() : void
      {
         if (!_btns) return;

         for each (var b:SetBtn in _btns) {
            if (b.parent) {
               b.parent.removeChild(b);
            }
         }
         _btns.length = 0;
      }

      private function initMainBtns() : void
      {
         _btns = new Vector.<SetBtn>();
         var settingMenu:Array;
         settingMenu ||= [
            { txt: "SETTINGS", cn: "", cn_y: 20 },
            { txt: "CONFIG", cn: "", cn_y: 20 },
            { txt: "RULES", cn: "", cn_y: 20 }
         ];
         var btn:SetBtn;
         var config:ConfigVO = GameData.I.config;

         for (var i:int; i < settingMenu.length; i++) {
            var o:Object = settingMenu[i];
            btn = addBtn(o.txt, o.cn, o.cn_y, o.options);
            if (o.select) {
                btn.onSelect = o.select;
            }
            btn.optionKey = o.optoinKey;
            if (btn.optionKey) {
                btn.setOptionByValue(config.getValueByKey(btn.optionKey));
            }
         }
         graphics.beginFill(0,0);
         graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,_btns[_btns.length - 1].y + 800);
         graphics.endFill();
      }

      private function addBtn(label:String, cn:String, cn_y:int = 0, options:Array = null) : SetBtn
      {
         var btn:SetBtn = new SetBtn(label, cn, cn_y);

         switch (direct) {
            case 0:
               btn.x = startX + gap * _btns.length;
               btn.y = startY;
               break;
            case 1:
               btn.x = startX;
               btn.y = startY + gap * _btns.length;
         }
         addChild(btn);
         if (label == "Return") {
            btn.y = startY + 35 * _btns.length;
         }
         if (options) {
            btn.setOption(options);
            btn.addEventListener(SetBtnEvent.OPTION_CHANGE, onChangeOption);
         } else {
            btn.addEventListener(SetBtnEvent.SELECT, onSelect);
         }
         btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            if (!keyEnable) return;
            setArrowIndex(_btns.indexOf(btn));
            btn.select();
         });

         _btns.push(btn);
         return btn;
      }

      private function initArrow(param1:int = 0) : void
      {
         _arrow = ResUtils.I.createDisplayObject(ResUtils.swfLib.common_ui,"select_arrow_mc");
         addChild(_arrow);
      }

      public function setArrowIndex(id:int, sound:Boolean = true, isScroll:Boolean = true) : void
      {
         if (_arrowIndex == id) return;
         if (!_btns || _btns.length < 1) return;
         if (id < 0) {
            if (_btnDisplayOffset > 0) {
               _btnDisplayOffset--;
               refreshVisibleBtns();
               id = 0;
            } else {
               id = 0;
            }
         }
         if (id >= MAX_VISIBLE_BTNS) {
            if (_btnDisplayOffset + MAX_VISIBLE_BTNS < _btnData.length) {
               _btnDisplayOffset++;
               refreshVisibleBtns();
               id = _btns.length - 1;
            } else {
               id = _btns.length - 1;
            }
         }
         if (id >= _btns.length) {
            id = _btns.length - 1;
         }

         var btn:SetBtn = _btns[id];

         _arrowIndex = id;
         _arrow.x = btn.x - 10;
         _arrow.y = btn.y + 15;

         _btns.forEach(function(item:SetBtn, i:int, v:Vector.<SetBtn>):Boolean
         {
            if(btn == item)
            {
               item.hover();
            } else {
               item.hoverOut();
            }
            return true;
         });

         if(sound) SoundCtrl.I.sndSelect();
      }

      public function render() : void
      {
         if (!keyEnable) return;
         if (!_btns || _btns.length < 1) return;

         var btn:SetBtn = _btns[_arrowIndex];
         if (!_isSubMenu) {
            if(GameInputer.wankai(gameInputType,1))
            {
               selectTabByIndex(_currentTabIndex - 1);
            }
            if(GameInputer.superSkill(gameInputType,1))
            {
               selectTabByIndex(_currentTabIndex + 1);
            }
         }
         if (GameInputer.up(gameInputType,1))
         {
            if(direct == 1)
            {
               setArrowIndex(_arrowIndex - 1);
            }
         }
         if(GameInputer.down(gameInputType,1))
         {
            if(direct == 1)
            {
               setArrowIndex(_arrowIndex + 1);
            }
         }
         if(GameInputer.left(gameInputType,1))
         {
            if(direct == 0)
            {
               setArrowIndex(_arrowIndex - 1);
            }
            if(direct == 1)
            {
               btn.prevOption();
            }
         }
         if(GameInputer.right(gameInputType,1))
         {
            if(direct == 0)
            {
               setArrowIndex(_arrowIndex + 1);
            }
            if(direct == 1)
            {
               btn.nextOption();
            }
         }
         if(GameInputer.jump(gameInputType,1) || GameInputer.select(gameInputType,1) || GameInputer.attack(gameInputType,1))
         {
            btn.select();
         }
      }

      private function onChangeOption(param1:SetBtnEvent) : void
      {
         dispatchEvent(param1.newEvent());
      }

      private function onSelect(param1:SetBtnEvent) : void
      {
         var _loc2_:SetBtn = param1.currentTarget as SetBtn;
         if(_loc2_.onSelect != null)
         {
            _loc2_.onSelect();
         }
         dispatchEvent(param1.newEvent());
      }
   }
}

