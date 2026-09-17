package net.play5d.game.bvn.ui.mosou
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.text.TextField;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.ctrl.mosou_ctrls.MosouCtrl;
   import net.play5d.kyo.utils.KyoDrawUtils;
   
   public class MosouWaveUI
   {
      private var _ui:Sprite;
      
      private var _txtCur:TextField;
      
      private var _txtMax:TextField;
      
      private var _circleMc:Sprite;
      
      private var _circleBp:Bitmap;
      
      public function MosouWaveUI(param1:Sprite)
      {
         super();
         _ui = param1;
         _txtCur = param1.getChildByName("txt") as TextField;
         _txtMax = param1.getChildByName("txt_max") as TextField;
         _circleBp = new Bitmap();
         var _loc2_:Sprite = param1.getChildByName("ct_circle") as Sprite;
         _loc2_.addChild(_circleBp);
      }
      
      public function renderAnimate() : void
      {
         var _loc1_:MosouCtrl = GameCtrl.I.getMosouCtrl();
         _txtCur.text = _loc1_.currentWave.toString();
         _txtMax.text = _loc1_.waveCount.toString();
         renderCircle();
      }
      
      private function renderCircle() : void
      {
         var _loc2_:MosouCtrl = GameCtrl.I.getMosouCtrl();
         var _loc1_:* = _loc2_.getWavePercent() * 360 << 0;
         _circleBp.bitmapData = KyoDrawUtils.drawRing(10,29,_loc1_,[16776960,16711680],1);
      }
   }
}

