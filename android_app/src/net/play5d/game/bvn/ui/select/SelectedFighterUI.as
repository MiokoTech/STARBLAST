package net.play5d.game.bvn.ui.select
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.UIUtils;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.BitmapText;
   
   public class SelectedFighterUI extends EventDispatcher
   {
      public var ui:Sprite;
      
      public var trueY:Number = 0;
      
      private var _fighterIndex:int = -1;
      
      private var _face:DisplayObject;
      
      private var _fighter:FighterVO;
      
      private var _text:BitmapText;
      
      private var _uiWidth:Number;
      private var _isP1:Boolean = true;
      private static var _selectedItemP1:Class;
      
      public function SelectedFighterUI(itemSprite:Sprite)
      {
         super();
         this.ui = itemSprite;
         itemSprite.mouseChildren = false;
         
         if(!_selectedItemP1)
         {
            try
            {
               _selectedItemP1 = ResUtils.I.getItemClass(ResUtils.swfLib.select, "selected_item_p1_mc");
            }
            catch(e:Error)
            {
            }
         }
         _isP1 = _selectedItemP1 ? (itemSprite is _selectedItemP1) : true;
         
         if(GameUI.SHOW_CN_TEXT)
         {
            _text = new BitmapText(true,16777215,[new GlowFilter(0,1,3,3,3)]);
            if(_isP1)
            {
               UIUtils.formatText(_text.textfield,{
                  "color":16777215,
                  "size":16,
                  "align":"left"
               });
               _text.x = 25;
               _text.width = 300;
               _text.y = 350;
            }
            else
            {
               UIUtils.formatText(_text.textfield,{
                  "color":16777215,
                  "size":16,
                  "align":"right"
               });
               _text.x = -325;
               _text.width = 300;
               _text.y = 350;
            }
            itemSprite.addChild(_text);
         }
      }
      
      public function mouseEnabled(enabled:Boolean) : void
      {
         if(enabled)
         {
            if(GameConfig.TOUCH_MODE)
            {
               ui.addEventListener("touchTap",mouseHandler);
            }
            else
            {
               ui.buttonMode = true;
               ui.addEventListener("mouseOver",mouseHandler);
               ui.addEventListener("click",mouseHandler);
            }
         }
         else
         {
            ui.buttonMode = false;
            ui.removeEventListener("touchTap",mouseHandler);
            ui.removeEventListener("mouseOver",mouseHandler);
            ui.removeEventListener("click",mouseHandler);
         }
      }
      
      private function mouseHandler(event:Event) : void
      {
         dispatchEvent(event);
      }
      
      // Nonaktifkan interaksi mouse/touch tanpa menghapus portrait
      public function freeze() : void
      {
         mouseEnabled(false);
      }
      
      // Bersihkan seluruh aset UI dan event listener
      public function destory() : void
      {
         mouseEnabled(false);
         if(_text)
         {
            _text.destory();
            _text = null;
         }
         if(_face)
         {
            if(_face.parent)
            {
               try
               {
                  _face.parent.removeChild(_face);
               }
               catch(e:Error)
               {
               }
            }
            _face = null;
         }
      }
      
      // Tampilkan data petarung dan ilustrasi big portrait
      public function setFighter(fighter:FighterVO) : void
      {
         if(!fighter)
         {
            return;
         }
         _fighter = fighter;
         if(_text)
         {
            _text.text = fighter.name;
         }
         var ctOuter:Sprite = ui.getChildByName("ct") as Sprite;
         var ctInner:Sprite = ctOuter ? ctOuter.getChildByName("ct") as Sprite : null;
         var container:Sprite = ctInner ? ctInner : ctOuter;
         if(container)
         {
            if(_face)
            {
               try
               {
                  container.removeChild(_face);
               }
               catch(e:Error)
               {
               }
               _face = null;
            }
            var faceObj:DisplayObject = AssetManager.I.getFighterFaceBig(fighter);
            if(faceObj)
            {
               _face = faceObj;
               _face.y = 0;
               if(_isP1)
               {
                  container.x = 0;
                  _face.scaleX = Math.abs(_face.scaleX);
                  _face.x = 0;
               }
               else
               {
                  // Geser container P2 ke kiri dan mirror portrait agar tampil di tepi kanan layar
                  container.x = -550;
                  _face.scaleX = -Math.abs(_face.scaleX);
                  _face.x = 550;
               }
               container.scrollRect = new Rectangle(0, 0, 550, 720);
               container.addChild(_face);
            }
         }
      }
      
      public function getFighter() : FighterVO
      {
         return _fighter;
      }
      
      public function getFighterIndex() : int
      {
         return _fighterIndex;
      }
      
      public function setFighterIndex(index:int) : void
      {
         _fighterIndex = index;
         var badgeMc:MovieClip = ResUtils.I.createDisplayObject(ResUtils.swfLib.select,"seltwzmc");
         if(!badgeMc)
         {
            return;
         }
         badgeMc.gotoAndStop(index);
         ui.addChild(badgeMc);
         if(_isP1)
         {
            badgeMc.x = 20;
         }
         else
         {
            badgeMc.x = -60 - badgeMc.width;
         }
         badgeMc.y = 80;
         mouseEnabled(false);
      }
      
      public function setAssister() : void
      {
         var badgeMc:MovieClip = ResUtils.I.createDisplayObject(ResUtils.swfLib.select,"seltwzmc");
         if(!badgeMc)
         {
            return;
         }
         badgeMc.gotoAndStop(4);
         ui.addChild(badgeMc);
         if(_isP1)
         {
            badgeMc.x = 20;
         }
         else
         {
            badgeMc.x = -60 - badgeMc.width;
         }
         badgeMc.y = 80;
      }
   }
}

