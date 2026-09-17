package net.play5d.game.bvn.input
{
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import net.play5d.game.bvn.data.KeyConfigVO;
   import net.play5d.game.bvn.utils.KeyBoarder;
   
   public class GameKeyInput implements IGameInput
   {
      private var _config:KeyConfigVO;
      
      private var _downKeys:Object = {};
      
      private var _enabled:Boolean = true;
      
      public function GameKeyInput()
      {
         super();
      }
      
      public function initlize(param1:Stage) : void
      {
         KeyBoarder.initlize(param1);
         KeyBoarder.listen(keyBoardHandler);
      }
      
      public function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         _enabled = param1;
      }
      
      public function setConfig(param1:Object) : void
      {
         _config = param1 as KeyConfigVO;
      }
      
      public function focus() : void
      {
         KeyBoarder.focus();
      }
      
      public function anyKey() : Boolean
      {
         for(var i:String in _downKeys)
         {
            if(_downKeys[i] == 1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function back() : Boolean
      {
         return isDown(27);
      }
      
      public function select() : Boolean
      {
         for each(var i:int in _config.selects)
         {
            if(isDown(i))
            {
               return true;
            }
         }
         return false;
      }
      
      public function up() : Boolean
      {
         return isDown(_config.up);
      }
      
      public function down() : Boolean
      {
         return isDown(_config.down);
      }
      
      public function left() : Boolean
      {
         return isDown(_config.left);
      }
      
      public function right() : Boolean
      {
         return isDown(_config.right);
      }
      
      public function attack() : Boolean
      {
         return isDown(_config.attack);
      }
      
      public function jump() : Boolean
      {
         return isDown(_config.jump);
      }
      
      public function dash() : Boolean
      {
         return isDown(_config.dash);
      }
      
      public function skill() : Boolean
      {
         return isDown(_config.skill);
      }
      
      public function superSkill() : Boolean
      {
         return isDown(_config.superKill);
      }
      
      public function special() : Boolean
      {
         return isDown(_config.beckons);
      }
      
      public function wankai() : Boolean
      {
         return isDown(_config.attack) && isDown(_config.jump);
      }
      
      public function clear() : void
      {
         _downKeys = {};
      }
      
      private function keyBoardHandler(param1:KeyboardEvent) : void
      {
         switch(param1.type)
         {
            case "keyDown":
               _downKeys[param1.keyCode] = 1;
               break;
            case "keyUp":
               _downKeys[param1.keyCode] = 0;
         }
      }
      
      private function isDown(param1:uint) : Boolean
      {
         return _downKeys[param1] == 1;
      }
   }
}

