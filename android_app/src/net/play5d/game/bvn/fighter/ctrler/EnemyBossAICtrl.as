package net.play5d.game.bvn.fighter.ctrler
{
   public class EnemyBossAICtrl extends FighterAICtrl
   {
      public function EnemyBossAICtrl()
      {
         super();
      }
      
      override public function waiKai() : Boolean
      {
         return false;
      }
      
      override public function waiKaiW() : Boolean
      {
         return false;
      }
      
      override public function waiKaiS() : Boolean
      {
         return false;
      }
      
      override public function ghostStep() : Boolean
      {
         return false;
      }
      
      override public function ghostJump() : Boolean
      {
         return false;
      }
      
      override public function ghostJumpDown() : Boolean
      {
         return false;
      }
      
      override public function assist() : Boolean
      {
         return false;
      }
      
      override public function specailSkill() : Boolean
      {
         return false;
      }
      
      override public function bishaSUPER() : Boolean
      {
         return false;
      }
      
      override public function catch1() : Boolean
      {
         return false;
      }
      
      override public function catch2() : Boolean
      {
         return false;
      }
   }
}

