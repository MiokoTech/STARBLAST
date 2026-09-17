package net.play5d.game.bvn.mob.input
{
   import net.play5d.kyo.utils.KyoUtils;
   
   public class JoyStickConfigVO
   {
      public var deviceId:String;
      
      public var deviceIsSet:Boolean = false;
      
      public var up2:JoyStickSetVO = new JoyStickSetVO(1,0.5);
      
      public var down2:JoyStickSetVO = new JoyStickSetVO(1,-0.5);
      
      public var left2:JoyStickSetVO = new JoyStickSetVO(0,-0.5);
      
      public var right2:JoyStickSetVO = new JoyStickSetVO(0,0.5);
      
      public var up:JoyStickSetVO = new JoyStickSetVO(16,1);
      
      public var down:JoyStickSetVO = new JoyStickSetVO(17,1);
      
      public var left:JoyStickSetVO = new JoyStickSetVO(18,1);
      
      public var right:JoyStickSetVO = new JoyStickSetVO(19,1);
      
      public var attack:JoyStickSetVO = new JoyStickSetVO(6,1);
      
      public var jump:JoyStickSetVO = new JoyStickSetVO(4,1);
      
      public var dash:JoyStickSetVO = new JoyStickSetVO(5,1);
      
      public var skill:JoyStickSetVO = new JoyStickSetVO(7,1);
      
      public var superSkill:JoyStickSetVO = new JoyStickSetVO(9,1);
      
      public var special:JoyStickSetVO = new JoyStickSetVO(8,1);
      
      public var waikai:JoyStickSetVO = new JoyStickSetVO(10,1);
      
      public var back:JoyStickSetVO = new JoyStickSetVO(12,1);
      
      public var select:JoyStickSetVO = new JoyStickSetVO(13,1);
      
      public function JoyStickConfigVO()
      {
         super();
      }
      
      public function readObj(param1:Object) : void
      {
         var _loc3_:Object = null;
         for(var _loc2_:String in param1)
         {
            _loc3_ = param1[_loc2_];
            if(this.hasOwnProperty(_loc2_))
            {
               if(this[_loc2_] is JoyStickSetVO)
               {
                  (this[_loc2_] as JoyStickSetVO).readObj(_loc3_);
               }
               else
               {
                  this[_loc2_] = _loc3_;
               }
            }
         }
      }
      
      public function toObj() : Object
      {
         var _loc1_:* = undefined;
         var _loc3_:Array = KyoUtils.getItemVaribles(this);
         var _loc4_:Object = {};
         for each(var _loc2_:String in _loc3_)
         {
            _loc1_ = this[_loc2_];
            if(_loc1_ is JoyStickSetVO)
            {
               _loc4_[_loc2_] = (this[_loc2_] as JoyStickSetVO).toObj();
            }
            else
            {
               _loc4_[_loc2_] = this[_loc2_];
            }
         }
         return KyoUtils.itemToObject(this);
      }
   }
}

