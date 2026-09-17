package net.play5d.game.bvn.data.mosou
{
   import net.play5d.game.bvn.utils.WrapInteger;
   
   public class MosouFighterSellVO
   {
      public var id:String;
      
      private var _price:WrapInteger = new WrapInteger(0);
      
      public function MosouFighterSellVO(param1:String, param2:int)
      {
         super();
         this.id = param1;
         _price.setValue(param2);
      }
      
      public function getPrice() : int
      {
         return _price.getValue();
      }
   }
}

