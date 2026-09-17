package net.play5d.game.bvn.ui
{
   import com.greensock.TweenLite;
   import flash.display.Sprite;
   import net.play5d.kyo.display.BitmapText;

   public class SetBtnLine extends Sprite
   {
      private var _txt:BitmapText;
      private var _line:Sprite;

      public function SetBtnLine(cn_y:int = 0)
      {
         super();
         mouseChildren = mouseEnabled = false;
         _line = new Sprite();
         addChild(_line);
         if(GameUI.SHOW_CN_TEXT)
         {
            _txt = new BitmapText();
            UIUtils.formatText(_txt.textfield,{
               "font":"黑体",
               "size":19
            });
            _txt.color = 16777215;
            _txt.y = cn_y;
            addChild(_txt);
         }
      }

      public function show(param1:Number, param2:String) : void
      {
         _line.graphics.clear();
         _line.graphics.lineStyle(1,16777215,1);
         _line.graphics.lineTo(param1,0);
         _line.scaleX = 0.1;
         TweenLite.to(_line,0.3,{"scaleX":0.7});
         this.visible = true;
         if(_txt)
         {
            _txt.width = width;
            _txt.x = -80;
            _txt.text = param2;
         }
      }

      public function hide() : void
      {
         this.visible = false;
      }
   }
}

