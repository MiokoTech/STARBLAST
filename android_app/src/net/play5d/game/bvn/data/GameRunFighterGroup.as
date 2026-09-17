package net.play5d.game.bvn.data
{
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class GameRunFighterGroup
   {
      public var fighter1:FighterVO;
      
      public var fighter2:FighterVO;
      
      public var fighter3:FighterVO;
      
      public var assister:FighterVO;
      
      public var nextFighter1:FighterMain;
      
      public var nextFighter2:FighterMain;
      
      public var currentFighter:FighterMain;
      
      public var currentAssister:Assister;
      
      public function get currentFighterId() : String
      {
         if(currentFighter && currentFighter.data)
         {
            return currentFighter.data.id;
         }
         return null;
      }
      
      public function get currentAssisterId() : String
      {
         if(currentAssister && currentAssister.data)
         {
            return currentAssister.data.id;
         }
         if(assister)
         {
            return assister.id;
         }
         return null;
      };
      
      private var _fighterMap:Dictionary;
      
      public function GameRunFighterGroup()
      {
         super();
      }
      
      public function destory() : void
      {
         fighter1 = null;
         fighter2 = null;
         fighter3 = null;
         assister = null;
         if(currentFighter)
         {
            currentFighter.destory(true);
            currentFighter = null;
         }
         if(currentAssister)
         {
            currentAssister.destory(true);
            currentAssister = null;
         }
      }
      
      public function getFighters(param1:Boolean = false) : Vector.<FighterVO>
      {
         var _loc2_:Vector.<FighterVO> = new Vector.<FighterVO>();
         var _loc3_:FighterVO = !!currentFighter ? currentFighter.data : null;
         if(param1)
         {
            if(fighter1 != _loc3_)
            {
               _loc2_.push(fighter1);
            }
            if(fighter2 != _loc3_)
            {
               _loc2_.push(fighter2);
            }
            if(fighter3 != _loc3_)
            {
               _loc2_.push(fighter3);
            }
         }
         else
         {
            _loc2_.push(fighter1);
            _loc2_.push(fighter2);
            _loc2_.push(fighter3);
         }
         return _loc2_;
      }
      
      public function getAliveFighters() : Vector.<FighterMain>
      {
         var _loc1_:Vector.<FighterMain> = new Vector.<FighterMain>();
         var _loc2_:FighterMain = getFighter(fighter1);
         var _loc3_:FighterMain = getFighter(fighter2);
         var _loc4_:FighterMain = getFighter(fighter3);
         if(_loc2_ && _loc2_.isAlive)
         {
            _loc1_.push(_loc2_);
         }
         if(_loc3_ && _loc3_.isAlive)
         {
            _loc1_.push(_loc3_);
         }
         if(_loc4_ && _loc4_.isAlive)
         {
            _loc1_.push(_loc4_);
         }
         return _loc1_;
      }
      
      public function getNextAliveFighter() : FighterMain
      {
         if(!currentFighter)
         {
            return null;
         }
         var _loc1_:Vector.<FighterMain> = getAliveFighters();
         if(_loc1_.length < 2)
         {
            return null;
         }
         var _loc2_:int = int(_loc1_.indexOf(currentFighter));
         if(_loc2_ == _loc1_.length - 1)
         {
            return _loc1_[0];
         }
         return _loc1_[_loc2_ + 1];
      }
      
      public function getNextFighter(param1:Boolean = false) : FighterVO
      {
         if(!currentFighter)
         {
            return null;
         }
         switch(currentFighter.data)
         {
            case fighter1:
               return fighter2;
            case fighter2:
               return fighter3;
            case fighter3:
               return param1 ? fighter1 : null;
            default:
               return null;
         }
      }
      
      public function putFighter(param1:FighterMain) : void
      {
         if(!_fighterMap)
         {
            _fighterMap = new Dictionary();
         }
         _fighterMap[param1.data] = param1;
      }
      
      public function getFighter(param1:FighterVO) : FighterMain
      {
         if(!_fighterMap)
         {
            return null;
         }
         return _fighterMap[param1];
      }
      
      public function getHoldFighters() : Vector.<FighterMain>
      {
         if(!currentFighter)
         {
            return null;
         }
         var _loc1_:Vector.<FighterMain> = getAliveFighters();
         var _loc2_:int = int(_loc1_.indexOf(currentFighter));
         if(_loc2_ != -1)
         {
            _loc1_.splice(_loc2_,1);
         }
         return _loc1_;
      }
   }
}

