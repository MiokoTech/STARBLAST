package net.play5d.kyo.display
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class MCNumber extends Sprite
   {
      public var mcWidth:Number = -1;
      
      public var startFrame:int;
      
      protected var _mc:Class;
      
      protected var _mcs:Array = [];
      
      protected var _number:uint;
      
      protected var _bits:uint;
      
      public function MCNumber(param1:Class, param2:uint, param3:int = 1, param4:Number = -1, param5:uint = 0)
      {
         super();
         this._mc = param1;
         this._bits = param5;
         this.startFrame = param3;
         this.mcWidth = param4;
         this.number = param2;
      }
      
      public function get number() : uint
      {
         return this._number;
      }

      public function set number(v:uint) : void
      {
         _number = v;
         for each(var m:DisplayObject in _mcs) {
            removeChild(m);
         }
         _mcs              = [];
         var numStr:String = v.toString();

         while (numStr.length < _bits) {
            numStr = '0' + numStr;
         }

         var xx:Number = 0;
         for (var i:int; i < numStr.length; i++) {
            var w:String          = numStr.charAt(i);
            var wmc:DisplayObject = createNum(int(w));
            wmc.x                 = xx;
            xx += mcWidth == -1 ? wmc.width : mcWidth;
         }
      }
      
      protected function createNum(param1:int) : DisplayObject
      {
         var _loc2_:MovieClip = new this._mc();
         _loc2_.gotoAndStop(this.startFrame + param1);
         addChild(_loc2_);
         this._mcs.push(_loc2_);
         return _loc2_;
      }
   }
}

