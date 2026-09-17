package net.play5d.game.bvn.ui.dialog.select
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.mosou.MosouFighterSellVO;
   import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
   import net.play5d.game.bvn.ui.Text;
   import net.play5d.game.bvn.utils.ResUtils;
   
   public class SelectFighterUI
   {
      public var sellData:MosouFighterSellVO;
      
      private var _playerData:MosouFighterVO;
      
      private var _lvTxt:Text;
      
      private var _selectUI:MovieClip;
      
      private var _selected:Boolean;
      
      private var _faceImg:DisplayObject;
      
      public var ui:Sprite;
      
      public function SelectFighterUI(param1:MosouFighterSellVO)
      {
         super();
         ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog,"face_ui_mc");
         this.sellData = param1;
         _selectUI = ui.getChildByName("seltmc") as MovieClip;
         _lvTxt = new Text(16777215,14);
         _lvTxt.visible = false;
         ui.addChild(_lvTxt);
         initFace();
         updateUI();
      }
      
      private function initFace() : void
      {
         var _loc1_:FighterVO = FighterModel.I.getFighter(sellData.id);
         var _loc2_:DisplayObject = AssetManager.I.getFighterFace(_loc1_);
         if(_loc2_)
         {
            _loc2_.x = 1;
            ui.addChildAt(_loc2_,0);
         }
         _faceImg = _loc2_;
      }
      
      public function select(param1:Boolean) : void
      {
         if(_selected == param1)
         {
            return;
         }
         _selected = param1;
         if(_selectUI)
         {
            _selectUI.gotoAndPlay(param1 ? "in" : "out");
         }
      }
      
      public function isBought() : Boolean
      {
         return _playerData != null;
      }
      
      public function getLevel() : int
      {
         if(!_playerData)
         {
            return 0;
         }
         return _playerData.getLevel();
      }
      
      public function updateUI() : void
      {
         _playerData = GameData.I.mosouData.getFighterDataById(sellData.id);
         if(_playerData)
         {
            _lvTxt.visible = true;
            _lvTxt.text = "Lv." + _playerData.getLevel();
            ui.alpha = 1;
         }
         else
         {
            _lvTxt.visible = false;
            ui.alpha = 0.5;
         }
      }
   }
}

