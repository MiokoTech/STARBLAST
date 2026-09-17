package net.play5d.game.bvn.ui.mosou
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class LittleHpBar
   {
      private var _ui:*;
      
      private var _fighter:FighterMain;
      
      public function LittleHpBar(param1:*)
      {
         super();
         _ui = param1;
      }
      
      public function setFighter(param1:FighterMain) : void
      {
         _fighter = param1;
         updateFace();
      }
      
      private function updateFace() : void
      {
         var _loc2_:DisplayObject = null;
         var _loc1_:Sprite = _ui.face.getChildByName("ct") as Sprite;
         if(_loc1_)
         {
            _loc2_ = AssetManager.I.getFighterFace(_fighter.data);
            if(_loc2_)
            {
               _loc1_.removeChildren();
               _loc1_.addChild(_loc2_);
            }
         }
      }
      
      public function renderAnimate() : void
      {
         if(!_fighter)
         {
            return;
         }
         _ui.bar_hp.scaleX = getScale(_fighter.hp,_fighter.hpMax);
         _ui.bar_qi.scaleX = getScale(_fighter.qi,300);
      }
      
      private function getScale(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = param1 / param2;
         if(_loc3_ < 0.0001)
         {
            _loc3_ = 0.0001;
         }
         if(_loc3_ > 1)
         {
            _loc3_ = 1;
         }
         return _loc3_;
      }
   }
}

