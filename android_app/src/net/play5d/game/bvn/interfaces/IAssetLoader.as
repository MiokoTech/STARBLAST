package net.play5d.game.bvn.interfaces
{
   public interface IAssetLoader
   {
      function loadXML(param1:String, param2:Function, param3:Function = null) : void;
      
      function loadJSON(param1:String, param2:Function, param3:Function = null) : void;
      
      function loadSwf(param1:String, param2:Function, param3:Function = null, param4:Function = null) : void;
      
      function loadSound(param1:String, param2:Function, param3:Function = null, param4:Function = null) : void;
      
      function loadBitmap(param1:String, param2:Function, param3:Function = null, param4:Function = null) : void;
      
      function dispose(param1:String) : void;
      
      function needPreLoad() : Boolean;
      
      function loadPreLoad(param1:Function, param2:Function = null, param3:Function = null) : void;
   }
}

