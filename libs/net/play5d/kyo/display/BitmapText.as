package net.play5d.kyo.display
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.filters.BitmapFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class BitmapText extends Bitmap
   {
      public var autoUpdate:Boolean;
      
      protected var _tf:TextField;
      
      private var _format:TextFormat = new TextFormat();
      
      private var _filers:Array;
      
      private var _width:Number = 0;
      
      private var _height:Number = 0;
      
      public function BitmapText(param1:Boolean = true, param2:uint = 0, param3:Array = null)
      {
         super();
         this.autoUpdate = param1;
         this.smoothing = true;
         this._filers = param3;
         this._tf = new TextField();
         this.color = param2;
      }
      
      public function multiLine(param1:Boolean) : void
      {
         this._tf.multiline = param1;
         this._tf.wordWrap = true;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this._tf.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         this._tf.height = param1;
      }
      
      public function get textfield() : TextField
      {
         return this._tf;
      }
      
      public function get font() : String
      {
         return this._format.font;
      }
      
      public function set font(param1:String) : void
      {
         this._format.font = param1;
         if(this.autoUpdate)
         {
            this.update();
         }
      }
      
      public function get fontSize() : Object
      {
         return this._format.size;
      }
      
      public function set fontSize(param1:Object) : void
      {
         this._format.size = param1;
         if(this.autoUpdate)
         {
            this.update();
         }
      }
      
      public function get color() : uint
      {
         return this._format.color as uint;
      }
      
      public function set color(param1:uint) : void
      {
         this._format.color = param1;
         if(this.autoUpdate)
         {
            this.update();
         }
      }
      
      public function get align() : String
      {
         return this._format.align;
      }
      
      public function set align(param1:String) : void
      {
         this._format.align = param1;
      }
      
      public function get text() : String
      {
         return this._tf.text;
      }
      
      public function set text(param1:String) : void
      {
         this._tf.text = param1;
         if(this.autoUpdate)
         {
            this.update();
         }
      }
      
      public function setTextFormat(param1:TextFormat, param2:int = -1, param3:int = -1) : void
      {
         this._tf.setTextFormat(param1,param2,param3);
         if(this.autoUpdate)
         {
            this.update();
         }
      }
      
      public function get defaultTextFormat() : TextFormat
      {
         return this._format;
      }
      
      public function set defaultTextFormat(param1:TextFormat) : void
      {
         this._format = param1;
         if(this.autoUpdate)
         {
            this.update();
         }
      }
      
      public function getTextWidth() : Number
      {
         return this._tf.textWidth;
      }
      
      public function get textWidth() : Number
      {
         return this._tf.width;
      }
      
      public function set textWidth(param1:Number) : void
      {
         this._tf.width = param1;
      }
      
      public function get textHeight() : Number
      {
         return this._tf.height;
      }
      
      public function set textHeight(param1:Number) : void
      {
         this._tf.height = param1;
      }
      
      public function set leading(param1:Number) : void
      {
         this._format.leading = param1;
      }
      
      public function set letterSpacing(param1:Number) : void
      {
         this._format.letterSpacing = param1;
      }
      
      public function update() : void
      {
         var _loc3_:BitmapFilter = null;
         if(!this._tf)
         {
            return;
         }
         if(!this._tf.text)
         {
            return;
         }
         var _loc1_:int = int(this._format.size) > 0 ? int(this._format.size) : 12;
         this._tf.setTextFormat(this._format);
         this._tf.width = this._width != 0 ? this._width : this._tf.textWidth + _loc1_;
         this._tf.height = this._height != 0 ? this._height : this._tf.textHeight + _loc1_;
         var _loc2_:BitmapData = new BitmapData(this._tf.width,this._tf.height,true,0);
         _loc2_.draw(this._tf);
         if(this._filers)
         {
            for each(_loc3_ in this._filers)
            {
               _loc2_.applyFilter(_loc2_,new Rectangle(0,0,_loc2_.width,_loc2_.height),new Point(),_loc3_);
            }
         }
         if(bitmapData)
         {
            bitmapData.dispose();
         }
         bitmapData = _loc2_;
      }
      
      public function destory() : void
      {
         try
         {
            parent.removeChild(this);
         }
         catch(e:Error)
         {
         }
         if(bitmapData)
         {
            bitmapData.dispose();
         }
         this._tf = null;
      }
   }
}

