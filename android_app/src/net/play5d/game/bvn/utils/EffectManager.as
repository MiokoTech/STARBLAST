package net.play5d.game.bvn.utils
{
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.data.EffectModel;
   import net.play5d.game.bvn.data.EffectVO;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.game.bvn.views.effects.BuffEffectView;
   import net.play5d.game.bvn.views.effects.EffectView;
   import net.play5d.game.bvn.views.effects.ShineEffectView;
   import net.play5d.game.bvn.views.effects.SpecialEffectView;
   import net.play5d.game.bvn.views.effects.SteelHitEffect;
   
   public class EffectManager
   {
      private var _viewCache:Dictionary = new Dictionary();
      
      private var _hitCache:Dictionary = new Dictionary();
      
      private var _defCache:Dictionary = new Dictionary();
      
      private var _shineCache:Vector.<ShineEffectView> = new Vector.<ShineEffectView>();
      
      public function EffectManager()
      {
         super();
      }
      
      public function destory() : void
      {
         for each(var _loc1_:Vector.<EffectView> in _viewCache)
         {
            for each(var _loc2_:EffectView in _loc1_)
            {
               _loc2_.destory();
            }
         }
         for each(var _loc3_:ShineEffectView in _shineCache)
         {
            _loc3_.destory();
         }
         _viewCache = null;
         _hitCache = null;
         _defCache = null;
         _shineCache = null;
      }
      
      public function getHitEffectVOByHitVO(param1:HitVO, param2:IGameSprite = null) : EffectVO
      {
         var _loc4_:FighterMain = null;
         var _loc6_:EffectCacheVO = _hitCache[param1];
         var _loc3_:Boolean = false;
         if(param2 && param2 is FighterMain)
         {
            _loc4_ = param2 as FighterMain;
            _loc3_ = _loc4_.isMosouEnemy();
         }
         if(_loc6_)
         {
            if(_loc3_ && _loc6_.mosouEnemy)
            {
               return _loc6_.mosouEnemy;
            }
            if(!_loc3_ && _loc6_.normal)
            {
               return _loc6_.normal;
            }
         }
         var _loc5_:EffectVO;
         if(_loc3_)
         {
            _loc5_ = EffectModel.I.getMosouEnemyHitEffect(param1.hitType);
         }
         else if(param1.customEffectVO)
         {
            _loc5_ = param1.customEffectVO;
         }
         else
         {
            _loc5_ = EffectModel.I.getHitEffect(param1.hitType);
         }
         if(!_loc5_)
         {
            _hitCache[param1] = null;
            return null;
         }
         _loc5_ = _loc5_.clone();
         if(_loc5_.shake)
         {
            if(_loc5_.shake.pow != undefined && _loc5_.shake.pow != 0)
            {
               _loc5_.shake.y = _loc5_.shake.pow;
            }
            if(_loc5_.shake.x == 0 && _loc5_.shake.y == 0)
            {
               _loc5_.shake.x = 3;
            }
         }
         _loc6_ = new EffectCacheVO();
         if(_loc3_)
         {
            _loc6_.mosouEnemy = _loc5_;
         }
         else
         {
            _loc6_.normal = _loc5_;
         }
         _hitCache[param1] = _loc6_;
         return _loc5_;
      }
      
      public function getDefenseEffectVOByHitVO(param1:HitVO, param2:int, param3:IGameSprite = null) : EffectVO
      {
         var _loc5_:FighterMain = null;
         var _loc7_:EffectCacheVO = _defCache[param1];
         var _loc4_:Boolean = false;
         if(param3 && param3 is FighterMain)
         {
            _loc5_ = param3 as FighterMain;
            _loc4_ = _loc5_.isMosouEnemy();
         }
         if(_loc7_)
         {
            if(_loc4_ && _loc7_.mosouEnemy)
            {
               return _loc7_.mosouEnemy;
            }
            if(!_loc4_ && _loc7_.normal)
            {
               return _loc7_.normal;
            }
         }
         var _loc6_:EffectVO = _loc4_ ? EffectModel.I.getMosouEnemyDefenseEffect(param1.hitType,param2) : EffectModel.I.getDefenseEffect(param1.hitType,param2);
         if(!_loc6_)
         {
            _defCache[param1] = null;
            return null;
         }
         _loc6_ = _loc6_.clone();
         _loc7_ = new EffectCacheVO();
         if(_loc4_)
         {
            _loc7_.mosouEnemy = _loc6_;
         }
         else
         {
            _loc7_.normal = _loc6_;
         }
         _defCache[param1] = _loc7_;
         return _loc6_;
      }
      
      public function getEffectView(param1:EffectVO) : EffectView
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:EffectView = null;
         var _loc3_:Vector.<EffectView> = _viewCache[param1];
         if(_loc3_)
         {
            _loc5_ = int(_loc3_.length);
            while(_loc4_ < _loc5_)
            {
               if(!_loc3_[_loc4_].isActive)
               {
                  return _loc3_[_loc4_];
               }
               _loc4_++;
            }
         }
         else
         {
            _loc3_ = new Vector.<EffectView>();
            _viewCache[param1] = _loc3_;
         }
         if(param1.isSpecial)
         {
            _loc2_ = new SpecialEffectView(param1);
         }
         else if(param1.isBuff)
         {
            _loc2_ = new BuffEffectView(param1);
         }
         else if(param1.isSteelHit)
         {
            _loc2_ = new SteelHitEffect(param1);
         }
         else
         {
            _loc2_ = new EffectView(param1);
         }
         _loc3_.push(_loc2_);
         return _loc2_;
      }
      
      public function getShine() : ShineEffectView
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(_shineCache.length);
         while(_loc2_ < _loc3_)
         {
            if(!_shineCache[_loc2_].isActive)
            {
               return _shineCache[_loc2_];
            }
            _loc2_++;
         }
         var _loc1_:ShineEffectView = new ShineEffectView();
         _shineCache.push(_loc1_);
         return _loc1_;
      }
   }
}

