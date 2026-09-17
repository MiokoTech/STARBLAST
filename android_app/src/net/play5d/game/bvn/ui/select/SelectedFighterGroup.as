package net.play5d.game.bvn.ui.select
{
   import flash.display.Sprite;
   import net.play5d.game.bvn.data.FighterVO;

   public class SelectedFighterGroup extends Sprite
   {
      public var nameGroup:Sprite = new Sprite();
      public var slotGroup:Sprite = new Sprite();
      public var isP1:Boolean = true;

      private var _uiClass:Class;
      private var _uis:Array = [];
      private var _curUI:SelectedFighterUI;

      private var _totalCount:int = 1;
      private var _circleSlots:Array = [];
      private var _pickedCount:int = 0;
      private var _assistSlot:CircleSlotUI;
      private static const COLOR_GOLD:uint = 0xffd700;

      public function SelectedFighterGroup(uiClass:Class, isP1:Boolean = true)
      {
         super();
         _uiClass = uiClass;
         this.isP1 = isP1;
      }

      public function initSlots(totalCount:int) : void
      {
         _totalCount = totalCount;
         clearSlots();

         var radius:Number = 24;
         var gap:Number = 65;
         var startX:Number;

         if(_totalCount > 1)
         {
            var slotNum:int = _totalCount - 1;
            if(isP1)
            {
               startX = 75;
            }
            else
            {
               startX = 1280 - 75 - (slotNum - 1) * gap;
            }

            for(var i:int = 0; i < slotNum; i++)
            {
               var slot:CircleSlotUI = new CircleSlotUI(isP1, radius);
               slot.x = startX + i * gap;
               slot.y = 615;
               slotGroup.addChild(slot);
               _circleSlots.push(slot);
            }
         }

         var assistX:Number;
         var assistY:Number;
         if(_totalCount <= 1)
         {
            assistX = isP1 ? 75 : 1205;
            assistY = 615;
         }
         else
         {
            assistX = isP1 ? 75 : startX;
            assistY = 669;
         }

         _assistSlot = new CircleSlotUI(isP1, radius, COLOR_GOLD);
         _assistSlot.x = assistX;
         _assistSlot.y = assistY;
         _assistSlot.visible = false;
         slotGroup.addChild(_assistSlot);
      }

      private function clearSlots() : void
      {
         for each(var slot:CircleSlotUI in _circleSlots)
         {
            if(slot) slot.destory();
         }
         _circleSlots = [];
         if(_assistSlot)
         {
            _assistSlot.destory();
            _assistSlot = null;
         }
         if(slotGroup)
         {
            slotGroup.removeChildren();
         }
         _pickedCount = 0;
      }

      public function destory() : void
      {
         clearSlots();
         if(slotGroup && slotGroup.parent)
         {
            try { slotGroup.parent.removeChild(slotGroup); } catch(e:Error) {}
         }
         slotGroup = null;

         for each(var item:SelectedFighterUI in _uis)
         {
            if(item)
            {
               item.destory();
            }
         }
         _uis = [];
         _curUI = null;

         if(nameGroup)
         {
            if(nameGroup.parent)
            {
               try { nameGroup.parent.removeChild(nameGroup); } catch(e:Error) {}
            }
            nameGroup = null;
         }
      }

      public function addFighter(fighter:FighterVO = null) : void
      {
         if(!_curUI)
         {
            var newUI:SelectedFighterUI = new SelectedFighterUI(new _uiClass(), this.isP1);
            addChild(newUI.ui);
            if(newUI.nameTf)
            {
               nameGroup.addChild(newUI.nameTf);
            }
            _uis.push(newUI);
            _curUI = newUI;
            return;
         }

         if(fighter)
         {
            if(_totalCount > 1 && _pickedCount < _circleSlots.length)
            {
               var curSlot:CircleSlotUI = _circleSlots[_pickedCount];
               if(curSlot)
               {
                  curSlot.setFighter(fighter);
               }
               _pickedCount++;
            }
         }
      }

      public function removeLastFighter() : void
      {
         if(_pickedCount > 0 && _circleSlots.length > 0)
         {
            _pickedCount--;
            if(_pickedCount < _circleSlots.length)
            {
               var curSlot:CircleSlotUI = _circleSlots[_pickedCount];
               if(curSlot)
               {
                  curSlot.setFighter(null);
               }
            }
         }
      }

      public function updateFighter(fighter:FighterVO) : void
      {
         if(_curUI)
         {
            _curUI.setFighter(fighter);
         }
      }

      public function setAssist(assist:FighterVO) : void
      {
         if(!_assistSlot)
         {
            return;
         }
         _assistSlot.visible = true;
         _assistSlot.setFighter(assist);
      }

      public function clearAssist() : void
      {
         if(_assistSlot)
         {
            _assistSlot.clearFighter();
            _assistSlot.visible = false;
         }
      }

      public function showAssistSlot() : void
      {
         if(_assistSlot)
         {
            _assistSlot.visible = true;
         }
      }

      public function get assistSlot() : CircleSlotUI
      {
         return _assistSlot;
      }
   }
}
