package net.play5d.game.bvn.state
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import com.greensock.easing.Quad;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.ctrl.GameLoader;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.ctrl.StateCtrl;
   import net.play5d.game.bvn.data.AssisterModel;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.MessionModel;
   import net.play5d.game.bvn.data.SelectCharListConfigVO;
   import net.play5d.game.bvn.data.SelectCharListItemVO;
   import net.play5d.game.bvn.data.SelectStageConfigVO;
   import net.play5d.game.bvn.data.SelectVO;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.input.GameInputType;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.select.GameSettingUI;
   import net.play5d.game.bvn.ui.select.MapSelectUI;
   import net.play5d.game.bvn.ui.select.SelectFighterItem;
   import net.play5d.game.bvn.ui.select.SelectUIFactory;
   import net.play5d.game.bvn.ui.select.SelectedFighterGroup;
   import net.play5d.game.bvn.ui.select.SelecterItemUI;
   import net.play5d.game.bvn.utils.KeyBoarder;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.stage.Istage;
   import net.play5d.kyo.utils.ArrayMap;
   import net.play5d.kyo.utils.KyoRandom;

   public class SelectFighterStage implements Istage
   {
      public static var AUTO_FINISH:Boolean = true;
      private static const SELECT_STATE_FIGHTER:int = 0;
      private static const SELECT_STATE_ASSIST:int = 1;
      private static const SELECT_STATE_MAP:int = 2;
      private var _selectState:int;
      private var _fighterListUI:Sprite;
      private var _config:SelectStageConfigVO;
      private var _curListConfig:SelectCharListConfigVO;
      private var _itemObj:Object;
      private var _p1Slt:SelecterItemUI;
      private var _p2Slt:SelecterItemUI;
      private var _p1SelectedGroup:SelectedFighterGroup;
      private var _p2SelectedGroup:SelectedFighterGroup;
      private var _mapSelectUI:MapSelectUI;
      private var _gameSettings:GameSettingUI;
      private var _ui:MovieClip;
      private var _curStep:int = 0;
      private var _tweenTime:int = 500;
      private var _twoPlayerSelectFin:Boolean;

      private var _backMenuBtn:Sprite;
      private var _moreFighterMap:Dictionary = new Dictionary();
      private var _moreFighterCache:Object = {};
      private var _p1IdleContainer:Sprite;
      private var _p2IdleContainer:Sprite;
      private var _p1IdleFighter:FighterMain;
      private var _p2IdleFighter:FighterMain;
      private var _p1IdleLoader:Loader;
      private var _p2IdleLoader:Loader;
      private var _curP1FighterId:String;
      private var _curP2FighterId:String;

      public function SelectFighterStage()
      {
         super();
      }

      public function get display() : DisplayObject
      {
         return _ui;
      }

      public function build() : void
      {
         _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.select,"stg_select") as MovieClip;
         _fighterListUI = new Sprite();
         _ui.addChild(_fighterListUI);

         _p1IdleContainer = new Sprite();
         _p1IdleContainer.mouseEnabled = false;
         _p1IdleContainer.mouseChildren = false;
         _p1IdleContainer.x = 302;
         _p1IdleContainer.y = 660;

         _p2IdleContainer = new Sprite();
         _p2IdleContainer.mouseEnabled = false;
         _p2IdleContainer.mouseChildren = false;
         _p2IdleContainer.x = 978;
         _p2IdleContainer.y = 660;

         var anim124:DisplayObject = _ui.getChildByName("anim124_mc");
         var anim103:DisplayObject = _ui.getChildByName("anim103_mc");

         if(anim124 is MovieClip)
         {
            var anim124Mc:MovieClip = anim124 as MovieClip;
            if(anim124Mc.totalFrames > 1)
            {
               anim124Mc.addFrameScript(anim124Mc.totalFrames - 1, anim124Mc.stop);
            }
         }

         if (anim124 && anim103)
         {
            var baseIdx:int = Math.min(_ui.getChildIndex(anim124), _ui.getChildIndex(anim103));
            _ui.setChildIndex(anim124, baseIdx);
            _ui.addChildAt(_p1IdleContainer, baseIdx + 1);
            _ui.addChildAt(_p2IdleContainer, baseIdx + 2);
            _ui.setChildIndex(anim103, baseIdx + 3);
         }
         else if (anim103)
         {
            var idx103:int = _ui.getChildIndex(anim103);
            _ui.addChildAt(_p1IdleContainer, idx103);
            _ui.addChildAt(_p2IdleContainer, idx103 + 1);
         }
         else
         {
            _ui.addChild(_p1IdleContainer);
            _ui.addChild(_p2IdleContainer);
         }
         _config = GameData.I.config.select_config;
         GameRender.add(render);
         GameInputer.focus();
         GameInputer.enabled = false;
         nextStep();
         SoundCtrl.I.BGM(AssetManager.I.getSound("select"));
         StateCtrl.I.clearTrans();
         KeyBoarder.focus();
         GameEvent.dispatchEvent(GameEvent.SELECT_FIGHTER);
      }

      private function backMenuHandler(e:Event = null):void
      {
         if(_mapSelectUI && _mapSelectUI.enabled)
         {
            cancelMapSelect();
            return;
         }
         if(_p2Slt && _p2Slt.enabled)
         {
            cancelP2Select();
            return;
         }
         if(_p1Slt && _p1Slt.enabled && (_p1Slt.selectTimes > 0 || _curStep == 3))
         {
            cancelP1Select();
            return;
         }
         GameUI.confrim('BACK TITLE?', '返回到主菜单？', MainGame.I.goMenu);
         GameEvent.dispatchEvent(GameEvent.CONFRIM_BACK_MENU);
      }

      private function initPageBtn() : void
      {
         var _loc3_:SimpleButton = _ui.getChildByName("bu1") as SimpleButton;
         var _loc1_:SimpleButton = _ui.getChildByName("bu2") as SimpleButton;
         if(GameConfig.TOUCH_MODE)
         {
            if(_loc3_)
            {
               _loc3_.addEventListener("touchTap",pageLeftHandler);
               _loc3_.visible = true;
            }
            if(_loc1_)
            {
               _loc1_.addEventListener("touchTap",pageRightHandler);
               _loc1_.visible = true;
            }
         }
         else
         {
            if(_loc3_)
            {
               _loc3_.addEventListener("click",pageLeftHandler);
               _loc3_.visible = true;
            }
            if(_loc1_)
            {
               _loc1_.addEventListener("click",pageRightHandler);
               _loc1_.visible = true;
            }
         }
      }

      private function removePageBtn() : void
      {
         var _loc3_:SimpleButton = _ui.getChildByName("bu1") as SimpleButton;
         var _loc1_:SimpleButton = _ui.getChildByName("bu2") as SimpleButton;
         if(_loc3_)
         {
            _loc3_.removeEventListener("touchTap",pageLeftHandler);
            _loc3_.removeEventListener("click",pageLeftHandler);
            _loc3_.visible = false;
         }
         if(_loc1_)
         {
            _loc1_.removeEventListener("touchTap",pageRightHandler);
            _loc1_.removeEventListener("click",pageRightHandler);
            _loc1_.visible = false;
         }
      }

      private function pageLeftHandler(param1:Event) : void
      {
         if(_fighterListUI.width <= GameConfig.GAME_SIZE.x)
         {
            return;
         }
         var _loc3_:* = _fighterListUI.x + 1280;
         var _loc2_:Number = 0;
         if(_loc3_ > _loc2_)
         {
            _loc3_ = _loc2_;
         }
         TweenLite.to(_fighterListUI,0.2,{"x":_loc3_});
      }

      private function pageRightHandler(param1:Event) : void
      {
         var _loc3_:* = _fighterListUI.x - 1280;
         TweenLite.to(_fighterListUI,0.2,{"x":_loc3_});
      }

      private function initFighter() : void
      {
         clear();
         _selectState = SELECT_STATE_FIGHTER;
         buildList(_config.charList);
         GameData.I.p1Select = new SelectVO();
         if(GameMode.isVsPeople() || GameMode.isVsCPU())
         {
            GameData.I.p2Select = new SelectVO();
         }
         GameInputer.enabled = false;
         setTimeout(initSelecter, _tweenTime);
      }

      private function clearGridOnly() : void
      {
         if(_itemObj)
         {
            for each(var item:SelectFighterItem in _itemObj)
            {
               item.destory();
            }
            _itemObj = null;
         }
         while(_fighterListUI.numChildren > 0)
         {
            _fighterListUI.removeChildAt(0);
         }
      }

      private function initAssist() : void
      {
         TweenLite.to(_fighterListUI,0.2,{"x":0});
         clearGridOnly();
         _selectState = SELECT_STATE_ASSIST;
         buildList(_config.assistList);
         if(_p1Slt && _p1Slt.group)
         {
            _p1Slt.group.showAssistSlot();
         }
         if(_p2Slt && _p2Slt.group)
         {
            _p2Slt.group.showAssistSlot();
         }
         GameInputer.enabled = false;
         setTimeout(initSelecter, _tweenTime);
      }

      private function fadOutList(param1:Function = null) : void
      {
         var _loc2_:Number = NaN;
         var _loc6_:int = 0;
         var _loc4_:SelectFighterItem = null;
         GameInputer.enabled = false;
         var _loc7_:Number = GameConfig.GAME_SIZE.x / 2 - 30;
         var _loc8_:Number = GameConfig.GAME_SIZE.y / 2 - 30;
         for each(var i:SelectFighterItem in _itemObj)
         {
            _loc2_ = Math.random() * 0.1;
            TweenLite.to(i.ui,0.2,{
               "x":_loc7_,
               "y":_loc8_,
               "scaleX":0,
               "scaleY":0,
               "delay":_loc2_
            });
         }
         for each(var f:ArrayMap in _moreFighterMap)
         {
            if(f)
            {
               _loc6_ = 0;
               while(_loc6_ < f.length)
               {
                  _loc4_ = f.getItemByIndex(_loc6_);
                  _loc4_.destory();
                  _loc6_++;
               }
               _moreFighterMap[f] = null;
            }
         }
         if(param1 != null)
         {
            TweenLite.delayedCall(0.3,param1);
         }
      }

      private function clearSelectionGrid() : void
      {
         if(_itemObj)
         {
            for each(var item:SelectFighterItem in _itemObj)
            {
               item.destory();
            }
            _itemObj = null;
         }
         if(_fighterListUI)
         {
            _fighterListUI.visible = false;
         }
         if(_p1Slt)
         {
            _p1Slt.enabled = false;
            _p1Slt.removeSelecter();
         }
         if(_p2Slt)
         {
            _p2Slt.enabled = false;
            _p2Slt.removeSelecter();
         }
         if(_mapSelectUI)
         {
            _mapSelectUI.destory();
            _mapSelectUI = null;
         }
      }

      private function clear() : void
      {
         if(_itemObj)
         {
            for each(var i:SelectFighterItem in _itemObj)
            {
               i.destory();
            }
            _itemObj = null;
         }
         if(_p1Slt)
         {
            if(_p1Slt.group && _p1Slt.group.nameGroup && _p1Slt.group.nameGroup.parent)
            {
               try { _p1Slt.group.nameGroup.parent.removeChild(_p1Slt.group.nameGroup); } catch(e:Error) {}
            }
            if(_p1Slt.group && _p1Slt.group.slotGroup && _p1Slt.group.slotGroup.parent)
            {
               try { _p1Slt.group.slotGroup.parent.removeChild(_p1Slt.group.slotGroup); } catch(e:Error) {}
            }
            _p1Slt.destory();
            _p1Slt = null;
         }
         if(_p2Slt)
         {
            if(_p2Slt.group && _p2Slt.group.nameGroup && _p2Slt.group.nameGroup.parent)
            {
               try { _p2Slt.group.nameGroup.parent.removeChild(_p2Slt.group.nameGroup); } catch(e:Error) {}
            }
            if(_p2Slt.group && _p2Slt.group.slotGroup && _p2Slt.group.slotGroup.parent)
            {
               try { _p2Slt.group.slotGroup.parent.removeChild(_p2Slt.group.slotGroup); } catch(e:Error) {}
            }
            _p2Slt.destory();
            _p2Slt = null;
         }
         if(_mapSelectUI)
         {
            _mapSelectUI.destory();
            _mapSelectUI = null;
         }
         if(_p1SelectedGroup)
         {
            _p1SelectedGroup.destory();
            _p1SelectedGroup = null;
         }
         if(_p2SelectedGroup)
         {
            _p2SelectedGroup.destory();
            _p2SelectedGroup = null;
         }
         clearIdleFighter(1);
         clearIdleFighter(2);
      }

      private function buildList(param1:SelectCharListConfigVO) : void
      {
         var _loc4_:int = 0;
         var _loc9_:SelectCharListItemVO = null;
         var _loc10_:SelectFighterItem = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc11_:Number = NaN;
         _fighterListUI.y = 0;
         var _loc14_:Number = _config.x + _config.left;
         var _loc13_:Number = _config.y + _config.top;
         var _loc5_:Number = param1.HCount > 1 ? (_config.width - _config.unitSize.x - _config.left - _config.right) / (param1.HCount - 1) : 0;
         var _loc7_:Number = param1.VCount > 1 ? (_config.height - _config.unitSize.y - _config.top - _config.bottom) / (param1.VCount - 1) : 0;
         var _loc12_:Array = param1.list;
         _curListConfig = param1;
         _itemObj = {};
         var _loc8_:Number = GameConfig.GAME_SIZE.x / 2 - 30;
         var _loc6_:Number = GameConfig.GAME_SIZE.y / 2 - 30;
         while(_loc4_ < _loc12_.length)
         {
            _loc9_ = _loc12_[_loc4_];
            _loc10_ = addFighterItem(_loc9_);
            if(_loc10_)
            {
               _loc2_ = _loc14_ + _loc5_ * _loc10_.selectData.x;
               _loc3_ = _loc13_ + _loc7_ * _loc10_.selectData.y;
               if(_loc10_.selectData.offset)
               {
                  _loc2_ += _loc10_.selectData.offset.x;
                  _loc3_ += _loc10_.selectData.offset.y;
               }
               _loc10_.ui.scaleX = 0;
               _loc10_.ui.scaleY = 0;
               _loc10_.ui.x = _loc8_;
               _loc10_.ui.y = _loc6_;
               _loc11_ = Math.random() * (_tweenTime - 300) / 1000;
               TweenLite.to(_loc10_.ui,0.3,{
                  "x":_loc2_,
                  "y":_loc3_,
                  "delay":_loc11_,
                  "scaleX":1,
                  "scaleY":1,
                  "ease":Back.easeOut
               });
            }
            _loc4_++;
         }
      }
      
      private function addFighterItem(param1:SelectCharListItemVO) : SelectFighterItem
      {
         if(!param1.fighterID)
         {
            return null;
         }
         var _loc2_:FighterVO = _selectState == 1 ? AssisterModel.I.getAssister(param1.fighterID) : FighterModel.I.getFighter(param1.fighterID);
         if(!_loc2_)
         {
            Debugger.log("SelectFighterStage.addFighterItem :: 未找到角色数据：" + param1.fighterID);
            return null;
         }
         var _loc3_:Number = 60;
         var _loc5_:Number = 60;
         var _loc4_:SelectFighterItem = new SelectFighterItem(_loc2_,param1);
         _fighterListUI.addChild(_loc4_.ui);
         _itemObj[param1.x + "," + param1.y] = _loc4_;
         return _loc4_;
      }
      
      private function selectFighterMouseHandler(param1:String, param2:SelectFighterItem) : void
      {
         if(!param2 || !param2.selectData && !param2.isMore)
         {
            return;
         }
         switch(param1)
         {
            case "mouseOver":
               doHover(param2);
               break;
            case "click":
               doSelect(param2);
         }
      }
      
      private function selectFighterTouchHandler(param1:String, param2:SelectFighterItem) : void
      {
         if(!param2 || !param2.selectData && !param2.isMore)
         {
            return;
         }
         var activeSlt:SelecterItemUI = null;
         if(_curStep == 2)
         {
            if(_p2Slt && _p2Slt.enabled)
            {
               activeSlt = _p2Slt;
            }
         }
         else
         {
            if(_p1Slt && _p1Slt.enabled)
            {
               activeSlt = _p1Slt;
            }
            else if(_p2Slt && _p2Slt.enabled)
            {
               activeSlt = _p2Slt;
            }
         }
         if(!activeSlt)
         {
            return;
         }
         if(activeSlt.touchHoverItem == param2)
         {
            doSelect(param2);
            activeSlt.touchHoverItem = null;
         }
         else
         {
            activeSlt.touchHoverItem = param2;
            doHover(param2);
         }
      }
      
      private function doHover(param1:SelectFighterItem) : void
      {
         if(_p1Slt && _p1Slt.enabled)
         {
            if(_p1Slt.moreEnabled() && param1.isMore)
            {
               moveToSelectFighterMore(_p1Slt,param1);
               SoundCtrl.I.sndSelect();
               return;
            }
            if(checkSelected(_p1Slt,param1))
            {
               return;
            }
            moveToSelectFighter(_p1Slt,param1);
            SoundCtrl.I.sndSelect();
            return;
         }
         if(_p2Slt && _p2Slt.enabled)
         {
            if(_p2Slt.moreEnabled() && param1.isMore)
            {
               moveToSelectFighterMore(_p2Slt,param1);
               SoundCtrl.I.sndSelect();
               return;
            }
            if(checkSelected(_p2Slt,param1))
            {
               return;
            }
            moveToSelectFighter(_p2Slt,param1);
            SoundCtrl.I.sndSelect();
            return;
         }
      }
      
      private function checkSelected(param1:SelecterItemUI, param2:SelectFighterItem) : Boolean
      {
         var _loc3_:int = 0;
         if(!param2.selectData && !param2.fighterData)
         {
            return false;
         }
         if(!param2.selectData && param2.fighterData)
         {
            return param1.isSelected(param2.fighterData.id);
         }
         if(param2.selectData.moreFighterIDs)
         {
            while(_loc3_ < param2.selectData.moreFighterIDs.length)
            {
               if(param1.isSelected(param2.selectData.moreFighterIDs[_loc3_]))
               {
                  return true;
               }
               _loc3_++;
            }
         }
         return param1.isSelected(param2.selectData.fighterID);
      }
      
      private function doSelect(param1:SelectFighterItem) : void
      {
         if(_p1Slt && _p1Slt.enabled)
         {
            if(checkSelected(_p1Slt,param1))
            {
               return;
            }
            _p1Slt.select(playerSeltBack);
            SoundCtrl.I.sndConfrim();
            return;
         }
         if(_p2Slt && _p2Slt.enabled)
         {
            if(checkSelected(_p2Slt,param1))
            {
               return;
            }
            _p2Slt.select(playerSeltBack);
            SoundCtrl.I.sndConfrim();
            return;
         }
      }
      
      private function getFighterItem(param1:int, param2:int) : SelectFighterItem
      {
         if(!_itemObj)
         {
            return null;
         }
         return _itemObj[param1 + "," + param2];
      }

      private function getFighterItemById(fighterId:String) : SelectFighterItem
      {
         if(!_itemObj || !fighterId)
         {
            return null;
         }
         for each(var item:SelectFighterItem in _itemObj)
         {
            if(item && item.fighterData && item.fighterData.id == fighterId)
            {
               return item;
            }
         }
         return null;
      }

      private function initSelecter() : void
      {
         GameInputer.enabled = true;
         if(GameMode.isVsPeople())
         {
            initSelecterP1();
            initSelecterP2();
            _twoPlayerSelectFin = false;
         }
         else
         {
            initSelecterP1();
         }
      }
      
      private function initSelecterP1() : void
      {
         if(_selectState == 1 && _p1Slt)
         {
            _p1Slt.isSelectAssist = true;
            _p1Slt.selectTimesCount = 1;
            _p1Slt.selectTimes = 0;
            _fighterListUI.addChild(_p1Slt.ui);
            _p1Slt.enabled = true;
            if(_p1Slt.group)
            {
               _p1Slt.group.showAssistSlot();
            }
            moveSlt(_p1Slt,0,0);
            return;
         }

         _p1Slt = SelectUIFactory.createSelecter(1);
         _p1Slt.isSelectAssist = _selectState == 1;
         if (GameMode.currentMode == GameMode.WATCH || GameMode.currentMode == GameMode.VS_CPU || GameMode.isVsPeople())
         {
            _p1Slt.selectTimesCount = !_p1Slt.isSelectAssist ? Math.max(1, GameData.I.config.player1) : 1;
         }
         else
         {
            _p1Slt.selectTimesCount = GameMode.isTeamMode() && !_p1Slt.isSelectAssist ? 3 : 1;
         }
         if (_p1Slt.group)
         {
            _p1Slt.group.initSlots(_p1Slt.selectTimesCount);
         }

         _fighterListUI.addChild(_p1Slt.ui);
         var anim124P1:DisplayObject = _ui.getChildByName("anim124_mc");
         var idx124P1:int = anim124P1 ? _ui.getChildIndex(anim124P1) : 0;
         if (_p1Slt.group)
         {
            _ui.addChildAt(_p1Slt.group, idx124P1);
            if (_p1Slt.group.nameGroup)
            {
               _ui.addChild(_p1Slt.group.nameGroup);
            }
            if (_p1Slt.group.slotGroup)
            {
               _ui.addChild(_p1Slt.group.slotGroup);
            }
         }
         moveSlt(_p1Slt,0,0);
      }

      private function initSelecterP2() : void
      {
         if(_selectState == 1 && _p2Slt)
         {
            _p2Slt.isSelectAssist = true;
            _p2Slt.selectTimesCount = 1;
            _p2Slt.selectTimes = 0;
            _fighterListUI.addChild(_p2Slt.ui);
            _p2Slt.enabled = true;
            if(_p2Slt.group)
            {
               _p2Slt.group.showAssistSlot();
            }
            moveSlt(_p2Slt,9,0);
            return;
         }

         _p2Slt = SelectUIFactory.createSelecter(2);
         _p2Slt.isSelectAssist = _selectState == 1;
         if (GameMode.currentMode == GameMode.WATCH || GameMode.currentMode == GameMode.VS_CPU || GameMode.isVsPeople())
         {
            _p2Slt.selectTimesCount = !_p2Slt.isSelectAssist ? Math.max(1, GameData.I.config.player2) : 1;
         }
         else
         {
            _p2Slt.selectTimesCount = GameMode.isTeamMode() && !_p2Slt.isSelectAssist ? 3 : 1;
         }
         if (_p2Slt.group)
         {
            _p2Slt.group.initSlots(_p2Slt.selectTimesCount);
         }

         _fighterListUI.addChild(_p2Slt.ui);
         var anim124P2:DisplayObject = _ui.getChildByName("anim124_mc");
         var idx124P2:int = anim124P2 ? _ui.getChildIndex(anim124P2) : 0;
         if (_p2Slt.group)
         {
            _ui.addChildAt(_p2Slt.group, idx124P2);
            if (_p2Slt.group.nameGroup)
            {
               _ui.addChild(_p2Slt.group.nameGroup);
            }
            if (_p2Slt.group.slotGroup)
            {
               _ui.addChild(_p2Slt.group.slotGroup);
            }
         }
         moveSlt(_p2Slt,9,0);
      }

      private function moveSlt(param1:SelecterItemUI, param2:int, param3:int, param4:Boolean = true) : Boolean
      {
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc9_:int = 0;
         var _loc8_:* = 0;
         var _loc6_:Boolean = false;
         var _loc5_:SelectFighterItem = getFighterItem(param2,param3);
         if(!_loc5_ || _loc5_ && checkSelected(param1,_loc5_))
         {
            if(!param4)
            {
               return true;
            }
            if(param2 > param1.x)
            {
               _loc10_ = true;
               _loc8_ = 0;
               while(_loc8_ < _curListConfig.HCount)
               {
                  _loc9_ = param2 + _loc8_;
                  if(_loc9_ > _curListConfig.HCount - 1)
                  {
                     _loc9_ -= _curListConfig.HCount;
                  }
                  _loc5_ = getFighterItem(_loc9_,param1.y);
                  if(_loc5_ && !checkSelected(param1,_loc5_))
                  {
                     break;
                  }
                  _loc8_++;
               }
            }
            if(param2 < param1.x)
            {
               _loc7_ = true;
               _loc8_ = 0;
               while(_loc8_ < _curListConfig.HCount)
               {
                  _loc9_ = param2 - _loc8_;
                  if(_loc9_ < 0)
                  {
                     _loc9_ = _curListConfig.HCount + _loc9_;
                  }
                  _loc5_ = getFighterItem(_loc9_,param1.y);
                  if(_loc5_ && !checkSelected(param1,_loc5_))
                  {
                     break;
                  }
                  _loc8_++;
               }
            }
            if(param3 > param1.y)
            {
               _loc12_ = true;
               if(param3 > _curListConfig.VCount - 1)
               {
                  param3 = 0;
               }
               _loc8_ = param3;
               while(_loc8_ < _curListConfig.VCount)
               {
                  _loc5_ = getHLineFighter(param1.x,_loc8_);
                  if(_loc5_)
                  {
                     break;
                  }
                  _loc8_++;
               }
            }
            if(param3 < param1.y)
            {
               _loc11_ = true;
               if(param3 < 0)
               {
                  param3 = _curListConfig.VCount - 1;
               }
               _loc8_ = param3;
               while(_loc8_ >= 0)
               {
                  _loc5_ = getHLineFighter(param1.x,_loc8_);
                  if(_loc5_)
                  {
                     break;
                  }
                  _loc8_--;
               }
            }
         }
         if(!_loc5_)
         {
            return false;
         }
         param1.x = _loc5_.selectData.x;
         param1.y = _loc5_.selectData.y;
         if(checkSelected(param1,_loc5_))
         {
            if(_loc11_ || _loc12_)
            {
               _loc6_ = moveSlt(param1,param1.x + 1,param1.y);
               if(!_loc6_)
               {
                  if(_loc11_)
                  {
                     moveSlt(param1,param1.x,param1.y - 1);
                  }
                  if(_loc12_)
                  {
                     moveSlt(param1,param1.x,param1.y + 1);
                  }
               }
            }
            return true;
         }
         moveToSelectFighter(param1,_loc5_);
         return true;
      }
      
      private function isHoverFighter(param1:SelecterItemUI, param2:SelectFighterItem) : Boolean
      {
         if(!param2.selectData)
         {
            return false;
         }
         return param1.x == param2.selectData.x && param1.y == param2.selectData.y;
      }
      
      private function moveToSelectFighter(param1:SelecterItemUI, param2:SelectFighterItem) : void
      {
         if(!param2 || !param2.selectData)
         {
            return;
         }
         param1.randoms = null;
         param1.x = param2.selectData.x;
         param1.y = param2.selectData.y;
         param1.moveTo(param2.ui.x,param2.ui.y);
         param1.currentFighter = param2.fighterData;
         if(param1.group)
         {
            if(param1.isSelectAssist)
            {
               param1.group.setAssist(param1.currentFighter);
            }
            else
            {
               param1.group.updateFighter(param1.currentFighter);
            }
         }
         checkRandom(param1);
         showMoreFighters(param1,param2);
         var playerIdx:int = (param1 == _p2Slt || (param1 && param1.playerType == 2)) ? 2 : 1;
         if(!param1.isSelectAssist)
         {
            if(param1.randoms)
            {
               clearIdleFighter(playerIdx);
            }
            else
            {
               updateIdleSprite(playerIdx, param1.currentFighter);
            }
         }
      }
      
      private function moveToSelectFighterMore(param1:SelecterItemUI, param2:SelectFighterItem) : void
      {
         param1.randoms = null;
         param1.moreX = param2.position.x;
         param1.moreY = param2.position.y;
         param1.moveTo(param2.ui.x,param2.ui.y);
         param1.currentFighter = param2.fighterData;
         if(param1.group)
         {
            if(param1.isSelectAssist)
            {
               param1.group.setAssist(param1.currentFighter);
            }
            else
            {
               param1.group.updateFighter(param1.currentFighter);
            }
         }
         var playerIdxMore:int = (param1 == _p2Slt || (param1 && param1.playerType == 2)) ? 2 : 1;
         if(!param1.isSelectAssist)
         {
            updateIdleSprite(playerIdxMore, param1.currentFighter);
         }
      }
      
      private function showMoreFighters(param1:SelecterItemUI, param2:SelectFighterItem) : void
      {
         var _loc8_:ArrayMap = null;
         var _loc14_:SelectFighterItem = null;
         var _loc6_:int = 0;
         var _loc3_:String = null;
         var _loc10_:FighterVO = null;
         var _loc5_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc11_:Point = null;
         var _loc4_:int = 0;
         var _loc18_:Point = null;
         var _loc7_:int = 0;
         var _loc13_:Point = null;
         var _loc17_:Number = NaN;
         var _loc16_:Number = NaN;
         if(param1.showingMoreSelecter == param2)
         {
            return;
         }
         _loc8_ = _moreFighterMap[param1];
         if(_loc8_)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc8_.length)
            {
               _loc14_ = _loc8_.getItemByIndex(_loc6_);
               _loc14_.hideMore();
               _loc6_++;
            }
            _moreFighterMap[param1] = null;
         }
         param1.setMoreEnabled(false);
         if(!param2.selectData.moreFighterIDs || param2.selectData.moreFighterIDs.length < 1)
         {
            return;
         }
         _loc8_ = _moreFighterCache[param2.fighterData.id];
         if(_loc8_ && _loc8_.length > 0)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc8_.length)
            {
               _loc14_ = _loc8_.getItemByIndex(_loc6_);
               _fighterListUI.addChild(_loc14_.ui);
               _loc14_.showMore(_loc6_ * 0.01);
               _loc6_++;
            }
            _moreFighterMap[param1] = _loc8_;
            param1.setMoreEnabled(true,param2);
            return;
         }
         var _loc15_:Array = param2.selectData.moreFighterIDs;
         _loc8_ = new ArrayMap();
         var _loc19_:Array = [new Point(0,-1),new Point(0,1),new Point(-1,0),new Point(1,0),new Point(-1,-1),new Point(1,-1),new Point(-1,1),new Point(1,1)];
         var _loc12_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc15_.length)
         {
            _loc3_ = String(_loc15_[_loc6_]);
            trace(_loc3_);
            _loc10_ = _selectState == 1 ? AssisterModel.I.getAssister(_loc3_) : FighterModel.I.getFighter(_loc3_);
            if(!_loc10_)
            {
               Debugger.log("SelectFighterStage.addFighterItem :: 未找到角色数据：" + _loc3_);
            }
            else
            {
               _loc5_ = 60;
               _loc9_ = 49;
               _loc11_ = null;
               _loc4_ = 0;
               _loc18_ = null;
               while(_loc11_ == null)
               {
                  _loc7_ = _loc12_ % 8;
                  _loc12_++;
                  _loc13_ = _loc19_[_loc7_];
                  if(!_loc13_)
                  {
                     Debugger.log("pos未定义" + _loc7_ + " / " + _loc12_);
                  }
                  else
                  {
                     _loc17_ = param2.ui.x + _loc13_.x * (_loc5_ + 2);
                     _loc16_ = param2.ui.y + _loc13_.y * (_loc9_ + 2);
                     if(_loc17_ < 0 || _loc17_ > GameConfig.GAME_SIZE.x)
                     {
                        Debugger.log("pos.x 越界 (" + _loc17_ + ")  " + _loc7_ + " / " + _loc12_);
                     }
                     else if(_loc16_ < 0 || _loc16_ > GameConfig.GAME_SIZE.y)
                     {
                        Debugger.log("pos.y 越界 (" + _loc16_ + ")  " + _loc7_ + " / " + _loc12_);
                     }
                     else
                     {
                        _loc18_ = _loc13_.clone();
                        _loc11_ = new Point(_loc17_,_loc16_);
                     }
                  }
               }
               _loc14_ = new SelectFighterItem(_loc10_,null,true);
               trace(_loc12_,_loc11_,_loc14_.fighterData.id);
               if(GameConfig.TOUCH_MODE)
               {
                  _loc14_.addEventListener("touchTap",selectFighterTouchHandler);
               }
               else
               {
                  _loc14_.addEventListener("mouseOver",selectFighterMouseHandler);
                  _loc14_.addEventListener("click",selectFighterMouseHandler);
               }
               _loc14_.position = _loc18_;
               _loc14_.initMoreTween(new Point(param2.ui.x,param2.ui.y),_loc11_);
               _fighterListUI.addChild(_loc14_.ui);
               _loc4_++;
               _loc14_.showMore(_loc4_ * 0.01);
               _loc8_.push(_loc14_.positionId,_loc14_);
               _moreFighterMap[param1] = _loc8_;
               _moreFighterCache[param2.fighterData.id] = _loc8_;
            }
            _loc6_++;
         }
         param1.setMoreEnabled(true,param2);
      }
      
      private function moveMoreSlt(param1:SelecterItemUI, param2:int, param3:int) : Boolean
      {
         var _loc6_:ArrayMap = _moreFighterMap[param1];
         if(!_loc6_ || _loc6_.length < 1)
         {
            return false;
         }
         if(param2 == 0 && param3 == 0 && param1.showingMoreSelecter)
         {
            param1.moreX = 0;
            param1.moreY = 0;
            param1.moveTo(param1.showingMoreSelecter.ui.x,param1.showingMoreSelecter.ui.y);
            param1.currentFighter = param1.showingMoreSelecter.fighterData;
            if(param1.group)
            {
               param1.group.updateFighter(param1.currentFighter);
            }
            return true;
         }
         var _loc4_:String = SelectFighterItem.getIdByPoint(param2,param3);
         var _loc5_:SelectFighterItem = _loc6_.getItemById(_loc4_);
         if(!_loc5_)
         {
            return false;
         }
         if(param1.isSelected(_loc5_.fighterData.id))
         {
            return false;
         }
         param1.randoms = null;
         param1.moreX = _loc5_.position.x;
         param1.moreY = _loc5_.position.y;
         param1.moveTo(_loc5_.ui.x,_loc5_.ui.y);
         param1.currentFighter = _loc5_.fighterData;
         if(param1.group)
         {
            param1.group.updateFighter(param1.currentFighter);
         }
         return true;
      }
      
      private function checkRandom(param1:SelecterItemUI) : Boolean
      {
         var slt:SelecterItemUI = param1;
         if(slt.currentFighter.id.indexOf("random") != -1)
         {
            switch(_selectState)
            {
               case 0:
                  slt.randoms = FighterModel.I.getFighters(slt.currentFighter.comicType,function(param1:FighterVO):Boolean
                  {
                     return param1.id.indexOf("random") == -1 && GameLogic.canSelectFighter(param1.id) && !slt.selectVO.isSelected(param1.id);
                  });
                  break;
               case 1:
                  slt.randoms = AssisterModel.I.getAssisters(slt.currentFighter.comicType,function(param1:FighterVO):Boolean
                  {
                     return param1.id.indexOf("random") == -1 && GameLogic.canSelectAssist(param1.id);
                  });
                  break;
               default:
                  return false;
            }
            slt.randFrame = 0;
            renderRandom(slt);
            return true;
         }
         return false;
      }
      
      private function getHLineFighter(param1:int, param2:int) : SelectFighterItem
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:SelectFighterItem = null;
         while(true)
         {
            _loc4_ = param1 + _loc5_;
            if(_loc4_ >= 0 && _loc4_ < _curListConfig.HCount)
            {
               _loc3_ = getFighterItem(_loc4_,param2);
               if(_loc3_)
               {
                  break;
               }
            }
            if(_loc5_ == 0)
            {
               _loc5_ = 1;
            }
            else if(_loc5_ > 0)
            {
               _loc5_ *= -1;
            }
            else
            {
               if(_loc5_ < -_curListConfig.HCount)
               {
                  return null;
               }
               _loc5_ *= -1;
               _loc5_++;
            }
         }
         return _loc3_;
      }
      
      private function renderRandom(param1:SelecterItemUI) : void
      {
         if(param1.randoms)
         {
            if(param1.randFrame > 0)
            {
               param1.randFrame = 0;
               return;
            }
            ++param1.randFrame;
            param1.currentFighter = KyoRandom.getRandomInArray(param1.randoms,false);
            if(param1.group)
            {
               param1.group.updateFighter(param1.currentFighter);
            }
         }
      }
      
      private function moveSelecter(param1:SelecterItemUI, param2:int, param3:int) : void
      {
         if(param1.moreEnabled())
         {
            if(moveMoreSlt(param1,param1.moreX + param2,param1.moreY + param3))
            {
               return;
            }
            param1.setMoreEnabled(false);
         }
         moveSlt(param1,param1.x + param2,param1.y + param3);
      }
      
      private function render() : void
      {
         var inputType:String = null;
         if(GameUI.showingDialog())
         {
            return;
         }
         if(_p1IdleFighter)
         {
            if(_p1IdleFighter.direct != 1)
            {
               _p1IdleFighter.direct = 1;
            }
            if(_p1IdleFighter.mc && _p1IdleFighter.mc.scaleX < 0)
            {
               _p1IdleFighter.mc.scaleX = Math.abs(_p1IdleFighter.mc.scaleX);
            }
         }
         if(_p2IdleFighter)
         {
            if(_p2IdleFighter.direct != -1)
            {
               _p2IdleFighter.direct = -1;
            }
            if(_p2IdleFighter.mc && _p2IdleFighter.mc.scaleX > 0)
            {
               _p2IdleFighter.mc.scaleX = -Math.abs(_p2IdleFighter.mc.scaleX);
            }
         }
         if(_p1Slt && _p1Slt.enabled)
         {
            renderRandom(_p1Slt);
            inputType = _p1Slt.inputType;
            if(GameInputer.up(inputType,1))
            {
               moveSelecter(_p1Slt,0,-1);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.down(inputType,1))
            {
               moveSelecter(_p1Slt,0,1);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.left(inputType,1))
            {
               moveSelecter(_p1Slt,-1,0);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.right(inputType,1))
            {
               moveSelecter(_p1Slt,1,0);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.jump(inputType,1))
            {
               _p1Slt.select(playerSeltBack);
               SoundCtrl.I.sndConfrim();
               return;
            }
            if(GameInputer.dash(inputType,1) || GameInputer.back(1))
            {
               cancelP1Select();
               return;
            }
         }
         if(_p2Slt && _p2Slt.enabled)
         {
            inputType = _p2Slt.inputType;
            renderRandom(_p2Slt);
            if(GameInputer.up(inputType,1))
            {
               moveSelecter(_p2Slt,0,-1);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.down(inputType,1))
            {
               moveSelecter(_p2Slt,0,1);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.left(inputType,1))
            {
               moveSelecter(_p2Slt,-1,0);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.right(inputType,1))
            {
               moveSelecter(_p2Slt,1,0);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.jump(inputType,1))
            {
               _p2Slt.select(playerSeltBack);
               SoundCtrl.I.sndConfrim();
               return;
            }
            if(GameInputer.dash(inputType,1) || GameInputer.back(1))
            {
               cancelP2Select();
               return;
            }
         }
         if(_mapSelectUI && _mapSelectUI.enabled)
         {
            var mapInputType:String = _mapSelectUI.inputType;
            if(GameInputer.left(mapInputType,1))
            {
               _mapSelectUI.prev();
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.right(mapInputType,1))
            {
               _mapSelectUI.next();
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.select(mapInputType,1) || GameInputer.jump(mapInputType,1) || GameInputer.attack(mapInputType,1))
            {
               _mapSelectUI.select(onMapSelect);
               SoundCtrl.I.sndConfrim();
               return;
            }
            if(GameInputer.dash(mapInputType,1) || GameInputer.back(1))
            {
               cancelMapSelect();
               return;
            }
         }
      }
      
      public function get p1SelectFinish() : Boolean
      {
         return Boolean(_p1Slt) && _p1Slt.selectFinish();
      }
      
      public function get p2SelectFinish() : Boolean
      {
         return Boolean(_p2Slt) && _p2Slt.selectFinish();
      }
      
      public function setSelect(param1:int, param2:Array) : void
      {
         var _loc3_:SelecterItemUI = param1 == 1 ? _p1Slt : _p2Slt;
         _loc3_.setCurrentSelect(param2);
         _loc3_.removeSelecter();
         SoundCtrl.I.sndConfrim();
      }
      
      private function playerSeltBack(selt:SelecterItemUI) : void
      {
         if(selt.selectFinish())
         {
            if(GameMode.isVsPeople())
            {
               GameEvent.dispatchEvent("SELECT_FIGHTER_STEP",selt.getCurrentSelectes());
               var otherSlt:SelecterItemUI = selt == _p1Slt ? _p2Slt : _p1Slt;
               if(otherSlt && otherSlt.selectFinish() && !_twoPlayerSelectFin)
               {
                  _twoPlayerSelectFin = true;
                  if(!AUTO_FINISH)
                  {
                     return;
                  }
                  nextStep();
               }
            }
            else
            {
               nextStep();
            }
            selt.removeSelecter();
            selt.enabled = false;
         }
         else if(!selt.randoms)
         {
            var moveDirection:int = (selt == _p1Slt) ? 1 : -1;
            moveSlt(selt,selt.x + moveDirection,selt.y,true);
         }
      }
      
      public function nextStep() : void
      {
         switch(_curStep)
         {
            case 0:
               initFighter();
               _curStep = 1;
               break;
            case 1:
               if(GameMode.isVsCPU())
               {
                  _p1Slt.removeSelecter();
                  _p1Slt.enabled = false;
                  initSelecterP2();
                  _curStep = 2;
                  _p2Slt.inputType = GameInputType.P1;
               }
               else if(GameData.I.config.assisterPartner)
               {
                  fadOutList(initAssist);
                  _curStep = 3;
               }
               else
               {
                  GameData.I.p1Select.fuzhu = null;
                  GameData.I.p2Select.fuzhu = null;
                  if(GameMode.isVsPeople())
                  {
                     _curStep = 5;
                     initMap();
                  }
                  else
                  {
                     if(GameMode.isAcrade())
                     {
                        startAcradeGame();
                     }
                     if(GameMode.currentMode == 100)
                     {
                        startMosouGame();
                     }
                  }
               }
               break;
            case 2:
               if(GameData.I.config.assisterPartner)
               {
                  fadOutList(initAssist);
                  _curStep = 3;
               }
               else
               {
                  GameData.I.p1Select.fuzhu = null;
                  GameData.I.p2Select.fuzhu = null;
                  _curStep = 5;
                  initMap();
               }
               break;
            case 3:
               if(GameMode.isVsCPU())
               {
                  _p1Slt.removeSelecter();
                  _p1Slt.enabled = false;
                  initSelecterP2();
                  _p2Slt.inputType = GameInputType.P1;
                  _curStep = 4;
               }
               else if(GameMode.isVsCPU() || GameMode.isVsPeople())
               {
                  _curStep = 5;
                  initMap();
               }
               else
               {
                  if(GameMode.isAcrade())
                  {
                     startAcradeGame();
                  }
                  if(GameMode.currentMode == 100)
                  {
                     startMosouGame();
                  }
               }
               break;
            case 4:
               _curStep = 5;
               initMap();
               break;
            case 5:
               selectFinish();
         }
      }

      private function initMap() : void
      {
         trace("选择地图");
         GameEvent.dispatchEvent("SELECT_MAP");
         if(_p1Slt)
         {
            _p1Slt.enabled = false;
            _p1Slt.removeSelecter();
         }
         if(_p2Slt)
         {
            _p2Slt.enabled = false;
            _p2Slt.removeSelecter();
         }
         for each(var f:ArrayMap in _moreFighterMap)
         {
            if(f)
            {
               var idx:int = 0;
               while(idx < f.length)
               {
                  var item:SelectFighterItem = f.getItemByIndex(idx);
                  if(item) item.destory();
                  idx++;
               }
               _moreFighterMap[f] = null;
            }
         }
         if(_fighterListUI)
         {
            _fighterListUI.visible = true;
            _fighterListUI.mouseChildren = false;
            _fighterListUI.mouseEnabled = false;
            TweenLite.to(_fighterListUI, 0.22, {
               "alpha": 0.22,
               "ease": Quad.easeOut
            });
         }
         if(_mapSelectUI)
         {
            _mapSelectUI.destory();
            _mapSelectUI = null;
         }
         _mapSelectUI = new MapSelectUI();
         _mapSelectUI.alpha = 0;
         _ui.addChild(_mapSelectUI);
         _mapSelectUI.addMouseEvents(mapPrevHandler,mapNextHandler,mapConfrimHandler);
         _mapSelectUI.inputType = GameInputType.P1;
         _mapSelectUI.enabled = false;
         GameInputer.clearInput();
         GameInputer.enabled = false;
         _mapSelectUI.playOpenAnimation(function():void
         {
            if(_mapSelectUI)
            {
               _mapSelectUI.enabled = true;
            }
            GameInputer.clearInput();
            GameInputer.enabled = true;
         });
      }
      
      private function mapPrevHandler() : void
      {
         _mapSelectUI.prev();
      }
      
      private function mapNextHandler() : void
      {
         _mapSelectUI.next();
      }
      
      private function mapConfrimHandler() : void
      {
         _mapSelectUI.select(onMapSelect);
      }
      
      private function onMapSelect() : void
      {
         nextStep();
      }

      private function cancelMapSelect() : void
      {
         if(!_mapSelectUI)
         {
            return;
         }
         _mapSelectUI.destory();
         _mapSelectUI = null;

         if(_fighterListUI)
         {
            _fighterListUI.visible = true;
            _fighterListUI.mouseChildren = true;
            _fighterListUI.mouseEnabled = true;
            TweenLite.to(_fighterListUI, 0.2, {
               "alpha": 1,
               "ease": Quad.easeOut
            });
         }

         if(GameMode.isVsCPU())
         {
            if(GameData.I.config.assisterPartner)
            {
               _curStep = 4;
            }
            else
            {
               _curStep = 2;
            }
         }
         else
         {
            _twoPlayerSelectFin = false;
            _curStep = GameData.I.config.assisterPartner ? 3 : 1;
         }

         if(_p2Slt)
         {
            _fighterListUI.addChild(_p2Slt.ui);
            _p2Slt.enabled = true;
            _p2Slt.cancelSelect();
            var itemP2:SelectFighterItem = getFighterItemById(_p2Slt.lastCancelledFighterId);
            if(!itemP2)
            {
               itemP2 = getFighterItem(_p2Slt.x, _p2Slt.y);
            }
            if(itemP2)
            {
               moveToSelectFighter(_p2Slt, itemP2);
            }
         }
         else if(_p1Slt)
         {
            _fighterListUI.addChild(_p1Slt.ui);
            _p1Slt.enabled = true;
            _p1Slt.cancelSelect();
            var itemP1:SelectFighterItem = getFighterItemById(_p1Slt.lastCancelledFighterId);
            if(!itemP1)
            {
               itemP1 = getFighterItem(_p1Slt.x, _p1Slt.y);
            }
            if(itemP1)
            {
               moveToSelectFighter(_p1Slt, itemP1);
            }
         }

         SoundCtrl.I.sndSelect();
         GameInputer.clearInput();
         GameInputer.enabled = true;
      }

      private function cancelP2Select() : void
      {
         if(!_p2Slt)
         {
            return;
         }

         if(_curStep == 4)
         {
            _p2Slt.removeSelecter();
            _p2Slt.enabled = false;
            if(_p2Slt.group)
            {
               _p2Slt.group.clearAssist();
            }
            _curStep = 3;
            if(_p1Slt)
            {
               _fighterListUI.addChild(_p1Slt.ui);
               _p1Slt.enabled = true;
               _p1Slt.cancelSelect();
               var curItemP1Assist:SelectFighterItem = getFighterItemById(_p1Slt.lastCancelledFighterId);
               if(!curItemP1Assist)
               {
                  curItemP1Assist = getFighterItem(_p1Slt.x, _p1Slt.y);
               }
               if(curItemP1Assist)
               {
                  moveToSelectFighter(_p1Slt, curItemP1Assist);
               }
            }
            SoundCtrl.I.sndSelect();
            GameInputer.clearInput();
            GameInputer.enabled = true;
            return;
         }

         if(_p2Slt.selectTimes > 0)
         {
            _p2Slt.cancelSelect();
            var curItemP2:SelectFighterItem = getFighterItemById(_p2Slt.lastCancelledFighterId);
            if(!curItemP2)
            {
               curItemP2 = getFighterItem(_p2Slt.x, _p2Slt.y);
            }
            if(curItemP2)
            {
               moveToSelectFighter(_p2Slt, curItemP2);
            }
            SoundCtrl.I.sndSelect();
            return;
         }

         _p2Slt.removeSelecter();
         _p2Slt.destory();
         _p2Slt = null;
         clearIdleFighter(2);

         _curStep = 1;

         if(_p1Slt)
         {
            _fighterListUI.addChild(_p1Slt.ui);
            _p1Slt.enabled = true;
            _p1Slt.cancelSelect();
            var curItemP1:SelectFighterItem = getFighterItemById(_p1Slt.lastCancelledFighterId);
            if(!curItemP1)
            {
               curItemP1 = getFighterItem(_p1Slt.x, _p1Slt.y);
            }
            if(curItemP1)
            {
               moveToSelectFighter(_p1Slt, curItemP1);
            }
         }
         else
         {
            initSelecterP1();
         }

         SoundCtrl.I.sndSelect();
         GameInputer.clearInput();
         GameInputer.enabled = true;
      }

      private function cancelP1Select() : void
      {
         if(!_p1Slt)
         {
            GameUI.confrim('BACK TITLE?', '返回到主菜单？', MainGame.I.goMenu);
            GameEvent.dispatchEvent(GameEvent.CONFRIM_BACK_MENU);
            return;
         }

         if(_curStep == 3)
         {
            if(_p1Slt.group)
            {
               _p1Slt.group.clearAssist();
            }
            if(_p2Slt && _p2Slt.group)
            {
               _p2Slt.group.clearAssist();
            }
            clearGridOnly();
            _selectState = SELECT_STATE_FIGHTER;
            buildList(_config.charList);

            if(GameMode.isVsCPU())
            {
               _curStep = 2;
               if(_p2Slt)
               {
                  _p2Slt.isSelectAssist = false;
                  _p2Slt.selectTimesCount = GameMode.isTeamMode() ? 3 : Math.max(1, GameData.I.config.player2);
                  _fighterListUI.addChild(_p2Slt.ui);
                  _p2Slt.enabled = true;
                  _p2Slt.cancelSelect();
                  var itemP2Char:SelectFighterItem = getFighterItemById(_p2Slt.lastCancelledFighterId);
                  if(!itemP2Char)
                  {
                     itemP2Char = getFighterItem(_p2Slt.x, _p2Slt.y);
                  }
                  if(itemP2Char)
                  {
                     moveToSelectFighter(_p2Slt, itemP2Char);
                  }
               }
            }
            else
            {
               _curStep = 1;
               _p1Slt.isSelectAssist = false;
               _p1Slt.selectTimesCount = GameMode.isTeamMode() ? 3 : Math.max(1, GameData.I.config.player1);
               _fighterListUI.addChild(_p1Slt.ui);
               _p1Slt.enabled = true;
               _p1Slt.cancelSelect();
               var itemP1Char:SelectFighterItem = getFighterItemById(_p1Slt.lastCancelledFighterId);
               if(!itemP1Char)
               {
                  itemP1Char = getFighterItem(_p1Slt.x, _p1Slt.y);
               }
               if(itemP1Char)
               {
                  moveToSelectFighter(_p1Slt, itemP1Char);
               }
            }
            SoundCtrl.I.sndSelect();
            GameInputer.clearInput();
            GameInputer.enabled = true;
            return;
         }

         if(_p1Slt.selectTimes > 0)
         {
            _p1Slt.cancelSelect();
            var curItemP1Fighter:SelectFighterItem = getFighterItemById(_p1Slt.lastCancelledFighterId);
            if(!curItemP1Fighter)
            {
               curItemP1Fighter = getFighterItem(_p1Slt.x, _p1Slt.y);
            }
            if(curItemP1Fighter)
            {
               moveToSelectFighter(_p1Slt, curItemP1Fighter);
            }
            SoundCtrl.I.sndSelect();
            return;
         }

         SoundCtrl.I.sndSelect();
         GameUI.confrim('BACK TITLE?', '返回到主菜单？', MainGame.I.goMenu);
         GameEvent.dispatchEvent(GameEvent.CONFRIM_BACK_MENU);
      }
      
      private function startAcradeGame() : void
      {
         MessionModel.I.initMession();
         selectFinish();
      }
      
      private function startMosouGame() : void
      {
         selectFinish();
      }
      
      private function selectFinish() : void
      {
         GameEvent.dispatchEvent("SELECT_FIGHTER_FINISH");
         if(!AUTO_FINISH)
         {
            return;
         }
         goLoadGame();
      }
      
      public function goLoadGame() : void
      {
         trace("开始游戏");
         StateCtrl.I.transIn(MainGame.I.loadGame);
      }
      
      public function afterBuild() : void
      {
      }
      
      private function updateIdleSprite(playerIndex:int, fighter:FighterVO) : void
      {
         if(_selectState != SELECT_STATE_FIGHTER)
         {
            return;
         }
         if(!fighter)
         {
            clearIdleFighter(playerIndex);
            return;
         }

         var currentId:String = playerIndex == 1 ? _curP1FighterId : _curP2FighterId;
         if(currentId == fighter.id)
         {
            return;
         }

         if(playerIndex == 1)
         {
            _curP1FighterId = fighter.id;
         }
         else
         {
            _curP2FighterId = fighter.id;
         }

         clearIdleFighter(playerIndex, false);

         var targetFighterId:String = fighter.id;
         var fileUrl:String = fighter.fileUrl;
         if(!fileUrl)
         {
            var fv:FighterVO = FighterModel.I.getFighter(targetFighterId, true);
            if(fv)
            {
               fileUrl = fv.fileUrl;
            }
         }
         if(!fileUrl)
         {
            return;
         }

         var onFail:Function = function(msg:Object = null):void
         {
            var activeId:String = playerIndex == 1 ? _curP1FighterId : _curP2FighterId;
            if(activeId == targetFighterId)
            {
               clearIdleFighter(playerIndex, false);
            }
         };

         AssetManager.I.loadSWF(fileUrl, function(loadedLoader:Loader):void
         {
            var activeId:String = playerIndex == 1 ? _curP1FighterId : _curP2FighterId;
            if(!loadedLoader || !loadedLoader.content || activeId != targetFighterId)
            {
               if(loadedLoader)
               {
                  try
                  {
                     loadedLoader.unloadAndStop(true);
                  }
                  catch(e:Error)
                  {
                     try
                     {
                        loadedLoader.unload();
                     }
                     catch(e2:Error)
                     {
                     }
                  }
               }
               return;
            }

            clearIdleFighter(playerIndex, false);

            if(playerIndex == 1)
            {
               _p1IdleLoader = loadedLoader;
            }
            else
            {
               _p2IdleLoader = loadedLoader;
            }

            try
            {
               var loadedFighter:FighterMain = new FighterMain(loadedLoader.content as MovieClip);
               loadedFighter.data = fighter;
               if(!loadedFighter.initlized())
               {
                  loadedFighter.initlize();
               }
               loadedFighter.scale = 5.2;
               loadedFighter.direct = playerIndex == 1 ? 1 : -1;
               loadedFighter.x = 0;
               loadedFighter.y = 0;
               loadedFighter.setVelocity(0, 0);
               loadedFighter.setVec2(0, 0);
               loadedFighter.isApplyG = false;
               loadedFighter.isInAir = false;
               loadedFighter.isTouchBottom = true;
               loadedFighter.renderSelf();
               loadedFighter.idle();
               loadedFighter.disableShadow();

               var container:Sprite = playerIndex == 1 ? _p1IdleContainer : _p2IdleContainer;
               if(container && loadedFighter.mc)
               {
                  container.addChild(loadedFighter.mc);
                  loadedFighter.disableShadow();
               }

               if(playerIndex == 1)
               {
                  _p1IdleFighter = loadedFighter;
               }
               else
               {
                  _p2IdleFighter = loadedFighter;
               }
            }
            catch(err:Error)
            {
            }
         }, onFail);
      }

      private function clearIdleFighter(playerIndex:int, resetId:Boolean = true) : void
      {
         if(playerIndex == 1)
         {
            if(resetId)
            {
               _curP1FighterId = null;
            }
            if(_p1IdleFighter)
            {
               try
               {
                  if(_p1IdleFighter.mc && _p1IdleFighter.mc.parent)
                  {
                     _p1IdleFighter.mc.parent.removeChild(_p1IdleFighter.mc);
                  }
                  _p1IdleFighter.destory();
               }
               catch(e:Error)
               {
               }
               _p1IdleFighter = null;
            }
            if(_p1IdleLoader)
            {
               try
               {
                  _p1IdleLoader.unloadAndStop(true);
               }
               catch(e:Error)
               {
                  try
                  {
                     _p1IdleLoader.unload();
                  }
                  catch(e2:Error)
                  {
                  }
               }
               _p1IdleLoader = null;
            }
            if(_p1IdleContainer)
            {
               while(_p1IdleContainer.numChildren > 0)
               {
                  _p1IdleContainer.removeChildAt(0);
               }
            }
         }
         else
         {
            if(resetId)
            {
               _curP2FighterId = null;
            }
            if(_p2IdleFighter)
            {
               try
               {
                  if(_p2IdleFighter.mc && _p2IdleFighter.mc.parent)
                  {
                     _p2IdleFighter.mc.parent.removeChild(_p2IdleFighter.mc);
                  }
                  _p2IdleFighter.destory();
               }
               catch(e:Error)
               {
               }
               _p2IdleFighter = null;
            }
            if(_p2IdleLoader)
            {
               try
               {
                  _p2IdleLoader.unloadAndStop(true);
               }
               catch(e:Error)
               {
                  try
                  {
                     _p2IdleLoader.unload();
                  }
                  catch(e2:Error)
                  {
                  }
               }
               _p2IdleLoader = null;
            }
            if(_p2IdleContainer)
            {
               while(_p2IdleContainer.numChildren > 0)
               {
                  _p2IdleContainer.removeChildAt(0);
               }
            }
         }
      }

      public function destory(param1:Function = null) : void
      {
         clear();
         clearIdleFighter(1);
         clearIdleFighter(2);
         GameRender.remove(render);
         GameInputer.enabled = false;
         SoundCtrl.I.BGM(null);
         GameUI.closeConfrim();
         if(_backMenuBtn)
         {
            _backMenuBtn.removeEventListener("touchTap",backMenuHandler);
            _backMenuBtn.removeEventListener("click",backMenuHandler);
            _backMenuBtn.visible = false;
         }
         if(_p1IdleContainer)
         {
            if(_p1IdleContainer.parent)
            {
               _p1IdleContainer.parent.removeChild(_p1IdleContainer);
            }
            _p1IdleContainer = null;
         }
         if(_p2IdleContainer)
         {
            if(_p2IdleContainer.parent)
            {
               _p2IdleContainer.parent.removeChild(_p2IdleContainer);
            }
            _p2IdleContainer = null;
         }
      }
   }
}

