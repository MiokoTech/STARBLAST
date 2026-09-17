package net.play5d.game.bvn.views.effects
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import net.play5d.game.bvn.ctrl.AssetManager;
   
   public class BishaFaceEffectView
   {
      public var mc:MovieClip;
      
      private var _faceObj:Object = {};
      
      public function BishaFaceEffectView()
      {
         super();
         mc = AssetManager.I.getEffect("bisha_face_mc");
      }
      
      public function setFace(param1:int, param2:DisplayObject) : void
      {
         var _loc3_:MovieClip = mc["facemc" + param1];
         if(!_loc3_)
         {
            return;
         }
         _faceObj[param1] = param2;
         param2.width = 254;
         param2.height = 180;
         _loc3_.addChild(param2);
      }
      
      public function fadIn() : void
      {
         mc.gotoAndPlay(2);
      }
      
      public function destory() : void
      {
         for each(var i:DisplayObject in _faceObj)
         {
            if(i is Bitmap)
            {
               (i as Bitmap).bitmapData.dispose();
            }
         }
      }
   }
}

