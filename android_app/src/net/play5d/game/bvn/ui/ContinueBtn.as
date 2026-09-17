package net.play5d.game.bvn.ui
{
   import flash.display.Sprite;
   import net.play5d.game.bvn.events.SetBtnEvent;
   
   public class ContinueBtn extends Sprite
   {
      private var _btnGroup:SetBtnGroup;
      
      private var _onClick:Function;
      
      public function ContinueBtn()
      {
         super();
         _btnGroup = new SetBtnGroup();
         _btnGroup.startX = 0;
         _btnGroup.startY = 0;
         _btnGroup.setBtnData([{
            "label":"CONTINUE",
            "cn":"继续游戏"
         }],2);
         addChild(_btnGroup);
      }
      
      public function onClick(param1:Function) : void
      {
         _onClick = param1;
         if(_btnGroup.hasEventListener("SELECT"))
         {
            return;
         }
         _btnGroup.addEventListener("SELECT",onBtnClick);
      }
      
      private function onBtnClick(param1:SetBtnEvent) : void
      {
         if(_onClick != null)
         {
            _onClick(this);
         }
      }
      
      public function destory() : void
      {
         if(_btnGroup)
         {
            _btnGroup.destory();
         }
      }
   }
}

