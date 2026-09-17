package net.play5d.game.bvn.data
{
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.interfaces.IExtendConfig;
   import net.play5d.kyo.utils.KyoUtils;
   
   public class ConfigVO implements ISaveData
   {
      public const key_menu:KeyConfigVO = new KeyConfigVO(0);
      
      public const key_p1:KeyConfigVO = new KeyConfigVO(1);
      
      public const key_p2:KeyConfigVO = new KeyConfigVO(2);
      
      public var select_config:SelectStageConfigVO = new SelectStageConfigVO();
      
      public var difficulty:int = 4;
      
      public var player1:int = 1;
      
      public var player2:int = 1;
      
      public var rounds:int = 2;
      
      public var fighterHP:Number = 1;
      
      public var fightTime:int = 60;
      
      public var quality:String = "medium";
      
      public var soundVolume:Number = 0.7;
      
      public var bgmVolume:Number = 0.7;
      
      public var keyInputMode:int = 1;
      
      public var cameraZoomRate:Number = 0.7;
      
      public var cameraDistance:Number = 2.5;

      public var cameraStyle:int = GameConfig.CAMERA_STYLE_BVN;
      
      public var legacyAssetScaleMode:int = GameConfig.LEGACY_SCALE_MODE_AUTO;

      public var pixelStyleMode:Boolean = true;

      public var shadowEnabled:Boolean = true;

      public var qiGainRate:Number = 1;

      public var bishaEnergyMax:int = 3;

      public var gameplayStyle:int = GameConfig.GAMEPLAY_STYLE_BVN;

      public var extendConfig:IExtendConfig;
      
      public function ConfigVO()
      {
         super();
         extendConfig = GameInterface.instance.getConfigExtend();
         setDefaultConfig(key_menu);
         setDefaultConfig(key_p1);
         setDefaultConfig(key_p2);
      }
      
      public function setDefaultConfig(param1:KeyConfigVO) : void
      {
         switch(param1.id)
         {
            case 0:
               param1.setKeys(87,83,65,68,74,75,76,85,73,79);
               break;
            case 1:
               param1.setKeys(87,83,65,68,74,75,76,85,73,79);
               break;
            case 2:
               param1.setKeys(38,40,37,39,97,98,99,100,101,102);
         }
      }
      
      public function toSaveObj() : Object
      {
         var _loc1_:Object = {};
         _loc1_.key_p1 = key_p1.toSaveObj();
         _loc1_.key_p2 = key_p2.toSaveObj();
         _loc1_.difficulty = difficulty;
         _loc1_.player1 = player1;
         _loc1_.player2 = player2;
         _loc1_.rounds = rounds;
         _loc1_.fighterHP = fighterHP;
         _loc1_.fightTime = fightTime;
         _loc1_.quality = quality;
         _loc1_.keyInputMode = keyInputMode;
         _loc1_.soundVolume = soundVolume;
         _loc1_.bgmVolume = bgmVolume;
         _loc1_.cameraZoomRate = cameraZoomRate;
         _loc1_.cameraDistance = cameraDistance;
         _loc1_.cameraStyle = cameraStyle;
         _loc1_.legacyAssetScaleMode = legacyAssetScaleMode;
         _loc1_.pixelStyleMode = pixelStyleMode;
         _loc1_.shadowEnabled = shadowEnabled;
         _loc1_.qiGainRate = qiGainRate;
         _loc1_.bishaEnergyMax = bishaEnergyMax;
         _loc1_.gameplayStyle = gameplayStyle;
         if(extendConfig)
         {
            _loc1_.extend_config = extendConfig.toSaveObj();
         }
         return _loc1_;
      }
      
      public function readSaveObj(param1:Object) : void
      {
         key_p1.readSaveObj(param1.key_p1);
         key_p2.readSaveObj(param1.key_p2);
         if(param1.extend_config && extendConfig)
         {
            extendConfig.readSaveObj(param1.extend_config);
         }
         delete param1["key_p1"];
         delete param1["key_p2"];
         delete param1["forceFourByThreeViewport"];
         if(param1.bishaEnergyMax == undefined && param1.bishaStart != undefined)
         {
            param1.bishaEnergyMax = param1.bishaStart;
         }
         delete param1["bishaStart"];
         KyoUtils.setValueByObject(this,param1);
      }
      
      public function getValueByKey(param1:String) : *
      {
         if(this.hasOwnProperty(param1))
         {
            return this[param1];
         }
         if(extendConfig)
         {
            try
            {
               return extendConfig[param1];
            }
            catch(e:Error)
            {
            }
         }
         return null;
      }
      
      public function setValueByKey(param1:String, param2:*) : void
      {
         if(this.hasOwnProperty(param1))
         {
            this[param1] = param2;
            switch(param1)
            {
               case "bgmVolume":
                  SoundCtrl.I.setBgmVolumn(bgmVolume);
                  break;
               case "soundVolume":
                  SoundCtrl.I.setSoundVolumn(soundVolume);
                  break;
               case "shadowEnabled":
                  GameConfig.SHADOW_ENABLED = Boolean(shadowEnabled);
            }
            return;
         }
         if(extendConfig)
         {
            try
            {
               extendConfig[param1] = param2;
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public function applyConfig() : void
      {
         if(legacyAssetScaleMode < GameConfig.LEGACY_SCALE_MODE_OFF || legacyAssetScaleMode > GameConfig.LEGACY_SCALE_MODE_FORCE_800X600)
         {
            legacyAssetScaleMode = GameConfig.LEGACY_SCALE_MODE_AUTO;
         }
         bishaEnergyMax = int(bishaEnergyMax);
         if(bishaEnergyMax < 1 || bishaEnergyMax > 5)
         {
            bishaEnergyMax = 3;
         }
         if(qiGainRate < 0.1 || qiGainRate > 5)
         {
            qiGainRate = 1;
         }
         cameraStyle = int(cameraStyle);
         if(cameraStyle < GameConfig.CAMERA_STYLE_BVN || cameraStyle > GameConfig.CAMERA_STYLE_STARBLAST)
         {
            cameraStyle = GameConfig.CAMERA_STYLE_BVN;
         }
         gameplayStyle = GameConfig.GAMEPLAY_STYLE_BVN;
         GameConfig.PIXEL_STYLE_MODE = pixelStyleMode;
         GameConfig.SHADOW_ENABLED = shadowEnabled;
         GameConfig.LEGACY_ASSET_SCALE_MODE = legacyAssetScaleMode;
         GameConfig.CAMERA_STYLE = cameraStyle;
         GameConfig.QI_GAIN_RATE = qiGainRate;
         GameConfig.BISHA_ENERGY_MAX = bishaEnergyMax;
         GameConfig.applyGameplayStyle(gameplayStyle);
         switch(quality)
         {
            case "low":
               GameConfig.QUALITY_GAME = "low";
               GameConfig.setGameFps(30);
               GameConfig.FPS_SHINE_EFFECT = 15;
               EffectCtrl.EFFECT_SMOOTHING = false;
               break;
            case "medium":
               GameConfig.QUALITY_GAME = "low";
               GameConfig.setGameFps(60);
               GameConfig.FPS_SHINE_EFFECT = 30;
               EffectCtrl.EFFECT_SMOOTHING = false;
               break;
            case "high":
               GameConfig.QUALITY_GAME = "medium";
               GameConfig.setGameFps(60);
               GameConfig.FPS_SHINE_EFFECT = 30;
               EffectCtrl.EFFECT_SMOOTHING = false;
               break;
            case "higher":
               GameConfig.QUALITY_GAME = "high";
               GameConfig.setGameFps(60);
               GameConfig.FPS_SHINE_EFFECT = 30;
               EffectCtrl.EFFECT_SMOOTHING = true;
               break;
            case "best":
               GameConfig.QUALITY_GAME = "high";
               GameConfig.setGameFps(60);
               GameConfig.FPS_SHINE_EFFECT = 60;
               EffectCtrl.EFFECT_SMOOTHING = true;
         }
         if(GameConfig.PIXEL_STYLE_MODE)
         {
            EffectCtrl.EFFECT_SMOOTHING = false;
         }
         GameInterface.instance.applyConfig(this);
         SoundCtrl.I.setBgmVolumn(bgmVolume);
         SoundCtrl.I.setSoundVolumn(soundVolume);
      }
   }
}

