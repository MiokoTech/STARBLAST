package net.play5d.kyo.display.bitmap
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class BitmapFont
   {
      public var charGap:Number = 0;
      
      public var spaceGap:Number = 0;
      
      public var offsetX:Number = 0;
      
      public var offsetY:Number = 0;
      
      private var _source:BitmapData;
      
      private var _fontCache:Object;
      
      private var _charWidth:int;
      
      private var _charHeight:int;
      
      private var _yOffsetMin:int = 999;
      
      public function BitmapFont(param1:XML, param2:BitmapData)
      {
         var _loc3_:XML = null;
         var _loc4_:InsCharVO = null;
         this._fontCache = {};
         super();
         this._source = param2;
         this._charWidth = param1.info.@size;
         for each(_loc3_ in param1.chars.char)
         {
            _loc4_ = new InsCharVO(_loc3_);
            if(this._charHeight < _loc4_.height)
            {
               this._charHeight = _loc4_.height;
            }
            if(this._yOffsetMin > _loc4_.yoffset)
            {
               this._yOffsetMin = _loc4_.yoffset;
            }
            this._fontCache[_loc4_.id] = _loc4_;
         }
      }
      
      public function translate(param1:String) : BitmapData
      {
         var _loc4_:int = 0;
         var _loc5_:InsCharVO = null;
         var _loc7_:int = 0;
         var _loc8_:Rectangle = null;
         var _loc9_:Point = null;
         if(param1 == null)
         {
            param1 = "";
         }
         var _loc2_:Number = 0;
         var _loc3_:Array = [];
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc7_ = int(param1.charCodeAt(_loc4_));
            if(_loc7_ == 32 && Boolean(this.spaceGap))
            {
               _loc2_ += this.spaceGap;
            }
            else
            {
               _loc5_ = this.getChar(_loc7_);
               if(!_loc5_)
               {
                  if(_loc7_ == 32)
                  {
                     _loc2_ += this._charWidth + this.charGap;
                  }
               }
               else
               {
                  _loc5_.x = _loc2_;
                  _loc2_ += _loc5_.width + this.charGap;
                  _loc3_.push(_loc5_);
               }
            }
            _loc4_++;
         }
         if(this.charGap < 0)
         {
            _loc2_ -= this.charGap;
         }
         var outputWidth:int = int(Math.ceil(_loc2_));
         if(outputWidth < 1)
         {
            outputWidth = this._charWidth > 0 ? this._charWidth : 1;
         }
         var outputHeight:int = this._charHeight > 0 ? this._charHeight : 1;
         var _loc6_:BitmapData = new BitmapData(outputWidth,outputHeight,true,0);
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            _loc8_ = new Rectangle(_loc5_.sx,_loc5_.sy,_loc5_.width,_loc5_.height);
            _loc9_ = new Point(_loc5_.x + this.offsetX,_loc5_.y + (_loc5_.yoffset - this._yOffsetMin) + this.offsetY);
            _loc6_.copyPixels(this._source,_loc8_,_loc9_,null,null,true);
            _loc4_++;
         }
         return _loc6_;
      }
      
      private function getChar(param1:int) : InsCharVO
      {
         var _loc2_:InsCharVO = this._fontCache[param1];
         if(_loc2_)
         {
            return _loc2_.clone();
         }
         return null;
      }
   }
}

class InsCharVO
{
   public var x:Number = 0;
   
   public var y:Number = 0;
   
   public var id:String;
   
   public var sx:int;
   
   public var sy:int;
   
   public var width:int;
   
   public var height:int;
   
   public var xoffset:int;
   
   public var yoffset:int;
   
   public var xadvance:int;
   
   private var _xml:XML;
   
   public function InsCharVO(param1:XML = null)
   {
      super();
      this._xml = param1;
      if(param1)
      {
         this.id = param1.@id;
         this.sx = param1.@x;
         this.sy = param1.@y;
         this.width = param1.@width;
         this.height = param1.@height;
         this.xoffset = param1.@xoffset;
         this.yoffset = param1.@yoffset;
         this.xadvance = param1.@xadvance;
      }
   }
   
   public function clone() : InsCharVO
   {
      return new InsCharVO(this._xml);
   }
}
