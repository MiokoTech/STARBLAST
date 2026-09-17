package net.play5d.game.bvn.mob.input
{
   import flash.display.Stage;
   import net.play5d.game.bvn.input.IGameInput;
   import net.play5d.game.bvn.mob.data.SocketInputData;
   
   public class GameSocketInput implements IGameInput
   {
      private var _data:SocketInputData;
      
      private var _enabled:Boolean = false;
      
      private var _inputers:Vector.<IGameInput>;
      
      private var _inputData:int = 0;
      
      private var _upK:int;
      
      private var _downK:int;
      
      private var _leftK:int;
      
      private var _rightK:int;
      
      private var _attackK:int;
      
      private var _jumpK:int;
      
      private var _dashK:int;
      
      private var _skillK:int;
      
      private var _bishaK:int;
      
      private var _specialK:int;
      
      public function GameSocketInput()
      {
         super();
         initK();
      }
      
      private function initK() : void
      {
         _upK = parseInt("1000000000",2);
         _downK = parseInt("0100000000",2);
         _leftK = parseInt("0010000000",2);
         _rightK = parseInt("0001000000",2);
         _attackK = parseInt("0000100000",2);
         _jumpK = parseInt("0000010000",2);
         _dashK = parseInt("0000001000",2);
         _skillK = parseInt("0000000100",2);
         _bishaK = parseInt("0000000010",2);
         _specialK = parseInt("0000000001",2);
      }
      
      public function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         _enabled = param1;
         if(param1)
         {
            _data = new SocketInputData();
         }
         else
         {
            _data = null;
         }
      }
      
      public function setInputers(param1:Array) : void
      {
         _inputers = new Vector.<IGameInput>();
         for each(var i:IGameInput in param1)
         {
            _inputers.push(i);
         }
      }
      
      public function renderInput() : void
      {
         var _loc2_:int = 0;
         var _loc1_:IGameInput = null;
         if(!_inputers || _inputers.length < 1)
         {
            return;
         }
         var _loc3_:int = int(_inputers.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            _loc1_ = _inputers[_loc2_];
            _loc1_.up() && (_inputData = _inputData | _upK);
            _loc1_.down() && (_inputData = _inputData | _downK);
            _loc1_.left() && (_inputData = _inputData | _leftK);
            _loc1_.right() && (_inputData = _inputData | _rightK);
            _loc1_.attack() && (_inputData = _inputData | _attackK);
            _loc1_.jump() && (_inputData = _inputData | _jumpK);
            _loc1_.dash() && (_inputData = _inputData | _dashK);
            _loc1_.skill() && (_inputData = _inputData | _skillK);
            _loc1_.superSkill() && (_inputData = _inputData | _bishaK);
            _loc1_.special() && (_inputData = _inputData | _specialK);
            _loc2_++;
         }
      }
      
      public function freeRender() : void
      {
         var _loc2_:int = 0;
         var _loc1_:IGameInput = null;
         if(!_inputers || _inputers.length < 1)
         {
            return;
         }
         if(!_data)
         {
            return;
         }
         _data.clear();
         var _loc3_:int = int(_inputers.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            _loc1_ = _inputers[_loc2_];
            _data.up ||= _loc1_.up();
            _data.down ||= _loc1_.down();
            _data.left ||= _loc1_.left();
            _data.right ||= _loc1_.right();
            _data.attack ||= _loc1_.attack();
            _data.jump ||= _loc1_.jump();
            _data.dash ||= _loc1_.dash();
            _data.skill ||= _loc1_.skill();
            _data.superSkill ||= _loc1_.superSkill();
            _data.special ||= _loc1_.special();
            _data.select ||= _loc1_.select();
            _data.back ||= _loc1_.back();
            _loc2_++;
         }
      }
      
      public function resetInput() : void
      {
         _inputData = 0;
         renderInput();
      }
      
      public function setSocketData(param1:int) : void
      {
         if(!_data)
         {
            trace("GameSocketInput.data is null!");
            return;
         }
         var _loc2_:String = param1.toString(2);
         var _loc3_:int = _loc2_.length;
         _data.special = _loc2_.charAt(_loc3_ - 1) == "1";
         _data.superSkill = _loc2_.charAt(_loc3_ - 2) == "1";
         _data.skill = _loc2_.charAt(_loc3_ - 3) == "1";
         _data.dash = _loc2_.charAt(_loc3_ - 4) == "1";
         _data.jump = _loc2_.charAt(_loc3_ - 5) == "1";
         _data.attack = _loc2_.charAt(_loc3_ - 6) == "1";
         _data.right = _loc2_.charAt(_loc3_ - 7) == "1";
         _data.left = _loc2_.charAt(_loc3_ - 8) == "1";
         _data.down = _loc2_.charAt(_loc3_ - 9) == "1";
         _data.up = _loc2_.charAt(_loc3_ - 10) == "1";
      }
      
      public function getSocketData() : int
      {
         return _inputData;
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
      
      public function anyKey() : Boolean
      {
         return false;
      }
      
      public function back() : Boolean
      {
         return false;
      }
      
      public function select() : Boolean
      {
         return _data && (_data.attack || _data.select);
      }
      
      public function up() : Boolean
      {
         return _data && _data.up;
      }
      
      public function down() : Boolean
      {
         return _data && _data.down;
      }
      
      public function left() : Boolean
      {
         return _data && _data.left;
      }
      
      public function right() : Boolean
      {
         return _data && _data.right;
      }
      
      public function attack() : Boolean
      {
         return _data && _data.attack;
      }
      
      public function jump() : Boolean
      {
         return _data && _data.jump;
      }
      
      public function dash() : Boolean
      {
         return _data && _data.dash;
      }
      
      public function skill() : Boolean
      {
         return _data && _data.skill;
      }
      
      public function superSkill() : Boolean
      {
         return _data && _data.superSkill;
      }
      
      public function special() : Boolean
      {
         return _data && _data.special;
      }
      
      public function wankai() : Boolean
      {
         return _data && _data.attack && _data.jump;
      }
      
      public function clear() : void
      {
         _data && _data.clear();
         resetInput();
      }
   }
}

