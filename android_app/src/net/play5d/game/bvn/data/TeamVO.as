package net.play5d.game.bvn.data
{
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class TeamVO
   {
      public var id:int;
      
      public var name:String;
      
      public var children:Vector.<IGameSprite> = new Vector.<IGameSprite>();
      
      public function TeamVO(param1:int, param2:String = null)
      {
         super();
         this.id = param1;
         this.name = param2;
      }
      
      public function getAliveChildren() : Vector.<IGameSprite>
      {
         var _loc3_:int = 0;
         var _loc2_:IGameSprite = null;
         var _loc1_:Vector.<IGameSprite> = new Vector.<IGameSprite>();
         while(_loc3_ < children.length)
         {
            _loc2_ = children[_loc3_];
            if(_loc2_ is BaseGameSprite)
            {
               if((_loc2_ as BaseGameSprite).isAlive)
               {
                  _loc1_.push(_loc2_);
               }
            }
            else
            {
               _loc1_.push(_loc2_);
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function addChild(param1:IGameSprite) : void
      {
         var _loc2_:int = int(children.indexOf(param1));
         if(_loc2_ == -1)
         {
            children.push(param1);
         }
      }
      
      public function removeChild(param1:IGameSprite) : void
      {
         var _loc2_:int = int(children.indexOf(param1));
         if(_loc2_ != -1)
         {
            children.splice(_loc2_,1);
         }
      }
   }
}

