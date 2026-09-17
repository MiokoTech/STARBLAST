package net.play5d.game.bvn.ui.mosou.enemy
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.utils.ResUtils;
   public class EnemyHpFollowUI
   {
      private var _ui:MovieClip;
      
      private var _fighter:FighterMain;
      
      private var _bar:DisplayObject;
      
      private var _showDelay:int;
      
      public function EnemyHpFollowUI(param1:FighterMain)
      {
         super();
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.mosou,"mosou_enemyhpbarmc2") as MovieClip;
         _ui.scaleX = _ui.scaleY = 0.5;
         _bar = _ui.getChildByName("barmc");
         _fighter = param1;
         _ui.visible = false;
      }
      
      public function getFighter() : FighterMain
      {
         return _fighter;
      }
      
      public function getUI() : DisplayObject
      {
         return _ui;
      }
      
      public function active() : void
      {
         _ui.visible = true;
         _showDelay = GameConfig.FPS_GAME * 3;
      }
      
      public function render() : Boolean
      {
         if(!_fighter)
         {
            return false;
         }
         if(!_ui.visible)
         {
            return _fighter.isAlive;
         }
         var _loc1_:Number = _fighter.hp / _fighter.hpMax;
         if(_loc1_ < 0.0001)
         {
            _loc1_ = 0.0001;
         }
         if(_loc1_ > 1)
         {
            _loc1_ = 1;
         }
         _ui.x = _fighter.x;
         _ui.y = _fighter.y - 50;
         _bar.scaleX = _loc1_;
         if(--_showDelay <= 0)
         {
            _ui.visible = false;
         }
         return _fighter.isAlive;
      }
      
      public function destory() : void
      {
         _fighter = null;
         _bar = null;
         _ui = null;
      }
   }
}

