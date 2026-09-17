package net.play5d.kyo.utils
{
   public class KyoTimerFormat
   {
      private static const EN_DAYS:Object = {
         0:"Sunday",
         1:"Monday",
         2:"Tuesdry",
         3:"Wednesday",
         4:"Thursday",
         5:"Friday",
         6:"Saturday"
      };
      
      private static const CN_DAYS:Object = {
         0:"星期天",
         1:"星期一",
         2:"星期二",
         3:"星期三",
         4:"星期四",
         5:"星期五",
         6:"星期六"
      };
      
      public function KyoTimerFormat()
      {
         super();
      }
      
      public static function isAM(param1:Date) : Boolean
      {
         return param1.hours < 12;
      }
      
      public static function getTime(param1:Date, param2:String = " : ", param3:Boolean = true, param4:Boolean = true) : String
      {
         var _loc5_:int = param1.hours;
         var _loc6_:String = formatNum(param1.minutes);
         var _loc7_:String = param3 ? param2 + formatNum(param1.seconds) : "";
         if(!param4 && _loc5_ > 12)
         {
            _loc5_ -= 12;
         }
         var _loc8_:String = formatNum(_loc5_);
         return _loc8_ + param2 + _loc6_ + _loc7_;
      }
      
      public static function getDate(param1:Date, param2:String = "/") : String
      {
         return param1.fullYear + param2 + formatNum(param1.month + 1) + param2 + formatNum(param1.date);
      }
      
      public static function getDateTime(param1:Date, param2:String = "/", param3:String = " : ", param4:Boolean = true, param5:Boolean = true) : String
      {
         return getDate(param1,param2) + " " + getTime(param1,param3,param4,param5);
      }
      
      public static function getDay(param1:Date, param2:int = 1) : String
      {
         var _loc3_:int = param1.day;
         switch(param2)
         {
            case 1:
               return EN_DAYS[_loc3_];
            case 2:
               return CN_DAYS[_loc3_];
            default:
               return _loc3_.toString();
         }
      }
      
      public static function secToTime(param1:int, param2:String = ":", param3:Boolean = true, param4:Boolean = true) : String
      {
         var _loc5_:int = param1 / 60 / 60;
         param1 -= _loc5_ * 60 * 60;
         var _loc6_:int = param1 / 60;
         param1 -= _loc6_ * 60;
         var _loc7_:String = "";
         if(param4)
         {
            _loc7_ = _loc5_ >= 10 ? _loc5_.toString() : "0" + _loc5_;
            _loc7_ = _loc7_ + param2;
         }
         var _loc8_:String = _loc6_ >= 10 ? _loc6_.toString() : "0" + _loc6_;
         var _loc9_:String = "";
         if(param3)
         {
            _loc9_ = param1 >= 10 ? param1.toString() : "0" + param1;
            _loc9_ = param2 + _loc9_;
         }
         return _loc7_ + _loc8_ + _loc9_;
      }
      
      public static function formatNum(param1:int) : String
      {
         return param1 >= 10 ? param1.toString() : "0" + param1;
      }
   }
}

