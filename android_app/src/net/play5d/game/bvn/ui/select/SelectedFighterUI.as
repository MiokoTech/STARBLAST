package net.play5d.game.bvn.ui.select
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.text.AntiAliasType;
   import flash.text.Font;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.getQualifiedClassName;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.utils.ResUtils;
   
   public class SelectedFighterUI extends EventDispatcher
   {
      public var ui:Sprite;
      
      public var trueY:Number = 0;
      
      private var _fighterIndex:int = -1;
      
      private var _face:DisplayObject;
      
      private var _fighter:FighterVO;
      
      private var _nameTf:TextField;
      
      private var _uiWidth:Number;
      private var _isP1:Boolean = true;
      private static var _selectedItemP1:Class;
      private static var _fontRegistered:Boolean = false;
      
      public function SelectedFighterUI(itemSprite:Sprite, isP1:Boolean = true)
      {
         super();
         this.ui = itemSprite;
         this._isP1 = isP1;
         itemSprite.mouseChildren = false;
         
         registerSelectFont();
         
         _nameTf = new TextField();
         _nameTf.selectable = false;
         _nameTf.mouseEnabled = false;
         _nameTf.antiAliasType = AntiAliasType.ADVANCED;
         _nameTf.filters = [new GlowFilter(0x000000, 1, 3, 3, 15, 3)];
         _nameTf.width = 400;
         _nameTf.height = 32;
         _nameTf.y = 526;
         if(_isP1)
         {
            _nameTf.x = 30;
         }
         else
         {
            _nameTf.x = 855;
         }
         itemSprite.addChild(_nameTf);
      }
      
      private static function registerSelectFont() : void
      {
         if(_fontRegistered)
         {
            return;
         }
         try
         {
            var fontCls:Class = ResUtils.I.getItemClass(ResUtils.swfLib.select, "mbtl_font");
            if(fontCls)
            {
               Font.registerFont(fontCls);
               _fontRegistered = true;
            }
         }
         catch(e:Error)
         {
         }
      }
      
      private static function isAsciiOnly(text:String) : Boolean
      {
         if(!text)
         {
            return true;
         }
         for(var i:int = 0; i < text.length; i++)
         {
            if(text.charCodeAt(i) > 127)
            {
               return false;
            }
         }
         return true;
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
      
      public function get nameTf() : TextField
      {
         return _nameTf;
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
         if(_nameTf)
         {
            if(_nameTf.parent)
            {
               try
               {
                  _nameTf.parent.removeChild(_nameTf);
               }
               catch(e:Error)
               {
               }
            }
            _nameTf = null;
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
         if(_nameTf)
         {
            registerSelectFont();
            var isAscii:Boolean = isAsciiOnly(fighter.name);
            var fontName:String = isAscii ? "MBTL_Name" : "SimHei";
            var fontSize:int = isAscii ? 22 : 20;
            var alignMode:String = _isP1 ? TextFormatAlign.RIGHT : TextFormatAlign.LEFT;
            
            var tfFormat:TextFormat = new TextFormat(fontName, fontSize, 0xFFFFFF, false, false, false, null, null, alignMode);
            _nameTf.embedFonts = isAscii;
            _nameTf.defaultTextFormat = tfFormat;
            _nameTf.text = fighter.name;
            _nameTf.setTextFormat(tfFormat);
            _nameTf.filters = [new GlowFilter(0x000000, 1, 3, 3, 15, 3)];
            _nameTf.visible = true;
            
            if(_nameTf.parent)
            {
               _nameTf.parent.setChildIndex(_nameTf, _nameTf.parent.numChildren - 1);
            }
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
         if(_nameTf && _nameTf.parent)
         {
            _nameTf.parent.setChildIndex(_nameTf, _nameTf.parent.numChildren - 1);
         }
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
         if(_nameTf && _nameTf.parent)
         {
            _nameTf.parent.setChildIndex(_nameTf, _nameTf.parent.numChildren - 1);
         }
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
