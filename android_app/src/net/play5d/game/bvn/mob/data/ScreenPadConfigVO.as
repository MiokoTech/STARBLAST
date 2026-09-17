package net.play5d.game.bvn.mob.data
{
   public class ScreenPadConfigVO
   {
      public var joyMode:int = 1;
      
      public var joyAlpha:Number = 0.7;
      
      public var joySet:Object;
      
      public var wankaiAutoHide:Boolean = true;
      
      public var specialAutoHide:Boolean = true;
      
      public var superSkillAutoHide:Boolean = true;
      
      public function ScreenPadConfigVO()
      {
         super();
      }
      
      public function toObj() : Object
      {
         return {
            "joyMode":joyMode,
            "joyAlpha":joyAlpha,
            "joySet":joySet,
            "wankaiAutoHide":wankaiAutoHide,
            "specialAutoHide":specialAutoHide,
            "superSkillAutoHide":superSkillAutoHide
         };
      }
      
      public function readObj(param1:Object) : void
      {
         if(!param1)
         {
            return;
         }
         if(param1.joyMode != undefined)
         {
            joyMode = param1.joyMode;
         }
         if(param1.joyAlpha != undefined)
         {
            joyAlpha = param1.joyAlpha;
         }
         if(param1.joySet != undefined)
         {
            joySet = param1.joySet;
         }
         if(param1.wankaiAutoHide != undefined)
         {
            wankaiAutoHide = param1.wankaiAutoHide;
         }
         if(param1.specialAutoHide != undefined)
         {
            specialAutoHide = param1.specialAutoHide;
         }
         if(param1.superSkillAutoHide != undefined)
         {
            superSkillAutoHide = param1.bishaAutoHide;
         }
      }
      
      public function setValueByKey(param1:String, param2:Object) : void
      {
         if(this.hasOwnProperty(param1))
         {
            this[param1] = param2;
         }
      }
   }
}

