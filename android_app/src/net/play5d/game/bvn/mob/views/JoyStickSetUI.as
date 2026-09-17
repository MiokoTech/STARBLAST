package net.play5d.game.bvn.mob.views
{
   import com.greensock.TweenLite;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.ui.GameInputDevice;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.interfaces.IInnerSetUI;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   import net.play5d.game.bvn.mob.input.JoyStickConfigVO;
   import net.play5d.game.bvn.mob.input.JoyStickSetVO;
   import net.play5d.game.bvn.mob.input.JoySticker;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.SetBtnDialog;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   import net.play5d.game.bvn.utils.URL;
   
   public class JoyStickSetUI extends EventDispatcher implements IInnerSetUI
   {
      [Embed(source='/../assets/setting_joy.png')]
      private var _joybitmap:Class;
      
      private var _btnGroup:SetBtnGroup;
      
      private var _player:int;
      
      private var _ui:Sprite;
      
      private var _bp:Bitmap;
      
      private var _joyConfig:JoyStickConfigVO;
      
      private var _tmpJoyConfig:JoyStickConfigVO;
      
      private var _deviceId:String;
      
      private var _setIndex:int;
      
      private var _mappings:Array;
      
      private var _dialog:SetBtnDialog;
      
      private var _startSet:Boolean;
      
      public function JoyStickSetUI()
      {
         super();
         _ui = new Sprite();
         _bp = new _joybitmap();
         _bp.x = 170;
         _bp.y = 250;
         _ui.addChild(_bp);
         _tmpJoyConfig = new JoyStickConfigVO();
         initKeyMapping();
      }
      
      private function subString(param1:String, param2:int) : String
      {
         if(!param1)
         {
            return null;
         }
         if(param1.length < param2)
         {
            return param1;
         }
         return param1.substr(0,param2) + "...";
      }
      
      private function initBtns() : void
      {
         var _loc3_:int = 0;
         var _loc1_:GameInputDevice = null;
         var _loc4_:Vector.<GameInputDevice> = JoySticker.getAllDeivces();
         var _loc2_:Array = [{
            "label":"NONE",
            "cn":"不使用",
            "value":null
         }];
         while(_loc3_ < _loc4_.length)
         {
            _loc1_ = _loc4_[_loc3_];
            _loc2_.push({
               "label":subString(_loc1_.name,15),
               "cn":subString(_loc1_.name,45),
               "value":_loc1_.id
            });
            _loc3_++;
         }
         _btnGroup = new SetBtnGroup();
         _btnGroup.startY = 30;
         _btnGroup.setBtnData([{
            "label":"USE JOY",
            "cn":"绑定手柄",
            "options":_loc2_,
            "optoinKey":"deviceId",
            "optionValue":_tmpJoyConfig.deviceId
         },{
            "label":"SET ALL",
            "cn":"设置全部"
         },{
            "label":"SET DEFAULT",
            "cn":"还原默认按键"
         },{
            "label":"BUY JOY",
            "cn":"购买推荐手柄"
         },{
            "label":"APPLY",
            "cn":"应用"
         },{
            "label":"CANCEL",
            "cn":"取消"
         }]);
         _btnGroup.addEventListener("SELECT",onBtnSelect);
         _btnGroup.addEventListener("OPTION_CHANGE",onOptoinChange);
         _ui.addChild(_btnGroup);
      }
      
      public function setConfig(param1:int, param2:JoyStickConfigVO) : void
      {
         _player = param1;
         _joyConfig = param2;
         _tmpJoyConfig.readObj(param2.toObj());
         _deviceId = _tmpJoyConfig.deviceId;
         initBtns();
      }
      
      private function onBtnSelect(param1:SetBtnEvent) : void
      {
         switch(param1.selectedLabel)
         {
            case "SET ALL":
               if(!JoySticker.isActive(_tmpJoyConfig.deviceId))
               {
                  GameUI.alert("NO JOYSTICK CONNECT","未检测到可用的手柄");
                  return;
               }
               _setIndex = -1;
               _btnGroup.keyEnable = false;
               _startSet = false;
               GameRender.add(renderSet);
               setNextKey();
               break;
            case "SET DEFAULT":
               _tmpJoyConfig = new JoyStickConfigVO();
               _tmpJoyConfig.deviceId = _deviceId;
               GameUI.alert("SET JOYSTICK DEFAULT SUCCESS","已设置为默认按键");
               break;
            case "BUY JOY":
               URL.buyJoystick();
               break;
            case "APPLY":
               _joyConfig.readObj(_tmpJoyConfig.toObj());
               if(_player == 1)
               {
                  GameInterfaceManager.config.updateJoyConfig();
               }
               dispatchEvent(new SetBtnEvent("APPLY_SET"));
               break;
            case "CANCEL":
               dispatchEvent(new SetBtnEvent("CANCEL_SET"));
         }
      }
      
      private function onOptoinChange(param1:SetBtnEvent) : void
      {
         if(param1.optionKey == "deviceId")
         {
            _tmpJoyConfig.deviceId = param1.optionValue;
            _tmpJoyConfig.deviceIsSet = true;
            _deviceId = param1.optionValue;
         }
      }
      
      private function renderSet() : void
      {
         var _loc1_:Object = null;
         if(!_startSet)
         {
            if(JoySticker.isDownAnyKey(_tmpJoyConfig.deviceId) == false)
            {
               _startSet = true;
            }
            return;
         }
         var _loc2_:JoyStickSetVO = JoySticker.getDownKey(_tmpJoyConfig.deviceId,true);
         if(_loc2_)
         {
            _loc1_ = _mappings[_setIndex];
            if(_loc1_)
            {
               _tmpJoyConfig[_loc1_.id] = _loc2_;
            }
            setNextKey();
         }
      }
      
      private function initKeyMapping() : void
      {
         _mappings = [{
            "id":"up2",
            "name":"UP roker",
            "cn":"上(摇杆)"
         },{
            "id":"down2",
            "name":"DOWN roker",
            "cn":"下(摇杆)"
         },{
            "id":"left2",
            "name":"LEFT roker",
            "cn":"左(摇杆)"
         },{
            "id":"right2",
            "name":"RIGHT roker",
            "cn":"右(摇杆)"
         },{
            "id":"up",
            "name":"UP button",
            "cn":"上(按钮)"
         },{
            "id":"down",
            "name":"DOWN button",
            "cn":"下(按钮)"
         },{
            "id":"left",
            "name":"LEFT button",
            "cn":"左(按钮)"
         },{
            "id":"right",
            "name":"RIGHT button",
            "cn":"右(按钮)"
         },{
            "id":"attack",
            "name":"ATTACK",
            "cn":"攻击"
         },{
            "id":"jump",
            "name":"JUMP",
            "cn":"跳跃"
         },{
            "id":"dash",
            "name":"DASH",
            "cn":"冲刺"
         },{
            "id":"skill",
            "name":"SKILL",
            "cn":"技能"
         },{
            "id":"superSkill",
            "name":"SUPER SKILL",
            "cn":"大招"
         },{
            "id":"special",
            "name":"SPECIAL",
            "cn":"特殊"
         },{
            "id":"waikai",
            "name":"BANN KAI",
            "cn":"卍解"
         },{
            "id":"back",
            "name":"BACK",
            "cn":"返回键"
         },{
            "id":"select",
            "name":"SELECT",
            "cn":"确认键（菜单）"
         }];
      }
      
      private function setNextKey() : void
      {
         _setIndex++;
         var _loc1_:Object = _mappings[_setIndex];
         if(_loc1_)
         {
            if(!_dialog)
            {
               _dialog = new SetBtnDialog();
               _ui.addChild(_dialog.ui);
            }
            _dialog.show(_loc1_.name,_loc1_.cn);
         }
         else
         {
            _dialog.hide();
            _btnGroup.keyEnable = true;
            GameRender.remove(renderSet);
         }
      }
      
      public function fadIn() : void
      {
         _bp.y = 600;
         TweenLite.to(_bp,0.3,{"y":240});
      }
      
      public function fadOut() : void
      {
         TweenLite.to(_ui,0.3,{"y":600});
      }
      
      public function getUI() : DisplayObject
      {
         return _ui;
      }
      
      public function destory() : void
      {
         GameRender.remove(renderSet);
         if(_btnGroup)
         {
            try
            {
               _ui.removeChild(_btnGroup);
            }
            catch(e:Error)
            {
            }
            _btnGroup.destory();
            _btnGroup = null;
         }
      }
   }
}

