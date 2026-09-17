package net.play5d.game.bvn.data.mosou
{
   public class MosouFighterModel
   {
      private static var _i:MosouFighterModel;
      
      public var fighters:Vector.<MosouFighterSellVO>;
      
      private var _inited:Boolean = false;
      
      public function MosouFighterModel()
      {
         super();
      }
      
      public static function get I() : MosouFighterModel
      {
         if(!_i)
         {
            _i = new MosouFighterModel();
         }
         return _i;
      }
      
      public function init() : void
      {
         if(!_inited)
         {
            initFighters();
            _inited = true;
         }
      }
      
      public function allCustom() : void
      {
         fighters = new Vector.<MosouFighterSellVO>();
         _inited = true;
      }
      
      private function initFighters() : void
      {
         fighters = new Vector.<MosouFighterSellVO>();
         fighters.push(new MosouFighterSellVO("meirin",10000));
         fighters.push(new MosouFighterSellVO("flandre",10000));
         fighters.push(new MosouFighterSellVO("ibuki",10000));
      }
      
      public function addFighter(param1:String, param2:int) : void
      {
         if(containsFighter(param1))
         {
            trace("MosouFighterModel.addFighter 重复：" + param1);
            return;
         }
         fighters.push(new MosouFighterSellVO(param1,param2));
      }
      
      private function containsFighter(id:*) : Boolean
      {
         for each(var i:MosouFighterSellVO in fighters)
         {
            if(i.id == id)
            {
               return true;
            }
         }
         return false;
      }
   }
}

