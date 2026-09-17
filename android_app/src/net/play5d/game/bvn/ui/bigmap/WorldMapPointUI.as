package net.play5d.game.bvn.ui.bigmap
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.mosou_ctrls.MosouLogic;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.mosou.MosouWorldMapAreaVO;
   import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.ui.Text;
   import net.play5d.game.bvn.ui.dialog.DialogManager;
   import net.play5d.game.bvn.ui.dialog.MosouStateDialog;
   import net.play5d.game.bvn.utils.BtnUtils;
   
   public class WorldMapPointUI extends EventDispatcher
   {
      public static const EVENT_SELECT:String = "EVENT_SELECT";
      
      private var _pointMc:Sprite;
      
      private var _ppmc:MovieClip;
      
      private var _facemc:Sprite;
      
      private var _maskMc:MovieClip;
      
      public var data:MosouWorldMapAreaVO;
      
      private var _perTxt:Text;
      
      private var _lvTxt:Text;
      
      public function WorldMapPointUI(param1:Sprite, param2:MovieClip, param3:MosouWorldMapAreaVO)
      {
         super();
         _pointMc = param1;
         _maskMc = param2;
         _ppmc = _pointMc.getChildByName("pmc") as MovieClip;
         _facemc = _pointMc.getChildByName("face") as Sprite;
         BtnUtils.btnMode(_ppmc);
         BtnUtils.btnMode(_facemc);
         this.data = param3;
         update();
         initEvents();
      }
      
      public function getPosition() : Point
      {
         return new Point(_pointMc.x,_pointMc.y);
      }
      
      public function destory() : void
      {
         BtnUtils.destoryBtn(_ppmc);
         BtnUtils.destoryBtn(_facemc);
         if(_lvTxt)
         {
            _lvTxt.destory();
            _lvTxt = null;
         }
      }
      
      public function update() : void
      {
         var _loc1_:Boolean = MosouLogic.I.checkAreaIsOpen(data.id);
         try
         {
            if(_loc1_)
            {
               _pointMc.visible = true;
               _maskMc.visible = true;
               updateCurrent();
               updatePercent();
               updateColor();
            }
            else
            {
               _pointMc.visible = false;
               _maskMc.visible = false;
            }
         }
         catch(e:Error)
         {
            trace("WorldMapPointUI",e);
         }
      }
      
      private function initEvents() : void
      {
         BtnUtils.initBtn(_ppmc,btnHandler);
         BtnUtils.initBtn(_facemc,btnHandler);
      }
      
      private function btnHandler(param1:DisplayObject) : void
      {
         if(param1 == _facemc)
         {
            GameEvent.dispatchEvent("MOSOU_FIGHTER");
            DialogManager.showDialog(new MosouStateDialog());
            return;
         }
         if(param1 == _ppmc)
         {
            this.dispatchEvent(new Event("EVENT_SELECT"));
         }
      }
      
      private function updateCurrent() : void
      {
         var isCurrent:Boolean = MosouLogic.I.checkCurrentArea(data.id);
         if(!isCurrent)
         {
            if(_facemc && _facemc.visible)
            {
               TweenLite.to(_facemc,0.1,{
                  "scaleX":0.1,
                  "scaleY":0.1,
                  "onComplete":function():void
                  {
                     _facemc.visible = false;
                  }
               });
            }
            if(_lvTxt)
            {
               _lvTxt.visible = false;
            }
         }
         else
         {
            updateFace();
         }
      }
      
      private function updateFace() : void
      {
         if(!_facemc)
         {
            return;
         }
         _facemc.visible = true;
         var _loc1_:Sprite = _facemc.getChildByName("ct") as Sprite;
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:MosouFighterVO = GameData.I.mosouData.getLeader();
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:DisplayObject = AssetManager.I.getFighterFace(FighterModel.I.getFighter(_loc2_.id));
         if(_loc3_)
         {
            _loc3_.x = 1;
            _loc1_.removeChildren();
            _loc1_.addChild(_loc3_);
         }
         if(!_lvTxt)
         {
            _lvTxt = new Text(16777215,12);
            _lvTxt.align = "right";
            _lvTxt.x = -15;
            _lvTxt.y = -32;
            _facemc.addChild(_lvTxt);
         }
         _lvTxt.text = "Lv." + _loc2_.getLevel();
         _lvTxt.visible = true;
         _facemc.scaleX = _facemc.scaleY = 0.01;
         TweenLite.to(_facemc,0.1,{
            "scaleX":1,
            "scaleY":1,
            "ease":Back.easeOut,
            "delay":0.1
         });
      }
      
      private function updatePercent() : void
      {
         if(!_perTxt)
         {
            _perTxt = new Text();
            _perTxt.fontSize = 20;
            _perTxt.y = 35;
            _pointMc.addChild(_perTxt);
         }
         var _loc1_:Number = MosouLogic.I.getAreaPercent(data.id);
         _perTxt.text = int(_loc1_ * 100) + "%";
         _perTxt.x = -_perTxt.getTextWidth() / 2 + 12;
      }
      
      private function updateColor() : void
      {
         if(!_ppmc)
         {
            return;
         }
         if(data.building())
         {
            _ppmc.gotoAndStop(2);
            return;
         }
         var _loc1_:Number = MosouLogic.I.getAreaPercent(data.id);
         if(_loc1_ < 0.6)
         {
            _ppmc.gotoAndStop(3);
            return;
         }
         if(_loc1_ < 1)
         {
            _ppmc.gotoAndStop(4);
            return;
         }
         _ppmc.gotoAndStop(1);
      }
   }
}

