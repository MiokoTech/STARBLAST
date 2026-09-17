package net.play5d.game.bvn.ui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.bitmap.BitmapFontText;

   public class SetBtn extends Sprite
   {
      public var optionKey:String;
      public var onSelect:Function;
      private var _label:BitmapFontText;
      private var _options:Array;
      private var _optionIndex:int;
      private var _optionTxt:BitmapFontText;
      private var _prevArrow:MovieClip;
      private var _nextArrow:MovieClip;
      private var _line:SetBtnLine;
      private var _cn:String;

      public function SetBtn(param1:String, param2:String, param3:int = 0)
      {
         super();
         this.buttonMode = true;
         _label = new BitmapFontText(AssetManager.I.getFont("regular"));
         _label.text = param1;
         _label.scaleX = _label.scaleY = 0.7;
         _cn = param2;
         _line = new SetBtnLine(param3);
         _line.y = _label.height;
         _line.hide();
         addChild(_label);
      }

      public function get label() : String
      {
         return _label.text;
      }

      public function destory() : void
      {
         if(_label)
         {
            _label.dispose();
         }
         if (_line && contains(_line)) {
            removeChild(_line);
         }
         _line = null;
      }

      public function hover() : void
      {
         updateLine();
         if (!contains(_line)) {
            addChild(_line);
         }
      }

      private function updateLine() : void
      {
         var option:Object = getOption();
         if (option) {
            _line.show(width, _cn + option.cn);
         } else {
            _line.show(width,_cn);
         }
      }

      public function setLineVisible(isVisible:Boolean):void {
         if (isVisible) {
            updateLine();
            if (!contains(_line)) addChild(_line);
         } else {
           _line.hide();
            if (contains(_line)) removeChild(_line);
         }
      }

      public function hoverOut() : void
      {
         _line.hide();
         if (contains(_line)) {
            removeChild(_line);
         }
      }

      public function select() : void
      {
         var e:SetBtnEvent = new SetBtnEvent(SetBtnEvent.SELECT);
         e.selectedLabel = label;
         dispatchEvent(e);
         SoundCtrl.I.sndConfrim();
      }

      public function setOption(param1:Array) : void
      {
         _options = param1;
         _prevArrow = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting,"txt_arrow_mc");
         _nextArrow = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting,"txt_arrow_mc");
         _prevArrow.name = "prevArrow";
         _nextArrow.name = "nextArrow";
         _nextArrow.scaleX = -1;
         _prevArrow.y = _nextArrow.y = 17;
         _optionTxt = new BitmapFontText(AssetManager.I.getFont("regular"));
         addChild(_prevArrow);
         addChild(_nextArrow);
         addChild(_optionTxt);
         updateOption();
      }

      public function getOption() : Object
      {
         if (!_options) return null;
         return _options[_optionIndex];
      }

      public function nextOption() : void
      {
         if (!_options) return;

         var toIndex:int = _optionIndex + 1;
         if (toIndex > _options.length - 1) {
            toIndex = 0;
         }
         changeOption(toIndex);
         SoundCtrl.I.sndSelect();
      }

      public function prevOption() : void
      {
         if (!_options) return;

         var toIndex:int = _optionIndex - 1;
         if (toIndex < 0) {
            toIndex = _options.length - 1;
         }
         changeOption(toIndex);
         SoundCtrl.I.sndSelect();
      }

      public function setOptionByValue(value:Object) : void
      {
         for (var i:int; i < _options.length; i++) {
            var option:Object = _options[i];
            if (option.value == value) {
                changeOption(i, false);
                return;
            }
         }
      }

      private function changeOption(index:int, _dispatchEvent:Boolean = true) : void
      {
         _optionIndex = index;
         updateOption();
         updateLine();

         if (_dispatchEvent) {
            var e:SetBtnEvent = new SetBtnEvent(SetBtnEvent.OPTION_CHANGE);
            var option:Object = getOption();
            if (option) {
                e.optionKey   = optionKey;
                e.optionValue = option.value;
                dispatchEvent(e);
            }
         }
      }

      private function updateOption() : void
      {
         var _loc1_:String = getOption().label;
         _optionTxt.text = _loc1_;
         _prevArrow.x = 670;
         _optionTxt.x = _prevArrow.x + 40;
         _nextArrow.x = 810;
      }
   }
}

