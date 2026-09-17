package net.play5d.game.bvn.ui.select
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.geom.Point;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.SelectVO;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.input.GameInputer;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.kyo.utils.KyoRandom;
   
   public class SelectIndexUIGroup extends Sprite
   {
      public var isFinish:Boolean;
      
      public var fzx:Number = 0;
      
      public var fzy:Number = 425;
      
      public var onFinish:Function;
      
      public var fighterOffset:Point = new Point();
      
      private var _fighters:Vector.<SelectedFighterUI>;
      
      private var _fighterScale:Number = 1;
      
      private var _fzScale:Number = 1;
      
      private var _arrowOffset:Point = new Point();
      
      private var _arrow:DisplayObject;
      
      private var _selectIndex:int;
      
      private var _selectItem:SelectedFighterUI;
      
      private var _inputType:String;
      
      private var _currentSelectId:int = 1;
      
      private var _gy:int = 275;
      
      private var _gyDuo:int = 360;
      
      private var _fuzhu:SelectedFighterUI;
      
      public function SelectIndexUIGroup()
      {
         super();
      }
      
      public function getOrder() : Array
      {
         var _loc2_:int = 0;
         var _loc1_:Array = [];
         _fighters.sort(sortFighters);
         while(_loc2_ < _fighters.length)
         {
            _loc1_.push(_fighters[_loc2_].getFighter().id);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function setFighterScale(param1:Number) : void
      {
         _fighterScale = param1;
         for each(var i:SelectedFighterUI in _fighters)
         {
            i.ui.scaleX = i.ui.scaleY = param1;
         }
      }
      
      public function setFZScale(param1:Number) : void
      {
         _fzScale = param1;
         if(!_fuzhu)
         {
            return;
         }
         _fuzhu.ui.scaleX = _fuzhu.ui.scaleY = param1;
      }
      
      public function setOrder(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc2_ < _fighters.length)
         {
            _loc3_ = int(param1.indexOf(_fighters[_loc2_].getFighter().id));
            if(_loc3_ != -1)
            {
               _fighters[_loc2_].setFighterIndex(_loc3_ + 1);
            }
            _loc2_++;
         }
         removeArrow();
         isFinish = true;
         updateOrder();
      }
      
      private function sortFighters(param1:SelectedFighterUI, param2:SelectedFighterUI) : int
      {
         var _loc4_:int = param1.getFighterIndex();
         var _loc3_:int = param2.getFighterIndex();
         if(_loc4_ == -1)
         {
            _loc4_ = 10;
         }
         if(_loc3_ == -1)
         {
            _loc3_ = 10;
         }
         if(_loc4_ > _loc3_)
         {
            return 1;
         }
         if(_loc4_ < _loc3_)
         {
            return -1;
         }
         return 0;
      }
      
      public function destory() : void
      {
         removeArrow();
         if(_fighters)
         {
            for each(var i:SelectedFighterUI in _fighters)
            {
               i.removeEventListener("mouseOver",selectFighterMouseHandler);
               i.removeEventListener("click",selectFighterMouseHandler);
               i.removeEventListener("touchTap",selectFighterTouchHandler);
               i.destory();
            }
            _fighters = null;
         }
         if(_fuzhu)
         {
            _fuzhu.destory();
            _fuzhu = null;
         }
         _selectItem = null;
      }
      
      public function build(param1:Class, param2:SelectVO) : void
      {
         var _loc4_:SelectedFighterUI = null;
         var _loc3_:int = 0;
         var _loc5_:Array = param2.getSelectFighters();
         _fighters = new Vector.<SelectedFighterUI>();
         while(_loc3_ < _loc5_.length)
         {
            _loc4_ = new SelectedFighterUI(new param1());
            _loc4_.setFighter(FighterModel.I.getFighter(_loc5_[_loc3_]));
            _loc4_.mouseEnabled(true);
            if(_loc5_.length > 1)
            {
               if(GameConfig.TOUCH_MODE)
               {
                  _loc4_.addEventListener("touchTap",selectFighterTouchHandler);
               }
               else
               {
                  _loc4_.addEventListener("mouseOver",selectFighterMouseHandler);
                  _loc4_.addEventListener("click",selectFighterMouseHandler);
               }
            }
            if(GameMode.isTeamMode())
            {
               _loc4_.ui.x = _loc3_ * _gyDuo + fighterOffset.x;
               _loc4_.trueY = _loc3_ * _gyDuo + fighterOffset.y;
            }
            else
            {
               _loc4_.ui.x = _loc3_ * _gy + fighterOffset.x;
               _loc4_.trueY = _loc3_ * _gy + fighterOffset.y;
            }
            if(_fighterScale != 1)
            {
               _loc4_.ui.scaleX = _loc4_.ui.scaleY = _fighterScale;
            }
            _fighters.push(_loc4_);
            addChild(_loc4_.ui);
            _loc3_++;
         }
      }
      
      private function selectFighterTouchHandler(param1:TouchEvent) : void
      {
         var _loc3_:SelectedFighterUI = param1.currentTarget as SelectedFighterUI;
         var _loc2_:int = int(_fighters.indexOf(_loc3_));
         if(_loc2_ == -1)
         {
            return;
         }
         selectIndex(_loc2_);
         doConfrim();
      }
      
      private function selectFighterMouseHandler(param1:MouseEvent) : void
      {
         var _loc3_:SelectedFighterUI = param1.currentTarget as SelectedFighterUI;
         var _loc2_:int = int(_fighters.indexOf(_loc3_));
         if(_loc2_ == -1)
         {
            return;
         }
         switch(param1.type)
         {
            case "mouseOver":
               selectIndex(_loc2_);
               SoundCtrl.I.sndSelect();
               break;
            case "click":
               doConfrim();
         }
      }
      
      public function initArrow(param1:DisplayObject, param2:Point) : void
      {
         _arrowOffset = param2;
         _arrow = param1;
         _arrow.x = param2.x;
         addChild(_arrow);
         selectIndex(0);
      }
      
      public function selectIndex(param1:int, param2:int = 0) : void
      {
         if(param1 < 0)
         {
            param1 = _fighters.length - 1;
         }
         if(param1 > _fighters.length - 1)
         {
            param1 = 0;
         }
         var _loc3_:SelectedFighterUI = _fighters[param1];
         if(_loc3_.getFighterIndex() != -1)
         {
            if(param2 != 0)
            {
               selectIndex(param1 + param2,param2);
            }
            return;
         }
         _selectIndex = param1;
         _selectItem = _fighters[param1];
         _arrow.x = _selectItem.trueY + _arrowOffset.y;
      }
      
      public function setKey(param1:String) : void
      {
         _inputType = param1;
         GameRender.add(render);
         GameInputer.focus();
      }
      
      public function autoSelect() : void
      {
         var _loc2_:* = null;
         var _loc1_:Array = [];
         for each(_loc2_ in _fighters)
         {
            _loc1_.push(_loc2_);
         }
         KyoRandom.arraySortRandom(_loc1_);
         var _loc3_:int = 1;
         for each(_loc2_ in _loc1_)
         {
            _loc2_.setFighterIndex(_loc3_);
            _loc3_++;
         }
         selectFinish();
      }
      
      private function removeArrow() : void
      {
         if(_arrow)
         {
            try
            {
               removeChild(_arrow);
            }
            catch(e:Error)
            {
            }
            _arrow = null;
         }
         GameRender.remove(render);
      }
      
      private function render() : void
      {
         if(GameUI.showingDialog())
         {
            return;
         }
         if(GameInputer.up(_inputType,1))
         {
            selectIndex(_selectIndex - 1,-1);
            SoundCtrl.I.sndSelect();
         }
         if(GameInputer.down(_inputType,1))
         {
            selectIndex(_selectIndex + 1,1);
            SoundCtrl.I.sndSelect();
         }
         if(GameInputer.select(_inputType,1))
         {
            doConfrim();
         }
      }
      
      private function doConfrim() : void
      {
         if(_selectItem)
         {
            _selectItem.setFighterIndex(_currentSelectId);
            _currentSelectId++;
            if(_currentSelectId > _fighters.length - 1)
            {
               selectLast();
               selectFinish();
            }
            else
            {
               updateOrder();
               selectIndex(1,1);
            }
            SoundCtrl.I.sndConfrim();
         }
      }
      
      private function selectLast() : void
      {
         for each(var i:SelectedFighterUI in _fighters)
         {
            if(i.getFighterIndex() == -1)
            {
               i.setFighterIndex(_currentSelectId);
               return;
            }
         }
      }
      
      private function selectFinish() : void
      {
         removeArrow();
         isFinish = true;
         updateOrder();
         if(onFinish != null)
         {
            GameEvent.dispatchEvent("SELECT_FIGHTER_INDEX",getOrder());
            onFinish();
         }
      }
      
      private function updateOrder() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Number = NaN;
         var _loc3_:DisplayObject = null;
         _fighters.sort(sortFighters);
         while(_loc2_ < _fighters.length)
         {
            _loc1_ = _loc2_ * _gy;
            _fighters[_loc2_].trueY = _loc1_;
            _loc3_ = _fighters[_loc2_].ui;
            _loc2_++;
         }
      }
   }
}

