package net.play5d.kyo.stage.effect
{
   import net.play5d.kyo.stage.Istage;
   
   public interface IStageFadEffect
   {
      function fadIn(param1:Istage, param2:Function = null) : void;
      
      function fadOut(param1:Istage, param2:Function = null) : void;
   }
}

