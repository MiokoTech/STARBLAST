package net.play5d.game.bvn.views.effects
{
   import flash.geom.ColorTransform;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.data.EffectVO;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class SteelHitEffect extends EffectView
   {
      private var _fighter:FighterMain;
      
      public function SteelHitEffect(param1:EffectVO)
      {
         super(param1);
      }
      
      override public function setTarget(param1:IGameSprite) : void
      {
         var ct:ColorTransform;
         var v:IGameSprite = param1;
         super.setTarget(v);
         if(v is FighterMain)
         {
            _fighter = v as FighterMain;
            if(_fighter.isSteelBody)
            {
               ct = new ColorTransform();
               ct.redOffset = 150;
               ct.greenOffset = 150;
               ct.blueOffset = 150;
               if(_fighter.isSuperSteelBody)
               {
                  ct.blueOffset = 0;
                  EffectCtrl.I.shine(16776960,0.3);
               }
               _fighter.changeColor(ct);
               EffectCtrl.I.setOnFreezeOver(function():void
               {
                  _fighter.resumeColor();
               });
            }
         }
      }
   }
}

