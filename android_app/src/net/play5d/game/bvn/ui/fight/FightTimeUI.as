package net.play5d.game.bvn.ui.fight
{
   import flash.display.DisplayObject;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.MCNumber;
   
   public class FightTimeUI
   {
      private var _ui:*;
      
      private var _numMc:MCNumber;
      
      private var _renderTime:Boolean;
      
      public function FightTimeUI(param1:*)
      {
         var _loc2_:Class = null;
         super();
         _ui = param1;
         var _loc3_:int = GameCtrl.I.gameRunData.gameTimeMax;
         if(_loc3_ == -1)
         {
            _renderTime = false;
            _ui.wuxian.visible = true;
         }
         else
         {
            _renderTime = true;
            _loc2_ = ResUtils.I.getItemClass(ResUtils.swfLib.fight,"time_txtmc");
            _numMc = new MCNumber(_loc2_,0,1,26,2);
            _numMc.x = -22;
            _numMc.y = -15;
            _ui.addChild(_numMc);
            _ui.wuxian.visible = false;
            _numMc.number = _loc3_;
         }
      }
      
      public function get timeUI() : DisplayObject
      {
         return _numMc;
      }
      
      public function render() : void
      {
         if(!_renderTime)
         {
            return;
         }
         var _loc1_:int = GameCtrl.I.gameRunData.gameTime;
         _numMc.number = _loc1_;
      }
   }
}

