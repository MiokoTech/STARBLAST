package net.play5d.game.bvn.ui.mosou
{
   import flash.display.MovieClip;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.Text;
   import net.play5d.game.bvn.utils.BtnUtils;
   
   public class CoinUI
   {
      public static var ADD_ABLE:Boolean = true;
      
      private var _ui:MovieClip;
      
      private var _moneyTxt:Text;
      
      public function CoinUI(param1:MovieClip)
      {
         super();
         _ui = param1;
         _moneyTxt = new Text(16777215,16);
         _moneyTxt.x = 45;
         _moneyTxt.y = 12;
         _moneyTxt.width = 70;
         _moneyTxt.align = "center";
         if(ADD_ABLE)
         {
            _ui.gotoAndStop(1);
            BtnUtils.btnMode(_ui);
            BtnUtils.initBtn(_ui,clickHandler);
         }
         else
         {
            _ui.gotoAndStop(2);
         }
         GameEvent.addEventListener("MONEY_UPDATE",update);
         update();
      }
      
      public function destory() : void
      {
         GameEvent.removeEventListener("MONEY_UPDATE",update);
      }
      
      private function update(... rest) : void
      {
         _ui.addChild(_moneyTxt);
         _moneyTxt.text = GameData.I.mosouData.getMoney().toString();
      }
      
      private function clickHandler(param1:*) : void
      {
         GameInterface.addMoney(addMoneyBack);
      }
      
      private function addMoneyBack(param1:int) : void
      {
         GameUI.alert("MONEY","获得金币 " + param1 + " !");
         GameData.I.mosouData.addMoney(param1);
      }
   }
}

