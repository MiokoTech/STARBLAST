package net.play5d.game.bvn.ui.fight
{
   import flash.display.DisplayObject;
   import flash.filters.DropShadowFilter;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.kyo.display.BitmapText;
   
   public class FighterHpBar
   {
      private var _ui:*;
      
      private var _bar:DisplayObject;
      
      private var _redbar:DisplayObject;
      
      private var _fighter:FighterMain;
      
      private var _hprate:Number = 1;
      
      private var _redBarMoving:Boolean;
      
      private var _redBarMoveDelay:int;
      
      private var _justHurtFly:Boolean;
      
      private var _hpText:BitmapText;
      
      private var _damageText:BitmapText;
      
      private var _direct:int;
      
      public function FighterHpBar(param1:*)
      {
         super();
         _ui = param1;
         _bar = _ui.bar;
         _redbar = _ui.redbar;
         if(GameUI.SHOW_HP_TEXT)
         {
            _hpText = new BitmapText(true,16777215,[new DropShadowFilter()]);
            _hpText.font = "Arial";
            _hpText.x = 120;
            _hpText.y = 2;
            param1.addChild(_hpText);
            _damageText = new BitmapText(true,16776960,[new DropShadowFilter()]);
            _damageText.font = "Arial";
            _damageText.x = 10;
            _damageText.y = 2;
            _damageText.visible = false;
            param1.addChild(_damageText);
         }
      }
      
      public function get ui() : DisplayObject
      {
         return _ui;
      }
      
      public function setDirect(param1:int) : void
      {
         _direct = param1;
         if(param1 < 0)
         {
            if(_hpText)
            {
               _hpText.scaleX = -1;
            }
            if(_damageText)
            {
               _damageText.scaleX = -1;
               _damageText.x = 40;
            }
         }
      }
      
      public function destory() : void
      {
         _fighter = null;
         if(_hpText)
         {
            _hpText.destory();
            _hpText = null;
         }
         if(_damageText)
         {
            _damageText.destory();
            _damageText = null;
         }
      }
      
      public function setFighter(param1:FighterMain) : void
      {
         _fighter = param1;
      }
      
      public function render() : void
      {
         var _loc5_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc1_:Number = _fighter.hp / _fighter.hpMax;
         if(_redBarMoving && _loc1_ != _hprate)
         {
            _redbar.scaleX = _hprate;
            _redBarMoving = false;
         }
         _hprate = _loc1_;
         var _loc4_:Number = _hprate - _bar.scaleX;
         var _loc3_:Number = _loc4_ < 0 ? 0.4 : 0.04;
         if(Math.abs(_loc4_) < 0.01)
         {
            _bar.scaleX = _hprate;
         }
         else
         {
            _bar.scaleX += _loc4_ * _loc3_;
         }
         switch(_fighter.actionState - 21)
         {
            case 0:
               _redBarMoveDelay = 100;
               break;
            case 1:
            case 2:
               if(_redBarMoveDelay > 0)
               {
                  if(!_justHurtFly)
                  {
                     _redBarMoveDelay = 1.5 * GameConfig.FPS_GAME;
                     _justHurtFly = true;
                  }
                  else if(_redBarMoveDelay > 0)
                  {
                     _redBarMoveDelay--;
                  }
               }
               break;
            default:
               _redBarMoveDelay = 0;
               _justHurtFly = false;
         }
         if(_redBarMoveDelay <= 0)
         {
            _loc5_ = _hprate - _redbar.scaleX;
            _loc2_ = _loc5_ < 0 ? 0.1 : 0.02;
            if(Math.abs(_loc5_) < 0.01)
            {
               _redbar.scaleX = _hprate;
               _redBarMoving = false;
            }
            else
            {
               _redbar.scaleX += _loc5_ * _loc2_;
               _redBarMoving = true;
            }
         }
         if(_hpText)
         {
            _hpText.text = _fighter.hp.toString();
         }
         if(_damageText)
         {
            if(_fighter.currentHurtDamage() > 0)
            {
               _damageText.text = "-" + _fighter.currentHurtDamage().toString();
               _damageText.visible = true;
            }
            else
            {
               _damageText.visible = false;
            }
         }
      }
   }
}

