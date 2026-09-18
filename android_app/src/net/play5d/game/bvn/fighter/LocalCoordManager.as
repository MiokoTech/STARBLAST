package net.play5d.game.bvn.fighter
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.GameConfig;
   
   public class LocalCoordManager
   {
      public static const DEFAULT_LOCALCOORD_WIDTH:Number = 640;
      
      public static const DEFAULT_LOCALCOORD_HEIGHT:Number = 360;
      
      public static const DEFAULT_SCALE:Number = 2.0;
      
      public static const SPRITE_STYLE_LOCALCOORD:int = GameConfig.SPRITE_STYLE_LOCALCOORD;
      
      public static const SPRITE_STYLE_ORIGINAL:int = GameConfig.SPRITE_STYLE_ORIGINAL;
      
      public static var spriteStyle:int = SPRITE_STYLE_LOCALCOORD;
      
      private static var _coordRegistry:Dictionary = initCoordRegistry();
      
      private static function initCoordRegistry() : Dictionary
      {
         var dict:Dictionary = new Dictionary();
         dict["meirin"] = new Point(320, 240);
         dict["flandre"] = new Point(320, 240);
         dict["ibuki"] = new Point(320, 240);
         dict["kenshin"] = new Point(320, 240);
         return dict;
      }
      
      public function LocalCoordManager()
      {
         super();
      }
      
      public static function register(fighterId:String, width:Number, height:Number) : void
      {
         if(!fighterId || width <= 0 || height <= 0)
         {
            return;
         }
         _coordRegistry[fighterId] = new Point(width, height);
      }
      
      public static function parseCoord(coordStr:String) : Point
      {
         if(!coordStr)
         {
            return null;
         }
         var parts:Array = coordStr.split(",");
         if(parts.length < 2)
         {
            parts = coordStr.split("x");
         }
         if(parts.length >= 2)
         {
            var w:Number = parseFloat(parts[0]);
            var h:Number = parseFloat(parts[1]);
            if(!isNaN(w) && !isNaN(h) && w > 0 && h > 0)
            {
               return new Point(w, h);
            }
         }
         return null;
      }
      
      public static function getLocalCoord(fighterId:String = null) : Point
      {
         if(fighterId && _coordRegistry[fighterId])
         {
            return (_coordRegistry[fighterId] as Point).clone();
         }
         return new Point(DEFAULT_LOCALCOORD_WIDTH, DEFAULT_LOCALCOORD_HEIGHT);
      }
      
      public static var currentStageCoord:Point = null;
      
      public static var isCurrentStageCustom:Boolean = false;
      
      public static function setStageContext(isCustom:Boolean, coordX:Number = 640, coordY:Number = 360) : void
      {
         isCurrentStageCustom = isCustom;
         if(isCustom && coordX > 0 && coordY > 0)
         {
            currentStageCoord = new Point(coordX, coordY);
         }
         else
         {
            currentStageCoord = null;
         }
      }

      public static function isLocalCoordMode() : Boolean
      {
         return spriteStyle == SPRITE_STYLE_LOCALCOORD;
      }
      
      public static function getScale(fighterId:String = null, customW:Number = NaN, customH:Number = NaN) : Number
      {
         if(spriteStyle == SPRITE_STYLE_ORIGINAL)
         {
            return 1.0;
         }
         if(!isNaN(customH) && customH > 0)
         {
            return GameConfig.GAME_SIZE.y / customH;
         }
         if(!isNaN(customW) && customW > 0)
         {
            return GameConfig.GAME_SIZE.x / customW;
         }
         if(isCurrentStageCustom && currentStageCoord)
         {
            if(fighterId && _coordRegistry[fighterId])
            {
               var regPt:Point = _coordRegistry[fighterId] as Point;
               if(regPt && regPt.x > 0 && regPt.y > 0)
               {
                  return (GameConfig.GAME_SIZE.y * currentStageCoord.x) / (currentStageCoord.y * regPt.x);
               }
            }
            return DEFAULT_SCALE;
         }
         if(fighterId && _coordRegistry[fighterId])
         {
            var pt:Point = _coordRegistry[fighterId] as Point;
            if(pt && pt.y > 0)
            {
               return GameConfig.GAME_SIZE.y / pt.y;
            }
         }
         return DEFAULT_SCALE;
      }
      
      public static function getScaleForStage(fighterId:String = null, isStageCustom:Boolean = false, stageCoordX:Number = 0, stageCoordY:Number = 0) : Number
      {
         if(isStageCustom)
         {
            var scX:Number = stageCoordX > 0 ? stageCoordX : (currentStageCoord ? currentStageCoord.x : 640);
            var scY:Number = stageCoordY > 0 ? stageCoordY : (currentStageCoord ? currentStageCoord.y : 360);
            if(fighterId && _coordRegistry[fighterId])
            {
               var pt:Point = _coordRegistry[fighterId] as Point;
               if(pt && pt.x > 0 && pt.y > 0)
               {
                  return (GameConfig.GAME_SIZE.y * scX) / (scY * pt.x);
               }
            }
            return DEFAULT_SCALE;
         }
         return getScale(fighterId);
      }
      
      public static function scaleHitRect(rect:Rectangle, scale:Number) : Rectangle
      {
         if(!rect)
         {
            return null;
         }
         return new Rectangle(rect.x * scale, rect.y * scale, rect.width * scale, rect.height * scale);
      }
      
      public static function scaleOffset(point:Point, scale:Number) : Point
      {
         if(!point)
         {
            return null;
         }
         return new Point(point.x * scale, point.y * scale);
      }
   }
}
