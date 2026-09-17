package net.play5d.game.bvn.ctrl.game_ctrls
{
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.StateCtrl;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class TrainingCtrler
   {
      public static var RECOVER_HP:Boolean = true;
      
      public static var RECOVER_QI:Boolean = true;
      
      public static var RECOVER_FZ_QI:Boolean = true;
      
      private var _trainAddDelay:Object;
      
      private var _fighters:Array;
      
      public function TrainingCtrler()
      {
         super();
      }
      
      public function initlize(fighters:Array) : void
      {
         _fighters = fighters;
         for each(var i:FighterMain in _fighters) {
            i.qi = i.qiMax;
         }
         _trainAddDelay = {};
         StateCtrl.I.transOut(null, true);
      }
      
      public function destory() : void
      {
         _fighters = null;
         _trainAddDelay = null;
      }
      
      public function render() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc4_:String = null;
         for each(var _loc3_:FighterMain in _fighters)
         {
            _loc1_ = _loc3_.id + "_hp";
            if(_loc3_.actionState == 21 || _loc3_.actionState == 22)
            {
               _trainAddDelay[_loc1_] = 1 * GameConfig.FPS_GAME;
            }
            else if(_trainAddDelay[_loc1_] != undefined && _trainAddDelay[_loc1_] > 0)
            {
               _trainAddDelay[_loc1_]--;
               if(_trainAddDelay[_loc1_] <= 0 && RECOVER_HP)
               {
                  _loc3_.hp = _loc3_.hpMax;
               }
            }
            else if(_loc3_.hp == _loc3_.hpMax)
            {
               _trainAddDelay[_loc1_] = 0;
            }
            else
            {
               _trainAddDelay[_loc1_] = 2 * GameConfig.FPS_GAME;
            }
            _loc2_ = _loc3_.id + "_qi";
            if(_trainAddDelay[_loc2_] != undefined && _trainAddDelay[_loc2_] > 0)
            {
               _trainAddDelay[_loc2_]--;
               if(_trainAddDelay[_loc2_] <= 0 && RECOVER_QI)
               {
                  _loc3_.qi = _loc3_.qiMax;
               }
            }
            else if(_loc3_.qi == _loc3_.qiMax)
            {
               _trainAddDelay[_loc2_] = 0;
            }
            else
            {
               _trainAddDelay[_loc2_] = 2 * GameConfig.FPS_GAME;
            }
            _loc4_ = _loc3_.id + "fz";
            if(_trainAddDelay[_loc4_] != undefined && _trainAddDelay[_loc4_] > 0)
            {
               _trainAddDelay[_loc4_]--;
               if(_trainAddDelay[_loc4_] <= 0 && RECOVER_FZ_QI)
               {
                  _loc3_.fzqi = 100;
               }
            }
            else if(_loc3_.fzqi == 100)
            {
               _trainAddDelay[_loc4_] = 0;
            }
            else
            {
               _trainAddDelay[_loc4_] = 2 * GameConfig.FPS_GAME;
            }
         }
      }
   }
}

