package net.play5d.game.bvn.data.mosou
{
   public class MosouWaveRepeatVO
   {
      public var type:int;
      
      public var hold:int;
      
      public var wave:MosouWaveVO;
      
      public var enemies:Vector.<MosouEnemyVO>;
      
      public var _holdFrame:int;
      
      public function MosouWaveRepeatVO()
      {
         super();
      }
      
      public function addEnemy(param1:Vector.<MosouEnemyVO>) : void
      {
         if(!enemies)
         {
            enemies = new Vector.<MosouEnemyVO>();
         }
         for each(var e:MosouEnemyVO in param1)
         {
            e.wave = wave;
            e.repeat = this;
            enemies.push(e);
         }
      }
   }
}

