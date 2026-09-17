package net.play5d.game.bvn.data
{
   import net.play5d.kyo.utils.KyoRandom;
   
   public class MessionStageVO
   {
      public var fighters:Array;
      
      public var assister:String;
      
      public var map:String;
      
      public var mession:MessionVO;
      
      public var attackRate:Number = 1;
      
      public var hpRate:Number = 1;
      
      public function MessionStageVO()
      {
         super();
      }
      
      public function getFighters() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(mession.gameMode == 0)
         {
            _loc1_ = [];
            _loc1_ = _loc1_.concat(fighters);
            _loc2_ = 3 - _loc1_.length;
            if(_loc2_ > 0)
            {
               while(_loc3_ < _loc2_)
               {
                  _loc1_.push(null);
                  _loc3_++;
               }
            }
            return _loc1_;
         }
         return [KyoRandom.getRandomInArray(fighters)];
      }
   }
}

