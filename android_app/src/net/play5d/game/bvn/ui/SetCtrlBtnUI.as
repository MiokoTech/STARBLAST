package net.play5d.game.bvn.ui
{
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.KeyConfigVO;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.interfaces.IInnerSetUI;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.input.KyoKeyCode;
   
   public class SetCtrlBtnUI extends EventDispatcher implements IInnerSetUI
   {
      public var ui:MovieClip;
      
      private var _keyMappings:Array;
      
      private var _keyMap:Object;
      
      private var _keyConfig:KeyConfigVO;
      
      private var _btnGroup:SetBtnGroup;
      
      private var _dialog:SetBtnDialog;
      
      private var _tmpKeyConfig:KeyConfigVO;
      
      private var _setKeyIndex:int;
      
      public function SetCtrlBtnUI()
      {
         super();
         this.ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.setting,"keyset_mc");
         this._btnGroup = new SetBtnGroup();
         this._btnGroup.startY = 30;
         this._btnGroup.initKeySet();
         this._btnGroup.addEventListener("SELECT",this.onBtnSelect);
         this.ui.addChild(this._btnGroup);
         this._dialog = new SetBtnDialog();
         this.ui.addChild(this._dialog.ui);
         this.initKeyMapping();
      }
      
      public function destory() : void
      {
         if(this._btnGroup)
         {
            try
            {
               this.ui.removeChild(this._btnGroup);
            }
            catch(e:Error)
            {
            }
            this._btnGroup.removeEventListener("SELECT",this.onBtnSelect);
            this._btnGroup.destory();
            this._btnGroup = null;
         }
      }
      
      public function getUI() : DisplayObject
      {
         return this.ui;
      }
      
      public function setKey(param1:KeyConfigVO) : void
      {
         this._keyConfig = param1;
         this._tmpKeyConfig = param1.clone();
         this.updateKeyMapping();
      }
      
      private function updateKeyMapping() : void
      {
         this._keyMap["up"].setKey(this._tmpKeyConfig.up);
         this._keyMap["down"].setKey(this._tmpKeyConfig.down);
         this._keyMap["left"].setKey(this._tmpKeyConfig.left);
         this._keyMap["right"].setKey(this._tmpKeyConfig.right);
         this._keyMap["attack"].setKey(this._tmpKeyConfig.attack);
         this._keyMap["jump"].setKey(this._tmpKeyConfig.jump);
         this._keyMap["dash"].setKey(this._tmpKeyConfig.dash);
         this._keyMap["skill"].setKey(this._tmpKeyConfig.skill);
         this._keyMap["superKill"].setKey(this._tmpKeyConfig.superKill);
         this._keyMap["beckons"].setKey(this._tmpKeyConfig.beckons);
      }
      
      private function initKeyMapping() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Sprite = null;
         var _loc3_:Object = null;
         var _loc4_:KeyMapping = null;
         var _loc5_:MovieClip = this.ui.keysmc;
         var _loc6_:Array = [{
            "id":"up",
            "name":"UP",
            "cn":"上"
         },{
            "id":"down",
            "name":"DOWN",
            "cn":"下"
         },{
            "id":"left",
            "name":"LEFT",
            "cn":"左"
         },{
            "id":"right",
            "name":"RIGHT",
            "cn":"右"
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
            "id":"superKill",
            "name":"SUPER SKILL",
            "cn":"大招"
         },{
            "id":"beckons",
            "name":"SPECIAL",
            "cn":"特殊"
         }];
         this._keyMappings = [];
         this._keyMap = {};
         while(_loc1_ < _loc6_.length)
         {
            _loc2_ = _loc5_.getChildByName("k" + _loc1_) as Sprite;
            _loc3_ = _loc6_[_loc1_];
            if(!_loc2_)
            {
               trace("mc[k" + _loc1_ + "]不存在！");
            }
            else
            {
               _loc4_ = new KeyMapping(_loc2_,_loc3_.id,_loc3_.name,_loc3_.cn);
               this._keyMappings.push(_loc4_);
               this._keyMap[_loc4_.keyId] = _loc4_;
            }
            _loc1_++;
         }
      }
      
      private function onBtnSelect(param1:SetBtnEvent) : void
      {
         switch(param1.selectedLabel)
         {
            case "SET ALL":
               MainGame.I.stage.addEventListener("keyDown",this.onKeyDown);
               MainGame.I.stage.focus = MainGame.I.stage;
               this._setKeyIndex = -1;
               this._btnGroup.keyEnable = false;
               this.setNextKey();
               break;
            case "SET DEFAULT":
               GameData.I.config.setDefaultConfig(this._tmpKeyConfig);
               this.updateKeyMapping();
               break;
            case "APPLY":
               this._keyConfig.readSaveObj(this._tmpKeyConfig.toSaveObj());
               dispatchEvent(new SetBtnEvent("APPLY_SET"));
               break;
            case "CANCEL":
               dispatchEvent(new SetBtnEvent("CANCEL_SET"));
         }
      }
      
      private function setNextKey() : void
      {
         ++this._setKeyIndex;
         var _loc1_:KeyMapping = this._keyMappings[this._setKeyIndex];
         if(_loc1_)
         {
            this._dialog.show(_loc1_.name,_loc1_.cn);
         }
         else
         {
            MainGame.I.stage.removeEventListener("keyDown",this.onKeyDown);
            this._btnGroup.keyEnable = true;
         }
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         if(!this._dialog.isShow)
         {
            return;
         }
         var _loc2_:KeyMapping = this._keyMappings[this._setKeyIndex];
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:String = _loc2_.keyId;
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:String = KyoKeyCode.code2name(param1.keyCode);
         if(!_loc4_)
         {
            return;
         }
         this._tmpKeyConfig[_loc3_] = param1.keyCode;
         _loc2_.setKey(param1.keyCode,_loc4_);
         this._dialog.hide();
         this.setNextKey();
      }
      
      public function fadIn() : void
      {
         var duration:Number = 0.3;
         this.ui.y = GameConfig.GAME_SIZE.y;
         TweenLite.to(this.ui,duration,{
            "y":0,
            "onComplete":function():void
            {
               _btnGroup.keyEnable = true;
            }
         });
         this._btnGroup.setArrowIndex(0);
         this.ui.visible = true;
      }
      
      public function fadOut() : void
      {
         var duration:Number = 0.3;
         this._btnGroup.keyEnable = false;
         TweenLite.to(this.ui,duration,{
            "y":GameConfig.GAME_SIZE.y,
            "onComplete":function():void
            {
               ui.visible = false;
            }
         });
      }
   }
}

