package net.play5d.game.bvn.fighter.ctrler
{
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.kyo.utils.KyoRandom;
   
   public class FighterVoiceCtrler
   {
      private var _voiceObj:Object = {};
      
      private var _channel:SoundChannel;
      
      private var _curLength:int;
      
      private var _soundTransform:SoundTransform;
      
      public function FighterVoiceCtrler()
      {
         super();
         _soundTransform = new SoundTransform();
         _soundTransform.volume = GameData.I.config.soundVolume;
      }
      
      public function destory() : void
      {
         if(_voiceObj)
         {
            _voiceObj = null;
         }
         if(_channel)
         {
            _channel.stop();
            _channel = null;
         }
      }
      
      public function setVoice(param1:int, param2:Array) : void
      {
         _voiceObj[param1] = param2;
      }
      
      public function playVoice(param1:int, param2:Number = 1) : void
      {
         var _loc5_:Class = null;
         var _loc4_:Sound = null;
         if(_channel && _channel.position < _curLength)
         {
            return;
         }
         if(Math.random() > param2)
         {
            return;
         }
         var _loc3_:Array = _voiceObj[param1];
         if(_loc3_ && _loc3_.length > 0)
         {
            _loc5_ = _loc3_.length > 1 ? KyoRandom.getRandomInArray(_loc3_) : _loc3_[0];
            if(_loc5_)
            {
               _loc4_ = new _loc5_();
               _curLength = _loc4_.length;
               _channel = _loc4_.play(0,0,_soundTransform);
            }
         }
      }
   }
}

