package net.play5d.game.bvn.data.mosou
{
   public class MosouEnemyVO
   {
      public var fighterID:String;
      
      public var maxHp:int = 0;
      
      public var atk:int = 0;
      
      public var isBoss:Boolean;
      
      public var wave:MosouWaveVO;
      
      public var repeat:MosouWaveRepeatVO;
      
      private var exp:int = 10;
      
      private var money:int = 10;
      
      public var level:int = 1;
      
      public function MosouEnemyVO()
      {
         super();
      }
      
      public static function create(param1:String, param2:int = 200, param3:int = 0, param4:Boolean = false, param5:int = 10, param6:int = 10) : MosouEnemyVO
      {
         var _loc7_:MosouEnemyVO = new MosouEnemyVO();
         _loc7_.fighterID = param1;
         _loc7_.isBoss = param4;
         if(param2 > 0)
         {
            _loc7_.maxHp = param2;
         }
         if(param3 > 0)
         {
            _loc7_.atk = param3;
         }
         if(param5 > 0)
         {
            _loc7_.exp = param5;
         }
         else
         {
            _loc7_.exp = param4 ? 100 : 10;
         }
         if(param6 > 0)
         {
            _loc7_.money = param6;
         }
         else
         {
            _loc7_.money = param4 ? 100 : 10;
         }
         return _loc7_;
      }
      
      public static function createByJSON(param1:Object) : Vector.<MosouEnemyVO>
      {
         var _loc8_:int = 0;
         var _loc9_:MosouEnemyVO = null;
         var _loc10_:String = param1.id;
         var _loc6_:int = int(param1.hp);
         var _loc7_:int = int(param1.atk);
         var _loc3_:int = int(param1.amount);
         var _loc5_:Boolean = Boolean(param1.isBoss);
         var _loc11_:int = int(param1.exp);
         var _loc4_:int = int(param1.money);
         var _loc2_:Vector.<MosouEnemyVO> = new Vector.<MosouEnemyVO>();
         while(_loc8_ < _loc3_)
         {
            _loc9_ = create(_loc10_,_loc6_,_loc7_,_loc5_,_loc11_,_loc4_);
            _loc2_.push(_loc9_);
            _loc8_++;
         }
         return _loc2_;
      }
      
      public function getExp() : int
      {
         var _loc1_:int = isBoss ? level * 10 : level * 2;
         return exp + _loc1_;
      }
      
      public function getMoney() : int
      {
         var _loc1_:int = isBoss ? level * 5 : level * 1;
         return money + _loc1_;
      }
   }
}

