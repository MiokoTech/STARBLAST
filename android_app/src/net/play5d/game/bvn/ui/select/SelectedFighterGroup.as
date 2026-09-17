package net.play5d.game.bvn.ui.select
{
   import com.greensock.TweenLite;
   import flash.display.Sprite;
   import net.play5d.game.bvn.data.FighterVO;
   
   public class SelectedFighterGroup extends Sprite
   {
      private var _uiClass:Class;
      
      private var _uis:Array = [];
      
      private var _curUI:SelectedFighterUI;
      
      public function SelectedFighterGroup(uiClass:Class)
      {
         super();
         _uiClass = uiClass;
      }
      
      // Bersihkan seluruh slot tampilan karakter
      public function destory() : void
      {
         for each(var item:SelectedFighterUI in _uis)
         {
            if(item)
            {
               item.destory();
            }
         }
         _uis = [];
         _curUI = null;
      }
      
      // Tambahkan slot karakter baru ke tumpukan grup
      public function addFighter(fighter:FighterVO = null) : void
      {
         // Kunci slot sebelumnya agar tidak terhapus dan tidak menerima hover baru
         if(_curUI)
         {
            if(fighter)
            {
               _curUI.setFighter(fighter);
            }
            _curUI.freeze();
            _curUI = null;
         }

         var prevUI:SelectedFighterUI = null;
         var i:int = 0;
         var stepY:Number = 20 - (_uis.length - 1) * 3;
         var startY:Number = _uis.length * -20;
         var startAlpha:Number = 0.7 - (_uis.length - 1) * 0.3;
         var startScale:Number = 0.85 - (_uis.length - 1) * 0.15;
         while(i < _uis.length)
         {
            prevUI = _uis[i];
            TweenLite.to(prevUI.ui,0.1,{
               "y":startY,
               "alpha":startAlpha,
               "scaleX":startScale,
               "scaleY":startScale
            });
            startY += stepY;
            startAlpha += 0.3;
            startScale += 0.15;
            i++;
         }

         var newUI:SelectedFighterUI = new SelectedFighterUI(new _uiClass());
         newUI.ui.y = 50;
         TweenLite.to(newUI.ui,0.1,{
            "y":0,
            "delay":0.05
         });
         addChild(newUI.ui);
         _uis.push(newUI);
         _curUI = newUI;
      }
      
      // Perbarui preview karakter yang sedang diarahkan kursor
      public function updateFighter(fighter:FighterVO) : void
      {
         if(_curUI)
         {
            _curUI.setFighter(fighter);
         }
      }
   }
}

