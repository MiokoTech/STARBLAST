package net.play5d.game.bvn.ui.dialog
{
   import com.greensock.TweenLite;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.MainGame;
   
   public class DialogManager
   {
      private static var _dialogBG:Sprite;
      
      private static var _showingDialogs:Vector.<BaseDialog> = new Vector.<BaseDialog>();
      
      public function DialogManager()
      {
         super();
      }
      
      public static function showingDialog() : Boolean
      {
         return _showingDialogs.length > 0;
      }
      
      private static function addDialogBg() : void
      {
         var _loc1_:BitmapData = null;
         if(!_dialogBG)
         {
            _loc1_ = new BitmapData(1,1,false,0);
            _dialogBG = new Sprite();
            _dialogBG.graphics.beginBitmapFill(_loc1_,null,true,false);
            _dialogBG.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
            _dialogBG.graphics.endFill();
            _dialogBG.alpha = 0.7;
         }
         MainGame.I.root.addChild(_dialogBG);
      }
      
      public static function showDialog(param1:BaseDialog, param2:Boolean = true) : void
      {
         if(param2 && _showingDialogs.length > 0)
         {
            for each(var d:BaseDialog in _showingDialogs)
            {
               d.hide();
            }
         }
         else
         {
            addDialogBg();
         }
         var _loc4_:Number = param1.width > 0 ? (GameConfig.GAME_SIZE.x - param1.width) / 2 : 0;
         var _loc5_:Number = param1.height > 0 ? (GameConfig.GAME_SIZE.y - param1.height) / 2 : 0;
         param1.show(_loc4_,_loc5_);
         fadIn(param1);
         _showingDialogs.push(param1);
      }
      
      public static function closeDialog(param1:BaseDialog) : void
      {
         var v:BaseDialog = param1;
         var tweenBack:* = function():void
         {
            var _loc1_:BaseDialog = null;
            var _loc2_:int = int(_showingDialogs.indexOf(v));
            if(_loc2_ != -1)
            {
               _showingDialogs.splice(_loc2_,1);
            }
            if(_showingDialogs.length < 1)
            {
               try
               {
                  MainGame.I.root.removeChild(_dialogBG);
               }
               catch(e:Error)
               {
               }
            }
            else
            {
               _loc1_ = _showingDialogs[_showingDialogs.length - 1];
               if(_loc1_.hiding())
               {
                  _loc1_.resume();
               }
               addDialogBg();
               fadIn(_loc1_);
            }
         };
         fadOut(v,tweenBack);
      }
      
      private static function fadIn(param1:BaseDialog, param2:Function = null) : void
      {
         var d:BaseDialog = param1;
         var back:Function = param2;
         var view:DisplayObject = d.getDisplay();
         var y:Number = view.y;
         view.alpha = 0;
         view.y -= 10;
         MainGame.I.root.addChild(d.getDisplay());
         TweenLite.to(view,0.3,{
            "y":y,
            "alpha":1,
            "onComplete":function():void
            {
               d.init();
               if(back != null)
               {
                  back();
               }
            }
         });
      }
      
      private static function fadOut(param1:BaseDialog, param2:Function) : void
      {
         var d:BaseDialog = param1;
         var back:Function = param2;
         var view:DisplayObject = d.getDisplay();
         TweenLite.to(view,0.2,{
            "y":view.y - 10,
            "alpha":0,
            "onComplete":function():void
            {
               d.close();
               d.destory();
               try
               {
                  MainGame.I.root.removeChild(d.getDisplay());
               }
               catch(e:Error)
               {
               }
            }
         });
         if(back != null)
         {
            back();
         }
      }
   }
}

