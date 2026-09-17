package net.play5d.game.bvn.ui
{
   import flash.display.DisplayObject;
   
   public interface IGameUI
   {
      function setVolume(param1:Number) : void;
      
      function destory() : void;
      
      function fadIn(param1:Boolean = true) : void;
      
      function fadOut(param1:Boolean = true) : void;
      
      function getUI() : DisplayObject;
      
      function render() : void;
      
      function renderAnimate() : void;
      
      function showHits(param1:int, param2:int) : void;
      
      function hideHits(param1:int) : void;
      
      function showStart(param1:Function = null, param2:Object = null) : void;
      
      function showEnd(param1:Function = null, param2:Object = null) : void;
      
      function clearStartAndEnd() : void;
      
      function pause() : void;
      
      function resume() : Boolean;
   }
}

