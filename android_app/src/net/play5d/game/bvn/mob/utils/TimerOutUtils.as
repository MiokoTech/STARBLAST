package net.play5d.game.bvn.mob.utils
{
   import flash.events.Event;
   
   public class TimerOutUtils
   {
      private static var _timers:Object = {};
      
      public function TimerOutUtils()
      {
         super();
      }
      
      public static function setTimeout(param1:Function, param2:int, ... rest) : int
      {
         var _loc4_:InsTimer = new InsTimer(param2,param1,rest);
         _loc4_.addEventListener("complete",timerCompleteHandler);
         _timers[_loc4_.id] = _loc4_;
         return _loc4_.id;
      }
      
      public static function clearTimeout(param1:int) : void
      {
         var _loc2_:InsTimer = _timers[param1];
         if(_loc2_)
         {
            _loc2_.removeEventListener("complete",timerCompleteHandler);
            _loc2_.clear();
         }
         delete _timers[param1];
      }
      
      public static function pauseAllTimer() : void
      {
         var _loc1_:InsTimer = null;
         for(var i:String in _timers)
         {
            _loc1_ = _timers[i];
            _loc1_.pause();
         }
      }
      
      public static function resumeAllTimer() : void
      {
         var _loc1_:InsTimer = null;
         for(var i:String in _timers)
         {
            _loc1_ = _timers[i];
            _loc1_.resume();
         }
      }
      
      private static function resetTimer(param1:int) : void
      {
         var _loc2_:InsTimer = _timers[param1];
         if(_loc2_)
         {
            _loc2_.reset();
         }
      }
      
      private static function timerCompleteHandler(param1:Event) : void
      {
         var _loc2_:InsTimer = param1.currentTarget as InsTimer;
         clearTimeout(_loc2_.id);
      }
   }
}

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

class InsTimer extends EventDispatcher
{
   public var id:int;
   
   private var _func:Function;
   
   private var _timer:Timer;
   
   private var _params:Array;
   
   public function InsTimer(param1:Number, param2:Function, param3:Array)
   {
      super();
      this.id = Math.random() * 100000 << 0;
      _func = param2;
      _params = param3;
      _timer = new Timer(param1,1);
      _timer.addEventListener("timerComplete",timerHandler);
      _timer.start();
   }
   
   public function pause() : void
   {
      if(_timer)
      {
         _timer.stop();
      }
   }
   
   public function resume() : void
   {
      if(_timer)
      {
         _timer.start();
      }
   }
   
   public function reset() : void
   {
      if(_timer)
      {
         _timer.reset();
      }
   }
   
   public function clear() : void
   {
      if(_timer)
      {
         _timer.stop();
         _timer.removeEventListener("timerComplete",timerHandler);
         _timer = null;
      }
      _func = null;
      _params = null;
   }
   
   private function timerHandler(param1:TimerEvent) : void
   {
      if(_func != null)
      {
         if(_params)
         {
            _func.apply(null,_params);
         }
         else
         {
            _func();
         }
         _func = null;
         _params = null;
      }
      dispatchEvent(new Event("complete"));
   }
}
