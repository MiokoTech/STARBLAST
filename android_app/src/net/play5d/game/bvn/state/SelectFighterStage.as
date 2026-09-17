package net.play5d.game.bvn.state
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import flash.display.DisplayObject;
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
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.ctrl.GameRender;
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

      private function backMenuHandler(e:Event):void
      {
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

      private function initAssist() : void
      {
         TweenLite.to(_fighterListUI,0.2,{"x":0});
         clear();
         _selectState = SELECT_STATE_ASSIST;
         buildList(_config.assistList);
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
            _p1Slt.destory();
            _p1Slt = null;
         }
         if(_p2Slt)
         {
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
         var _loc3_:SelecterItemUI = null;
         if(_p1Slt && _p1Slt.enabled)
         {
            _loc3_ = _p1Slt;
         }
         if(!_loc3_ && (_p2Slt && _p2Slt.enabled))
         {
            _loc3_ = _p2Slt;
         }
         if(!_loc3_)
         {
            return;
         }
         if(_loc3_.touchHoverItem == param2)
         {
            doSelect(param2);
            _loc3_.touchHoverItem = null;
         }
         else
         {
            _loc3_.touchHoverItem = param2;
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

         _fighterListUI.addChild(_p1Slt.ui);
         if (_fighterListUI && _ui.contains(_fighterListUI))
         {
            _ui.addChildAt(_p1Slt.group, _ui.getChildIndex(_fighterListUI));
         }
         else
         {
            _ui.addChild(_p1Slt.group);
         }
         moveSlt(_p1Slt,0,0);
      }

      private function initSelecterP2() : void
      {
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

         _fighterListUI.addChild(_p2Slt.ui);
         if (_fighterListUI && _ui.contains(_fighterListUI))
         {
            _ui.addChildAt(_p2Slt.group, _ui.getChildIndex(_fighterListUI));
         }
         else
         {
            _ui.addChild(_p2Slt.group);
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
            param1.group.updateFighter(param1.currentFighter);
         }
         checkRandom(param1);
         showMoreFighters(param1,param2);
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
            param1.group.updateFighter(param1.currentFighter);
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
         var _loc1_:String = null;
         if(GameUI.showingDialog())
         {
            return;
         }
         if(_p1Slt && _p1Slt.enabled)
         {
            renderRandom(_p1Slt);
            _loc1_ = _p1Slt.inputType;
            if(GameInputer.up(_loc1_,1))
            {
               moveSelecter(_p1Slt,0,-1);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.down(_loc1_,1))
            {
               moveSelecter(_p1Slt,0,1);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.left(_loc1_,1))
            {
               moveSelecter(_p1Slt,-1,0);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.right(_loc1_,1))
            {
               moveSelecter(_p1Slt,1,0);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.jump(_loc1_,1))
            {
               _p1Slt.select(playerSeltBack);
               SoundCtrl.I.sndConfrim();
            }
            if(GameInputer.dash(_loc1_,1))
            {
               MainGame.I.goMenu();
            }
         }
         if(_p2Slt && _p2Slt.enabled)
         {
            _loc1_ = _p2Slt.inputType;
            renderRandom(_p2Slt);
            if(GameInputer.up(_loc1_,1))
            {
               moveSelecter(_p2Slt,0,-1);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.down(_loc1_,1))
            {
               moveSelecter(_p2Slt,0,1);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.left(_loc1_,1))
            {
               moveSelecter(_p2Slt,-1,0);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.right(_loc1_,1))
            {
               moveSelecter(_p2Slt,1,0);
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.jump(_loc1_,1))
            {
               _p2Slt.select(playerSeltBack);
               SoundCtrl.I.sndConfrim();
            }
         }
         if(_mapSelectUI && _mapSelectUI.enabled)
         {
            _loc1_ = _mapSelectUI.inputType;
            if(GameInputer.left(_loc1_,1))
            {
               _mapSelectUI.prev();
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.right(_loc1_,1))
            {
               _mapSelectUI.next();
               SoundCtrl.I.sndSelect();
            }
            if(GameInputer.jump(_loc1_,1))
            {
               _mapSelectUI.select(onMapSelect);
               SoundCtrl.I.sndConfrim();
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
                  _p2Slt.inputType = GameInputType.P1;
                  _curStep = 2;
               }
               else
               {
                  fadOutList(initAssist);
                  _curStep = 3;
               }
               break;
            case 2:
               fadOutList(initAssist);
               _curStep = 3;
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
                  fadOutList(initMap);
                  _curStep = 5;
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
               fadOutList(initMap);
               break;
            case 5:
               selectFinish();
         }
      }

      private function initMap() : void
      {
         var oldX:Number;
         var oldY:Number;
         trace("选择地图");
         GameEvent.dispatchEvent("SELECT_MAP");
         clear();
         GameInputer.enabled = false;
         _mapSelectUI = new MapSelectUI();
         _ui.addChild(_mapSelectUI);
         oldX = _mapSelectUI.x;
         oldY = _mapSelectUI.y;
         _mapSelectUI.scaleX = 0;
         _mapSelectUI.scaleY = 0;
         _mapSelectUI.x = GameConfig.GAME_SIZE.x / 2;
         _mapSelectUI.y = GameConfig.GAME_SIZE.y / 2;
         TweenLite.to(_mapSelectUI,0.3,{
            "x":oldX,
            "y":oldY,
            "scaleX":1,
            "scaleY":1,
            "ease":Back.easeOut,
            "onComplete":function():void
            {
               if(_mapSelectUI)
               {
                  _mapSelectUI.addMouseEvents(mapPrevHandler,mapNextHandler,mapConfrimHandler);
                  _mapSelectUI.inputType = GameInputType.P1;
                  _mapSelectUI.enabled = true;
               }
               GameInputer.enabled = true;
            }
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
      
      public function destory(param1:Function = null) : void
      {
         clear();
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
      }
   }
}

