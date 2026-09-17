package net.play5d.game.bvn.ui.select
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.SelectCharListItemVO;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.BitmapText;
   
   public class SelectFighterItem extends EventDispatcher
   {
      public var selectData:SelectCharListItemVO;
      
      public var fighterData:FighterVO;
      
      public var ui:MovieClip;
      
      public var position:Point;
      
      public var isMore:Boolean = false;
      
      private var faceSize:Point;
      
      private var _moreText:BitmapText;
      
      private var _listeners:Object;
      
      private var _tweenFrom:Point;
      
      private var _tweenTo:Point;
      
      public function SelectFighterItem(param1:FighterVO, param2:SelectCharListItemVO, param3:Boolean = false)
      {
         var _loc5_:ColorTransform = null;
         ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.select,"slt_item_mc") as MovieClip;
         position = new Point();
         faceSize = new Point(50,50);
         _listeners = {};
         super();
         this.isMore = param3;
         this.selectData = param2;
         this.fighterData = param1;
         var _loc4_:DisplayObject = AssetManager.I.getFighterFace(param1);
         if(_loc4_)
         {
            ui.ct.addChild(_loc4_);
         }
         ui.mouseChildren = false;
         ui.buttonMode = true;
         if(param2 && param2.moreFighterIDs)
         {
            initMoreUI();
         }
         if(ui.more_bg)
         {
            ui.more_bg.visible = param3;
            ui.more_bg.mouseEnabled = ui.more_bg.mouseChildren = false;
            _loc5_ = new ColorTransform();
            _loc5_.greenOffset = 255;
            _loc5_.blueOffset = -255;
            ui.more_bg.transform.colorTransform = _loc5_;
         }
      }
      
      public static function getIdByPoint(param1:int, param2:int) : String
      {
         return param1 + "," + param2;
      }
      
      public function get positionId() : String
      {
         return getIdByPoint(position.x,position.y);
      }
      
      private function initMoreUI() : void
      {
         var _loc1_:BitmapText = new BitmapText(false,16776960,[new GlowFilter(0,1,5,5,3)]);
         _loc1_.width = 50;
         _loc1_.defaultTextFormat.bold = true;
         _loc1_.defaultTextFormat.color = 16776960;
         _loc1_.defaultTextFormat.size = 16;
         _loc1_.align = "right";
         _loc1_.y = 2;
         _loc1_.text = selectData.moreFighterIDs.length + "+";
         _loc1_.update();
         ui.addChild(_loc1_);
         _moreText = _loc1_;
      }
      
      public function setMoreNumberVisible(param1:Boolean) : void
      {
         if(_moreText)
         {
            _moreText.visible = param1;
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
      
      public function initMoreTween(param1:Point, param2:Point) : void
      {
         _tweenFrom = param1;
         _tweenTo = param2;
      }
      
      public function showMore(param1:Number = 0.1) : void
      {
         var delay:Number = param1;
         ui.x = _tweenFrom.x;
         ui.y = _tweenFrom.y;
         ui.mouseEnabled = false;
         TweenLite.to(ui,0.2,{
            "x":_tweenTo.x,
            "y":_tweenTo.y,
            "ease":Back.easeOut,
            "delay":delay,
            "onComplete":function():void
            {
               ui.mouseEnabled = true;
            }
         });
      }
      
      public function hideMore() : void
      {
         TweenLite.to(ui,0.1,{
            "x":_tweenFrom.x,
            "y":_tweenFrom.y,
            "onComplete":function():void
            {
               try
               {
                  ui.parent.removeChild(ui);
               }
               catch(e:Error)
               {
               }
            }
         });
      }
      
      public function destory() : void
      {
         if(ui)
         {
            removeAllEventListener();
         }
         if(ui && ui.parent)
         {
            try
            {
               ui.parent.removeChild(ui);
            }
            catch(e:Error)
            {
            }
            ui = null;
         }
      }
   }
}

