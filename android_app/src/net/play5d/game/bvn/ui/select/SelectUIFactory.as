package net.play5d.game.bvn.ui.select
{
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.utils.ResUtils;
   
   public class SelectUIFactory
   {
      public function SelectUIFactory()
      {
         super();
      }
      
      public static function createSelecter(playerIndex:int = 1) : SelecterItemUI
      {
         var selecterItem:SelecterItemUI = new SelecterItemUI(playerIndex);
         selecterItem.inputType = playerIndex == 1 ? "P1" : "P2";
         var isP1:Boolean = playerIndex == 1;
         selecterItem.selectVO = isP1 ? GameData.I.p1Select : GameData.I.p2Select;
         var itemClassName:String = isP1 ? "selected_item_p1_mc" : "selected_item_p2_mc";
         var itemClass:Class = ResUtils.I.getItemClass(ResUtils.swfLib.select, itemClassName);
         var fighterGroup:SelectedFighterGroup = new SelectedFighterGroup(itemClass, isP1);
         fighterGroup.x = isP1 ? 0 : GameConfig.GAME_SIZE.x;
         fighterGroup.y = 0;
         if(fighterGroup.nameGroup)
         {
            fighterGroup.nameGroup.x = 0;
            fighterGroup.nameGroup.y = 0;
         }
         fighterGroup.addFighter(null);
         selecterItem.group = fighterGroup;
         return selecterItem;
      }
   }
}

