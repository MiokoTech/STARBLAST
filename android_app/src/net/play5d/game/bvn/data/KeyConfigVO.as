package net.play5d.game.bvn.data
{
   import net.play5d.kyo.utils.KyoUtils;
   
   public class KeyConfigVO
   {
      public var id:int;
      
      public var up:uint;
      
      public var down:uint;
      
      public var left:uint;
      
      public var right:uint;
      
      public var attack:uint;
      
      public var jump:uint;
      
      public var dash:uint;
      
      public var skill:uint;
      
      public var superKill:uint;
      
      public var beckons:uint;
      
      public var selects:Array;
      
      public var l2:uint;
      
      public function KeyConfigVO(param1:int)
      {
         super();
         this.id = param1;
      }
      
      public function setKeys(param1:uint, param2:uint, param3:uint, param4:uint, param5:uint, param6:uint, param7:uint, param8:uint, param9:uint, param10:uint) : void
      {
         this.up = param1;
         this.down = param2;
         this.left = param3;
         this.right = param4;
         this.attack = param5;
         this.jump = param6;
         this.dash = param7;
         this.skill = param8;
         this.dash = param7;
         this.superKill = param9;
         this.beckons = param10;
         if(!selects)
         {
            selects = [param5];
         }
      }
      
      public function toSaveObj() : Object
      {
         var _loc1_:Object = KyoUtils.itemToObject(this);
         delete _loc1_["id"];
         return _loc1_;
      }
      
      public function readSaveObj(param1:Object) : void
      {
         KyoUtils.setValueByObject(this,param1);
      }
      
      public function clone() : KeyConfigVO
      {
         var _loc2_:Object = toSaveObj();
         var _loc1_:KeyConfigVO = new KeyConfigVO(id);
         _loc1_.readSaveObj(_loc2_);
         return _loc1_;
      }
   }
}

