package com.adobe.crypto
{
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.prng.Random;
   import com.hurlant.crypto.symmetric.ICipher;
   import com.hurlant.crypto.symmetric.IPad;
   import com.hurlant.crypto.symmetric.IVMode;
   import com.hurlant.util.Base64;
   import com.hurlant.util.Hex;
   import flash.utils.ByteArray;
   
   public class AES
   {
      public static const DEFAULT_CIPHER_NAME:String = "aes-128-cbc";
      
      public static const DEFAULT_PADNAME:String = "pkcs5";
      
      public static const NULL_PADDING:String = "null";
      
      private static const RAND:Random = new Random();
      
      private var _name:String;
      
      private var _key:ByteArray;
      
      private var _iv:ByteArray;
      
      private var _padName:String;
      
      private var _enc:ICipher;
      
      private var _dec:ICipher;
      
      public function AES(param1:ByteArray, param2:ByteArray = null, param3:String = "aes-128-cbc", param4:String = "pkcs5")
      {
         super();
         this._name = param3;
         this._key = param1;
         this._iv = param2;
         this._padName = param4;
         this.init();
      }
      
      public static function generateKey(param1:String) : ByteArray
      {
         var _loc2_:uint = Crypto.getKeySize(param1);
         var _loc3_:ByteArray = new ByteArray();
         RAND.nextBytes(_loc3_,_loc2_);
         return _loc3_;
      }
      
      public static function generateIV(param1:String, param2:ByteArray) : ByteArray
      {
         var _loc3_:ICipher = Crypto.getCipher(param1,param2);
         var _loc4_:ByteArray = new ByteArray();
         RAND.nextBytes(_loc4_,_loc3_.getBlockSize());
         return _loc4_;
      }
      
      private function init() : void
      {
         var _loc2_:IVMode = null;
         var _loc3_:IVMode = null;
         var _loc1_:IPad = Crypto.getPad(this._padName);
         this._enc = Crypto.getCipher(this._name,this._key,_loc1_);
         this._dec = Crypto.getCipher(this._name,this._key,_loc1_);
         if(this.iv)
         {
            if(this._enc is IVMode)
            {
               _loc2_ = this._enc as IVMode;
               _loc2_.IV = this.iv;
            }
            if(this._dec is IVMode)
            {
               _loc3_ = this._dec as IVMode;
               _loc3_.IV = this.iv;
            }
         }
      }
      
      public function encrypt(param1:ByteArray) : ByteArray
      {
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:ByteArray = new ByteArray();
         _loc2_.writeBytes(param1,0,param1.length);
         this._enc.encrypt(param1);
         _loc3_.writeBytes(param1,0,param1.length);
         param1.length = 0;
         param1.writeBytes(_loc2_,0,_loc2_.length);
         _loc2_.clear();
         return _loc3_;
      }
      
      public function decrypt(param1:ByteArray) : ByteArray
      {
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:ByteArray = new ByteArray();
         _loc2_.writeBytes(param1,0,param1.length);
         this._dec.decrypt(param1);
         _loc3_.writeBytes(param1,0,param1.length);
         param1.length = 0;
         param1.writeBytes(_loc2_,0,_loc2_.length);
         _loc2_.clear();
         return _loc3_;
      }
      
      public function encryptString(param1:String) : ByteArray
      {
         if(!param1 || !param1.length)
         {
            return null;
         }
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         return this.encrypt(_loc2_);
      }
      
      public function encryptString2Hex(param1:String) : String
      {
         var _loc2_:ByteArray = this.encryptString(param1);
         return Hex.fromArray(_loc2_);
      }
      
      public function encryptString2Base64(param1:String) : String
      {
         var _loc2_:ByteArray = this.encryptString(param1);
         return Base64.encodeByteArray(_loc2_);
      }
      
      public function decryptString(param1:String) : ByteArray
      {
         if(!param1 || !param1.length)
         {
            return null;
         }
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         return this.decrypt(_loc2_);
      }
      
      public function decryptString2Hex(param1:String) : String
      {
         var _loc2_:ByteArray = this.decryptString(param1);
         return Hex.fromArray(_loc2_);
      }
      
      public function decryptString2Base64(param1:String) : String
      {
         var _loc2_:ByteArray = this.decryptString(param1);
         return Base64.encodeByteArray(_loc2_);
      }
      
      public function set iv(param1:ByteArray) : void
      {
         this._iv = param1;
      }
      
      public function get iv() : ByteArray
      {
         return this._iv;
      }
   }
}

