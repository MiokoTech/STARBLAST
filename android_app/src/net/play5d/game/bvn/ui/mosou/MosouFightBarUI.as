package net.play5d.game.bvn.ui.mosou
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class MosouFightBarUI
   {
      private var _ui:*;
      
      private var _face:*;
      
      private var _hpbar:MosouHpBar;
      
      private var _qibar:MosouQiBar;
      
      private var _energybar:MosouEnergyBar;
      
      private var _littleHpBar1:LittleHpBar;
      
      private var _littleHpBar2:LittleHpBar;
      
      private var _group:GameRunFighterGroup;
      
      public function MosouFightBarUI(param1:*)
      {
         super();
         _ui = param1;
         _hpbar = new MosouHpBar(param1.hpbar,param1.hpbar2);
         _qibar = new MosouQiBar(param1.qibar);
         _energybar = new MosouEnergyBar(param1.energybar);
         _littleHpBar1 = new LittleHpBar(param1.little_hp_1);
         _littleHpBar2 = new LittleHpBar(param1.little_hp_2);
         _face = param1.facemc;
      }
      
      public function setFighter(param1:GameRunFighterGroup) : void
      {
         _group = param1;
         updateFighters();
      }
      
      public function updateFighters() : void
      {
         _hpbar.setFighter(_group.currentFighter);
         _qibar.setFighter(_group.currentFighter);
         _energybar.setFighter(_group.currentFighter);
         updateFace();
         var _loc3_:Vector.<FighterVO> = _group.getFighters(true);
         var _loc2_:FighterMain = _group.getFighter(_loc3_[0]);
         var _loc1_:FighterMain = _group.getFighter(_loc3_[1]);
         _littleHpBar1.setFighter(_loc2_);
         _littleHpBar2.setFighter(_loc1_);
      }
      
      private function updateFace() : void
      {
         var _loc2_:DisplayObject = null;
         var _loc1_:Sprite = _face.getChildByName("ct") as Sprite;
         if(_loc1_)
         {
            _loc2_ = AssetManager.I.getFighterFaceBar(_group.currentFighter.data);
            if(_loc2_)
            {
               _loc1_.removeChildren();
               _loc1_.addChild(_loc2_);
            }
         }
      }
      
      public function render() : void
      {
         _hpbar.render();
         _qibar.render();
         _energybar.render();
      }
      
      public function renderAnimate() : void
      {
         _littleHpBar1.renderAnimate();
         _littleHpBar2.renderAnimate();
      }
   }
}

