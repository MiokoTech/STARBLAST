package net.play5d.game.bvn.data.mosou
{
   public class MosouMissionVO
   {
      public var id:String;
      
      public var name:String;
      
      public var map:String;
      
      public var time:int;
      
      public var enemyLevel:int;
      
      public var waves:Vector.<MosouWaveVO>;
      
      public var area:MosouWorldMapAreaVO;
      
      public function MosouMissionVO()
      {
         super();
      }
      
      public function initByJsonObject(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:MosouWaveVO = null;
         id = param1.id;
         map = param1.map;
         time = int(param1.time);
         enemyLevel = int(param1.enemyLevel);
         if(enemyLevel < 1)
         {
            enemyLevel = 1;
         }
         if(!map || time < 1)
         {
            throw new Error("init mousou stage error!");
         }
         var _loc2_:Array = param1.waves;
         waves = new Vector.<MosouWaveVO>();
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = MosouWaveVO.createByJSON(_loc2_[_loc3_]);
            addWave(_loc4_);
            _loc3_++;
         }
      }
      
      public function getAllEnemies() : Vector.<MosouEnemyVO>
      {
         var _loc3_:int = 0;
         var _loc2_:MosouWaveVO = null;
         var _loc4_:* = undefined;
         var _loc1_:Vector.<MosouEnemyVO> = new Vector.<MosouEnemyVO>();
         while(_loc3_ < waves.length)
         {
            _loc2_ = waves[_loc3_];
            _loc4_ = _loc2_.getAllEnemies();
            if(_loc4_)
            {
               _loc1_ = _loc1_.concat(_loc4_);
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function getAllEnemieIds() : Array
      {
         var _loc5_:int = 0;
         var _loc4_:MosouWaveVO = null;
         var _loc3_:Array = null;
         var _loc1_:Array = [];
         while(_loc5_ < waves.length)
         {
            _loc4_ = waves[_loc5_];
            _loc3_ = _loc4_.getAllEnemieIds();
            if(_loc3_)
            {
               for each(var _loc2_:String in _loc3_)
               {
                  if(_loc1_.indexOf(_loc2_) == -1)
                  {
                     _loc1_.push(_loc2_);
                  }
               }
            }
            _loc5_++;
         }
         return _loc1_;
      }
      
      public function getBossIds() : Array
      {
         var _loc2_:Vector.<MosouEnemyVO> = getBosses();
         var _loc1_:Array = [];
         for each(var _loc3_:MosouEnemyVO in _loc2_)
         {
            if(_loc1_.indexOf(_loc3_.fighterID) == -1)
            {
               _loc1_.push(_loc3_.fighterID);
            }
         }
         return _loc1_;
      }
      
      public function getBosses() : Vector.<MosouEnemyVO>
      {
         var _loc5_:int = 0;
         var _loc4_:MosouWaveVO = null;
         var _loc3_:* = undefined;
         var _loc1_:Vector.<MosouEnemyVO> = new Vector.<MosouEnemyVO>();
         while(_loc5_ < waves.length)
         {
            _loc4_ = waves[_loc5_];
            _loc3_ = _loc4_.getBosses();
            if(_loc3_)
            {
               for each(var _loc2_:MosouEnemyVO in _loc3_)
               {
                  if(_loc1_.indexOf(_loc2_) == -1)
                  {
                     _loc1_.push(_loc2_);
                  }
               }
            }
            _loc5_++;
         }
         return _loc1_;
      }
      
      public function addWave(param1:MosouWaveVO) : void
      {
         if(!waves)
         {
            waves = new Vector.<MosouWaveVO>();
         }
         param1.id = waves.length + 1;
         waves.push(param1);
      }
      
      public function bossCount() : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:MosouWaveVO = null;
         while(_loc3_ < waves.length)
         {
            _loc1_ = waves[_loc3_];
            _loc2_ += _loc1_.bossCount();
            _loc3_++;
         }
         return _loc2_;
      }
   }
}

