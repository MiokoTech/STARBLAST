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
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.WinUI;
   
   public class HpBar
   {
      private var _ui:*;
      
      private var _faceGroup1:FightFaceGroup;
      
      private var _faceGroup2:FightFaceGroup;
      
      private var _hpBar1:FighterHpBar;
      
      private var _hpBar2:FighterHpBar;
      
      private var _score:FightScoreUI;
      
      private var _isFadIn:Boolean;
      
      private var _timerMc:FightTimeUI;
      
      private var _winUI1:WinUI;
      
      private var _winUI2:WinUI;
      
      private var _isRenderAnimate:Boolean = false;
      
      private var _bp:Bitmap;
      
      private var _parent:DisplayObjectContainer;
      
      private var _children:Vector.<DisplayObject>;
      
      private var _drawMatrix:Matrix;
      
      private var _empytBd:BitmapData;
      
      public function HpBar(param1:*)
      {
         super();
         _ui = param1;
         _faceGroup1 = new FightFaceGroup(_ui.face1);
         _faceGroup2 = new FightFaceGroup(_ui.face2);
         _faceGroup2.setDirect(-1);
         _hpBar1 = new FighterHpBar(_ui.bar1);
         _hpBar2 = new FighterHpBar(_ui.bar2);
         _hpBar2.setDirect(-1);
         _winUI1 = new WinUI(_ui.win_p1,1);
         _winUI2 = new WinUI(_ui.win_p2,2);
         _timerMc = new FightTimeUI(_ui.timemc);
         if(GameUI.BITMAP_UI)
         {
            initBitmapUI();
         }
         else
         {
            _ui.scoremc.visible = false;
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
         addChildren(_ui.barmc);
         addChildren(_bp);
         addChildren(_hpBar1.ui);
         addChildren(_hpBar2.ui);
         if(_timerMc.timeUI)
         {
            addChildren(_timerMc.timeUI);
         }
         addChildren(_winUI1.ui);
         addChildren(_winUI2.ui);
         addChildren(_ui.scoremc);
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
      
      private function setChildrenVisible(v:Boolean) : void
      {
         for each(var i:DisplayObject in _children)
         {
            i.visible = v;
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
         if(_hpBar1)
         {
            _hpBar1.destory();
            _hpBar1 = null;
         }
         if(_hpBar2)
         {
            _hpBar2.destory();
            _hpBar2 = null;
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
      
      public function initScore() : void
      {
         if(!GameUI.BITMAP_UI)
         {
            _ui.scoremc.visible = true;
         }
         _score = new FightScoreUI(_ui.scoremc);
      }
      
      public function setScore(param1:int) : void
      {
         if(_score)
         {
            _score.setScore(param1);
         }
      }
      
      public function showWin(param1:FighterMain, param2:int) : void
      {
         var _loc3_:WinUI = null;
         if(!param1)
         {
            return;
         }
         if(param2 < 0 || param2 > 2)
         {
            return;
         }
         switch(param1.team.id - 1)
         {
            case 0:
               _loc3_ = _winUI1;
               break;
            case 1:
               _loc3_ = _winUI2;
         }
         if(!_loc3_)
         {
            return;
         }
         _loc3_.show(param1.data,param2);
      }
      
      public function setFighter(param1:GameRunFighterGroup = null, param2:GameRunFighterGroup = null) : void
      {
         if(param1)
         {
            _faceGroup1.setFighter(param1);
            if(param1.currentFighter)
            {
               _hpBar1.setFighter(param1.currentFighter);
            }
         }
         if(param2)
         {
            _faceGroup2.setFighter(param2);
            if(param2.currentFighter)
            {
               _hpBar2.setFighter(param2.currentFighter);
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
         _hpBar1.render();
         _hpBar2.render();
         _timerMc.render();
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

