package net.play5d.game.bvn.ui.dialog.mosou_state
{
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
   import net.play5d.game.bvn.ui.Text;
   
   public class BigFaceUI
   {
      private var _ui:Sprite;
      
      private var _data:MosouFighterVO;
      
      private var _nametxt:Text;
      
      private var _leveltxt:Text;
      
      public function BigFaceUI(param1:Sprite)
      {
         super();
         _ui = param1;
      }
      
      public function getUI() : Sprite
      {
         return _ui;
      }
      
      public function getFighter() : MosouFighterVO
      {
         return _data;
      }
      
      public function setFighter(param1:MosouFighterVO) : void
      {
         _data = param1;
         updateTexts();
         updateFace();
      }
      
      private function updateTexts() : void
      {
         if(_nametxt == null)
         {
            _nametxt = new Text(16776960,24);
            _nametxt.width = 270;
            _nametxt.height = 60;
            _nametxt.align = "center";
            _nametxt.y = 197;
            _ui.addChild(_nametxt);
         }
         if(_leveltxt == null)
         {
            _leveltxt = new Text(16777215);
            _leveltxt.width = 270;
            _leveltxt.height = 30;
            _leveltxt.align = "center";
            _leveltxt.y = 230;
            _ui.addChild(_leveltxt);
         }
         _nametxt.text = FighterModel.I.getFighterName(_data.id);
         _leveltxt.text = "Lv." + _data.getLevel();
      }
      
      private function updateFace() : void
      {
         var _loc1_:Sprite = _ui.getChildByName("ct") as Sprite;
         if(!_loc1_)
         {
            return;
         }
         _loc1_.removeChildren();
         var _loc2_:DisplayObject = AssetManager.I.getFighterFaceWin(FighterModel.I.getFighter(_data.id));
         if(_loc2_)
         {
            _loc1_.addChild(_loc2_);
         }
      }
      
      public function updatePos(param1:int, param2:Boolean = true) : void
      {
         var _loc3_:Object = {};
         switch(param1)
         {
            case 0:
               _loc3_.x = 230;
               _loc3_.y = 33;
               _loc3_.scaleX = _loc3_.scaleY = 1;
               if(_ui.parent)
               {
                  _ui.parent.addChild(_ui);
               }
               break;
            case 1:
               _loc3_.x = 70;
               _loc3_.y = -24;
               _loc3_.scaleX = _loc3_.scaleY = 0.74;
               break;
            case 2:
               _loc3_.x = 458;
               _loc3_.y = -4;
               _loc3_.scaleX = _loc3_.scaleY = 0.74;
         }
         if(param2)
         {
            TweenLite.to(_ui,0.2,_loc3_);
         }
         else
         {
            _ui.x = _loc3_.x;
            _ui.y = _loc3_.y;
            _ui.scaleX = _loc3_.scaleX;
            _ui.scaleY = _loc3_.scaleY;
         }
      }
      
      public function updateLeader() : void
      {
         var _loc1_:Sprite = _ui.getChildByName("isLeaderMc") as Sprite;
         if(_loc1_)
         {
            _loc1_.visible = _data == GameData.I.mosouData.getLeader();
         }
      }
   }
}

