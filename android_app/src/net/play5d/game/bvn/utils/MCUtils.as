package net.play5d.game.bvn.utils
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.display.PixelSnapping;
   import flash.filters.ColorMatrixFilter;
   import net.play5d.game.bvn.fighter.LocalCoordManager;
   
   public class MCUtils
   {
      public function MCUtils()
      {
         super();
      }
      
      public static function hasFrameLabel(param1:MovieClip, param2:String) : Boolean
      {
         var _loc4_:Array = param1.currentLabels;
         for each(var i:FrameLabel in _loc4_)
         {
            if(i.name == param2)
            {
               return true;
            }
         }
         var fallbackHasLabel:Function = param1.hasOwnProperty("sbHasLabel") ? param1["sbHasLabel"] as Function : null;
         if(fallbackHasLabel != null)
         {
            try
            {
               return Boolean(fallbackHasLabel(param2));
            }
            catch(e:Error)
            {
            }
         }
         return false;
      }
      
      public static function setHUE(param1:DisplayObject, param2:Number = 0) : void
      {
         var _loc3_:ColorMatrixFilter = null;
         if(param2 == 0)
         {
            param1.filters = null;
         }
         else
         {
            _loc3_ = createHueFilter(param2);
            param1.filters = [_loc3_];
         }
      }
      
      private static function createHueFilter(param1:Number) : ColorMatrixFilter
      {
         var _loc4_:Number = NaN;
         _loc4_ = 0.213;
         var _loc5_:Number = NaN;
         _loc5_ = 0.715;
         var _loc6_:Number = NaN;
         _loc6_ = 0.072;
         var _loc2_:Number = Math.cos(param1 * 3.141592653589793 / 180);
         var _loc3_:Number = Math.sin(param1 * 3.141592653589793 / 180);
         return new ColorMatrixFilter([0.213 + _loc2_ * (1 - 0.213) + _loc3_ * (0 - 0.213),0.715 + _loc2_ * (0 - 0.715) + _loc3_ * (0 - 0.715),0.072 + _loc2_ * (0 - 0.072) + _loc3_ * (1 - 0.072),0,0,0.213 + _loc2_ * (0 - 0.213) + _loc3_ * 0.143,0.715 + _loc2_ * (1 - 0.715) + _loc3_ * 0.14,0.072 + _loc2_ * (0 - 0.072) + _loc3_ * -0.283,0,0,0.213 + _loc2_ * (0 - 0.213) + _loc3_ * -0.787,0.715 + _loc2_ * (0 - 0.715) + _loc3_ * 0.715,0.072 + _loc2_ * (1 - 0.072) + _loc3_ * 0.072,0,0,0,0,0,1,0]);
      }
      
      public static function applyPixelArtStyle(target:DisplayObjectContainer) : void
      {
         if(!target || !LocalCoordManager.isLocalCoordMode())
         {
            return;
         }
         var count:int = target.numChildren;
         for(var i:int = 0; i < count; i++)
         {
            var child:DisplayObject = target.getChildAt(i);
            if(child is Bitmap)
            {
               var bmp:Bitmap = child as Bitmap;
               bmp.smoothing = false;
               bmp.pixelSnapping = PixelSnapping.ALWAYS;
            }
            else if(child is DisplayObjectContainer)
            {
               applyPixelArtStyle(child as DisplayObjectContainer);
            }
         }
      }
   }
}

