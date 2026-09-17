package net.play5d.game.bvn.ui.select
{
   import com.greensock.TweenLite;
   import flash.display.Sprite;
   import net.play5d.game.bvn.data.FighterVO;
   
   public class SelectedFighterGroup extends Sprite
   {
      private var _uiClass:Class;
      
      private var _uis:Array = [];
      
      private var _curUI:SelectedFighterUI;
      
      public function SelectedFighterGroup(param1:Class)
      {
         super();
         _uiClass = param1;
      }
      
      public function destory() : void
      {
         if(_curUI)
         {
            _curUI.destory();
            _curUI = null;
         }
      }
      
      public function addFighter(param1:FighterVO) : void
      {
         var _loc2_:SelectedFighterUI = null;
         var _loc7_:int = 0;
         var _loc3_:Number = 20 - (_uis.length - 1) * 3;
         var _loc4_:Number = _uis.length * -20;
         var _loc5_:Number = 0.7 - (_uis.length - 1) * 0.3;
         var _loc6_:Number = 0.85 - (_uis.length - 1) * 0.15;
         while(_loc7_ < _uis.length)
         {
            _loc2_ = _uis[_loc7_];
            TweenLite.to(_loc2_.ui,0.1,{
               "y":_loc4_,
               "alpha":_loc5_,
               "scaleX":_loc6_,
               "scaleY":_loc6_
            });
            _loc4_ += _loc3_;
            _loc5_ += 0.3;
            _loc6_ += 0.15;
            _loc7_++;
         }
         _loc2_ = new SelectedFighterUI(new _uiClass());
         if(param1)
         {
            _loc2_.setFighter(param1);
         }
         _loc2_.ui.y = 50;
         TweenLite.to(_loc2_.ui,0.1,{
            "y":0,
            "delay":0.05
         });
         addChild(_loc2_.ui);
         _uis.push(_loc2_);
         if(_curUI)
         {
            _curUI.destory();
            _curUI = null;
         }
         _curUI = _loc2_;
      }
      
      public function updateFighter(param1:FighterVO) : void
      {
         _curUI.setFighter(param1);
      }
   }
}

