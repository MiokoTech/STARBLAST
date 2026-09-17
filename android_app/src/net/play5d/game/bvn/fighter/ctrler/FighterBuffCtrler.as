package net.play5d.game.bvn.fighter.ctrler
{
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.vos.FighterBuffVO;
   
   public class FighterBuffCtrler
   {
      
      private var _fighter:FighterMain;
      
      private var _speed:Number = 0;
      
      private var _attackRate:Number = 0;
      
      private var _buffObj:Object = {};
      
      public function FighterBuffCtrler(param1:FighterMain)
      {
         super();
         _fighter = param1;
      }
      
      public function destory() : void
      {
         _fighter = null;
      }
      
      public function speedUp(param1:Number = 0, param2:Number = 5) : void
      {
         var _loc3_:FighterBuffVO = addBuff("speed",param1,param2);
         if(!_loc3_)
         {
            return;
         }
         EffectCtrl.I.doEffectById("buff_effect_speed",_fighter.x,_fighter.y);
         EffectCtrl.I.doBuffEffect("buff_speed",_fighter,_loc3_);
      }
      
      public function attackUp(param1:Number = 0, param2:Number = 5) : void
      {
         var _loc3_:FighterBuffVO = addBuff("attackRate",param1,param2);
         if(!_loc3_)
         {
            return;
         }
         EffectCtrl.I.doEffectById("buff_effect_power",_fighter.x,_fighter.y);
         EffectCtrl.I.doBuffEffect("buff_power",_fighter,_loc3_);
      }
      
      public function defenseUp(param1:Number = 0, param2:Number = 5) : void
      {
         var _loc3_:FighterBuffVO = addBuff("defenseRate",param1,param2);
         if(!_loc3_)
         {
            return;
         }
         EffectCtrl.I.doEffectById("buff_effect_defense",_fighter.x,_fighter.y);
         EffectCtrl.I.doBuffEffect("buff_defense",_fighter,_loc3_);
      }
      
      public function speedDown(param1:Number = 0, param2:Number = 5) : void
      {
         addBuff("speed",-param1,param2);
      }
      
      public function attackDown(param1:Number = 0, param2:Number = 5) : void
      {
         addBuff("attackRate",param1,param2);
      }
      
      public function defenseDown(param1:Number = 0, param2:Number = 5) : void
      {
         addBuff("defense",-param1,param2);
      }
      
      private function addBuff(param1:String, param2:*, param3:Number) : FighterBuffVO
      {
         var _loc4_:FighterBuffVO = null;
         try
         {
            _loc4_ = _buffObj[param1];
            if(!_loc4_)
            {
               _loc4_ = new FighterBuffVO(param1,param3);
               _buffObj[param1] = _loc4_;
               _loc4_.resumeValue = _fighter[param1];
            }
            else
            {
               _loc4_.setHold(param3);
            }
            _fighter[param1] = _loc4_.resumeValue + param2;
            return _loc4_;
         }
         catch(e:Error)
         {
            trace(e);
            var _loc7_:* = null;
         }
         return _loc7_;
      }
      
      public function render() : void
      {
         var _loc1_:FighterBuffVO = null;
         for(var _loc2_:String in _buffObj)
         {
            _loc1_ = _buffObj[_loc2_];
            if(_loc1_.render())
            {
               _fighter[_loc1_.param] = _loc1_.resumeValue;
               delete _buffObj[_loc2_];
            }
         }
      }
   }
}

