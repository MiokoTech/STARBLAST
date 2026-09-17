package net.play5d.game.bvn.ui.fight
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.ui.GameUI;

   public class FightBar
   {
      private var _ui:*;
      private var _energyBar1:EnergyBar;
      private var _energyBar2:EnergyBar;
      private var _isFadIn:Boolean;
      private var _isRenderAnimate:Boolean = false;
      private var _bp:Bitmap;
      private var _parent:DisplayObjectContainer;
      private var _children:Vector.<DisplayObject>;
      private var _drawMatrix:Matrix;
      private var _empytBd:BitmapData;

      public function FightBar(param1:*)
      {
         super();
         _ui = param1;
         _energyBar1 = new EnergyBar(_ui.energy1);
         _energyBar2 = new EnergyBar(_ui.energy2);
         if(GameUI.BITMAP_UI)
         {
            initBitmapUI();
         }
         _ui.addEventListener("complete",uiPlayComplete);
      }
      
      public function get ui() : DisplayObject
      {
         return _ui;
      }
      
      private function initBitmapUI() : void
      {
         var _loc1_:Rectangle;
         _ui.gotoAndStop("fadin_fin");
         _parent = _ui.parent;
         try
         {
            _parent.removeChild(_ui);
         }
         catch(e:Error)
         {
         }
         _loc1_ = _ui.getBounds(_ui);
         _drawMatrix = new Matrix(1,0,0,1,-_loc1_.x,-_loc1_.y);
         _children = new Vector.<DisplayObject>();
         _bp = new Bitmap();
         _bp.bitmapData = new BitmapData(_ui.width,_ui.height,true,0);
         _bp.x = _loc1_.x;
         _bp.y = _loc1_.y;
         _empytBd = new BitmapData(_ui.width,_ui.height,true,0);
         addChildren(_bp);
         updateBitmap();
         setChildrenVisible(false);
      }
      
      private function setChildrenPosition(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObjectContainer = param1.parent;
         while(_loc2_ && _loc2_ != _ui)
         {
            param1.x += _loc2_.x;
            param1.y += _loc2_.y;
            _loc2_ = _loc2_.parent;
         }
         param1.x += _ui.x;
         param1.y += _ui.y;
      }
      
      private function addChildren(param1:DisplayObject, param2:int = -1) : void
      {
         setChildrenPosition(param1);
         if(param2 == -1)
         {
            _parent.addChild(param1);
         }
         else
         {
            _parent.addChildAt(param1,param2);
         }
         _children.push(param1);
      }
      
      private function setChildrenVisible(param1:Boolean) : void
      {
         for each(var _loc2_:DisplayObject in _children)
         {
            _loc2_.visible = param1;
         }
      }
      
      public function destory() : void
      {
         var _loc1_:*;
         if(_ui)
         {
            _ui.removeEventListener("complete",uiPlayComplete);
            _ui.gotoAndStop("destory");
            _ui = null;
         }
         if(_energyBar1)
         {
            _energyBar1.destory();
            _energyBar1 = null;
         }
         if(_energyBar2)
         {
            _energyBar2.destory();
            _energyBar2 = null;
         }
         if(GameUI.BITMAP_UI)
         {
            if(_bp)
            {
               _bp.bitmapData.dispose();
               _bp = null;
            }
            if(_empytBd)
            {
               _empytBd.dispose();
               _empytBd = null;
            }
            _drawMatrix = null;
            for each(_loc1_ in _children)
            {
               try
               {
                  _parent.removeChild(_loc1_);
               }
               catch(e:Error)
               {
               }
            }
            _children = null;
         }
      }
      
      private function uiPlayComplete(param1:Event) : void
      {
         if(_isFadIn)
         {
            _ui.visible = true;
         }
         else
         {
            _ui.visible = false;
         }
      }
      
      public function setFighter(param1:GameRunFighterGroup = null, param2:GameRunFighterGroup = null) : void
      {
         if(param1)
         {
            if(param1.currentFighter)
            {
               _energyBar1.setFighter(param1.currentFighter);
            }
         }
         if(param2)
         {
            if(param2.currentFighter)
            {
               _energyBar2.setFighter(param2.currentFighter);
            }
         }
         if(GameUI.BITMAP_UI)
         {
            updateBitmap();
         }
      }
      
      private function updateBitmap() : void
      {
         _bp.bitmapData.copyPixels(_empytBd,new Rectangle(0,0,_empytBd.width,_empytBd.height),new Point());
         _bp.bitmapData.draw(_ui,_drawMatrix);
      }
      
      public function render() : void
      {
         _energyBar1.render();
         _energyBar2.render();
      }
      
      public function fadIn(param1:Boolean) : void
      {
         if(_isFadIn)
         {
            return;
         }
         _isFadIn = true;
         if(GameUI.BITMAP_UI)
         {
            setChildrenVisible(true);
            return;
         }
         _ui.visible = true;
         if(param1)
         {
            _ui.gotoAndStop("fadin");
            _isRenderAnimate = true;
         }
         else
         {
            _ui.gotoAndStop("fadin_fin");
         }
      }
      
      public function fadOut(param1:Boolean) : void
      {
         if(!_isFadIn)
         {
            return;
         }
         _isFadIn = false;
         if(GameUI.BITMAP_UI)
         {
            setChildrenVisible(false);
            return;
         }
         if(param1)
         {
            _ui.gotoAndStop("fadout");
            _isRenderAnimate = true;
         }
         else
         {
            _ui.visible = false;
         }
      }

      
      public function renderAnimate() : void
      {
         if(!_isRenderAnimate)
         {
            return;
         }
         var _loc1_:String = _ui.currentFrameLabel;
         if(_loc1_ == "fadin_fin" || _loc1_ == "fadout_fin")
         {
            _isRenderAnimate = false;
            return;
         }
         _ui.nextFrame();
      }
   }
}

