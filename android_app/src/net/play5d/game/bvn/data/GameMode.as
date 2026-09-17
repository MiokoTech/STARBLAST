package net.play5d.game.bvn.data
{
   public class GameMode
   {
      public static var currentMode:int;

      public static const TEAM_ARCADE:int = 10;
      public static const TEAM_VS_PEOPLE:int = 11;
      public static const TEAM_VS_CPU:int = 12;

      public static const SINGLE_ARCADE:int = 20;
      public static const SINGLE_VS_PEOPLE:int = 21;
      public static const SINGLE_VS_CPU:int = 22;

      public static const SURVIVOR:int = 30;
      public static const TRAINING:int = 40;

      public static const VS_CPU:int = 50;
      public static const WATCH:int = 51;
      public static const NETWORK:int = 52;
      public static const TAG_BATTLE:int = 53;

      public static const MOSOU_ARCADE:int = 100;

      public function GameMode()
      {
         super();
      }

      public static function getTeams() : Array
      {
         return [{
            "id":1,
            "name":"P1"
         },{
            "id":2,
            "name":"P2"
         }];
      }

      public static function isTeamMode() : Boolean
      {
         return currentMode == TEAM_ARCADE || currentMode == TEAM_VS_CPU || currentMode == TEAM_VS_PEOPLE || currentMode == MOSOU_ARCADE || currentMode == WATCH || currentMode == VS_CPU;
      }

      public static function isSingleMode() : Boolean
      {
         return currentMode == SINGLE_ARCADE || currentMode == SINGLE_VS_CPU || currentMode == WATCH;
      }

      public static function isVsPeople() : Boolean
      {
         return currentMode == TEAM_VS_PEOPLE || currentMode == SINGLE_VS_PEOPLE;
      }

      public static function isVsCPU(param1:Boolean = true) : Boolean
      {
         return currentMode == TEAM_VS_CPU || currentMode == SINGLE_VS_CPU || param1 && currentMode == TRAINING || currentMode == WATCH || currentMode == VS_CPU;
      }

      public static function isTagTeam() : Boolean
      {
         return currentMode == TAG_BATTLE;
      }

      public static function isWatch() : Boolean
      {
         return currentMode == WATCH;
      }

      public static function isMultiplayer() : Boolean
      {
         return currentMode == NETWORK;
      }

      public static function isAcrade() : Boolean
      {
         return currentMode == SINGLE_ARCADE || currentMode == TEAM_ARCADE || currentMode == SURVIVOR;
      }
   }
}

