package net.play5d.game.bvn.mob
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.mob.views.GameSideBg;
   
   public class RootSprite
   {
      private static var _i:RootSprite;
      
      public static var STAGE:Stage;
      
      public static var FULL_SCREEN_SIZE:Point = new Point();
      
      private var _sp:Sprite;
      
      private var _gameSprite:Sprite;
      
      private var _mainGame:MainGame;
      
      private var _showGameSide:Boolean = false;
      
      private var _gameSideBg:GameSideBg;
      
      private var _assetLoader:AssetLoader = new AssetLoader();
      
      public function RootSprite()
      {
         super();
      }
      
      public static function get I() : RootSprite
      {
         if(!_i)
         {
            _i = new RootSprite();
         }
         return _i;
      }
      
      public function getMainGame() : MainGame
      {
         return _mainGame;
      }
      
      public function init(param1:Sprite) : void
      {
         _sp = param1;
      }
      
      public function buildGame(param1:Function, param2:Function) : void
      {
         AssetManager.I.setAssetLoader(_assetLoader);
         _gameSprite = new Sprite();
         _sp.addChild(_gameSprite);
         _mainGame = new MainGame();
         _mainGame.initlize(_gameSprite,STAGE,param1,param2);
         updateFullScreenSize();
      }
      
      public function addChild(param1:DisplayObject) : void
      {
         _sp.addChild(param1);
      }
      
      public function addChildToGameSprite(param1:DisplayObject) : void
      {
         _gameSprite && _gameSprite.addChild(param1);
      }
      
      public function updateSize() : void
      {
         updateFullScreenSize();
      }
      
      public function updateFullScreenSize(param1:Event = null) : void
      {
         var _loc2_:Number = STAGE.stageWidth;
         var _loc3_:Number = STAGE.stageHeight;
         if(_loc2_ > _loc3_)
         {
            FULL_SCREEN_SIZE.x = _loc2_;
            FULL_SCREEN_SIZE.y = _loc3_;
         }
         else
         {
            FULL_SCREEN_SIZE.x = _loc3_;
            FULL_SCREEN_SIZE.y = _loc2_;
         }
         updateGameSize();
      }
      
      private function updateGameSize() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc11_:Point = null;
         var _loc12_:Rectangle = null;
         trace("updateGameSize");
         if(!_gameSprite)
         {
            trace("_gameSprite is null, return!");
            return;
         }
         var _loc7_:Number = STAGE.stageWidth;
         var _loc4_:Number = STAGE.stageHeight;
         var _loc6_:Number = GameConfig.GAME_SIZE.x;
         var _loc13_:Number = GameConfig.GAME_SIZE.y;
         var _loc8_:Number = 0;
         var _loc10_:Number = 0;
         var _loc9_:Number = 0;
         var _loc5_:* = 0;
         switch(GameInterfaceManager.config.screenMode)
         {
            case 0:
               _loc9_ = _loc7_ / _loc6_;
               _loc5_ = _loc4_ / _loc13_;
               _loc8_ = _loc10_ = 0;
               _loc1_ = false;
               break;
            case 1:
               _loc2_ = _loc7_ / _loc6_;
               _loc3_ = _loc4_ / _loc13_;
               if(_loc2_ < _loc3_)
               {
                  _loc9_ = _loc5_ = _loc2_;
                  _loc10_ = (_loc4_ - _loc13_ * _loc2_) / 2;
               }
               else
               {
                  _loc9_ = _loc5_ = _loc3_;
                  _loc8_ = (_loc7_ - _loc6_ * _loc3_) / 2;
               }
               _loc1_ = true;
         }
         if(GameConfig.PIXEL_STYLE_MODE)
         {
            _loc8_ = Math.round(_loc8_);
            _loc10_ = Math.round(_loc10_);
         }
         if(_showGameSide == _loc1_ && Math.abs(_gameSprite.x - _loc8_) < 1 && Math.abs(_gameSprite.y - _loc10_) < 1 && Math.abs(_gameSprite.scaleX - _loc9_) < 1 && Math.abs(_gameSprite.scaleY - _loc5_) < 1)
         {
            trace("scale samed, return!");
            return;
         }
         _gameSprite.x = _loc8_;
         _gameSprite.y = _loc10_;
         _gameSprite.scaleX = _loc9_;
         _gameSprite.scaleY = _loc5_;
         _gameSprite.scrollRect = null;
         _loc12_ = new Rectangle(_loc8_,_loc10_,_loc6_ * _loc9_,_loc13_ * _loc5_);
         if(_loc1_)
         {
            _loc11_ = new Point(_loc7_,_loc4_);
            if(!_gameSideBg)
            {
               _gameSideBg = new GameSideBg(_loc11_,_loc12_);
               _sp.addChildAt(_gameSideBg,0);
            }
            else
            {
               _gameSideBg.update(_loc11_,_loc12_);
            }
         }
         else if(_gameSideBg)
         {
            _gameSideBg.destory();
            _gameSideBg = null;
         }
         GameConfig.GAME_SCALE.x = _loc9_;
         GameConfig.GAME_SCALE.y = _loc5_;
         _showGameSide = _loc1_;
         trace("==== UPDATE GAME SIZE =========================================");
         trace("stage W & H :",_loc7_,_loc4_);
         trace("game rect :",_gameSprite.x,_gameSprite.y,_loc6_ * _loc9_,_loc13_ * _loc5_);
         trace("game scale :",GameConfig.GAME_SCALE.x,GameConfig.GAME_SCALE.y);
         trace("====------------------=========================================");
      }
   }
}

