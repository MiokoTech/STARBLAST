package net.play5d.game.bvn.ui
{
   import flash.display.Sprite;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.input.GameInputer;
   
   public class MosouPauseDialog extends Sprite
   {
      private var _bg:Sprite;
      
      private var _btnGroup:SetBtnGroup;
      
      private var _moveList:MoveListSp;
      
      public function MosouPauseDialog()
      {
         super();
         _bg = new Sprite();
         _bg.graphics.beginFill(0,0.5);
         _bg.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
         _bg.graphics.endFill();
         addChild(_bg);
         _btnGroup = new SetBtnGroup();
         _btnGroup.setBtnData([{
            "label":"BACK MAP",
            "cn":"回大地图"
         },{
            "label":"MOVE LIST",
            "cn":"出招表"
         },{
            "label":"CONTINUE",
            "cn":"继续游戏"
         }],2);
         _btnGroup._isSubMenu = true;
         _btnGroup.addEventListener("SELECT",btnGroupSelectHandler);
         addChild(_btnGroup);
      }
      
      public function destory() : void
      {
         GameRender.remove(render, this);
         if(_btnGroup)
         {
            _btnGroup.removeEventListener("SELECT",btnGroupSelectHandler);
            _btnGroup.destory();
            _btnGroup = null;
         }
         if(_moveList)
         {
            _moveList.destory();
            _moveList = null;
         }
      }
      
      public function isShowing() : Boolean
      {
         return visible;
      }
      
      public function show() : void
      {
         this.visible = true;
         _btnGroup.keyEnable = true;
         _btnGroup.setArrowIndex(2);
         GameRender.add(render, this);
         GameInputer.focus();
         GameInputer.enabled = true;
      }
      
      public function hide() : Boolean
      {
         if(_moveList && _moveList.isShowing())
         {
            hideMoveList();
            return false;
         }
         this.visible = false;
         _btnGroup.keyEnable = false;
         GameRender.remove(render, this);
         GameUI.closeConfrim();
         return true;
      }

      private function render() : void
      {
         if(!visible) return;
         if(GameUI.showingDialog()) return;
         if(_moveList && _moveList.isShowing()) return;

         if(_btnGroup)
         {
            _btnGroup.render();
         }
         if(GameInputer.back(1))
         {
            GameCtrl.I.resume(true);
         }
      }
      
      private function btnGroupSelectHandler(param1:SetBtnEvent) : void
      {
         var e:SetBtnEvent = param1;
         if(GameUI.showingDialog())
         {
            return;
         }
         switch(e.selectedLabel)
         {
            case "BACK MAP":
               _btnGroup.keyEnable = false;
               GameUI.confrim("BACK MAP?","返回到大地图？",function():void
               {
                  MainGame.I.goWorldMap();
                  GameEvent.dispatchEvent("MOSOU_BACK_MAP");
               },function():void
               {
                  _btnGroup.keyEnable = true;
               });
               break;
            case "MOVE LIST":
               showMoveList();
               GameEvent.dispatchEvent("PAUSE_GAME_MENU","movelist");
               break;
            case "CONTINUE":
               GameCtrl.I.resume(true);
         }
      }
      
      private function showMoveList() : void
      {
         if(!_moveList)
         {
            _moveList = new MoveListSp();
            _moveList.onBackSelect = hideMoveList;
            addChild(_moveList);
         }
         _btnGroup.keyEnable = false;
         _moveList.show();
      }
      
      private function hideMoveList() : void
      {
         _moveList.hide();
         _btnGroup.keyEnable = true;
         GameEvent.dispatchEvent("PAUSE_GAME_MENU","movelist-back");
      }
   }
}

