package net.play5d.game.bvn.mob.input
{
   import flash.display.Stage;
   import net.play5d.game.bvn.input.IGameInput;
   
   public class GameJoystickInput implements IGameInput
   {
      public var player:int;
      
      private var _enabled:Boolean = true;
      
      private var _config:JoyStickConfigVO;
      
      public function GameJoystickInput(param1:int)
      {
         super();
         this.player = param1;
      }
      
      public function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         _enabled = param1;
      }
      
      public function getDeviceId() : String
      {
         return _config.deviceId;
      }
      
      public function setDeviceId(param1:String) : void
      {
         _config.deviceId = param1;
      }
      
      public function initlize(param1:Stage) : void
      {
         JoySticker.initlize();
      }
      
      public function setConfig(param1:Object) : void
      {
         this._config = param1 as JoyStickConfigVO;
      }
      
      public function focus() : void
      {
      }
      
      public function anyKey() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDownAnyKey(_config.deviceId);
      }
      
      public function back() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.back) || JoySticker.isDown(_config.deviceId,_config.select);
      }
      
      public function select() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.jump);
      }
      
      public function up() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.up) || JoySticker.isDown(_config.deviceId,_config.up2);
      }
      
      public function down() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.down) || JoySticker.isDown(_config.deviceId,_config.down2);
      }
      
      public function left() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.left) || JoySticker.isDown(_config.deviceId,_config.left2);
      }
      
      public function right() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.right) || JoySticker.isDown(_config.deviceId,_config.right2);
      }
      
      public function attack() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.attack);
      }
      
      public function jump() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.jump);
      }
      
      public function dash() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.dash);
      }
      
      public function skill() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.skill);
      }
      
      public function superSkill() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.superSkill);
      }
      
      public function special() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.special);
      }
      
      public function wankai() : Boolean
      {
         if(!_enabled)
         {
            return false;
         }
         return JoySticker.isDown(_config.deviceId,_config.waikai);
      }
      
      public function clear() : void
      {
      }
   }
}

