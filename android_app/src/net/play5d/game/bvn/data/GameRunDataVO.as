package net.play5d.game.bvn.data
{
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class GameRunDataVO
   {
      public const p1FighterGroup:GameRunFighterGroup = new GameRunFighterGroup();
      
      public const p2FighterGroup:GameRunFighterGroup = new GameRunFighterGroup();
      
      public var map:MapVO;
      
      public var p1Wins:int = 0;
      
      public var p2Wins:int = 0;
      
      public var lastWinnerTeam:TeamVO;
      
      public var continueLoser:FighterMain;
      
      public var lastWinner:FighterMain;
      
      public var lastWinnerHp:int = 1000;
      
      public var lastLoserData:FighterVO;
      
      public var lastLoserQi:int = 0;
      
      public var round:int = 1;
      
      public var gameTime:int;
      
      public var gameTimeMax:int;
      
      public var isTimerOver:Boolean;
      
      public var isDrawGame:Boolean;
      
      public function get isSameFighter() : Boolean
      {
         if(!p1FighterGroup || !p2FighterGroup)
         {
            return false;
         }
         var p1Id:String = p1FighterGroup.currentFighterId;
         var p2Id:String = p2FighterGroup.currentFighterId;
         return p1Id != null && p2Id != null && p1Id == p2Id;
      }
      
      public function get isSameAssister() : Boolean
      {
         if(!p1FighterGroup || !p2FighterGroup)
         {
            return false;
         }
         var p1Id:String = p1FighterGroup.currentAssisterId;
         var p2Id:String = p2FighterGroup.currentAssisterId;
         return p1Id != null && p2Id != null && p1Id == p2Id;
      };
      
      public function GameRunDataVO()
      {
         super();
      }
      
      public function getWins(param1:FighterMain) : int
      {
         switch(param1.team.id - 1)
         {
            case 0:
               return p1Wins;
            case 1:
               return p2Wins;
            default:
               return 0;
         }
      }
      
      public function reset() : void
      {
         p1Wins = 0;
         p2Wins = 0;
         round = 1;
         lastWinnerTeam = null;
         lastWinner = null;
         lastLoserData = null;
         lastLoserQi = 0;
         isTimerOver = false;
         isDrawGame = false;
         lastWinnerHp = GameData.I.config.fighterHP;
         gameTimeMax = GameData.I.config.fightTime;
         gameTime = gameTimeMax;
         continueLoser = null;
      }
      
      public function clear() : void
      {
         map = null;
         lastWinnerTeam = null;
         lastWinner = null;
         lastLoserData = null;
         continueLoser = null;
      }
      
      public function nextRound() : void
      {
         round++;
         gameTime = gameTimeMax;
         isTimerOver = false;
      }
      
      public function setAllowLoseHP(param1:Boolean) : void
      {
         if(p1FighterGroup && p1FighterGroup.currentFighter)
         {
            p1FighterGroup.currentFighter.isAllowLoseHP = param1;
         }
         if(p2FighterGroup && p2FighterGroup.currentFighter)
         {
            p2FighterGroup.currentFighter.isAllowLoseHP = param1;
         }
      }
   }
}

