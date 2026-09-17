package net.play5d.game.bvn.input
{
   import flash.display.Stage;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.interfaces.GameInterface;
   
   public class GameInputer
   {
      private static var _listenKeys:Object;
      
      private static const JUST_DOWN_DELAY:Number = 0.1;
      
      public static var enabled:Boolean = true;
      
      private static var _inputMap:Dictionary = new Dictionary();
      
      private static var _justDownKeys:Object = {};
      
      private static var _justDownDelayKeys:Object = {};
      
      public function GameInputer()
      {
         super();
      }
      
      public static function initlize(param1:Stage) : void
      {
         initInput();
         callVoid("initlize",param1);
         GameRender.add(render);
      }
      
      public static function initInput() : void
      {
         var _loc3_:Vector.<IGameInput> = GameInterface.instance.getGameInput("MENU");
         if(!_loc3_)
         {
            _loc3_ = new Vector.<IGameInput>([new GameKeyInput()]);
         }
         var _loc1_:Vector.<IGameInput> = GameInterface.instance.getGameInput("P1");
         if(_loc1_ == null)
         {
            _loc1_ = new Vector.<IGameInput>([new GameKeyInput()]);
         }
         var _loc2_:Vector.<IGameInput> = GameInterface.instance.getGameInput("P2");
         if(_loc2_ == null)
         {
            _loc2_ = new Vector.<IGameInput>([new GameKeyInput()]);
         }
         setInput("MENU",_loc3_);
         GameInputer.setInput("P1",_loc1_);
         GameInputer.setInput("P2",_loc2_);
      }
      
      public static function setInput(param1:String, param2:Vector.<IGameInput>) : void
      {
         _inputMap[param1] = param2;
      }
      
      public static function updateConfig() : void
      {
         if(GameInterface.instance.updateInputConfig())
         {
            return;
         }
         setConfig("MENU",GameData.I.config.key_menu);
         setConfig("P1",GameData.I.config.key_p1);
         setConfig("P2",GameData.I.config.key_p2);
      }
      
      private static function setConfig(param1:String, param2:Object) : void
      {
         call(param1,"setConfig",param2);
      }
      
      public static function focus() : void
      {
         callVoid("focus");
      }
      
      public static function listenKeys(param1:String, param2:Array, param3:int) : void
      {
         if(param3 != 1 && param3 != 2)
         {
            return;
         }
         if(!_listenKeys)
         {
            _listenKeys = {};
         }
         var _loc4_:String = param1 + "_" + param3;
         _listenKeys[_loc4_] = {
            "type":param1,
            "ids":param2,
            "justDown":param3
         };
      }
      
      public static function unListenKeys(param1:String, param2:int) : void
      {
         var _loc3_:String = param1 + "_" + param2;
         delete _listenKeys[_loc3_];
      }
      
      private static function renderListenKeys() : void
      {
         var _loc3_:int = 0;
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(!_listenKeys)
         {
            return;
         }
         for each(var _loc4_:Object in _listenKeys)
         {
            _loc1_ = _loc4_.ids;
            _loc3_ = int(_loc1_.length);
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               isDown(_loc4_.type,_loc1_[_loc2_],_loc4_.justDown,true);
               _loc2_++;
            }
         }
      }
      
      private static function isListenedKey(param1:String, param2:String, param3:int) : Boolean
      {
         if(!_listenKeys)
         {
            return false;
         }
         var _loc4_:String = param1 + "_" + param3;
         var _loc5_:Object = _listenKeys[_loc4_];
         if(!_loc5_ || !_loc5_.ids)
         {
            return false;
         }
         var _loc6_:Array = _loc5_.ids;
         return _loc6_.indexOf(param2) != -1;
      }
      
      public static function render() : void
      {
         var _loc3_:* = null;
         var _loc2_:Boolean = false;
         var _loc1_:String = null;
         for(_loc1_ in _justDownDelayKeys)
         {
            if(_justDownDelayKeys[_loc1_] > 0)
            {
               _justDownDelayKeys[_loc1_]--;
            }
            else
            {
               delete _justDownDelayKeys[_loc1_];
            }
         }
         renderListenKeys();
      }
      
      public static function anyKey(param1:int = 0) : Boolean
      {
         return isDown("MENU","anyKey",param1);
      }
      
      public static function back(param1:int = 0) : Boolean
      {
         return isDown("MENU","back",param1);
      }
      
      public static function select(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"select",param2);
      }
      
      public static function up(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"up",param2);
      }
      
      public static function down(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"down",param2);
      }
      
      public static function left(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"left",param2);
      }
      
      public static function right(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"right",param2);
      }
      
      public static function attack(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"attack",param2);
      }
      
      public static function jump(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"jump",param2);
      }
      
      public static function dash(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"dash",param2);
      }
      
      public static function skill(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"skill",param2);
      }
      
      public static function superSkill(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"superSkill",param2);
      }
      
      public static function special(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"special",param2);
      }
      
      public static function wankai(param1:String, param2:int = 0) : Boolean
      {
         return isDown(param1,"wankai",param2);
      }
      
      public static function clearInput() : void
      {
         _justDownKeys = {};
         _justDownDelayKeys = {};
         callVoid("clear");
      }
      
      private static function isDown(param1:String, param2:String, param3:int = 0, param4:Boolean = false) : Boolean
      {
         var _loc5_:Boolean = param4 ? false : isListenedKey(param1,param2,param3);
         if(param3 == 1)
         {
            return isJustDown(param1,param2);
         }
         if(param3 == 2)
         {
            return isJustDownDelay(param1,param2,_loc5_);
         }
         return call(param1,param2);
      }
      
      private static function isJustDown(param1:String, param2:String) : Boolean
      {
         var _loc3_:String = param1 + "_" + param2;
         var _loc4_:Boolean = call(param1,param2);
         if(!_loc4_)
         {
            _justDownKeys[_loc3_] = false;
            return false;
         }
         if(_justDownKeys[_loc3_])
         {
            return false;
         }
         _justDownKeys[_loc3_] = true;
         return true;
      }
      
      private static function isJustDownDelay(param1:String, param2:String, param3:Boolean) : Boolean
      {
         var _loc4_:Boolean = isJustDown(param1,param2);
         var _loc5_:String = param1 + "_" + param2;
         if(_loc4_)
         {
            _justDownDelayKeys[_loc5_] = GameConfig.getInputBufferFrame(MainGame.I.getFPS());
         }
         return Boolean(_justDownDelayKeys[_loc5_]) && _justDownDelayKeys[_loc5_] > 0;
      }
      
      private static function call(type:String, funcName:String, ... params) : Boolean
      {
         if (!enabled)
         {
            return false;
         }
         if (!_inputMap[type])
         {
            return false;
         }
         var inputs:Vector.<IGameInput> = _inputMap[type];
         for (var i:int; i < inputs.length; i++)
         {
            if (!inputs[i].enabled)
            {
                continue;
            }
            var func:Function = inputs[i][funcName];
            if (func != null) {
                if (func.apply(null, params))
                {
                    return true;
                }
            }
        }
        return false;
      }
      
      private static function callVoid(funcName:String, ... params) : void
      {
         var p:Vector.<IGameInput>;
         var i:int;
         for each(p in _inputMap)
         {
            for (i = 0; i < p.length; i++)
            {
                if (!p[i].enabled)
                {
                    continue;
                }
                var func:Function = p[i][funcName];
                if (func != null)
                {
                    func.apply(null, params);
                }
            }
         }
      }
   }
}

