package net.play5d.game.bvn.data
{
   public class MessionVO
   {
      public var comicType:int;
      
      public var gameMode:int;
      
      public var stageList:Vector.<MessionStageVO>;
      
      public function MessionVO()
      {
         super();
      }
      
      public function initByXML(param1:XML) : void
      {
         var _loc4_:int = 0;
         var _loc2_:MessionStageVO = null;
         var _loc3_:Object = null;
         var _loc5_:String = null;
         comicType = param1.@comicType;
         gameMode = param1.@gameMode;
         stageList = new Vector.<MessionStageVO>();
         while(_loc4_ < param1.stage.length())
         {
            _loc2_ = new MessionStageVO();
            _loc3_ = param1.stage[_loc4_];
            _loc5_ = _loc3_.@fighter;
            _loc2_.mession = this;
            _loc2_.assister = _loc3_.@assister;
            _loc2_.fighters = _loc5_.split(",");
            _loc2_.map = _loc3_.@map;
            _loc2_.hpRate = Number(_loc3_.@hpRate) > 0 ? Number(_loc3_.@hpRate) : 1;
            _loc2_.attackRate = Number(_loc3_.@attackRate) > 0 ? Number(_loc3_.@attackRate) : 1;
            stageList.push(_loc2_);
            _loc4_++;
         }
      }
   }
}

