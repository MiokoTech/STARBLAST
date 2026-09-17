package net.play5d.game.bvn.ui.dialog.select
{
   import com.greensock.TweenLite;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.mosou.MosouFighterModel;
   import net.play5d.game.bvn.data.mosou.MosouFighterSellVO;
   import net.play5d.game.bvn.utils.BtnUtils;
   import net.play5d.game.bvn.utils.TouchMoveEvent;
   import net.play5d.game.bvn.utils.TouchUtils;
   
   public class SelectFighterList extends Sprite
   {
      private var _fighterItems:Vector.<SelectFighterUI>;
      
      public var onSelectFighter:Function;
      
      public var onChangePage:Function;
      
      private var _scrollY:Number = 0;
      
      private var _width:Number = 385;
      
      private var _height:Number = 405;
      
      private var _listHeight:Number = 0;
      
      private var _listCt:Sprite;
      
      private var _curPage:int;
      
      private var _totalPage:int;
      
      public function SelectFighterList()
      {
         super();
         this.graphics.beginBitmapFill(new BitmapData(1,1,true,0));
         this.graphics.drawRect(0,0,_width,_height);
         this.graphics.endFill();
         _listCt = new Sprite();
         addChild(_listCt);
         _listCt.scrollRect = new Rectangle(0,0,_width,_height);
         build();
         listenEvents();
      }
      
      private function build() : void
      {
         var i:int;
         var sv:MosouFighterSellVO;
         var isInTeam:Boolean;
         var ui:SelectFighterUI;
         var X:int;
         var Y:int;
         var j:int;
         var fighters:Vector.<MosouFighterSellVO> = MosouFighterModel.I.fighters;
         var currentFighterIds:Array = GameData.I.mosouData.getFighterTeamIds();
         _fighterItems = new Vector.<SelectFighterUI>();
         while(i < fighters.length)
         {
            sv = fighters[i];
            isInTeam = false;
            if(currentFighterIds.indexOf(sv.id) == -1)
            {
               ui = new SelectFighterUI(sv);
               BtnUtils.btnMode(ui.ui);
               BtnUtils.initBtn(ui.ui,selectHandler,ui);
               _fighterItems.push(ui);
               _listCt.addChild(ui.ui);
            }
            i++;
         }
         _fighterItems.sort(function(param1:SelectFighterUI, param2:SelectFighterUI):int
         {
            if(!param1.isBought() && param2.isBought())
            {
               return 1;
            }
            if(param1.isBought() && !param2.isBought())
            {
               return -1;
            }
            return 0;
         });
         X = 10;
         Y = 10;
         _totalPage = 1;
         _curPage = 1;
         while(j < _fighterItems.length)
         {
            _fighterItems[j].ui.x = X + _width * (_totalPage - 1);
            _fighterItems[j].ui.y = Y;
            X += 80;
            if(X > _width)
            {
               X = 10;
               Y += 80;
            }
            if(Y > _height - 10)
            {
               _totalPage++;
               X = 10;
               Y = 10;
            }
            j++;
         }
         _listHeight = Y;
      }
      
      public function destory() : void
      {
         this.removeEventListener("mouseWheel",mouseHandler);
         TouchUtils.I.unlistenOneFinger(this);
      }
      
      private function listenEvents() : void
      {
         if(GameConfig.TOUCH_MODE)
         {
            TouchUtils.I.listenOneFinger(this,touchHandler,true,false);
         }
         else
         {
            this.addEventListener("mouseWheel",mouseHandler);
         }
      }
      
      public function update() : void
      {
         for each(var i:SelectFighterUI in _fighterItems)
         {
            i.updateUI();
         }
      }
      
      private function scroll(param1:Number) : void
      {
         scrollTo(_scrollY + param1);
      }
      
      private function scrollTo(param1:Number) : void
      {
         var v:Number = param1;
         var obj:Object = {
            "x":_listCt.scrollRect.x,
            "y":0
         };
         TweenLite.to(obj,0.3,{
            "x":v,
            "onUpdate":function():void
            {
               _listCt.scrollRect = new Rectangle(obj.x,obj.y,_width,_height);
            }
         });
      }
      
      private function selectHandler(param1:SelectFighterUI) : void
      {
         var _loc2_:* = false;
         for each(var i:SelectFighterUI in _fighterItems)
         {
            _loc2_ = i == param1;
            i.select(_loc2_);
            if(_loc2_ && onSelectFighter != null)
            {
               onSelectFighter(i);
            }
         }
      }
      
      private function mouseHandler(param1:MouseEvent) : void
      {
         if(param1.delta < 0)
         {
            setPage(_curPage + 1);
         }
         else
         {
            setPage(_curPage - 1);
         }
      }
      
      private function touchHandler(param1:TouchMoveEvent) : void
      {
         if(param1.type == "EVENT_TOUCH_END")
         {
            if(param1.distanceX > 50)
            {
               setPage(_curPage - 1);
            }
            if(param1.distanceX < -50)
            {
               setPage(_curPage + 1);
            }
         }
      }
      
      public function getPage() : int
      {
         return _curPage;
      }
      
      public function setPage(param1:int) : void
      {
         if(param1 < 1)
         {
            return;
         }
         if(param1 > getTotalPage())
         {
            return;
         }
         _curPage = param1;
         scrollTo((param1 - 1) * _width);
         if(onChangePage != null)
         {
            onChangePage();
         }
      }
      
      public function getTotalPage() : int
      {
         return _totalPage;
      }
   }
}

