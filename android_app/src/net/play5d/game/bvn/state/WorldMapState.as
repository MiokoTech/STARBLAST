package net.play5d.game.bvn.state
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.ctrl.StateCtrl;
   import net.play5d.game.bvn.ctrl.mosou_ctrls.MosouLogic;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.mosou.MosouModel;
   import net.play5d.game.bvn.data.mosou.MosouWorldMapAreaVO;
   import net.play5d.game.bvn.data.mosou.MosouWorldMapVO;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.bigmap.BigmapClould;
   import net.play5d.game.bvn.ui.bigmap.WorldMapPointUI;
   import net.play5d.game.bvn.ui.dialog.DialogManager;
   import net.play5d.game.bvn.utils.BtnUtils;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.game.bvn.utils.TouchMoveEvent;
   import net.play5d.game.bvn.utils.TouchUtils;
   import net.play5d.kyo.stage.Istage;
   
   public class WorldMapState implements Istage
   {
      private var _ui:Sprite;
      
      private var _mapUI:Sprite;
      
      private var _viewMc:Sprite;
      
      private var _pointMc:Sprite;
      
      private var _maskMc:Sprite;
      
      private var _bgMc:Sprite;
      
      private var _pointUIs:Vector.<WorldMapPointUI>;
      
      private var _downUIPos:Point = new Point();
      
      private var _downMousePos:Point = new Point();
      
      private var _scale:Number = 1;
      
      private var _position:Point = new Point();
      
      private var _currentPoint:WorldMapPointUI;
      
      private var _cloudUI:BigmapClould;
      
      private var _backBtn:DisplayObject;
      
      public function WorldMapState()
      {
         super();
      }
      
      public function get display() : DisplayObject
      {
         return _ui;
      }
      
      public function build() : void
      {
         _ui = new Sprite();
         _mapUI = ResUtils.I.createDisplayObject(ResUtils.swfLib.bigmap,ResUtils.BIG_MAP);
         _ui.addChild(_mapUI);
         _viewMc = _mapUI.getChildByName("view_mc") as Sprite;
         _pointMc = _mapUI.getChildByName("point_mc") as Sprite;
         _maskMc = _mapUI.getChildByName("mask_mc") as Sprite;
         _bgMc = _mapUI.getChildByName("bg_mc") as Sprite;
         _backBtn = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog,"backbtn_btn");
         if(_backBtn)
         {
            _backBtn.x = _backBtn.y = 10;
            BtnUtils.initBtn(_backBtn,backHandler);
            _ui.addChild(_backBtn);
         }
         _viewMc.mask = _maskMc;
         _viewMc.cacheAsBitmap = true;
         _maskMc.cacheAsBitmap = true;
         MosouLogic.I.updateMapAreas();
         initPointUIs();
         _cloudUI = new BigmapClould(_mapUI.getBounds(_mapUI));
         _ui.addChild(_cloudUI);
         _cloudUI.init();
         StateCtrl.I.transOut();
         GameEvent.addEventListener("MOSOU_FIGHTER_UPDATE",updatePointsUI);
         GameRender.add(render,this);
         SoundCtrl.I.BGM(AssetManager.I.getSound("back"));
      }
      
      private function render() : void
      {
         _cloudUI.render();
      }
      
      private function updatePointsUI(param1:GameEvent = null) : void
      {
         for each(var p:WorldMapPointUI in _pointUIs)
         {
            p.update();
         }
      }
      
      private function initPointUIs() : void
      {
         var _loc2_:DisplayObject = null;
         var _loc6_:int = 0;
         var _loc4_:WorldMapPointUI = null;
         var _loc3_:Object = {};
         var _loc1_:Object = {};
         _loc6_ = 0;
         while(_loc6_ < _pointMc.numChildren)
         {
            _loc2_ = _pointMc.getChildAt(_loc6_);
            if(_loc2_ != null)
            {
               _loc3_[_loc2_.name] = _loc2_;
               _loc2_.visible = false;
            }
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < _maskMc.numChildren)
         {
            _loc2_ = _maskMc.getChildAt(_loc6_);
            if(_loc2_ != null)
            {
               _loc1_[_loc2_.name] = _loc2_;
               _loc2_.visible = false;
            }
            _loc6_++;
         }
         _pointUIs = new Vector.<WorldMapPointUI>();
         var _loc7_:MosouWorldMapVO = MosouModel.I.getMap(GameData.I.mosouData.getCurrentMap().id);
         var _loc5_:Vector.<MosouWorldMapAreaVO> = _loc7_.areas;
         for each(var m:MosouWorldMapAreaVO in _loc5_)
         {
            if(_loc3_[m.id])
            {
               _loc4_ = new WorldMapPointUI(_loc3_[m.id],_loc1_[m.id],m);
               _loc4_.addEventListener("EVENT_SELECT",onSelectPoint);
               _pointUIs.push(_loc4_);
            }
         }
      }
      
      private function onSelectPoint(param1:Event) : void
      {
         var _loc2_:WorldMapPointUI = param1.currentTarget as WorldMapPointUI;
         var _loc3_:MosouWorldMapAreaVO = _loc2_.data;
         if(_loc3_.building())
         {
            GameUI.alert("NOT OPEN","暂未开放");
            return;
         }
         GameEvent.dispatchEvent("MOSOU_MAP");
         if(MosouLogic.I.checkCurrentArea(_loc3_.id))
         {
            gotoMission(_loc3_);
         }
         else
         {
            GameData.I.mosouData.setCurrentArea(_loc3_.id);
            updatePointsUI();
         }
      }
      
      private function gotoMission(param1:MosouWorldMapAreaVO) : void
      {
         var data:MosouWorldMapAreaVO = param1;
         var allFinish:Boolean = MosouLogic.I.getAreaPercent(data.id) >= 1;
         var txt:String = allFinish ? "已通过全部关卡，是否进入最后一关？" : "进入下一关？";
         GameUI.confrim("CONFRIM",txt,function():void
         {
            MosouModel.I.currentMission = MosouLogic.I.getNextMission(data);
            StateCtrl.I.transIn(MainGame.I.loadGame,true);
         });
         GameEvent.dispatchEvent("CONFRIM_MOSOU_NEXT_MISSION");
      }
      
      private function focusCurrentPoint() : void
      {
         var _loc1_:* = null;
         for each(var i:WorldMapPointUI in _pointUIs)
         {
            if(MosouLogic.I.checkCurrentArea(i.data.id))
            {
               _loc1_ = i;
               break;
            }
         }
         if(!_loc1_)
         {
            return;
         }
         _currentPoint = _loc1_;
         var _loc2_:Point = new Point(GameConfig.GAME_SIZE.x / 2,GameConfig.GAME_SIZE.y / 2);
         _scale = 1.5;
         _position.x = _loc2_.x - _loc1_.getPosition().x * _scale;
         _position.y = _loc2_.y - _loc1_.getPosition().y * _scale;
         renderPosAndSize();
      }
      
      public function afterBuild() : void
      {
         initDrag();
         focusCurrentPoint();
      }
      
      private function initDrag() : void
      {
         if(GameConfig.TOUCH_MODE)
         {
            TouchUtils.I.listenOneFinger(MainGame.I.stage,touchMoveHandler);
            TouchUtils.I.listenTwoFinger(MainGame.I.stage,touchZoomHandler);
         }
         else
         {
            MainGame.I.stage.addEventListener("mouseDown",mouseHandler);
            MainGame.I.stage.addEventListener("mouseUp",mouseHandler);
            MainGame.I.stage.addEventListener("mouseWheel",mouseHandler);
         }
      }
      
      private function touchMoveHandler(param1:TouchMoveEvent) : void
      {
         if(param1.type == "EVENT_TOUCH_MOVE")
         {
            _position.x += param1.deltaX;
            _position.y += param1.deltaY;
            renderPosAndSize();
         }
      }
      
      private function touchZoomHandler(param1:TouchMoveEvent) : void
      {
         if(param1.type == "EVENT_TOUCH_MOVE")
         {
            _scale += param1.delta;
            renderPosAndSize(true);
         }
      }
      
      private function mouseHandler(param1:MouseEvent) : void
      {
         if(DialogManager.showingDialog())
         {
            return;
         }
         switch(param1.type)
         {
            case "mouseDown":
               _downUIPos.x = _position.x;
               _downUIPos.y = _position.y;
               _downMousePos.x = MainGame.I.stage.mouseX;
               _downMousePos.y = MainGame.I.stage.mouseY;
               _mapUI.removeEventListener("enterFrame",renderDrag);
               _mapUI.addEventListener("enterFrame",renderDrag);
               break;
            case "mouseUp":
               _mapUI.removeEventListener("enterFrame",renderDrag);
               break;
            case "mouseWheel":
               if(param1.delta < 0)
               {
                  _scale -= 0.1;
               }
               else
               {
                  _scale += 0.1;
               }
               renderPosAndSize(true);
         }
      }
      
      private function renderDrag(param1:Event) : void
      {
         _position.x = MainGame.I.stage.mouseX - _downMousePos.x + _downUIPos.x;
         _position.y = MainGame.I.stage.mouseY - _downMousePos.y + _downUIPos.y;
         renderPosAndSize();
      }
      
      private function renderPosAndSize(param1:Boolean = false) : void
      {
         var _loc3_:Number = NaN;
         if(_scale < 1)
         {
            _scale = 1;
         }
         if(_scale > 2)
         {
            _scale = 2;
         }
         if(param1 && _currentPoint)
         {
            _loc3_ = _mapUI.scaleX - _scale;
            if(_loc3_ != 0)
            {
               _position.x += _currentPoint.getPosition().x * _loc3_;
               _position.y += _currentPoint.getPosition().y * _loc3_;
            }
         }
         var _loc4_:Number = GameConfig.GAME_SIZE.x - _bgMc.width * _scale;
         var _loc2_:Number = GameConfig.GAME_SIZE.y - _bgMc.height * _scale;
         if(_position.x > 0)
         {
            _position.x = 0;
         }
         if(_position.y > 0)
         {
            _position.y = 0;
         }
         if(_position.x < _loc4_)
         {
            _position.x = _loc4_;
         }
         if(_position.y < _loc2_)
         {
            _position.y = _loc2_;
         }
         _mapUI.scaleX = _mapUI.scaleY = _scale;
         _mapUI.x = _position.x;
         _mapUI.y = _position.y;
         _cloudUI.scaleX = _cloudUI.scaleY = _scale * 0.8;
         _cloudUI.x = _position.x * 0.8;
         _cloudUI.y = _position.y * 0.8;
      }
      
      private function backHandler(... rest) : void
      {
         GameUI.confrim("EXIT","返回到游戏主菜单？",MainGame.I.goMenu);
         GameEvent.dispatchEvent("CONFRIM_BACK_MENU");
      }
      
      public function destory(param1:Function = null) : void
      {
         GameRender.remove(render,this);
         TouchUtils.I.unlistenOneFinger(MainGame.I.stage);
         TouchUtils.I.unlistenTwoFinger(MainGame.I.stage);
         MainGame.I.stage.removeEventListener("mouseDown",mouseHandler);
         MainGame.I.stage.removeEventListener("mouseUp",mouseHandler);
         MainGame.I.stage.removeEventListener("mouseWheel",mouseHandler);
         GameEvent.removeEventListener("MOSOU_FIGHTER_UPDATE",updatePointsUI);
         if(_backBtn)
         {
            BtnUtils.destoryBtn(_backBtn);
            _backBtn = null;
         }
         if(_cloudUI)
         {
            _cloudUI.destory();
            _cloudUI = null;
         }
         if(_pointUIs)
         {
            for each(var p:WorldMapPointUI in _pointUIs)
            {
               p.destory();
            }
            _pointUIs = null;
         }
         if(_mapUI)
         {
            try
            {
               _ui.removeChild(_mapUI);
            }
            catch(e:Error)
            {
            }
            _mapUI = null;
         }
      }
   }
}

