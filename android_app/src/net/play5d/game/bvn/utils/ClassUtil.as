package net.play5d.game.bvn.utils
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   
   public class ClassUtil
   {
      public function ClassUtil()
      {
         super();
      }
      
      public static function getClassProperty(param1:Class) : Array
      {
         var _loc6_:Array;
         var _loc3_:*;
         var _loc5_:XML = null;
         var _loc2_:XMLList = null;
         var _loc4_:String = null;
         if(param1 == null)
         {
            return null;
         }
         _loc6_ = [];
         try
         {
            _loc5_ = describeType(param1);
            _loc2_ = _loc5_.factory.variable;
         }
         catch(e:Error)
         {
            trace("转换失败！");
         }
         if(_loc2_ == null)
         {
            return null;
         }
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.@name;
            _loc6_.push(_loc4_);
         }
         return _loc6_;
      }
      
      public static function getClassName(param1:*) : String
      {
         if(param1 == null)
         {
            return null;
         }
         return getQualifiedClassName(param1);
      }
      
      public static function getClassEventMethod(param1:*) : Array
      {
         var _loc7_:Array;
         var _loc11_:String;
         var _loc8_:String;
         var _loc9_:*;
         var _loc10_:XML = null;
         var _loc4_:XMLList = null;
         var _loc2_:String = null;
         var _loc12_:XMLList = null;
         var _loc5_:XML = null;
         var _loc3_:String = null;
         var _loc6_:String = null;
         if(param1 == null)
         {
            return null;
         }
         _loc7_ = [];
         try
         {
            _loc10_ = describeType(param1);
            _loc4_ = _loc10_.method;
         }
         catch(e:Error)
         {
            trace("转换失败！");
         }
         if(_loc4_ == null)
         {
            return null;
         }
         _loc11_ = getClassName(param1);
         _loc8_ = getClassName(Event);
         for each(_loc9_ in _loc4_)
         {
            _loc2_ = _loc9_.@declaredBy;
            if(_loc2_ == _loc11_)
            {
               _loc12_ = _loc9_.parameter;
               if(_loc12_.length() == 1)
               {
                  _loc5_ = _loc12_[0];
                  _loc3_ = _loc5_.@type;
                  if(_loc3_ == _loc8_)
                  {
                     _loc6_ = _loc9_.@name;
                     _loc7_.push(_loc6_);
                  }
               }
            }
         }
         return _loc7_;
      }
      
      public static function removeAllEventListener(param1:DisplayObject, param2:Function = null) : void
      {
         var _loc3_:Function = null;
         if(param1 == null || !param1.hasEventListener("enterFrame"))
         {
            return;
         }
         var _loc5_:Array = getClassEventMethod(param1);
         if(_loc5_ == null)
         {
            return;
         }
         for each(var _loc4_:String in _loc5_)
         {
            _loc3_ = param1[_loc4_] as Function;
            if(!(_loc3_ == null || !param1.hasEventListener("enterFrame")))
            {
               param1.removeEventListener("enterFrame",_loc3_);
               if(param2 != null)
               {
                  param2(_loc4_);
               }
            }
         }
      }
      
      public static function continuousAccess(param1:*, param2:Array = null) : *
      {
         var len:int;
         var i:int;
         var nextNode:String;
         var BRACKET:String;
         var nodeNameLen:int;
         var _loc7_:*;
         var begin:* = param1;
         var list:Array = param2;
         var check:* = function(param1:String):Boolean
         {
            return begin.hasOwnProperty(param1);
         };
         if(begin == null)
         {
            return null;
         }
         if(list == null || list.length == 0)
         {
            return begin;
         }
         len = int(list.length);
         i = 0;
         while(true)
         {
            if(i >= len)
            {
               return begin;
            }
            nextNode = list[i] as String;
            if(nextNode == null)
            {
               return null;
            }
            try
            {
               if(nextNode.indexOf(BRACKET) == -1)
               {
                  if(!check(nextNode))
                  {
                     return null;
                  }
                  if(begin[nextNode] != null)
                  {
                     begin = begin[nextNode];
                  }
               }
               else
               {
                  nodeNameLen = nextNode.length - BRACKET.length;
                  nextNode = nextNode.substr(0,nodeNameLen);
                  if(!check(nextNode))
                  {
                     return null;
                  }
                  if(begin[nextNode]() != null)
                  {
                     begin = begin[nextNode]();
                  }
               }
            }
            catch(e:Error)
            {
               trace("ClassUtil.continuousAccess::" + e);
               _loc7_ = null;
               break;
            }
            i++;
         }
         return _loc7_;
      }
   }
}

