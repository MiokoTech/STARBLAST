package net.play5d.game.bvn.fighter.models
{
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class FighterHitModel
   {
      
      private var _hitObj:Object = {};
      
      private var _fighter:IGameSprite;
      
      public function FighterHitModel(param1:IGameSprite)
      {
         super();
         _fighter = param1;
      }
      
      public function destory() : void
      {
         _hitObj = null;
         _fighter = null;
      }
      
      public function clear() : void
      {
         _hitObj = {};
      }
      
      public function getHitVO(param1:String) : HitVO
      {
         return _hitObj[param1];
      }
      
      public function getAll() : Object
      {
         return _hitObj;
      }
      
      public function getHitVOLike(param1:String) : Vector.<HitVO>
      {
         var _loc3_:Vector.<HitVO> = new Vector.<HitVO>();
         for(var _loc2_:String in _hitObj)
         {
            if(_loc2_.indexOf(param1) != -1)
            {
               _loc3_.push(_hitObj[_loc2_]);
            }
         }
         return _loc3_;
      }
      
      public function getHitVOByDisplayName(param1:String) : HitVO
      {
         var _loc3_:HitVO = getHitVO(param1);
         if(_loc3_)
         {
            return _loc3_;
         }
         if(param1.indexOf("atm") == -1)
         {
            return null;
         }
         var _loc2_:String = param1.replace("atm","");
         return getHitVO(_loc2_);
      }
      
      public function addHitVO(param1:String, param2:Object) : void
      {
         var _loc3_:HitVO = new HitVO(param2);
         _loc3_.owner = _fighter;
         _loc3_.id = param1;
         _hitObj[param1] = _loc3_;
      }
      
      public function setPowerRate(param1:Number) : void
      {
         for each(var _loc2_:HitVO in _hitObj)
         {
            _loc2_.powerRate = param1;
         }
      }
   }
}

