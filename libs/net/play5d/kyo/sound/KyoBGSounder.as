package net.play5d.kyo.sound
{
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   
   public class KyoBGSounder
   {
      private static var _i:KyoBGSounder;
      
      public var sound:Object;
      
      public var playing:Boolean;
      
      private var _snd:Sound;
      
      private var _channel:SoundChannel;
      
      private var _soundTransform:SoundTransform = new SoundTransform();
      
      private var _channelPausePosition:int;
      
      public function KyoBGSounder()
      {
         super();
      }
      
      public static function get I() : KyoBGSounder
      {
         _i = _i || new KyoBGSounder();
         return _i;
      }
      
      public function get volume() : Number
      {
         return this._soundTransform.volume;
      }
      
      public function set volume(param1:Number) : void
      {
         this._soundTransform.volume = param1;
         if(this._channel)
         {
            this._channel.soundTransform = this._soundTransform;
         }
      }
      
      public function play(param1:Object = null, param2:Boolean = true) : void
      {
         trace("bgm play");
         if(this._snd)
         {
            return;
         }
         if(!param1)
         {
            param1 = this.sound;
         }
         if(param1)
         {
            this.sound = param1;
            if(this.sound is String)
            {
               this._snd = new Sound(new URLRequest(this.sound as String));
            }
            if(this.sound is Class)
            {
               this._snd = new this.sound();
            }
            if(this.sound is Sound)
            {
               this._snd = this.sound as Sound;
            }
            this.playsnd(0,param2);
            this.playing = true;
            return;
         }
         trace("没有可播放的音乐");
      }
      
      public function stop() : void
      {
         trace("bgm stop");
         if(this._channel)
         {
            this._channel.stop();
            this._channel = null;
         }
         if(this._snd)
         {
            try
            {
               this._snd.close();
            }
            catch(e:Error)
            {
               trace("KyoBGSounder",e);
            }
            this._snd = null;
         }
         this.playing = false;
      }
      
      public function pause() : void
      {
         trace("bgm pause");
         if(this._channel)
         {
            this._channelPausePosition = this._channel.position;
            this._channel.stop();
         }
      }
      
      public function resume() : void
      {
         trace("bgm resume");
         if(this._channel)
         {
            this.playsnd(this._channelPausePosition);
         }
      }
      
      public function toogle() : void
      {
         if(this.playing)
         {
            this.stop();
         }
         else
         {
            this.play();
         }
      }
      
      private function playsnd(param1:int = 0, param2:Boolean = true) : void
      {
         if(!this._snd)
         {
            return;
         }
         this._channel = this._snd.play(param1,1,this._soundTransform);
         this._channel.removeEventListener(Event.SOUND_COMPLETE,this.playCompleteHandler);
         if(param2)
         {
            this._channel.addEventListener(Event.SOUND_COMPLETE,this.playCompleteHandler);
         }
      }
      
      private function playCompleteHandler(param1:Event) : void
      {
         if(this._channel)
         {
            this._channel.removeEventListener(Event.SOUND_COMPLETE,this.playCompleteHandler);
            this._channel = null;
         }
         this.playsnd(0);
      }
   }
}

