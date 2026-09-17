package net.play5d.game.bvn.data.mosou.utils
{
   import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
   
   public class MosouFighterFactory
   {
      public function MosouFighterFactory()
      {
         super();
      }
      
      public static function create(param1:String) : MosouFighterVO
      {
         var _loc2_:MosouFighterVO = new MosouFighterVO();
         _loc2_.id = param1;
         return _loc2_;
      }
   }
}

