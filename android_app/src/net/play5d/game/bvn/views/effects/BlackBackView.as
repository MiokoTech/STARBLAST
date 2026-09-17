package net.play5d.game.bvn.views.effects
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   
   public class BlackBackView extends Sprite
   {
      private var _bishaFace:BishaFaceEffectView;
      
      private var isRenderFadIn:Boolean;
      
      private var isRenderFadOut:Boolean;
      
      private var _bg:Bitmap;
      
      public function BlackBackView()
      {
         super();
         var _loc1_:BitmapData = new BitmapData(GameConfig.GAME_SIZE.x / 10,GameConfig.GAME_SIZE.y / 10,false,0);
         _bg = new Bitmap(_loc1_);
         _bg.width = GameConfig.GAME_SIZE.x;
         _bg.height = GameConfig.GAME_SIZE.y;
         addChild(_bg);
      }
      
      public function destory() : void
      {
         if(_bg)
         {
            try
            {
               removeChild(_bg);
            }
            catch(e:Error)
            {
            }
            _bg.bitmapData.dispose();
            _bg = null;
         }
         removeBishaFace();
      }
      
      public function renderAnimate() : void
      {
      }
      
      public function fadIn() : void
      {
      }
      
      public function fadOut() : void
      {
         removeBishaFace();
         try
         {
            parent.removeChild(this);
         }
         catch(e:Error)
         {
         }
      }
      
      public function showBishaFace(param1:int, param2:DisplayObject) : void
      {
         var _loc3_:Number = NaN;
         if(!_bishaFace)
         {
            _bishaFace = new BishaFaceEffectView();
            _loc3_ = 1;
            if(GameCtrl.I && GameCtrl.I.gameState && GameCtrl.I.gameState.camera)
            {
               _loc3_ = GameCtrl.I.gameState.camera.getZoom();
            }
            _bishaFace.mc.y = 100 + 100 / _loc3_;
            addChild(_bishaFace.mc);
         }
         _bishaFace.setFace(param1,param2);
         _bishaFace.fadIn();
      }
      
      private function removeBishaFace() : void
      {
         if(_bishaFace)
         {
            _bishaFace.destory();
            _bishaFace = null;
         }
      }
   }
}

