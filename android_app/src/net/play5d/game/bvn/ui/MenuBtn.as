package net.play5d.game.bvn.ui
{
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.ColorTransform;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.BitmapText;
   import net.play5d.kyo.display.bitmap.BitmapFontText;
   
   public class MenuBtn extends EventDispatcher
   {
      public var ui:MovieClip;
      
      public var cn:String;
      
      public var label:String;
      
      public var value_cn:int;

      public var fontSize:int = 1;
      
      public var func:Function;
      
      public var height:Number = 55;
      
      public var index:int;
      
      public var children:Array;
      
      private var _bitmapText:BitmapFontText;
      
      private var _cnTxt:BitmapText;
      
      private var _listeners:Object = {};
      
      private var _isOpen:Boolean;
      
      public function MenuBtn(param1:String, param2:String = "", param3:int = 0, param4:Function = null)
      {
         super();
         this.label = param1;
         this.cn = param2;
         this.value_cn = param3;
         this.func = param4;
         ui = AssetManager.I.createObject("mc_wzbtns","data/swflib/menu_idt.swf") as MovieClip;
         ui.buttonMode = true;
         ui.mouseChildren = false;
         _bitmapText = new BitmapFontText(AssetManager.I.getFont("regular"));
         _bitmapText.text = param1;
         ui.addChild(_bitmapText);
         ui.bg.mouseChildren = false;
         ui.bg.mouseEnabled = false;
         ui.bg.visible = false;
         if(GameUI.SHOW_CN_TEXT)
         {
            _cnTxt = new BitmapText();
            UIUtils.formatText(_cnTxt.textfield,{
               "font":"黑体",
               "size":19
            });
            _cnTxt.text = param2;
            _cnTxt.color = 16777215;
            _cnTxt.y = param3;
            ui.bg.addChild(_cnTxt);
         }
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         if(ui.hasEventListener(param1))
         {
            return;
         }
         ui.addEventListener(param1,selfHandler,param3,param4,param5);
         _listeners[param1] = param2;
      }
      
      public function removeAllEventListener() : void
      {
         for(var i:String in _listeners)
         {
            ui.removeEventListener(i,_listeners[i]);
         }
         _listeners = {};
      }
      
      private function selfHandler(param1:Event) : void
      {
         _listeners[param1.type](param1.type,this);
      }
      
      public function isHover() : Boolean
      {
         return ui.bg.visible;
      }
      
      public function hover() : void
      {
         if(_isOpen)
         {
            return;
         }
         if(ui.bg.visible)
         {
            return;
         }
         ui.bg.visible = true;
         var _loc1_:Number = Number(ui.bg.scaleX);
         ui.bg.scaleX = 0.01;
         TweenLite.to(ui.bg,0.2,{"scaleX":_loc1_});
         SoundCtrl.I.sndSelect();
      }
      
      public function normal() : void
      {
         if(_isOpen)
         {
            return;
         }
         ui.bg.visible = false;
      }
      
      public function select(param1:Function = null) : void
      {
         param1();
         SoundCtrl.I.sndConfrim();
      }
      
      public function openChild() : void
      {
         if(_isOpen)
         {
            return;
         }
         _isOpen = true;
         ui.bg.gotoAndStop(1);
         var _loc1_:ColorTransform = new ColorTransform();
         _loc1_.redOffset = 23;
         _loc1_.greenOffset = 103;
         _loc1_.blueOffset = 167;
         _bitmapText.colorTransform(_loc1_);
      }
      
      public function closeChild() : void
      {
         if(!_isOpen)
         {
            return;
         }
         _isOpen = false;
         ui.bg.gotoAndStop(1);
         _bitmapText.colorTransform(null);
      }
      
      public function dispose() : void
      {
         if(_bitmapText)
         {
            _bitmapText.dispose();
            _bitmapText = null;
         }
         removeAllEventListener();
         if(children)
         {
            for each(var b:MenuBtn in children)
            {
               b.dispose();
            }
            children = null;
         }
         if(_cnTxt)
         {
            _cnTxt.destory();
            _cnTxt = null;
         }
      }
      
      public function childMode() : void
      {
         var _loc1_:ColorTransform = new ColorTransform();
         _loc1_.redOffset = 23;
         _loc1_.greenOffset = 103;
         _loc1_.blueOffset = 167;
         _bitmapText.colorTransform(_loc1_);
         ui.bg.gotoAndStop(1);
         height = 55;
      }
   }
}

