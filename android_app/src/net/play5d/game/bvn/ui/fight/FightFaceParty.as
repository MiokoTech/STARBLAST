package net.play5d.game.bvn.ui.fight
{
   import flash.display.DisplayObject;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.FighterVO;
   
   public class FightFaceParty
   {
      private var _ui:*;
      
      public function FightFaceParty(param1:*)
      {
         super();
         _ui = param1;
      }
      
      public function setData(param1:FighterVO) : void
      {
         if(!param1)
         {
            _ui.visible = false;
            return;
         }
         _ui.visible = true;
         var _loc2_:DisplayObject = AssetManager.I.getPartyFighterFaceBar(param1);
         if(_loc2_)
         {
            _ui.ct.addChild(_loc2_);
         }
      }
      
      public function setDirect(param1:int) : void
      {
      }
   }
}

