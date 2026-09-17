package net.play5d.game.bvn.utils
{
   import com.adobe.crypto.AES;
   import com.adobe.crypto.MD5;
   import com.hurlant.util.Hex;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class GameEncriptUtils
   {
      public function GameEncriptUtils()
      {
         super();
      }
      
      public static function encript(param1:ByteArray) : String
      {
         return hashBytes(param1);
      }
      
      public static function getFileMD5(param1:ByteArray) : String
      {
         return hashBytes(param1);
      }
      
      private static function hashBytes(param1:ByteArray) : String
      {
         var _loc2_:* = null;
         var _loc3_:int = int(param1.length);
         var _loc4_:int = getTimer();
         if(_loc3_ < 2048)
         {
            _loc2_ = param1;
         }
         else
         {
            _loc2_ = new ByteArray();
            _loc2_.writeBytes(param1,0,1024);
            _loc2_.writeBytes(param1,_loc3_ - 1024,1024);
         }
         return MD5.hashBinary(_loc2_);
      }
      
      public static function encriptAES(param1:Object, param2:String, param3:String) : ByteArray
      {
         var _loc4_:ByteArray = null;
         var _loc6_:ByteArray = Hex.toArray(param2);
         var _loc7_:ByteArray = Hex.toArray(param3);
         var _loc8_:AES = new AES(_loc6_,_loc7_,"aes-128-cbc","null");
         if(param1 is String)
         {
            _loc4_ = new ByteArray();
            _loc4_.writeUTFBytes(param1 as String);
         }
         if(param1 is ByteArray)
         {
            _loc4_ = param1 as ByteArray;
         }
         return _loc8_.encrypt(_loc4_);
      }
      
      public static function decryptAES(param1:ByteArray, param2:String, param3:String) : String
      {
         var _loc4_:ByteArray = decryptAESBytes(param1,param2,param3);
         _loc4_.position = 0;
         return _loc4_.readUTFBytes(_loc4_.length);
      }
      
      public static function decryptAESBytes(param1:ByteArray, param2:String, param3:String) : ByteArray
      {
         var _loc5_:ByteArray = Hex.toArray(param2);
         var _loc6_:ByteArray = Hex.toArray(param3);
         var _loc7_:AES = new AES(_loc5_,_loc6_,"aes-128-cbc","null");
         return _loc7_.decrypt(param1);
      }
   }
}

