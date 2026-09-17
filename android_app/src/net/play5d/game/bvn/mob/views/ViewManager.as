package net.play5d.game.bvn.mob.views
{
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ui.SetChar;
   import net.play5d.game.bvn.ui.MenuBtn;
   import net.play5d.game.bvn.ui.MenuBtnGroup;
   import net.play5d.game.bvn.state.SettingState;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.mob.input.JoyStickConfigVO;
   import net.play5d.kyo.stage.Istage;
   
   public class ViewManager
   {
      private var _parentMenu:MenuBtnGroup;
      private var _parentChild:MenuBtn;
      private var _childLabel:String;
      private static var _i:ViewManager;
      
      public function ViewManager()
      {
         super();
      }
      
      public static function get I() : ViewManager
      {
         if(!_i)
         {
            _i = new ViewManager();
         }
         return _i;
      }

      public function goP1JoyStickSet() : void
      {
         goJoyStickSet(1,GameInterfaceManager.config.joy1Config);
      }
      
      private function goJoyStickSet(param1:int, param2:JoyStickConfigVO) : void
      {
         var _loc3_:Istage = MainGame.stageCtrl.currentStage;
         if(!_loc3_ is SettingState)
         {
            return;
         }
         var _loc4_:SettingState = _loc3_ as SettingState;
         var _loc5_:JoyStickSetUI = new JoyStickSetUI();
         _loc5_.setConfig(param1,param2);
         _loc4_.goInnerSetPage(_loc5_);
      }

      public function setChar(parentMenu:MenuBtnGroup, parentChild:MenuBtn = null, childLabel:String = null) : void
      {
         _parentMenu = parentMenu;
         _parentChild = parentChild;
         _childLabel = childLabel;
         var _loc1_:SetChar = new SetChar(parentMenu, parentChild, childLabel);
         RootSprite.I.addChildToGameSprite(_loc1_);
      }
   }
}


