package net.play5d.game.bvn.ui.select
{
   import flash.display.MovieClip;
   import net.play5d.game.bvn.data.AssisterModel;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.SelectVO;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.utils.KyoUtils;
   
   public class SelecterItemUI
   {
      public var ui:MovieClip;
      
      public var currentFighter:FighterVO;
      
      public var selectTimes:int;
      
      public var selectTimesCount:int = 1;
      
      public var inputType:String;
      
      public var group:SelectedFighterGroup;
      
      public var selectVO:SelectVO;
      
      public var isSelectAssist:Boolean;
      
      public var x:int;
      
      public var y:int;
      
      public var moreX:int = 0;
      
      public var moreY:int = 0;
      
      private var _moreEnable:Boolean = false;
      
      public var showingMoreSelecter:SelectFighterItem;
      
      public var enabled:Boolean = true;
      
      public var randoms:Vector.<FighterVO> = null;
      
      public var randFrame:int;
      
      public var touchHoverItem:SelectFighterItem;
      
      private var _playerType:int;
      
      public function SelecterItemUI(param1:int = 1)
      {
         super();
         _playerType = param1;
         ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.select,"select_item_mc") as MovieClip;
         ui.mouseEnabled = ui.mouseChildren = false;
         ui.mc.gotoAndStop(param1 == 1 ? 1 : 2);
      }
      
      public function selectFinish() : Boolean
      {
         return selectTimes >= selectTimesCount;
      }
      
      public function getCurrentSelectes() : Array
      {
         if(isSelectAssist)
         {
            return [selectVO.fuzhu];
         }
         return [selectVO.fighter1,selectVO.fighter2,selectVO.fighter3];
      }
      
      public function setCurrentSelect(param1:Array) : void
      {
         if(isSelectAssist)
         {
            selectVO.fuzhu = param1[0];
            group.updateFighter(AssisterModel.I.getAssister(selectVO.fuzhu));
         }
         else
         {
            selectVO.fighter1 = param1[0];
            selectVO.fighter2 = param1[1];
            selectVO.fighter3 = param1[2];
            group.updateFighter(FighterModel.I.getFighter(selectVO.fighter1));
            group.addFighter(FighterModel.I.getFighter(selectVO.fighter2));
            group.addFighter(FighterModel.I.getFighter(selectVO.fighter3));
         }
         selectTimes = selectTimesCount;
         enabled = false;
      }
      
      public function moreEnabled() : Boolean
      {
         return _moreEnable;
      }
      
      public function setMoreEnabled(param1:Boolean, param2:SelectFighterItem = null) : void
      {
         _moreEnable = param1;
         if(param1)
         {
            this.moreX = 0;
            this.moreY = 0;
            if(!param2)
            {
               throw Error("Need SelectFighterItem !!");
            }
            this.showingMoreSelecter = param2;
            if(this.showingMoreSelecter)
            {
               this.showingMoreSelecter.setMoreNumberVisible(false);
            }
         }
         else
         {
            if(this.showingMoreSelecter)
            {
               this.showingMoreSelecter.setMoreNumberVisible(true);
            }
            this.showingMoreSelecter = null;
         }
      }
      
      public function isSelected(param1:String) : Boolean
      {
         if(!selectVO)
         {
            return false;
         }
         if(isSelectAssist)
         {
            return selectVO.fuzhu == param1;
         }
         return selectVO.fighter1 == param1 || selectVO.fighter2 == param1 || selectVO.fighter3 == param1;
      }
      
      public function select(param1:Function = null) : void
      {
         var _this:*;
         var back:Function = param1;
         if(!selectVO)
         {
            throw new Error("未设置selectVO!");
         }
         if(isSelectAssist)
         {
            selectVO.fuzhu = currentFighter.id;
         }
         else
         {
            switch(selectTimes)
            {
               case 0:
                  selectVO.fighter1 = currentFighter.id;
                  break;
               case 1:
                  selectVO.fighter2 = currentFighter.id;
                  break;
               case 2:
                  selectVO.fighter3 = currentFighter.id;
            }
         }
         selectTimes++;
         if(!selectFinish())
         {
            group.addFighter(currentFighter);
         }
         enabled = false;
         _this = this;
         ui.gotoAndPlay("select");
         updateRandom();
         KyoUtils.addFrameScript(ui,function():void
         {
            if(!selectFinish())
            {
               enabled = true;
            }
            if(back != null)
            {
               back(_this);
            }
         });
      }
      
      public function moveTo(param1:Number, param2:Number) : void
      {
         ui.x = param1;
         ui.y = param2;
      }
      
      public function destory() : void
      {
         enabled = false;
         removeSelecter();
         removeGroup();
      }
      
      public function removeSelecter() : void
      {
         if(ui && ui.parent)
         {
            try
            {
               ui.parent.removeChild(ui);
            }
            catch(e:Error)
            {
            }
            ui = null;
         }
      }
      
      public function removeGroup() : void
      {
         if(group && group.parent)
         {
            try
            {
               group.parent.removeChild(group);
            }
            catch(e:Error)
            {
            }
            group = null;
         }
      }
      
      private function updateRandom() : void
      {
         if(!randoms)
         {
            return;
         }
         if(!selectVO)
         {
            return;
         }
         selectVO.fighter1 && removeRand(selectVO.fighter1);
         selectVO.fighter2 && removeRand(selectVO.fighter2);
         selectVO.fighter3 && removeRand(selectVO.fighter3);
      }
      
      private function removeRand(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = -1;
         while(_loc3_ < randoms.length)
         {
            if(randoms[_loc3_].id == param1)
            {
               _loc2_ = _loc3_;
               break;
            }
            _loc3_++;
         }
         if(_loc2_ != -1)
         {
            randoms.splice(_loc2_,1);
         }
      }
   }
}

