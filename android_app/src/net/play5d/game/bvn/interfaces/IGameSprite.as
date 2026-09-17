package net.play5d.game.bvn.interfaces
{
   import flash.display.DisplayObject;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.data.TeamVO;
   import net.play5d.game.bvn.fighter.models.HitVO;
   
   public interface IGameSprite
   {
      function get colorTransform() : ColorTransform;
      
      function set colorTransform(param1:ColorTransform) : void;
      
      function destory(param1:Boolean = true) : void;
      
      function isDestoryed() : Boolean;
      
      function render() : void;
      
      function renderAnimate() : void;
      
      function getDisplay() : DisplayObject;
      
      function get direct() : int;
      
      function set direct(param1:int) : void;
      
      function get x() : Number;
      
      function set x(param1:Number) : void;
      
      function get y() : Number;
      
      function set y(param1:Number) : void;
      
      function get team() : TeamVO;
      
      function set team(param1:TeamVO) : void;
      
      function hit(param1:HitVO, param2:IGameSprite) : void;
      
      function beHit(param1:HitVO, param2:Rectangle = null) : void;
      
      function getArea() : Rectangle;
      
      function getBodyArea() : Rectangle;
      
      function getCurrentHits() : Array;
      
      function allowCrossMapXY() : Boolean;
      
      function allowCrossMapBottom() : Boolean;
      
      function getIsTouchSide() : Boolean;
      
      function setIsTouchSide(param1:Boolean) : void;
      
      function setSpeedRate(param1:Number) : void;
      
      function setVolume(param1:Number) : void;
      
      function getActive() : Boolean;
      
      function setActive(param1:Boolean) : void;
   }
}

