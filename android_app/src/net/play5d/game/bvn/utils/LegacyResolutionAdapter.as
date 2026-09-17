package net.play5d.game.bvn.utils
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.GameConfig;
   
   public class LegacyResolutionAdapter
   {
      private static const LAYOUT_WIDTH_TOLERANCE:Number = 120;
      
      private static const LAYOUT_HEIGHT_TOLERANCE:Number = 110;
      
      private static const LEGACY_RATIO:Number = 4 / 3;
      
      private static const LEGACY_RATIO_TOLERANCE:Number = 0.18;
      
      private static const FULLSCREEN_POSITION_TOLERANCE:Number = 160;
      
      private static var _displayAdaptCache:Dictionary = new Dictionary(true);
      
      public function LegacyResolutionAdapter()
      {
         super();
      }
      
      public static function getScaleX(baseWidth:Number = NaN) : Number
      {
         var sourceWidth:Number = isNaN(baseWidth) || baseWidth <= 0 ? GameConfig.LEGACY_RESOLUTION_WIDTH : baseWidth;
         return GameConfig.GAME_SIZE.x / sourceWidth;
      }
      
      public static function getScaleY(baseHeight:Number = NaN) : Number
      {
         var sourceHeight:Number = isNaN(baseHeight) || baseHeight <= 0 ? GameConfig.LEGACY_RESOLUTION_HEIGHT : baseHeight;
         return GameConfig.GAME_SIZE.y / sourceHeight;
      }
      
      public static function scaleX(value:Number, baseWidth:Number = NaN) : Number
      {
         return value * getScaleX(baseWidth);
      }
      
      public static function scaleY(value:Number, baseHeight:Number = NaN) : Number
      {
         return value * getScaleY(baseHeight);
      }
      
      public static function scalePoint(point:Point, baseWidth:Number = NaN, baseHeight:Number = NaN) : Point
      {
         if(point == null)
         {
            return null;
         }
         return new Point(scaleX(point.x,baseWidth),scaleY(point.y,baseHeight));
      }
      
      public static function shouldScaleLegacyLayout(sourceWidth:Number, sourceHeight:Number) : Boolean
      {
         var currentMode:int = GameConfig.LEGACY_ASSET_SCALE_MODE;
         if(currentMode == GameConfig.LEGACY_SCALE_MODE_OFF)
         {
            return false;
         }
         if(currentMode == GameConfig.LEGACY_SCALE_MODE_FORCE_800X600)
         {
            return true;
         }
         if(sourceWidth <= 0 || sourceHeight <= 0)
         {
            return false;
         }
         var widthNearLegacy:Boolean = Math.abs(sourceWidth - GameConfig.LEGACY_RESOLUTION_WIDTH) <= LAYOUT_WIDTH_TOLERANCE;
         var heightNearLegacy:Boolean = Math.abs(sourceHeight - GameConfig.LEGACY_RESOLUTION_HEIGHT) <= LAYOUT_HEIGHT_TOLERANCE;
         return widthNearLegacy && heightNearLegacy;
      }
      
      public static function shouldScaleLegacyMap(sourceWidth:Number, sourceHeight:Number) : Boolean
      {
         var currentMode:int = GameConfig.LEGACY_ASSET_SCALE_MODE;
         if(currentMode == GameConfig.LEGACY_SCALE_MODE_OFF)
         {
            return false;
         }
         if(currentMode == GameConfig.LEGACY_SCALE_MODE_FORCE_800X600)
         {
            return true;
         }
         if(sourceWidth <= 0 || sourceHeight <= 0)
         {
            return false;
         }
         return Math.abs(sourceHeight - GameConfig.LEGACY_RESOLUTION_HEIGHT) <= LAYOUT_HEIGHT_TOLERANCE;
      }
      
      public static function adaptLegacyFighterChild(targetDisplay:DisplayObject) : void
      {
         if(targetDisplay == null)
         {
            return;
         }
         if(GameConfig.LEGACY_ASSET_SCALE_MODE == GameConfig.LEGACY_SCALE_MODE_OFF)
         {
            return;
         }
         var displayWidth:Number = Math.abs(targetDisplay.width);
         var displayHeight:Number = Math.abs(targetDisplay.height);
         if(displayWidth <= 0 || displayHeight <= 0)
         {
            return;
         }
         var hasLegacyShape:Boolean = shouldScaleLegacyFullScreenDisplay(displayWidth,displayHeight);
         if(!hasLegacyShape)
         {
            return;
         }
         if(!looksLikeFullScreenPlacement(targetDisplay,displayWidth,displayHeight))
         {
            return;
         }
         var cachedData:LegacyDisplayScaleData = _displayAdaptCache[targetDisplay];
         if(cachedData && cachedData.appliedMode == GameConfig.LEGACY_ASSET_SCALE_MODE)
         {
            return;
         }
         if(!cachedData)
         {
            cachedData = new LegacyDisplayScaleData();
            cachedData.originalX = targetDisplay.x;
            cachedData.originalY = targetDisplay.y;
            cachedData.originalScaleX = targetDisplay.scaleX;
            cachedData.originalScaleY = targetDisplay.scaleY;
            cachedData.originalWidth = displayWidth;
            cachedData.originalHeight = displayHeight;
            _displayAdaptCache[targetDisplay] = cachedData;
         }
         var legacyScaleX:Number = getScaleX();
         var legacyScaleY:Number = getScaleY();
         targetDisplay.scaleX = cachedData.originalScaleX * legacyScaleX;
         targetDisplay.scaleY = cachedData.originalScaleY * legacyScaleY;
         targetDisplay.x = cachedData.originalX * legacyScaleX;
         targetDisplay.y = cachedData.originalY * legacyScaleY;
         cachedData.appliedMode = GameConfig.LEGACY_ASSET_SCALE_MODE;
      }
      
      private static function shouldScaleLegacyFullScreenDisplay(sourceWidth:Number, sourceHeight:Number) : Boolean
      {
         if(sourceWidth <= 0 || sourceHeight <= 0)
         {
            return false;
         }
         var widthNearLegacy:Boolean = Math.abs(sourceWidth - GameConfig.LEGACY_RESOLUTION_WIDTH) <= LAYOUT_WIDTH_TOLERANCE;
         var heightNearLegacy:Boolean = Math.abs(sourceHeight - GameConfig.LEGACY_RESOLUTION_HEIGHT) <= LAYOUT_HEIGHT_TOLERANCE;
         if(!heightNearLegacy)
         {
            return false;
         }
         if(widthNearLegacy)
         {
            return true;
         }
         var sourceRatio:Number = sourceWidth / sourceHeight;
         return Math.abs(sourceRatio - LEGACY_RATIO) <= LEGACY_RATIO_TOLERANCE;
      }
      
      private static function looksLikeFullScreenPlacement(targetDisplay:DisplayObject, displayWidth:Number, displayHeight:Number) : Boolean
      {
         var nearTopLeft:Boolean = Math.abs(targetDisplay.x) <= FULLSCREEN_POSITION_TOLERANCE && Math.abs(targetDisplay.y) <= FULLSCREEN_POSITION_TOLERANCE;
         if(nearTopLeft)
         {
            return true;
         }
         var nearCenterAnchor:Boolean = Math.abs(targetDisplay.x + displayWidth * 0.5) <= FULLSCREEN_POSITION_TOLERANCE && Math.abs(targetDisplay.y + displayHeight * 0.5) <= FULLSCREEN_POSITION_TOLERANCE;
         if(nearCenterAnchor)
         {
            return true;
         }
         var nearNegativeAnchor:Boolean = Math.abs(targetDisplay.x + displayWidth) <= FULLSCREEN_POSITION_TOLERANCE && Math.abs(targetDisplay.y + displayHeight) <= FULLSCREEN_POSITION_TOLERANCE;
         return nearNegativeAnchor;
      }
   }
}

class LegacyDisplayScaleData
{
   public var originalX:Number = 0;
   
   public var originalY:Number = 0;
   
   public var originalScaleX:Number = 1;
   
   public var originalScaleY:Number = 1;
   
   public var originalWidth:Number = 0;
   
   public var originalHeight:Number = 0;
   
   public var appliedMode:int = -1;
   
   public function LegacyDisplayScaleData()
   {
      super();
   }
}
