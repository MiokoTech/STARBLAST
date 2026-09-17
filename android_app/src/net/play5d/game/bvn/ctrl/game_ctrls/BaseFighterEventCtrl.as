package net.play5d.game.bvn.ctrl.game_ctrls
{
   import net.play5d.game.bvn.fighter.Bullet;
   import net.play5d.game.bvn.fighter.FighterAttacker;
   import net.play5d.game.bvn.fighter.events.FighterEvent;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameSpriteUtil;
   import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
   
   public class BaseFighterEventCtrl
   {
      private var _attackers:Array = [];
      
      public function BaseFighterEventCtrl()
      {
         super();
      }
      
      public function initlize() : void
      {
         FighterEventDispatcher.removeAllListeners();
         FighterEventDispatcher.addEventListener("FIRE_BULLET",fireBullet);
         FighterEventDispatcher.addEventListener("ADD_ATTACKER",addAttacker);
      }
      
      private function fireBullet(param1:FighterEvent) : void
      {
         var _loc2_:Object = param1.params;
         if(!_loc2_ || !_loc2_.mc)
         {
            return;
         }
         var _loc3_:Bullet = new Bullet(_loc2_.mc,_loc2_);
         _loc3_.onRemove = removeBullet;
         _loc3_.setHitVO(_loc2_.hitVO);
         GameSpriteUtil.autoChangeSpColor(_loc3_,param1.fighter);
         GameCtrl.I.addGameSprite(param1.fighter.team.id,_loc3_);
      }
      
      private function removeBullet(param1:Bullet) : void
      {
         GameCtrl.I.removeGameSprite(param1);
      }
      
      private function addAttacker(param1:FighterEvent) : void
      {
         var _loc3_:Object = param1.params;
         if(!_loc3_ || !_loc3_.mc)
         {
            return;
         }
         var _loc2_:FighterAttacker = new FighterAttacker(_loc3_.mc,_loc3_);
         _loc2_.onRemove = removeAttacker;
         _loc2_.setOwner(param1.fighter);
         _loc2_.init();
         GameSpriteUtil.autoChangeSpColor(_loc2_,param1.fighter);
         _attackers.push(_loc2_);
         GameCtrl.I.addGameSprite(param1.fighter.team.id,_loc2_);
      }
      
      private function removeAttacker(param1:FighterAttacker) : void
      {
         GameCtrl.I.removeGameSprite(param1);
         var _loc2_:int = int(_attackers.indexOf(param1));
         if(_loc2_ != -1)
         {
            _attackers.splice(_loc2_,1);
         }
      }
      
      public function getAttacker(param1:String, param2:int) : FighterAttacker
      {
         for each(var i:FighterAttacker in _attackers)
         {
            if(i.name == param1 && i.team.id == param2)
            {
               return i;
            }
         }
         return null;
      }
      
      public function destory() : void
      {
         FighterEventDispatcher.removeAllListeners();
      }
   }
}

