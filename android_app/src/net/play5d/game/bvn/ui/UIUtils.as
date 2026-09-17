package net.play5d.game.bvn.ui
{
   import flash.text.TextField;
   import flash.text.TextFormat;
   import net.play5d.kyo.utils.KyoUtils;
   
   public class UIUtils
   {
      public static var formatTextFunction:Function;
      
      public static var DEFAULT_FONT:String = "黑体";
      
      public static var LOCK_FONT:String = null;
      
      public function UIUtils()
      {
         super();
      }
      
      public static function formatText(param1:TextField, param2:Object = null) : void
      {
         var _loc3_:TextFormat = null;
         if(param2)
         {
            _loc3_ = new TextFormat();
            _loc3_.font = DEFAULT_FONT;
            KyoUtils.setValueByObject(_loc3_,param2);
            if(LOCK_FONT)
            {
               _loc3_.font = LOCK_FONT;
            }
            param1.defaultTextFormat = _loc3_;
         }
         if(formatTextFunction != null)
         {
            formatTextFunction(param1);
         }
      }
   }
}

