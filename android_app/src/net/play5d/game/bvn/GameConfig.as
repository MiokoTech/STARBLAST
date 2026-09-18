package net.play5d.game.bvn
{
   import flash.geom.Point;
   
   public class GameConfig
   {
      public static var TOUCH_MODE:Boolean = false;

      public static var PIXEL_STYLE_MODE:Boolean = true;

      public static const SPRITE_STYLE_LOCALCOORD:int = 0;

      public static const SPRITE_STYLE_ORIGINAL:int = 1;

      public static var SPRITE_STYLE:int = SPRITE_STYLE_LOCALCOORD;

      public static var SHADOW_ENABLED:Boolean = true;

      public static const GAMEPLAY_STYLE_BVN:int = 0;

      public static var GAMEPLAY_STYLE:int = GAMEPLAY_STYLE_BVN;

      public static const CAMERA_STYLE_BVN:int = 0;

      public static const CAMERA_STYLE_STARBLAST:int = 1;

      public static var CAMERA_STYLE:int = CAMERA_STYLE_BVN;

      public static const G:Number = 12;
      
      public static const G_ADD:Number = 1.2;
      
      public static const G_ON_FLOOR:Number = 4;
      
      public static const GAME_SIZE:Point = new Point(1280,720);

      public static const LEGACY_RESOLUTION_WIDTH:Number = 800;

      public static const LEGACY_RESOLUTION_HEIGHT:Number = 600;

      public static const LEGACY_SCALE_MODE_OFF:int = 0;

      public static const LEGACY_SCALE_MODE_AUTO:int = 1;

      public static const LEGACY_SCALE_MODE_FORCE_800X600:int = 2;

      public static var LEGACY_ASSET_SCALE_MODE:int = LEGACY_SCALE_MODE_AUTO;
      
      public static var GAME_SCALE:Point = new Point(1,1);
      
      public static var FPS_GAME:int = 60;
      
      public static const FPS_UI:int = 30;
      
      public static const FPS_ANIMATE:int = 30;
      
      public static var FPS_SHINE_EFFECT:int = 15;
      
      public static var QUALITY_UI:String = "high";
      
      public static var QUALITY_GAME:String = "medium";
      
      public static var SHOW_HOW_TO_PLAY:Boolean = true;
      
      public static var SPEED_PLUS:Number = SPEED_PLUS_DEFAULT;
      
      public static const BULLET_HOLD_FRAME_PLUS:Number = 2;
      
      public static const JUMP_DELAY_FRAME:int = 2;
      
      public static const JUMP_DELAY_FRAME_AIR:int = 1;

      public static var JUMP_DELAY_FRAME_GROUND:int = JUMP_DELAY_FRAME;

      public static var JUMP_DELAY_FRAME_CUSTOM_AIR:int = JUMP_DELAY_FRAME_AIR;
      
      public static const JUMP_DAMPING:Number = 0.5;
      
      public static const HURT_JUMP_FRAME:int = 15;
      
      public static const HURT_GAP_FRAME:int = 4;
      
      public static const BREAK_DEF_GAP_FRAME:int = 4;
      
      public static const BREAK_DEF_DOWN_GAP_FRAME:int = 10;
      
      public static const BREAK_DEF_HOLD_FRAME:int = 42;

      public static var BREAK_DEF_HOLD_FRAME_SCALE:Number = 1;
      
      public static const DEFENSE_GAP_FRAME:int = 4;
      
      public static const DEFENSE_DAMPING_X:Number = 1;
      
      public static const DEFENSE_GAP_FRAME_DOWN:int = 8;
      
      public static const DEFENSE_LOSE_HP_RATE:Number = 0.05;
      
      public static const DEFENSE_HOLD_FRAME_MIN:int = 5;
      
      public static const DEFENSE_HOLD_FRAME_MAX:int = 10;
      
      public static const DEFENSE_HOLD_FRAME_DOWN:int = 10;

      public static var DEFENSE_HOLD_FRAME_SCALE:Number = 1;
      
      public static const HURT_DAMPING_X:Number = 0.1;
      
      public static const HURT_DAMPING_Y:Number = 0.5;
      
      public static const HURT_Y_ADD_INAIR:Number = 3;
      
      public static const HURT_Y_ADD:Number = 6;
      
      public static const STEEL_HURT_GAP_FRAME:int = 4;
      
      public static const STEEL_HURT_DOWN_GAP_FRAME:int = 10;
      
      public static const STEEL_HURT_HP_PERCENT:Number = 0.65;
      
      public static const STEEL_SUPER_HURT_HP_PERCENT:Number = 0.3;
      
      public static const HURT_FLY_DAMPING_X:Number = 0;
      
      public static const HURT_FLY_DAMPING_Y:Number = 0.5;
      
      public static const HIT_FLOOR_DAMPING_X:Number = 2;
      
      public static const HIT_FLOOR_DAMPING_X_HEAVY:Number = 4;
      
      public static const HIT_FLOOR_TAN_Y_MIN:Number = 3;
      
      public static const HIT_FLOOR_TAN_Y_MAX:Number = 8;
      
      public static const HIT_DOWN_FRAME:int = 15;
      
      public static const HIT_DOWN_FRAME_HEAVY:int = 30;
      
      public static const HIT_DOWN_BY_HITY:int = 5;
      
      public static const NO_TOUCH_BAN_ON_VECY:int = 5;
      
      public static var HURT_FRAME_OFFSET:int = 3;

      public static var HURT_HOLD_FRAME_SCALE:Number = 1;

      public static var HITSTOP_RATE_SCALE:Number = 1;

      public static var HITSTOP_TIME_SCALE:Number = 1;

      public static var GRAVITY_ACCEL_SCALE:Number = 1;

      public static var INPUT_BUFFER_SECONDS:Number = 0.1;
      
      public static const X_SIDE_OFFSET:int = 10;
      
      public static const HURT_DOWN_JUMP_FRAME:int = 20;
      
      public static const HURT_DOWN_JUMP_DAMPING:int = 1;
      
      public static const USE_ENERGY_CD:Number = 0.8;
      
      public static const ENERGY_ADD_NORMAL:Number = 2;
      
      public static const ENERGY_ADD_DEFENSE:Number = 0.8;
      
      public static const ENERGY_ADD_ATTACKING:Number = 1.1;
      
      public static const ENERGY_ADD_OVER_LOAD_PERFRAME:Number = 0.6;
      
      public static const ENERGY_ADD_OVER_LOAD_RESUME:Number = 30;
      
      public static const ENERGY_LOSE_DEFENSE_BREAK_RATE:Number = 0.9;
      
      public static const QI_ADD_HIT_BISHA_RATE:Number = 0;
      
      public static const QI_ADD_HIT_RATE:Number = 0.17;
      
      public static const QI_ADD_HIT_BULLET_RATE:Number = 0.1;
      
      public static const QI_ADD_HIT_ATTACKER_RATE:Number = 0.13;
      
      public static const QI_ADD_HIT_ASSISTER_RATE:Number = 0.15;
      
      public static const QI_ADD_HIT_MAX:Number = 15;
      
      public static const QI_ADD_HURT_RATE:Number = 0.08;
      
      public static const QI_ADD_HURT_MAX:Number = 20;

      public static var QI_GAIN_RATE:Number = 1;

      public static var BISHA_ENERGY_MAX:int = 3;

      public static function get BISHA_QI_MAX() : Number
      {
         return BISHA_ENERGY_MAX * 100;
      }
      
      public static const FUZHU_QU_ADD_PERFRAME:Number = 0.2;
      
      public static const CAMERA_TWEEN_SPD:Number = 2.5;
      
      public static const FIGHTER_HP_MAX:int = 1000;
      
      public static var MAP_LOGO_STATE:int = 0;
      
      public static var SHOW_UI_STATUS:int = 0;
      
      public function GameConfig()
      {
         super();
      }
      
      public static function setGameFps(param1:int) : void
      {
         FPS_GAME = param1;
         SPEED_PLUS = SPEED_PLUS_DEFAULT;
      }
      
      public static function get SPEED_PLUS_DEFAULT() : Number
      {
         return 30 / FPS_GAME;
      }

      public static function applyGameplayStyle(param1:int = 0) : void
      {
         GAMEPLAY_STYLE = GAMEPLAY_STYLE_BVN;
         INPUT_BUFFER_SECONDS = 0.1;
         HURT_HOLD_FRAME_SCALE = 1;
         DEFENSE_HOLD_FRAME_SCALE = 1;
         BREAK_DEF_HOLD_FRAME_SCALE = 1;
         HITSTOP_RATE_SCALE = 1;
         HITSTOP_TIME_SCALE = 1;
         GRAVITY_ACCEL_SCALE = 1;
         JUMP_DELAY_FRAME_GROUND = JUMP_DELAY_FRAME;
         JUMP_DELAY_FRAME_CUSTOM_AIR = JUMP_DELAY_FRAME_AIR;
      }

      public static function getInputBufferFrame(param1:Number) : int
      {
         var _loc2_:int = Math.round(INPUT_BUFFER_SECONDS * param1);
         if(_loc2_ < 1)
         {
            _loc2_ = 1;
         }
         return _loc2_;
      }

      public static function getJumpDelayFrame(param1:Boolean = false) : int
      {
         return param1 ? JUMP_DELAY_FRAME_CUSTOM_AIR : JUMP_DELAY_FRAME_GROUND;
      }

      public static function getGravityAddPerFrame() : Number
      {
         return G_ADD * GRAVITY_ACCEL_SCALE * SPEED_PLUS;
      }

      public static function calcHurtHoldFrame(param1:Number) : int
      {
         var _loc2_:int = Math.round(param1 * HURT_HOLD_FRAME_SCALE / 1000 * 30) + HURT_FRAME_OFFSET;
         if(_loc2_ < 4)
         {
            _loc2_ = 4;
         }
         return _loc2_;
      }

      public static function calcDefenseHoldFrame(param1:Number, param2:Boolean = false) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param2)
         {
            _loc3_ = Math.round(DEFENSE_HOLD_FRAME_DOWN * DEFENSE_HOLD_FRAME_SCALE);
            if(_loc3_ < 4)
            {
               _loc3_ = 4;
            }
            return _loc3_;
         }
         _loc3_ = param1 * DEFENSE_HOLD_FRAME_SCALE / 1000 * FPS_GAME / 5;
         _loc4_ = Math.round(DEFENSE_HOLD_FRAME_MIN * DEFENSE_HOLD_FRAME_SCALE);
         _loc5_ = Math.round(DEFENSE_HOLD_FRAME_MAX * DEFENSE_HOLD_FRAME_SCALE);
         if(_loc4_ < 2)
         {
            _loc4_ = 2;
         }
         if(_loc5_ < _loc4_)
         {
            _loc5_ = _loc4_;
         }
         if(_loc3_ < _loc4_)
         {
            _loc3_ = _loc4_;
         }
         if(_loc3_ > _loc5_)
         {
            _loc3_ = _loc5_;
         }
         return _loc3_;
      }

      public static function calcBreakDefenseHoldFrame() : int
      {
         var _loc1_:int = Math.round(BREAK_DEF_HOLD_FRAME * BREAK_DEF_HOLD_FRAME_SCALE);
         if(_loc1_ < 8)
         {
            _loc1_ = 8;
         }
         return _loc1_;
      }
   }
}

