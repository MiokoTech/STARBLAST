package net.play5d.kyo.display.bitmap
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   
   public class BitmapFontText extends Bitmap
   {
      private var _font:BitmapFont;
      
      private var _text:String;
      
      private var _orgBitmapData:BitmapData;
      
      public function BitmapFontText(param1:BitmapFont)
      {
         super(null,"auto",true);
         this._font = param1;
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      public function set text(param1:String) : void
      {
         this._text = param1;
         if(this._font == null)
         {
            bitmapData = new BitmapData(1,1,true,0);
            smoothing = true;
            return;
         }
         var translatedBitmapData:BitmapData = this._font.translate(param1);
         if(translatedBitmapData == null)
         {
            translatedBitmapData = new BitmapData(1,1,true,0);
         }
         bitmapData = translatedBitmapData;
         smoothing = true;
         width = bitmapData.width;
      }
      
      public function colorTransform(param1:ColorTransform) : void
      {
         if(param1 == null)
         {
            if(this._orgBitmapData)
            {
               bitmapData.dispose();
               bitmapData = this._orgBitmapData.clone();
            }
            return;
         }
         if(!this._orgBitmapData)
         {
            if(bitmapData == null)
            {
               return;
            }
            this._orgBitmapData = bitmapData.clone();
         }
         if(bitmapData == null)
         {
            return;
         }
         bitmapData.colorTransform(new Rectangle(0,0,bitmapData.width,bitmapData.height),param1);
      }
      
      public function applyColorTransform(param1:ColorTransform) : void
      {
         colorTransform(param1);
      }
      
      public function dispose() : void
      {
         if(this._orgBitmapData)
         {
            this._orgBitmapData.dispose();
            this._orgBitmapData = null;
         }
         if(bitmapData)
         {
            bitmapData.dispose();
            bitmapData = null;
         }
      }
   }
}

