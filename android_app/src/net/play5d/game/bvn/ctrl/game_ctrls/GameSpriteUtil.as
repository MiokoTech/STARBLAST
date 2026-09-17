package net.play5d.game.bvn.ctrl.game_ctrls
{
   import flash.geom.ColorTransform;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.Bullet;
   import net.play5d.game.bvn.fighter.FighterAttacker;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.IGameSprite;

   /**
    * Game Sprite utility for recoloring on mirror matches (same character / same assister).
    */
   public class GameSpriteUtil
   {
      public function GameSpriteUtil()
      {
         super();
      }

      /**
       * Change Game Sprite color transform. Default green offset -85.
       */
      public static function changeSpColor(param1:IGameSprite, param2:ColorTransform = null) : void
      {
         if(!param1)
         {
            return;
         }
         if(!param2)
         {
            param2 = new ColorTransform(1, 1, 1, 1, 0, -85, 0, 0);
         }
         param1.colorTransform = param2;
      }

      /**
       * Automatically change Game Sprite color when P2 uses the same character or assister.
       */
      public static function autoChangeSpColor(param1:IGameSprite, param2:IGameSprite = null, param3:ColorTransform = null) : void
      {
         if(!param1)
         {
            return;
         }

         if(!param2)
         {
            changeSpColor(param1, param3);
            return;
         }

         if(!param2.team || param2.team.id != 2)
         {
            return;
         }

         var isSameFighter:Boolean = GameCtrl.I.gameRunData.isSameFighter;
         var isSameAssister:Boolean = GameCtrl.I.gameRunData.isSameAssister;

         if(param1 is Assister)
         {
            if(isSameAssister)
            {
               changeSpColor(param1, param3);
            }
         }
         else if(param1 is FighterAttacker)
         {
            if((param2 is FighterMain && isSameFighter) || (param2 is Assister && isSameAssister))
            {
               changeSpColor(param1, param3);
            }
         }
         else if(param1 is Bullet)
         {
            if((param2 is FighterMain && isSameFighter) || (param2 is Assister && isSameAssister))
            {
               changeSpColor(param1, param3);
            }
            else if(param2 is FighterAttacker)
            {
               var owner:IGameSprite = (param2 as FighterAttacker).getOwner();
               autoChangeSpColor(param1, owner, param3);
            }
         }
      }
   }
}
