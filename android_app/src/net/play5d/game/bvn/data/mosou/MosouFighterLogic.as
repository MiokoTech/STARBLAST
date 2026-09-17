package net.play5d.game.bvn.data.mosou
{
   import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class MosouFighterLogic
   {
      public static const LV_DASH_AIR:int = 0;
      
      public static const LV_GHOST_STEP:int = 0;
      
      public static const LV_SKILL1:int = 0;
      
      public static const LV_SKILL2:int = 0;
      
      public static const LV_SKILL_AIR:int = 0;
      
      public static const LV_ZHAO1:int = 0;
      
      public static const LV_ZHAO2:int = 0;
      
      public static const LV_ZHAO3:int = 0;
      
      public static const LV_CATCH1:int = 0;
      
      public static const LV_CATCH2:int = 0;
      
      public static const LV_BISHA:int = 0;
      
      public static const LV_BISHA_AIR:int = 0;
      
      public static const LV_BISHA_UP:int = 0;
      
      public static const LV_BISHA_SUPER:int = 0;
      
      public static const LV_BANKAI:int = 0;
      
      public static const ALL_ACTION_LEVELS:Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
      
      private var _fightData:MosouFighterVO;
      
      public function MosouFighterLogic(param1:MosouFighterVO)
      {
         super();
         _fightData = param1;
      }
      
      public function getHP() : int
      {
         return _fightData.getHP();
      }
      
      public function getQI() : int
      {
         return _fightData.getQI();
      }
      
      public function getEnergy() : int
      {
         return _fightData.getEnergy();
      }
      
      public function initFighterProps(param1:FighterMain) : void
      {
         param1.initAttackAddDmg(_fightData.getAttackDmg(),_fightData.getSkillDmg(),_fightData.getBishaDmg());
      }
      
      public function canDash() : Boolean
      {
         return true;
      }
      
      public function canDashAir() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canGhostStep() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canSkillAir() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canSkill1() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canSkill2() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canZhao1() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canZhao2() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canZhao3() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canCatch1() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canCatch2() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canBisha() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canBishaUP() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canBishaAir() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canBishaSuper() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
      
      public function canBankai() : Boolean
      {
         return _fightData.getLevel() >= 0;
      }
   }
}

