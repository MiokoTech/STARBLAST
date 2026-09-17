package com.hurlant.math
{
   use namespace bi_internal;
   
   internal class MontgomeryReduction implements IReduction
   {
      private var m:BigInteger;
      
      private var mp:int;
      
      private var mpl:int;
      
      private var mph:int;
      
      private var um:int;
      
      private var mt2:int;
      
      public function MontgomeryReduction(param1:BigInteger)
      {
         super();
         this.m = param1;
         this.mp = param1.bi_internal::invDigit();
         this.mpl = this.mp & 0x7FFF;
         this.mph = this.mp >> 15;
         this.um = (1 << BigInteger.DB - 15) - 1;
         this.mt2 = 2 * param1.t;
      }
      
      public function convert(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         param1.abs().bi_internal::dlShiftTo(this.m.t,_loc2_);
         _loc2_.bi_internal::divRemTo(this.m,null,_loc2_);
         if(param1.bi_internal::s < 0 && _loc2_.compareTo(BigInteger.ZERO) > 0)
         {
            this.m.bi_internal::subTo(_loc2_,_loc2_);
         }
         return _loc2_;
      }
      
      public function revert(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         param1.bi_internal::copyTo(_loc2_);
         this.reduce(_loc2_);
         return _loc2_;
      }
      
      public function reduce(param1:BigInteger) : void
      {
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         while(param1.t <= this.mt2)
         {
            var _loc5_:*;
            param1.bi_internal::a[_loc5_ = param1.t++] = 0;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.m.t)
         {
            _loc3_ = param1.bi_internal::a[_loc2_] & 0x7FFF;
            _loc4_ = _loc3_ * this.mpl + ((_loc3_ * this.mph + (param1.bi_internal::a[_loc2_] >> 15) * this.mpl & this.um) << 15) & BigInteger.DM;
            _loc3_ = _loc2_ + this.m.t;
            param1.bi_internal::a[_loc3_] += this.m.bi_internal::am(0,_loc4_,param1,_loc2_,0,this.m.t);
            while(param1.bi_internal::a[_loc3_] >= BigInteger.DV)
            {
               param1.bi_internal::a[_loc3_] -= BigInteger.DV;
               ++param1.bi_internal::a[++_loc3_];
            }
            _loc2_++;
         }
         param1.bi_internal::clamp();
         param1.bi_internal::drShiftTo(this.m.t,param1);
         if(param1.compareTo(this.m) >= 0)
         {
            param1.bi_internal::subTo(this.m,param1);
         }
      }
      
      public function sqrTo(param1:BigInteger, param2:BigInteger) : void
      {
         param1.bi_internal::squareTo(param2);
         this.reduce(param2);
      }
      
      public function mulTo(param1:BigInteger, param2:BigInteger, param3:BigInteger) : void
      {
         param1.bi_internal::multiplyTo(param2,param3);
         this.reduce(param3);
      }
   }
}

