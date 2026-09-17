package net.play5d.game.bvn.state
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameSpriteUtil;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.ctrler.FighterAICtrl;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.game.bvn.map.MapMain;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.kyo.stage.Istage;
   
   public class GameState extends Sprite implements Istage
   {
      private var _gameLayer:Sprite = new Sprite();
      private var _playerLayer:Sprite = new Sprite();
      private var _gameSprites:Vector.<IGameSprite> = new Vector.<IGameSprite>();
      private var _map:MapMain;
      public var camera:GameCamera;
      private var _cameraFocus:Array;
      public var gameUI:GameUI;
      
      public function GameState()
      {
         super();
         _gameLayer.mouseChildren = _gameLayer.mouseEnabled = false;
      }
      
      public function get gameLayer() : Sprite
      {
         return _gameLayer;
      }
      
      public function getMap() : MapMain
      {
         return _map;
      }
      
      public function setVisibleByClass(param1:Class, param2:*) : void
      {
         var _loc4_:String = null;
         var _loc5_:Class = null;
         for each(var d:IGameSprite in _gameSprites)
         {
            _loc4_ = getQualifiedClassName(d);
            _loc5_ = getDefinitionByName(_loc4_) as Class;
            if(_loc5_ == param1)
            {
               d.getDisplay().visible = param2;
            }
         }
      }
      
      public function getFighterByData(param1:FighterVO) : FighterMain
      {
         for each(var d:IGameSprite in _gameSprites)
         {
            if(d is FighterMain && (d as FighterMain).data == param1)
            {
               return d as FighterMain;
            }
         }
         return null;
      }
      
      public function get display() : DisplayObject
      {
         return this;
      }
      
      public function getGameSpriteGlobalPosition(sp:IGameSprite, offsetX:Number = 0, offsetY:Number = 0) : Point
      {
         var zoom:Number    = camera.getZoom(true);
         var rect:Rectangle = camera.getScreenRect(true);

         var point:Point = new Point();
         point.x = (-rect.x + sp.x + offsetX) * zoom;
         point.y = (-rect.y + sp.y + offsetY) * zoom;

         return point;
      }
      
      public function getGameSprites() : Vector.<IGameSprite>
      {
         return _gameSprites;
      }
      
      public function addGameSprite(param1:IGameSprite) : void
      {
         param1.setActive(true);
         if(_gameSprites.indexOf(param1) != -1)
         {
            return;
         }
         _gameSprites.push(param1);
         _playerLayer.addChild(param1.getDisplay());
         param1.setVolume(GameData.I.config.soundVolume);
         param1.setSpeedRate(GameConfig.SPEED_PLUS);
      }
      
      public function addGameSpriteAt(param1:IGameSprite, param2:int) : void
      {
         param1.setActive(true);
         if(_gameSprites.indexOf(param1) != -1)
         {
            return;
         }
         _gameSprites.push(param1);
         _playerLayer.addChildAt(param1.getDisplay(),param2);
         param1.setVolume(GameData.I.config.soundVolume);
         param1.setSpeedRate(GameConfig.SPEED_PLUS);
      }
      
      public function removeGameSprite(param1:IGameSprite, param2:Boolean = false) : void
      {
         var _loc3_:int;
         if(param2)
         {
            param1.destory(true);
         }
         else
         {
            param1.setActive(false);
         }
         _loc3_ = int(_gameSprites.indexOf(param1));
         if(_loc3_ == -1)
         {
            return;
         }
         _gameSprites.splice(_loc3_,1);
         try
         {
            _playerLayer.removeChild(param1.getDisplay());
         }
         catch(e:Error)
         {
         }
      }
      
      public function build() : void
      {
         GameCtrl.I.initlize(this);
         EffectCtrl.I.initlize(this,_playerLayer);
         gameUI = new GameUI();
         GameEvent.dispatchEvent(GameEvent.FIGHT_START);
      }
      
      public function initFight(param1:GameRunFighterGroup, param2:GameRunFighterGroup, param3:MapMain) : void
      {
         var _loc6_:Point = null;
         EffectCtrl.SHADOW_ENABLED = true;
         _map = param3;
         _map.gameState = this;
         if(_map.bgLayer)
         {
            addChild(_map.bgLayer);
         }
         addChild(_gameLayer);
         if(_map.mapLayer)
         {
            _gameLayer.addChild(_map.mapLayer);
         }
         _gameLayer.addChild(_playerLayer);
         if(_map.frontFixLayer)
         {
            _gameLayer.addChild(_map.frontFixLayer);
         }
         _gameLayer.addChild(_map.frontLayer);
         _cameraFocus = [];
         var _loc5_:FighterMain = param1.currentFighter;
         var _loc4_:FighterMain = param2.currentFighter;
         if(GameMode.currentMode == 24 || GameMode.currentMode == 25)
         {
            var _loc8_:FighterMain = param2.nextFighter2;
         }
         if(GameMode.currentMode == 14 || GameMode.currentMode == 15)
         {
            var _loc7_:FighterMain = param1.nextFighter1;
            _loc8_ = param2.nextFighter2;
         }
         if(_loc5_)
         {
            GameLogic.resetFighterHP(_loc5_);
            _loc5_.x = _map.p1pos.x + 40;
            _loc5_.y = _map.p1pos.y;
            _loc5_.direct = 1;
            _loc5_.updatePosition();
            _cameraFocus.push(_loc5_.getDisplay());
         }
         if(_loc4_)
         {
            GameLogic.resetFighterHP(_loc4_);
            if(GameMode.isAcrade())
            {
               GameLogic.setMessionEnemyAttack(_loc4_);
            }
            _loc4_.x = _map.p2pos.x;
            _loc4_.y = _map.p2pos.y;
            _loc4_.direct = -1;
            _loc4_.updatePosition();
            _cameraFocus.push(_loc4_.getDisplay());
         }
         if(_loc7_)
         {
            GameLogic.resetFighterHP(_loc7_);
            _loc7_.x = _map.p1pos.x;
            _loc7_.y = _map.p1pos.y;
            _loc7_.direct = -1;
            _loc7_.idle();
            _loc7_.updatePosition();
         }
         if(_loc8_)
         {
            GameLogic.resetFighterHP(_loc8_);
            _loc8_.x = _map.p2pos.x + 40;
            _loc8_.y = _map.p2pos.y;
            _loc8_.direct = 1;
            _loc8_.updatePosition();
         }
         if(_map.mapLayer)
         {
            _loc6_ = new Point(_map.mapLayer.width,GameConfig.GAME_SIZE.y);
            initCamera();
            camera.focus(_cameraFocus);
            gameUI.initFight(param1,param2);
            addChild(gameUI.getUIDisplay());
            return;
         }
         throw new Error("map is error! :: mapLayer is null!");
      }
      
      public function resetFight(param1:GameRunFighterGroup, param2:GameRunFighterGroup) : void
      {
         var _loc4_:FighterMain = param1.currentFighter;
         var _loc3_:FighterMain = param2.currentFighter;
         EffectCtrl.SHADOW_ENABLED = true;
         _cameraFocus = [];
         
         if(_loc4_) _loc4_.setActive(true);
         if(_loc3_) _loc3_.setActive(true);

         if(GameMode.currentMode == 24 || GameMode.currentMode == 25)
         {
            var _loc8_:FighterMain = param2.nextFighter2;
            if(_loc8_) _loc8_.setActive(true);
         }
         if(GameMode.currentMode == 14 || GameMode.currentMode == 15)
         {
            var _loc5_:FighterMain = param1.nextFighter1;
            _loc8_ = param2.nextFighter2;
            if(_loc5_) _loc5_.setActive(true);
            if(_loc8_) _loc8_.setActive(true);
         }
         if(_loc4_)
         {
            GameLogic.resetFighterHP(_loc4_);
            _loc4_.x = _map.p1pos.x + 40;
            _loc4_.y = _map.p1pos.y;
            _loc4_.direct = 1;
            _loc4_.idle();
            _loc4_.updatePosition();
            resetFighterRoundAI(_loc4_);
            _cameraFocus.push(_loc4_.getDisplay());
         }
         if(_loc3_)
         {
            GameLogic.resetFighterHP(_loc3_);
            if(GameMode.isAcrade())
            {
               GameLogic.setMessionEnemyAttack(_loc3_);
            }
            _loc3_.x = _map.p2pos.x;
            _loc3_.y = _map.p2pos.y;
            _loc3_.direct = -1;
            _loc3_.idle();
            _loc3_.updatePosition();
            resetFighterRoundAI(_loc3_);
            _cameraFocus.push(_loc3_.getDisplay());
         }
         if(_loc5_)
         {
            GameLogic.resetFighterHP(_loc5_);
            _loc5_.x = _map.p1pos.x;
            _loc5_.y = _map.p1pos.y;
            _loc5_.direct = -1;
            _loc5_.idle();
            _loc5_.updatePosition();
            resetFighterRoundAI(_loc5_);
         }
         if(_loc8_)
         {
            GameLogic.resetFighterHP(_loc8_);
            _loc8_.x = _map.p2pos.x + 40;
            _loc8_.y = _map.p2pos.y;
            _loc8_.direct = -1;
            _loc8_.idle();
            _loc8_.updatePosition();
            resetFighterRoundAI(_loc8_);
         }
         gameUI.initFight(param1,param2);
         cameraResume();
      }
      
      private function resetFighterRoundAI(fighter:FighterMain) : void
      {
         var fighterAICtrl:FighterAICtrl = null;
         if(fighter == null || fighter.getCtrler() == null || fighter.getCtrler().getMcCtrl() == null)
         {
            return;
         }
         fighterAICtrl = fighter.getCtrler().getMcCtrl().getActionCtrler() as FighterAICtrl;
         if(fighterAICtrl != null)
         {
            fighterAICtrl.resetRoundAIState();
         }
      }
      
      public function cameraFocusOne(param1:DisplayObject) : void
      {
         camera.focus([param1]);
         camera.setZoom(getCameraFocusOneZoom());
         camera.tweenSpd = getCameraTweenSpd();
      }
      
      public function updateCameraFocus(param1:Array) : void
      {
         _cameraFocus = param1;
         camera.focus(param1);
         camera.setZoom(getCameraGroupFocusZoom());
         camera.tweenSpd = getCameraTweenSpd();
      }
      
      public function cameraResume() : void
      {
         camera.focus(_cameraFocus);
         if(_cameraFocus.length < 2 || !camera.autoZoom)
         {
            camera.setZoom(getCameraGroupFocusZoom());
         }
         camera.tweenSpd = getCameraTweenSpd();
      }

      private function getCameraStyle() : int
      {
         var _loc1_:int = GameConfig.CAMERA_STYLE;
         if(GameData.I && GameData.I.config)
         {
            _loc1_ = int(GameData.I.config.cameraStyle);
         }
         if(_loc1_ < GameConfig.CAMERA_STYLE_BVN || _loc1_ > GameConfig.CAMERA_STYLE_STARBLAST)
         {
            _loc1_ = GameConfig.CAMERA_STYLE_BVN;
         }
         return _loc1_;
      }

      private function getCameraTweenSpd() : Number
      {
         var _loc1_:int = getCameraStyle();
         switch(_loc1_)
         {
            case GameConfig.CAMERA_STYLE_STARBLAST:
               return 2.2 / GameConfig.SPEED_PLUS_DEFAULT;
            default:
               return 2.5 / GameConfig.SPEED_PLUS_DEFAULT;
         }
      }

      private function getCameraGroupFocusZoom() : Number
      {
         var _loc1_:Number = 2.5;
         if(GameData.I && GameData.I.config)
         {
            _loc1_ = Number(GameData.I.config.cameraDistance);
         }
         if(_loc1_ < 1.2)
         {
            _loc1_ = 1.2;
         }
         if(_loc1_ > 3.2)
         {
            _loc1_ = 3.2;
         }
         switch(getCameraStyle())
         {
            case GameConfig.CAMERA_STYLE_STARBLAST:
               _loc1_ += 0.2;
               break;
         }
         if(_loc1_ > 3.2)
         {
            _loc1_ = 3.2;
         }
         return _loc1_;
      }

      private function getCameraFocusOneZoom() : Number
      {
         var _loc1_:Number = getCameraGroupFocusZoom();
         switch(getCameraStyle())
         {
            case GameConfig.CAMERA_STYLE_STARBLAST:
               _loc1_ += 0.45;
               break;
            default:
               _loc1_ += 0.5;
         }
         if(_loc1_ > 3.2)
         {
            _loc1_ = 3.2;
         }
         return _loc1_;
      }
      
      private function initCamera() : void
      {
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(camera)
         {
            throw new Error("camera inited!");
         }
         var _loc1_:Point = _map.getStageSize();
         camera = new GameCamera(_gameLayer,GameConfig.GAME_SIZE,_loc1_,true);
         camera.focusX = true;
         camera.focusY = true;
         camera.offsetY = _map.getMapBottomDistance();
         camera.setStageBounds(new Rectangle(0,-1000,_loc1_.x,_loc1_.y));
         _loc5_ = getCameraStyle();
         _loc6_ = int(1 / GameData.I.config.cameraZoomRate * 100) / 100;
         if(_loc6_ < 1)
         {
            _loc6_ = 1;
         }
         if(_loc6_ > 3)
         {
            _loc6_ = 3;
         }
         switch(_loc5_)
         {
            case GameConfig.CAMERA_STYLE_STARBLAST:
               camera.focusY = true;
               camera.autoZoom = true;
               camera.autoZoomMin = _loc6_;
               camera.autoZoomMax = 3.2;
               camera.offsetY = _map.getMapBottomDistance() - 8;
               break;
            default:
               camera.focusY = true;
               camera.autoZoom = true;
               camera.autoZoomMin = _loc6_;
               camera.autoZoomMax = 3;
               camera.offsetY = _map.getMapBottomDistance();
         }
         camera.tweenSpd = getCameraTweenSpd();
         var _loc4_:Number = getCameraGroupFocusZoom();
         _loc7_ = GameConfig.GAME_SIZE.x * 0.5;
         _loc8_ = GameConfig.GAME_SIZE.y * (200 / 420);
         var _loc3_:Number = _loc1_.x / 2 * _loc4_ - _loc7_;
         var _loc2_:Number = _map.bottom - _loc8_;
         camera.setZoom(_loc4_);
         camera.setX(-_loc3_);
         camera.setY(-_loc2_);
         camera.updateNow();
      }
      
      public function render() : void
      {
         var _loc1_:Rectangle = null;
         if(camera)
         {
            camera.render();
         }
         if(gameUI)
         {
            gameUI.render();
         }
         if(_map && camera)
         {
            _loc1_ = camera.getScreenRect(true);
            _map.render(-_loc1_.x,-_loc1_.y,camera.getZoom(true));
         }
      }
      
      public function drawGameRect(param1:Rectangle, param2:uint = 16711680, param3:Number = 0.5, param4:Boolean = false) : void
      {
         if(param4)
         {
            _gameLayer.graphics.clear();
         }
         _gameLayer.graphics.beginFill(param2,param3);
         _gameLayer.graphics.drawRect(param1.x,param1.y,param1.width,param1.height);
         _gameLayer.graphics.endFill();
      }
      
      public function clearDrawGameRect() : void
      {
         _gameLayer.graphics.clear();
      }
      
      public function afterBuild() : void
      {
      }
      
      public function destory(param1:Function = null) : void
      {
         this.removeChildren();
         if(_gameSprites)
         {
            while(_gameSprites.length > 0)
            {
               removeGameSprite(_gameSprites.shift(),true);
            }
            _gameSprites = null;
         }
         if(_playerLayer)
         {
            _playerLayer.removeChildren();
            _playerLayer = null;
         }
         if(_gameLayer)
         {
            _gameLayer.removeChildren();
            _gameLayer = null;
         }
         if(camera)
         {
            camera = null;
         }
         if(gameUI)
         {
            gameUI.destory();
            gameUI = null;
         }
         EffectCtrl.I.destory();
         GameCtrl.I.destory();
         if(_map)
         {
            _map.destory();
            _map = null;
         }
      }
      
      public function initMosouFight(param1:GameRunFighterGroup, param2:MapMain) : void
      {
         var _loc4_:Point = null;
         _map = param2;
         _map.gameState = this;
         if(_map.bgLayer)
         {
            addChild(_map.bgLayer);
         }
         addChild(_gameLayer);
         if(_map.mapLayer)
         {
            _gameLayer.addChild(_map.mapLayer);
         }
         _gameLayer.addChild(_playerLayer);
         if(_map.frontFixLayer)
         {
            _gameLayer.addChild(_map.frontFixLayer);
         }
         if(_map.frontLayer)
         {
            _gameLayer.addChild(_map.frontLayer);
         }
         _cameraFocus = [];
         var _loc3_:FighterMain = param1.currentFighter;
         if(_loc3_)
         {
            _loc3_.x = _map.p1pos.x;
            _loc3_.y = _map.p1pos.y;
            _loc3_.direct = 1;
            _loc3_.updatePosition();
            _cameraFocus.push(_loc3_.getDisplay());
         }
         if(_map.mapLayer)
         {
            _loc4_ = new Point(_map.mapLayer.width,GameConfig.GAME_SIZE.y);
            initCamera();
            camera.focus(_cameraFocus);
            gameUI.initMission(param1);
            addChild(gameUI.getUIDisplay());
            return;
         }
         throw new Error("map is error! :: mapLayer is null!");
      }
   }
}

