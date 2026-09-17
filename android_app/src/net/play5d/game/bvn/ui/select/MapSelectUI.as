package net.play5d.game.bvn.ui.select
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.filters.GlowFilter;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.MapModel;
   import net.play5d.game.bvn.data.MapVO;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.UIUtils;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.BitmapText;
   import net.play5d.kyo.utils.KyoRandom;
   
   public class MapSelectUI extends Sprite
   {
      public var enabled:Boolean = false;
      
      public var inputType:String;

      public var _ui:MovieClip;
      
      private var _mapmc:MovieClip;
      
      private var _txtmc:MovieClip;
      
      private var _txt:BitmapText;
      
      private var _maps:Array;
      
      private var _curId:int;
      
      private var _picCache:Object = {};
      
      private var _prevListener:Function;
      
      private var _nextListener:Function;
      
      private var _confrimListener:Function;
      
      public function MapSelectUI()
      {
         super();
         build();
      }
      
      public function addMouseEvents(param1:Function, param2:Function, param3:Function) : void
      {
         _mapmc.left_arrow.buttonMode = true;
         _mapmc.right_arrow.buttonMode = true;
         _mapmc.kuang.buttonMode = true;
         _prevListener = param1;
         _nextListener = param2;
         _confrimListener = param3;
         if(GameConfig.TOUCH_MODE)
         {
            _mapmc.left_arrow.addEventListener("touchTap",touchHandler);
            _mapmc.right_arrow.addEventListener("touchTap",touchHandler);
            _mapmc.kuang.addEventListener("touchTap",touchHandler);
         }
         else
         {
            _mapmc.left_arrow.addEventListener("mouseOver",mouseHandler);
            _mapmc.right_arrow.addEventListener("mouseOver",mouseHandler);
            _mapmc.kuang.addEventListener("mouseOver",mouseHandler);
            _mapmc.left_arrow.addEventListener("click",mouseHandler);
            _mapmc.right_arrow.addEventListener("click",mouseHandler);
            _mapmc.kuang.addEventListener("click",mouseHandler);
         }
      }
      
      private function touchHandler(param1:TouchEvent) : void
      {
         switch(param1.currentTarget)
         {
            case _mapmc.left_arrow:
               if(_prevListener != null)
               {
                  _prevListener();
               }
               break;
            case _mapmc.right_arrow:
               if(_nextListener != null)
               {
                  _nextListener();
               }
               break;
            case _mapmc.kuang:
               if(_confrimListener != null)
               {
                  _confrimListener();
               }
         }
         SoundCtrl.I.sndConfrim();
      }
      
      private function mouseHandler(param1:MouseEvent) : void
      {
         if(param1.type == "mouseOver")
         {
            SoundCtrl.I.sndSelect();
            return;
         }
         switch(param1.currentTarget)
         {
            case _mapmc.left_arrow:
               if(_prevListener != null)
               {
                  _prevListener();
               }
               break;
            case _mapmc.right_arrow:
               if(_nextListener != null)
               {
                  _nextListener();
               }
               break;
            case _mapmc.kuang:
               if(_confrimListener != null)
               {
                  _confrimListener();
               }
         }
         SoundCtrl.I.sndConfrim();
      }
      
      private function build() : void
      {
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.select,"stg_set_ui") as MovieClip;
         addChild(_ui);
         _mapmc = ResUtils.I.createDisplayObject(ResUtils.swfLib.select,"select_map_mc") as MovieClip;
         _maps = MapModel.I.getAllMaps();
         _mapmc.x = (GameConfig.GAME_SIZE.x - _mapmc.bg.width) / 2;
         _mapmc.y = GameConfig.GAME_SIZE.y * 0.25;
         _mapmc.ct.x -= 2;
         addChild(_mapmc);
         if(GameUI.SHOW_CN_TEXT)
         {
            _txtmc = ResUtils.I.createDisplayObject(ResUtils.swfLib.select,"select_map_txt_mc") as MovieClip;
            _txtmc.x = (GameConfig.GAME_SIZE.x - _txtmc.width) / 2;
            _txtmc.y = GameConfig.GAME_SIZE.y - _txtmc.height - 35;
            addChild(_txtmc);
            _txt = new BitmapText(true,16777215,[new GlowFilter(0,1,3,3,3)]);
            UIUtils.formatText(_txt.textfield,{
               "color":16777215,
               "size":14,
               "align":"center"
            });
            _txt.width = _txtmc.width;
            _txtmc.addChild(_txt);
         }
         showMap(0);
      }
      
      public function destory() : void
      {
         _prevListener = null;
         _nextListener = null;
         _confrimListener = null;
         if(_mapmc)
         {
            _mapmc.left_arrow.removeEventListener("touchTap",touchHandler);
            _mapmc.right_arrow.removeEventListener("touchTap",touchHandler);
            _mapmc.kuang.removeEventListener("touchTap",touchHandler);
            _mapmc.left_arrow.removeEventListener("mouseOver",mouseHandler);
            _mapmc.right_arrow.removeEventListener("mouseOver",mouseHandler);
            _mapmc.kuang.removeEventListener("mouseOver",mouseHandler);
            _mapmc.left_arrow.removeEventListener("click",mouseHandler);
            _mapmc.right_arrow.removeEventListener("click",mouseHandler);
            _mapmc.kuang.removeEventListener("click",mouseHandler);
         }
         if(this.parent)
         {
            try
            {
               this.parent.removeChild(this);
            }
            catch(e:Error)
            {
            }
         }
         if(_txt)
         {
            _txt.destory();
            _txt = null;
         }
      }
      
      public function select(param1:Function) : void
      {
         var _loc2_:MapVO = _maps[_curId];
         if(_loc2_)
         {
            while(_loc2_.id == "random")
            {
               _loc2_ = KyoRandom.getRandomInArray(_maps);
            }
            GameData.I.selectMap = _loc2_.id;
            enabled = false;
            if(param1 != null)
            {
               param1();
            }
         }
      }
      
      public function prev() : void
      {
         var _loc1_:int = _curId - 1;
         if(_loc1_ < 0)
         {
            _loc1_ = _maps.length - 1;
         }
         showMap(_loc1_);
      }
      
      public function next() : void
      {
         var _loc1_:int = _curId + 1;
         if(_loc1_ > _maps.length - 1)
         {
            _loc1_ = 0;
         }
         showMap(_loc1_);
      }
      
      private function showMap(param1:int) : void
      {
         _curId = param1;
         var _loc2_:MapVO = _maps[param1];
         var _loc3_:DisplayObject = getPic(_loc2_);
         _mapmc.ct.removeChildren();
         if(_loc3_)
         {
            _mapmc.ct.addChild(_loc3_);
         }
         if(_txt)
         {
            _txt.text = _loc2_.name;
         }
      }
      
      private function getPic(param1:MapVO) : DisplayObject
      {
         var _loc2_:DisplayObject = _picCache[param1.id];
         if(_loc2_)
         {
            return _loc2_;
         }
         _loc2_ = AssetManager.I.getMapPic(param1);
         _picCache[param1.id] = _loc2_;
         return _loc2_;
      }
   }
}

