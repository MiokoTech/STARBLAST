package net.play5d.game.bvn.ui.fight
{
   import flash.display.DisplayObject;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   
   public class FightFaceGroup
   {
      private var _ui:*;
      
      private var _face1:FightFaceUI;
      
      private var _face2:FightFaceParty;
      
      private var _face3:FightFaceParty;
      
      public function FightFaceGroup(param1:*)
      {
         super();
         _ui = param1;
         _ui.cacheAsBitmap = true;
         _face1 = new FightFaceUI(_ui.face);
         _face2 = new FightFaceParty(_ui.face2);
         _face3 = new FightFaceParty(_ui.face3);
      }
      
      public function get ui() : DisplayObject
      {
         return _ui;
      }
      
      public function setFighter(param1:GameRunFighterGroup = null) : void
      {
         _ui.cacheAsBitmap = false;
         if(!param1.currentFighter)
         {
            return;
         }
         _face1.setData(param1.currentFighter.data);
         switch(param1.currentFighter.data)
         {
            case param1.fighter1:
               _face2.setData(param1.fighter2);
               _face3.setData(param1.fighter3);
               break;
            case param1.fighter2:
               _face2.setData(param1.fighter3);
               _face3.setData(null);
               break;
            case param1.fighter3:
               _face2.setData(null);
               _face3.setData(null);
         }
         _ui.cacheAsBitmap = true;
      }
      
      public function setDirect(param1:int) : void
      {
         _face1.setDirect(param1);
         _face2.setDirect(param1);
         _face3.setDirect(param1);
      }
   }
}

