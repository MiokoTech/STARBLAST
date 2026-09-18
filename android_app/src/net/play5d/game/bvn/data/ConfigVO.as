package net.play5d.game.bvn.data
{
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.fighter.LocalCoordManager;
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

      public var spriteStyle:int = GameConfig.SPRITE_STYLE_LOCALCOORD;

      public var shadowEnabled:Boolean = true;

      public var qiGainRate:Number = 1;

      public var bishaEnergyMax:int = 3;

      public var gameplayStyle:int = GameConfig.GAMEPLAY_STYLE_BVN;

      public var assisterPartner:Boolean = true;

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
         var saveData:Object = {};
         saveData.key_p1 = key_p1.toSaveObj();
         saveData.key_p2 = key_p2.toSaveObj();
         saveData.difficulty = difficulty;
         saveData.player1 = player1;
         saveData.player2 = player2;
         saveData.rounds = rounds;
         saveData.fighterHP = fighterHP;
         saveData.fightTime = fightTime;
         saveData.quality = quality;
         saveData.keyInputMode = keyInputMode;
         saveData.soundVolume = soundVolume;
         saveData.bgmVolume = bgmVolume;
         saveData.cameraZoomRate = cameraZoomRate;
         saveData.cameraDistance = cameraDistance;
         saveData.cameraStyle = cameraStyle;
         saveData.legacyAssetScaleMode = legacyAssetScaleMode;
         saveData.pixelStyleMode = pixelStyleMode;
         saveData.shadowEnabled = shadowEnabled;
         saveData.qiGainRate = qiGainRate;
         saveData.bishaEnergyMax = bishaEnergyMax;
         saveData.gameplayStyle = gameplayStyle;
         saveData.assisterPartner = assisterPartner;
         if(extendConfig)
         {
            saveData.extend_config = extendConfig.toSaveObj();
         }
         return saveData;
      }
      
      public function readSaveObj(saveObj:Object) : void
      {
         key_p1.readSaveObj(saveObj.key_p1);
         key_p2.readSaveObj(saveObj.key_p2);
         if(saveObj.extend_config && extendConfig)
         {
            extendConfig.readSaveObj(saveObj.extend_config);
         }
         delete saveObj["key_p1"];
         delete saveObj["key_p2"];
         delete saveObj["forceFourByThreeViewport"];
         if(saveObj.bishaEnergyMax == undefined && saveObj.bishaStart != undefined)
         {
            saveObj.bishaEnergyMax = saveObj.bishaStart;
         }
         delete saveObj["bishaStart"];
         KyoUtils.setValueByObject(this,saveObj);
      }
      
      public function getValueByKey(key:String) : *
      {
         if(this.hasOwnProperty(key))
         {
            return this[key];
         }
         if(extendConfig)
         {
            try
            {
               return extendConfig[key];
            }
            catch(e:Error)
            {
            }
         }
         return null;
      }
      
      public function setValueByKey(key:String, value:*) : void
      {
         if(this.hasOwnProperty(key))
         {
            this[key] = value;
            switch(key)
            {
               case "bgmVolume":
                  SoundCtrl.I.setBgmVolumn(bgmVolume);
                  break;
               case "soundVolume":
                  SoundCtrl.I.setSoundVolumn(soundVolume);
                  break;
               case "shadowEnabled":
                  GameConfig.SHADOW_ENABLED = Boolean(shadowEnabled);
                  break;
               case "spriteStyle":
                  GameConfig.SPRITE_STYLE = int(spriteStyle);
                  LocalCoordManager.spriteStyle = int(spriteStyle);
                  break;
            }
            return;
         }
         if(extendConfig)
         {
            try
            {
               extendConfig[key] = value;
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
          spriteStyle = int(spriteStyle);
          if(spriteStyle < GameConfig.SPRITE_STYLE_LOCALCOORD || spriteStyle > GameConfig.SPRITE_STYLE_ORIGINAL)
          {
             spriteStyle = GameConfig.SPRITE_STYLE_LOCALCOORD;
          }
          GameConfig.SPRITE_STYLE = spriteStyle;
          LocalCoordManager.spriteStyle = spriteStyle;
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

