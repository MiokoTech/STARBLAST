package net.play5d.game.bvn.ui.dialog
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.mosou.LevelModel;
   import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.ui.Text;
   import net.play5d.game.bvn.ui.dialog.mosou_state.BigFaceUI;
   import net.play5d.game.bvn.ui.mosou.CoinUI;
   import net.play5d.game.bvn.utils.BtnUtils;
   import net.play5d.game.bvn.utils.ResUtils;
   
   public class MosouStateDialog extends BaseDialog
   {
      private var _ui:MovieClip;
      
      private var _bigFaces:Vector.<BigFaceUI>;
      
      private var _leaderBtn:SimpleButton;
      
      private var _changeBtn:SimpleButton;
      
      private var _currentFighter:MosouFighterVO;
      
      private var _coinUI:CoinUI;
      
      private var _nameText:Text;
      
      private var _lvText:Text;
      
      private var _introText:Text;
      
      private var _introText2:Text;
      
      private var _expText:Text;
      
      private var _changeIndex:int;
      
      private var _face:Sprite;
      
      public function MosouStateDialog()
      {
         super();
         width = 741;
         height = 478;
         offsetY = 20;
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog,"dialog_mosou_status") as MovieClip;
         _dialogUI = _ui;
         _coinUI = new CoinUI(_ui.getChildByName("coinmc") as MovieClip);
         _bigFaces = new Vector.<BigFaceUI>();
         _bigFaces.push(new BigFaceUI(_ui.getChildByName("p0") as Sprite));
         _bigFaces.push(new BigFaceUI(_ui.getChildByName("p1") as Sprite));
         _bigFaces.push(new BigFaceUI(_ui.getChildByName("p2") as Sprite));
         _leaderBtn = _ui.getChildByName("leader") as SimpleButton;
         _changeBtn = _ui.getChildByName("change") as SimpleButton;
         BtnUtils.initBtn(_leaderBtn,btnHandler);
         BtnUtils.initBtn(_changeBtn,btnHandler);
         _nameText = new Text(16777215);
         _lvText = new Text(16777215,14);
         _introText = new Text(16777215,16);
         _introText.leading = 18;
         _introText2 = new Text(16777215,16);
         _introText2.leading = 18;
         _expText = new Text(13421772,14);
         var _loc1_:Sprite = _ui.getChildByName("ct_fighter") as Sprite;
         if(_loc1_)
         {
            _nameText.x = 75;
            _nameText.y = 30;
            _loc1_.addChild(_nameText);
            _lvText.x = 220;
            _lvText.y = 55;
            _loc1_.addChild(_lvText);
            _expText.x = 10;
            _expText.y = 90;
            _loc1_.addChild(_expText);
            _introText.x = 10;
            _introText.y = 130;
            _loc1_.addChild(_introText);
            _introText2.x = 180;
            _introText2.y = 130;
            _loc1_.addChild(_introText2);
         }
      }
      
      private function btnHandler(param1:DisplayObject) : void
      {
         if(param1 == _leaderBtn)
         {
            GameData.I.mosouData.setLeader(_currentFighter);
            GameData.I.saveData();
            for each(var i:BigFaceUI in _bigFaces)
            {
               i.updateLeader();
            }
         }
         if(param1 == _changeBtn)
         {
            _changeIndex = GameData.I.mosouData.getFighterTeam().indexOf(_currentFighter);
            if(_changeIndex < 0)
            {
               _changeIndex = 0;
            }
            DialogManager.showDialog(new MosouSelectDialog(_changeIndex));
         }
      }
      
      private function updateCurrentFighter() : void
      {
         var _loc6_:DisplayObject = null;
         _currentFighter = _bigFaces[0].getFighter();
         if(!_currentFighter)
         {
            return;
         }
         var _loc1_:FighterVO = FighterModel.I.getFighter(_currentFighter.id);
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:Sprite = _ui.getChildByName("ct_fighter") as Sprite;
         if(!_loc2_)
         {
            return;
         }
         if(_face)
         {
            _loc2_.removeChild(_face);
         }
         var _loc3_:DisplayObject = AssetManager.I.getFighterFace(_loc1_);
         if(_loc3_)
         {
            _face = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog,"face_ui_mc");
            _face.x = 16;
            _face.y = 15;
            _loc3_.x = 1;
            _face.addChildAt(_loc3_,0);
            _loc2_.addChild(_face);
         }
         _nameText.text = _loc1_.name;
         _lvText.text = "Lv." + _currentFighter.getLevel();
         var _loc5_:int = _currentFighter.getExp();
         var _loc7_:int = LevelModel.getLevelUpExp(_currentFighter.getLevel());
         var _loc4_:Sprite = _ui.getChildByName("expmc") as Sprite;
         if(_loc4_)
         {
            _loc6_ = _loc4_.getChildByName("bar");
            if(_loc6_)
            {
               _loc6_.scaleX = _loc5_ / _loc7_;
            }
         }
         _expText.text = "Exp." + _loc5_ + "/" + _loc7_;
         _introText.text = "HP " + _currentFighter.getHP() + "\n" + "MP " + _currentFighter.getQI() + "\n" + "EN " + _currentFighter.getEnergy();
         _introText2.text = "ATK " + _currentFighter.getAttackDmg() * 10;
      }
      
      private function initBigFaces() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Vector.<MosouFighterVO> = GameData.I.mosouData.getFighterTeam();
         while(_loc1_ < _loc2_.length)
         {
            if(_bigFaces[_loc1_])
            {
               _bigFaces[_loc1_].setFighter(_loc2_[_loc1_]);
               BtnUtils.btnMode(_bigFaces[_loc1_].getUI());
               BtnUtils.initBtn(_bigFaces[_loc1_].getUI(),bigFaceHandler,_bigFaces[_loc1_]);
               _bigFaces[_loc1_].updatePos(_loc1_,false);
               _bigFaces[_loc1_].updateLeader();
            }
            _loc1_++;
         }
      }
      
      private function updateBigFaces() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Vector.<MosouFighterVO> = GameData.I.mosouData.getFighterTeam();
         while(_loc1_ < _loc2_.length)
         {
            if(_bigFaces[_loc1_])
            {
               _bigFaces[_loc1_].setFighter(_loc2_[_loc1_]);
               _bigFaces[_loc1_].updateLeader();
            }
            _loc1_++;
         }
         focusFighter(_changeIndex,false);
      }
      
      private function bigFaceHandler(param1:BigFaceUI) : void
      {
         var _loc2_:int = int(_bigFaces.indexOf(param1));
         if(_loc2_ == 0 || _loc2_ == -1)
         {
            return;
         }
         focusFighter(_loc2_);
      }
      
      private function focusFighter(param1:int, param2:Boolean = true) : void
      {
         var _loc3_:Vector.<BigFaceUI> = _bigFaces.concat();
         if(param1 == 2)
         {
            _bigFaces[2] = _loc3_[1];
            _bigFaces[1] = _loc3_[0];
            _bigFaces[0] = _loc3_[2];
         }
         if(param1 == 1)
         {
            _bigFaces[1] = _loc3_[2];
            _bigFaces[2] = _loc3_[0];
            _bigFaces[0] = _loc3_[1];
         }
         _bigFaces[0].updatePos(0,param2);
         _bigFaces[1].updatePos(1,param2);
         _bigFaces[2].updatePos(2,param2);
         updateCurrentFighter();
      }
      
      override protected function onShow() : void
      {
         initBigFaces();
         updateCurrentFighter();
      }
      
      override protected function onClose() : void
      {
         GameEvent.dispatchEvent("MOSOU_FIGHTER_CLOSE");
      }
      
      override protected function onDestory() : void
      {
         if(_coinUI)
         {
            _coinUI.destory();
            _coinUI = null;
         }
      }
      
      override protected function onResume() : void
      {
         super.onResume();
         updateBigFaces();
         updateCurrentFighter();
      }
   }
}

