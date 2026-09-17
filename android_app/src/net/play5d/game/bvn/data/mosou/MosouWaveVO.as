package net.play5d.game.bvn.data.mosou
{
   public class MosouWaveVO
   {
      public var id:int;
      
      public var enemies:Vector.<MosouEnemyVO>;
      
      public var repeats:Vector.<MosouWaveRepeatVO>;
      
      public var hold:int;
      
      public function MosouWaveVO()
      {
         super();
      }
      
      public static function createByJSON(json:Object) : MosouWaveVO
      {
         var wave:MosouWaveVO = new MosouWaveVO();
         wave.hold = int(json.hold);
         var enemies:Array = json.enemies;
         for (var j:int = 0; j < enemies.length; j++)
         {
            wave.addEnemy(MosouEnemyVO.createByJSON(enemies[j]));
         }
         if (json.repeat)
         {
            wave.repeats = new Vector.<MosouWaveRepeatVO>();                      
            var waveRepeat:MosouWaveRepeatVO = new MosouWaveRepeatVO();
            waveRepeat.type = json.repeat.type;
            waveRepeat.hold = json.repeat.hold;
            var repeatEnemies:Array = json.repeat.enemies;
            for (var k:int = 0; k < repeatEnemies.length; k++)
            {
               waveRepeat.addEnemy(MosouEnemyVO.createByJSON(repeatEnemies[k]));
            }
            wave.repeats.push(waveRepeat);
         }
         return wave;
      }
      
      public function getAllEnemies() : Vector.<MosouEnemyVO>
      {
         var result:Vector.<MosouEnemyVO> = enemies.concat();
         for each(var i:MosouWaveRepeatVO in repeats)
         {
            if (i.enemies)
            {
               result = result.concat(i.enemies);
            }
         }
         return result;
      }
      
      public function getAllEnemieIds() : Array
      {
         var result:Array = [];
         var allEnemies:Vector.<MosouEnemyVO> = getAllEnemies();
         for each(var e:MosouEnemyVO in allEnemies)
         {
            if (result.indexOf(e.fighterID) == -1)
            {
               result.push(e.fighterID);
            }
         }
         return result;
      }
      
      public function getBosses() : Vector.<MosouEnemyVO>
      {
         var result:Vector.<MosouEnemyVO> = new Vector.<MosouEnemyVO>();
         var allEnemies:Vector.<MosouEnemyVO> = getAllEnemies();
         for each(var e:MosouEnemyVO in allEnemies)
         {
            if (!e.isBoss)
            {
               continue;
            }
            if (result.indexOf(e) == -1)
            {
               result.push(e);
            }
         }
         return result;
      }
      
      public function addEnemy(enemyAdd:Vector.<MosouEnemyVO>) : void
      {
         enemies ||= new Vector.<MosouEnemyVO>();
         for each(var e:MosouEnemyVO in enemyAdd)
         {
            e.wave = this;
            enemies.push(e);
         }
      }
      
      public function addRepeat(repeat:MosouWaveRepeatVO) : void
      {
         repeats ||= new Vector.<MosouWaveRepeatVO>();
         repeat.wave = this;
         repeats.push(repeat);
      }
      
      public function bossCount() : int
      {
         var count:int = 0;
         for each(var i:MosouEnemyVO in enemies)
         {
            if(i.isBoss)
            {
               count++;
            }
         }
         return count;
      }
   }
}

