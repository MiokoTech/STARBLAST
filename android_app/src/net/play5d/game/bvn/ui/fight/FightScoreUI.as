package net.play5d.game.bvn.ui.fight
{
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.MCNumber;
   
   public class FightScoreUI
   {
      private var _ui:*;
      
      private var _nummc:MCNumber;
      
      public function FightScoreUI(param1:*)
      {
         super();
         _ui = param1;
         var _loc2_:Class = ResUtils.I.getItemClass(ResUtils.swfLib.fight,"txtmc_score");
         _nummc = new MCNumber(_loc2_,0,1,10,10);
         _ui.ct.addChild(_nummc);
      }
      
      public function setScore(param1:int) : void
      {
         _nummc.number = param1;
      }
   }
}

