package net.play5d.game.bvn.fighter.vos
{
   import net.play5d.game.bvn.GameConfig;
   
   public class FighterBuffVO
   {
      
      public var param:String;
      
      public var resumeValue:Number = 0;
      
      public var finished:Boolean = false;
      
      private var _holdFrame:Number = 1;
      
      public function FighterBuffVO(param1:String, param2:Number = 1)
      {
         super();
         this.param = param1;
         this._holdFrame = param2 * GameConfig.FPS_GAME;
         this.finished = false;
      }
      
      public function setHold(param1:Number) : void
      {
         this._holdFrame = param1 * GameConfig.FPS_GAME;
         this.finished = false;
      }
      
      public function render() : Boolean
      {
         if(finished)
         {
            return true;
         }
         if(--_holdFrame <= 0)
         {
            finished = true;
            return true;
         }
         return false;
      }
   }
}

