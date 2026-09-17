package net.play5d.game.bvn.fighter
{
   public class FighterActionState
   {
      
      public static const NORMAL:int = 0;
      
      public static const FREEZE:int = 40;
      
      public static const ATTACK_ING:int = 10;
      
      public static const SKILL_ING:int = 11;
      
      public static const BISHA_ING:int = 12;
      
      public static const BISHA_SUPER_ING:int = 13;
      
      public static const JUMP_ING:int = 14;
      
      public static const DASH_ING:int = 15;
      
      public static const HURT_ACT_ING:int = 16;
      
      public static const DEFENCE_ING:int = 20;
      public static const DEFENSE_ING:int = 20;
      
      public static const HURT_ING:int = 21;
      
      public static const HURT_FLYING:int = 22;
      
      public static const HURT_DOWN:int = 23;
      
      public static const HURT_DOWN_TAN:int = 24;
      
      public static const DEAD:int = 30;
      
      public static const WAN_KAI_ING:int = 50;
      
      public static const KAI_CHANG:int = 60;
      
      public static const WIN:int = 61;
      
      public static const LOSE:int = 62;
      
      public function FighterActionState()
      {
         super();
      }
      
      public static function isAllowWinState(actionState:int) : Boolean
      {
         return allowGhostStep(actionState);
      }
      
      public static function isBishaIng(actionState:int) : Boolean
      {
         return [12,13].indexOf(actionState) != -1;
      }
      
      public static function isAttacking(actionState:int) : Boolean
      {
         return [10,11,12,13].indexOf(actionState) != -1;
      }
      
      public static function allowGhostStep(actionState:int) : Boolean
      {
         return [12,13,50].indexOf(actionState) == -1;
      }
      
      public static function isHurting(actionState:int) : Boolean
      {
         return [21,22,23,24].indexOf(actionState) != -1;
      }
      
      public static function isHurtFlying(actionState:int) : Boolean
      {
         return [22,23,24].indexOf(actionState) != -1;
      }
   }
}

