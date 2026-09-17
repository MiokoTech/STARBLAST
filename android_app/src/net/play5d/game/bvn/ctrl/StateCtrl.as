package net.play5d.game.bvn.ctrl
{
   import flash.display.Sprite;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ui.QuickTransUI;
   import net.play5d.game.bvn.ui.TransUI;
   
   public class StateCtrl
   {
      private static var _i:StateCtrl;
      
      public var transEnabled:Boolean = true;
      
      private var _transUI:TransUI;
      
      private var _quickTransUI:QuickTransUI;
      
      private var _transContainer:Sprite;
      
      public function StateCtrl()
      {
         super();
         _transContainer = MainGame.I.root;
      }
      
      public static function get I() : StateCtrl
      {
         if(!_i)
         {
            _i = new StateCtrl();
         }
         return _i;
      }
      
      private function addTransUI() : void
      {
         if(!_transUI)
         {
            _transUI = new TransUI();
         }
         _transContainer.addChild(_transUI.ui);
      }
      
      private function removeTrainsUI() : void
      {
         try
         {
            _transContainer.removeChild(_transUI.ui);
         }
         catch(e:Error)
         {
         }
      }
      
      public function transIn(param1:Function = null, param2:Boolean = false) : void
      {
         var back:Function = param1;
         var removeAfterComplete:Boolean = param2;
         var removeSelf:* = function():void
         {
            if(back != null)
            {
               back();
            }
            removeTrainsUI();
         };
         if(!transEnabled)
         {
            if(back != null)
            {
               back();
            }
            return;
         }
         addTransUI();
         if(removeAfterComplete)
         {
            _transUI.fadIn(removeSelf);
         }
         else
         {
            _transUI.fadIn(back);
         }
      }
      
      public function transOut(param1:Function = null, param2:Boolean = true) : void
      {
         var back:Function = param1;
         var removeAfterComplete:Boolean = param2;
         var removeSelf:* = function():void
         {
            if(back != null)
            {
               back();
            }
            removeTrainsUI();
         };
         if(!transEnabled)
         {
            if(back != null)
            {
               back();
            }
            return;
         }
         addTransUI();
         if(removeAfterComplete)
         {
            _transUI.fadOut(removeSelf);
         }
         else
         {
            _transUI.fadOut(back);
         }
      }
      
      public function quickTrans(param1:Function = null) : void
      {
         var back:Function = param1;
         var transCom:* = function():void
         {
            try
            {
               _transContainer.removeChild(_quickTransUI);
            }
            catch(e:Error)
            {
            }
            if(back != null)
            {
               back();
            }
         };
         if(!_transContainer)
         {
            if(back != null)
            {
               back();
            }
            return;
         }
         if(!_quickTransUI)
         {
            _quickTransUI = new QuickTransUI();
         }
         _transContainer.addChild(_quickTransUI);
         _quickTransUI.fadInAndOut(transCom);
      }
      
      public function clearTrans() : void
      {
         removeTrainsUI();
      }
   }
}

