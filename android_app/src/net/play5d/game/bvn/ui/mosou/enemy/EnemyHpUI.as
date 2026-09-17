package net.play5d.game.bvn.ui.mosou.enemy
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class EnemyHpUI
   {
      private var _ui:MovieClip;
      
      private var _fighter:FighterMain;
      
      private var _bar:DisplayObject;
      
      private var _faceCt:Sprite;
      
      public function EnemyHpUI(param1:FighterMain)
      {
         super();
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.mosou,"mosou_enemyhpbarmc") as MovieClip;
         _bar = _ui.getChildByName("bar");
         _faceCt = _ui.getChildByName("ct_face") as Sprite;
         _fighter = param1;
         var _loc2_:DisplayObject = AssetManager.I.getFighterFace(_fighter.data);
         if(_loc2_)
         {
            _faceCt.addChild(_loc2_);
         }
      }
      
      public function getFighter() : FighterMain
      {
         return _fighter;
      }
      
      public function getUI() : DisplayObject
      {
         return _ui;
      }
      
      public function render() : Boolean
      {
         var _loc1_:Number = _fighter.hp / _fighter.hpMax;
         if(_loc1_ < 0.0001)
         {
            _loc1_ = 0.0001;
         }
         if(_loc1_ > 1)
         {
            _loc1_ = 1;
         }
         _bar.scaleX = _loc1_;
         return _fighter.isAlive;
      }
      
      public function destory() : void
      {
      }
   }
}

