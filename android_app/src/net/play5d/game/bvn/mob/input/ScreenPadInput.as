package net.play5d.game.bvn.mob.input
{
   import flash.display.Stage;
   import net.play5d.game.bvn.input.IGameInput;
   
   public class ScreenPadInput implements IGameInput
   {
      private var isDownObj:Object = {};
      
      private var _enabled:Boolean = true;
      
      public function ScreenPadInput()
      {
         super();
      }
      
      public function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         _enabled = param1;
         if(!param1)
         {
            isDownObj = {};
         }
      }
      
      public function initlize(param1:Stage) : void
      {
      }
      
      public function setConfig(param1:Object) : void
      {
      }
      
      public function focus() : void
      {
      }
      
      public function setDown(param1:String, param2:Boolean) : void
      {
         isDownObj[param1] = param2;
      }
      
      public function anyKey() : Boolean
      {
         return Boolean(isDownObj["select"]) || Boolean(isDownObj["back"]);
      }
      
      public function back() : Boolean
      {
         return isDownObj["back"];
      }
      
      public function select() : Boolean
      {
         return isDownObj["select"];
      }
      
      public function up() : Boolean
      {
         return isDownObj["up"];
      }
      
      public function down() : Boolean
      {
         return isDownObj["down"];
      }
      
      public function left() : Boolean
      {
         return isDownObj["left"];
      }
      
      public function right() : Boolean
      {
         return isDownObj["right"];
      }
      
      public function attack() : Boolean
      {
         return isDownObj["attack"];
      }
      
      public function jump() : Boolean
      {
         return isDownObj["jump"];
      }
      
      public function dash() : Boolean
      {
         return isDownObj["dash"];
      }
      
      public function skill() : Boolean
      {
         return isDownObj["skill"];
      }
      
      public function superSkill() : Boolean
      {
         return isDownObj["superSkill"];
      }
      
      public function special() : Boolean
      {
         return isDownObj["special"];
      }
      
      public function wankai() : Boolean
      {
         return isDownObj["wankai"];
      }
      
      public function clear() : void
      {
         isDownObj = {};
      }
   }
}

