package net.play5d.game.bvn.state
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Quad;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.utils.setTimeout;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.ui.MenuBtn;
   import net.play5d.game.bvn.ui.MenuBtnGroup;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.stage.Istage;

   public class MenuState extends Sprite implements Istage
   {
      private var _ui:MovieClip;
      private var _btnGroup:MenuBtnGroup;
      private var _previewMc:MovieClip;
      private var _bgMc:MovieClip;
      private var _curPreviewFrame:String = "";
      private var _curVoiceChannel:SoundChannel;

      private static const PREVIEW_MAP:Object = {
         0: "single",
         1: "versus",
         2: "training",
         3: "option",
         4: "credits",
         5: "exit"
      };

      private static const PREVIEW_SIZES:Object = {
         "single":   {"w": 412, "h": 720},
         "versus":   {"w": 371, "h": 720},
         "training": {"w": 439, "h": 720},
         "credits":  {"w": 344, "h": 720},
         "exit":     {"w": 680, "h": 599},
         "option":   {"w": 510, "h": 720}
      };

      private static const SOUND_MAP:Object = {
         "single":   "menu_snd_01",
         "versus":   "menu_snd_02",
         "training": "menu_snd_03",
         "option":   "menu_snd_06",
         "credits":  "menu_snd_04",
         "exit":     "menu_snd_05"
      };

      public function MenuState()
      {
         super();
      }

      public function get display() : DisplayObject
      {
         return _ui;
      }

      public function build() : void
      {
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.menu,"front_game") as MovieClip;
         if (_ui)
         {
            _bgMc = _ui.getChildByName("bg_mc") as MovieClip;
            if (!_bgMc && _ui.numChildren > 0)
            {
               _bgMc = _ui.getChildAt(0) as MovieClip;
            }
            if (_bgMc)
            {
               _bgMc.stop();
               _bgMc.gotoAndStop("single");
            }
         }
         GameInterface.instance.initTitleUI(_ui);
         GameInputer.enabled = false;
         SoundCtrl.I.BGM(AssetManager.I.getSound("menu"));
      }

      public function afterBuild() : void
      {
         setTimeout(function():void
         {
            _ui.buttonMode = true;
            _ui.useHandCursor = true;
            GameRender.add(render);
            GameInputer.focus();
            GameInputer.enabled = true;
         },500);
      }

      private function render() : void
      {
         showBtns();
      }

      private function showBtns(... rest) : void
      {
         var ct:Sprite;
         var params:Array;
         params = rest;
         GameRender.remove(render);
         _ui.buttonMode = false;
         _ui.useHandCursor = false;
         SoundCtrl.I.playSwcSound(snd_menu5);

         if (!_previewMc) {
            try {
               _previewMc = ResUtils.I.createDisplayObject(ResUtils.swfLib.menu, "menu_preview_mc") as MovieClip;
            } catch(err:Error) {
               trace("menu_preview_mc not found in menu.swf:", err);
            }
            if (_previewMc) {
               _previewMc.mouseEnabled = false;
               _previewMc.mouseChildren = false;
               _previewMc.alpha = 0;
               _previewMc.stop();
               _ui.addChild(_previewMc);
            }
         }

         _btnGroup = new MenuBtnGroup();
         _btnGroup.enabled = false;
         _btnGroup.x = 40;
         _btnGroup.y = 50;
         _btnGroup.onHoverChange = onMenuBtnHover;
         ct = _ui.getChildByName("btnct") as Sprite;
         if(ct)
         {
            ct.addChild(_btnGroup);
            _ui.setChildIndex(ct, _ui.numChildren - 1);
         }
         else
         {
            _ui.addChild(_btnGroup);
         }
         _btnGroup.build();
         _btnGroup.fadIn(0.2,0.04);
         updatePreview("single");
         setTimeout(function():void
         {
            _btnGroup.enabled = true;
         },400);
      }

      private function onMenuBtnHover(btn:MenuBtn, index:int, isChild:Boolean) : void
      {
         var frameName:String = null;
         if (!isChild) {
            frameName = PREVIEW_MAP[index];
         } else if (_btnGroup && _btnGroup.showIngChildrenBtn) {
            frameName = PREVIEW_MAP[_btnGroup.showIngChildrenBtn.index];
         }
         if (frameName != null) {
            updatePreview(frameName);
         }
      }

      private function updatePreview(frameName:String) : void
      {
         if (_bgMc) {
            _bgMc.gotoAndStop(frameName);
         }

         if (_curPreviewFrame == frameName) {
            return;
         }
         _curPreviewFrame = frameName;

         playMenuVoice(frameName);

         if (!_previewMc) {
            return;
         }

         var size:Object = PREVIEW_SIZES[frameName];
         var imgW:Number = size ? size.w : 450;
         var imgH:Number = size ? size.h : 720;
         var targetX:Number = 1280 - imgW;
         var targetY:Number = 720 - imgH;

         TweenLite.killTweensOf(_previewMc);
         if (_previewMc.alpha > 0.05) {
            TweenLite.to(_previewMc, 0.15, {
               "alpha": 0,
               "ease": Quad.easeIn,
               "onComplete": function():void {
                  _previewMc.gotoAndStop(frameName);
                  var curW:Number = _previewMc.width > 0 ? _previewMc.width : imgW;
                  var curH:Number = _previewMc.height > 0 ? _previewMc.height : imgH;
                  var curX:Number = 1280 - curW;
                  var curY:Number = 720 - curH;
                  _previewMc.x = curX + 30;
                  _previewMc.y = curY;
                  TweenLite.to(_previewMc, 0.25, {
                     "alpha": 1,
                     "x": curX,
                     "ease": Quad.easeOut
                  });
               }
            });
         } else {
            _previewMc.gotoAndStop(frameName);
            var curW:Number = _previewMc.width > 0 ? _previewMc.width : imgW;
            var curH:Number = _previewMc.height > 0 ? _previewMc.height : imgH;
            var curX:Number = 1280 - curW;
            var curY:Number = 720 - curH;
            _previewMc.x = curX + 30;
            _previewMc.y = curY;
            TweenLite.to(_previewMc, 0.3, {
               "alpha": 1,
               "x": curX,
               "ease": Quad.easeOut
            });
         }
      }

      private function playMenuVoice(frameName:String) : void
      {
         if (_curVoiceChannel)
         {
            try
            {
               _curVoiceChannel.stop();
            }
            catch(err:Error)
            {
            }
            _curVoiceChannel = null;
         }

         var sndName:String = SOUND_MAP[frameName];
         if (!sndName)
         {
            return;
         }

         try
         {
            var sndCls:Class = ResUtils.I.getItemClass(ResUtils.swfLib.menu, sndName);
            if (sndCls)
            {
               var snd:Sound = new sndCls() as Sound;
               if (snd)
               {
                  var vol:Number = 1;
                  try
                  {
                     if (GameData.I && GameData.I.config)
                     {
                        vol = GameData.I.config.soundVolume;
                     }
                  }
                  catch(cfgErr:Error)
                  {
                  }
                  var st:SoundTransform = new SoundTransform(vol);
                  _curVoiceChannel = snd.play(0, 0, st);
               }
            }
         }
         catch(e:Error)
         {
            trace("playMenuVoice error:", e);
         }
      }

      public function destory(completeHandler:Function = null) : void
      {
         if (_curVoiceChannel)
         {
            try
            {
               _curVoiceChannel.stop();
            }
            catch(err:Error)
            {
            }
            _curVoiceChannel = null;
         }
         _bgMc = null;
         if(_previewMc)
         {
            try
            {
               TweenLite.killTweensOf(_previewMc);
               if(_previewMc.parent)
               {
                  _previewMc.parent.removeChild(_previewMc);
               }
            }
            catch(e:Error)
            {
            }
            _previewMc = null;
         }
         _curPreviewFrame = "";
         if(_btnGroup)
         {
            try
            {
               _btnGroup.parent.removeChild(_btnGroup);
            }
            catch(e:Error)
            {
            }
            _btnGroup.destory();
            _btnGroup = null;
         }
         GameInputer.enabled = false;
      }
   }
}

