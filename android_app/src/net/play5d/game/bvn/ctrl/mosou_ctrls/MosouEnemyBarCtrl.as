package net.play5d.game.bvn.ctrl.mosou_ctrls
{
   import flash.display.Sprite;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.ui.mosou.enemy.EnemyHpFollowUI;
   
   public class MosouEnemyBarCtrl
   {
      private var _barMap:Dictionary = new Dictionary();
      
      private var _gameLayer:Sprite;
      
      public function MosouEnemyBarCtrl()
      {
         super();
      }
      
      private function initalize() : void
      {
      }
      
      public function destory() : void
      {
         _barMap = null;
      }
      
      public function updateEnemyBar(f:FighterMain) : void
      {
         if(f.mosouEnemyData.isBoss)
         {
            return;
         }
         if(_barMap[f])
         {
            (_barMap[f] as EnemyHpFollowUI).active();
            return;
         }
         if(!_gameLayer)
         {
            _gameLayer = GameCtrl.I.gameState.gameLayer;
         }
         var b:EnemyHpFollowUI = new EnemyHpFollowUI(f);
         _barMap[f] = b;
         _gameLayer.addChild(b.getUI());
      }
      
      public function render() : void
      {
         if(!_barMap)
         {
            return;
         }
         for(var i:* in _barMap)
         {
            var f:FighterMain = i is FighterMain ? i as FighterMain : null;
            if(!f)
            {
               continue;
            }
            var b:EnemyHpFollowUI = _barMap[f];
            if(!b.render())
            {
               try
               {
                  _gameLayer.removeChild(b.getUI());
               }
               catch(e:Error)
               {
                  trace("remove bar error");
               }
               b.destory();
               delete _barMap[f];
            }
         }
      }
      
      public function renderAnimate() : void
      {
      }
   }
}

