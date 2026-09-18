package net.play5d.game.bvn.data
{
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.geom.Point;
   import net.play5d.game.bvn.fighter.LocalCoordManager;
   
   public class ExternalCharacterConfigLoader
   {
      private static const ROOT_FOLDER_NAME:String = "STARBLAST";
      
      private static const CHARACTER_LIST_FILE_NAME:String = "character.conf";
      
      private static const CHARACTERS_FOLDER_NAME:String = "characters";
      
      private static const CHARACTER_CONFIG_FILE_NAME:String = "character.json";
      
      private static const CHARACTER_CONFIG_ALT_FILE_NAME:String = "character.conf";
      
      private static const CONFIG_SECTION_CHARACTER:String = "character";
      
      private static const CONFIG_SECTION_ASSIST:String = "assist";
      
      public function ExternalCharacterConfigLoader()
      {
         super();
      }
      
      public static function loadFromInternalStorage() : ExternalCharacterConfigResult
      {
         ensureStorageStructure();
         var result:ExternalCharacterConfigResult = new ExternalCharacterConfigResult();
         var starblastRootFolder:File = File.userDirectory.resolvePath(ROOT_FOLDER_NAME);
         var characterListFile:File = starblastRootFolder.resolvePath(CHARACTER_LIST_FILE_NAME);
         var characterFolderNameList:Array = parseCharacterFolderList(characterListFile);
         var loadedFighterIDMap:Object = {};
         var selectableFighterIDMap:Object = {};
         for each(var characterFolderName:String in characterFolderNameList)
         {
            var characterConfig:Object = loadCharacterConfigObject(starblastRootFolder,characterFolderName);
            if(!characterConfig)
            {
               continue;
            }
            var fighterData:FighterVO = createFighterByConfig(characterConfig,characterFolderName);
            if(!fighterData || !fighterData.id)
            {
               continue;
            }
            if(!loadedFighterIDMap[fighterData.id])
            {
               result.fighterList.push(fighterData);
               loadedFighterIDMap[fighterData.id] = true;
            }
            if(shouldIncludeInSelect(characterConfig) && !selectableFighterIDMap[fighterData.id])
            {
               result.selectFighterIDs.push(fighterData.id);
               selectableFighterIDMap[fighterData.id] = true;
            }
         }
         return result;
      }
      
      private static function ensureStorageStructure() : void
      {
         try
         {
            var starblastRootFolder:File = File.userDirectory.resolvePath(ROOT_FOLDER_NAME);
            if(!starblastRootFolder.exists)
            {
               starblastRootFolder.createDirectory();
            }
            var charactersRootFolder:File = starblastRootFolder.resolvePath(CHARACTERS_FOLDER_NAME);
            if(!charactersRootFolder.exists)
            {
               charactersRootFolder.createDirectory();
            }
            var aiRootFolder:File = starblastRootFolder.resolvePath("ai");
            if(!aiRootFolder.exists)
            {
               aiRootFolder.createDirectory();
            }
            var characterListFile:File = starblastRootFolder.resolvePath(CHARACTER_LIST_FILE_NAME);
            if(!characterListFile.exists)
            {
               var templateText:String = "# STARBLAST character list\n[character]\n# one character folder per line\n# example_character_folder\n\n[assist]\n# one assist folder per line\n# example_assist_folder\n";
               writeTextFile(characterListFile,templateText);
            }
         }
         catch(e:Error)
         {
            trace("ExternalCharacterConfigLoader.ensureStorageStructure",e);
         }
      }
      
      private static function parseCharacterFolderList(characterListFile:File) : Array
      {
         var folderNameList:Array = [];
         var folderNameMap:Object = {};
         var listRaw:String = readTextFile(characterListFile);
         if(!listRaw)
         {
            return folderNameList;
         }
         var normalizedText:String = listRaw.split("\r").join("\n");
         var lines:Array = normalizedText.split("\n");
         var currentSection:String = CONFIG_SECTION_CHARACTER;
         for each(var rawLine:String in lines)
         {
            var lineText:String = trimText(rawLine);
            if(lineText.length < 1)
            {
               continue;
            }
            var hashCommentIndex:int = lineText.indexOf("#");
            if(hashCommentIndex == 0)
            {
               continue;
            }
            if(hashCommentIndex > 0)
            {
               lineText = trimText(lineText.substr(0,hashCommentIndex));
            }
            var semicolonCommentIndex:int = lineText.indexOf(";");
            if(semicolonCommentIndex == 0)
            {
               continue;
            }
            if(semicolonCommentIndex > 0)
            {
               lineText = trimText(lineText.substr(0,semicolonCommentIndex));
            }
            if(lineText.length < 1)
            {
               continue;
            }
            if(lineText.charAt(0) == "[" && lineText.charAt(lineText.length - 1) == "]")
            {
               var sectionName:String = trimText(lineText.substring(1,lineText.length - 1)).toLowerCase();
               if(sectionName == CONFIG_SECTION_CHARACTER || sectionName == CONFIG_SECTION_ASSIST)
               {
                  currentSection = sectionName;
               }
               continue;
            }
            if(currentSection != CONFIG_SECTION_CHARACTER)
            {
               continue;
            }
            var normalizedFolderName:String = normalizeFolderName(lineText);
            if(normalizedFolderName.length < 1)
            {
               continue;
            }
            if(!folderNameMap[normalizedFolderName])
            {
               folderNameList.push(normalizedFolderName);
               folderNameMap[normalizedFolderName] = true;
            }
         }
         return folderNameList;
      }
      
      private static function loadCharacterConfigObject(starblastRootFolder:File, characterFolderName:String) : Object
      {
         characterFolderName = normalizeFolderName(characterFolderName);
         if(characterFolderName.length < 1)
         {
            return null;
         }
         var characterFolder:File = starblastRootFolder.resolvePath(CHARACTERS_FOLDER_NAME + "/" + characterFolderName);
         if(!characterFolder.exists || !characterFolder.isDirectory)
         {
            trace("ExternalCharacterConfigLoader :: character folder missing",characterFolder.nativePath);
            return null;
         }
         var characterConfigFile:File = characterFolder.resolvePath(CHARACTER_CONFIG_FILE_NAME);
         if(characterConfigFile.exists)
         {
            var characterConfigByJSON:Object = parseCharacterConfigFile(characterConfigFile);
            if(characterConfigByJSON != null)
            {
               return characterConfigByJSON;
            }
         }
         var altConfigFile:File = characterFolder.resolvePath(CHARACTER_CONFIG_ALT_FILE_NAME);
         if(altConfigFile.exists)
         {
            var characterConfigByConf:Object = parseCharacterConfigFile(altConfigFile);
            if(characterConfigByConf != null)
            {
               return characterConfigByConf;
            }
         }
         var fallbackCharacterConfig:Object = buildFallbackCharacterConfig(characterFolder,characterFolderName);
         if(fallbackCharacterConfig == null)
         {
            trace("ExternalCharacterConfigLoader :: character config missing",characterConfigFile.nativePath);
         }
         return fallbackCharacterConfig;
      }
      
      private static function parseCharacterConfigFile(configFile:File) : Object
      {
         var configText:String = readTextFile(configFile);
         if(!configText)
         {
            return null;
         }
         try
         {
            return JSON.parse(configText);
         }
         catch(e:Error)
         {
            var parsedConfigByLine:Object = parseKeyValueConfigText(configText);
            if(parsedConfigByLine != null)
            {
               return parsedConfigByLine;
            }
            trace("ExternalCharacterConfigLoader :: parse config failed",configFile.nativePath,e);
         }
         return null;
      }
      
      private static function parseKeyValueConfigText(configText:String) : Object
      {
         if(configText == null)
         {
            return null;
         }
         var parsedConfig:Object = {};
         var hasAnyKey:Boolean = false;
         var normalizedText:String = configText.split("\r").join("\n");
         var lineList:Array = normalizedText.split("\n");
         for each(var rawLine:String in lineList)
         {
            var lineText:String = trimText(rawLine);
            if(lineText.length < 1)
            {
               continue;
            }
            if(lineText.charAt(0) == "#")
            {
               continue;
            }
            if(lineText.charAt(0) == ";")
            {
               continue;
            }
            if(lineText.charAt(0) == "[" && lineText.charAt(lineText.length - 1) == "]")
            {
               continue;
            }
            var equalSignIndex:int = lineText.indexOf("=");
            if(equalSignIndex <= 0)
            {
               equalSignIndex = lineText.indexOf(":");
            }
            if(equalSignIndex <= 0)
            {
               continue;
            }
            var keyName:String = trimText(lineText.substr(0,equalSignIndex));
            var keyValueText:String = trimText(lineText.substr(equalSignIndex + 1));
            if(keyName.length < 1)
            {
               continue;
            }
            parsedConfig[keyName] = keyValueText;
            hasAnyKey = true;
         }
         return hasAnyKey ? parsedConfig : null;
      }
      
      private static function buildFallbackCharacterConfig(characterFolder:File, characterFolderName:String) : Object
      {
         var fileList:Array = characterFolder.getDirectoryListing();
         if(fileList == null || fileList.length < 1)
         {
            return null;
         }
         var swfFilePath:String = findFallbackCharacterSwfPath(fileList,characterFolderName);
         if(swfFilePath == null || swfFilePath.length < 1)
         {
            return null;
         }
         var faceFilePath:String = findAssetPathByExtension(fileList,"png",characterFolderName);
         if(faceFilePath == null || faceFilePath.length < 1)
         {
            faceFilePath = findAssetPathByExtension(fileList,"jpg",characterFolderName);
         }
         var fallbackConfig:Object = {};
         fallbackConfig.id = characterFolderName;
         fallbackConfig.name = characterFolderName;
         fallbackConfig.swf = swfFilePath;
         if(faceFilePath != null && faceFilePath.length > 0)
         {
            fallbackConfig.face = faceFilePath;
            fallbackConfig.face_big = faceFilePath;
            fallbackConfig.face_bar = faceFilePath;
            fallbackConfig.face_win = faceFilePath;
         }
         var aiFilePath:String = findAssetPathByExtension(fileList,"cpu","ai");
         if(aiFilePath == null || aiFilePath.length < 1)
         {
            aiFilePath = findAssetPathByExtension(fileList,"cpu",characterFolderName);
         }
         if(aiFilePath == null || aiFilePath.length < 1)
         {
            aiFilePath = findAssetPathByExtension(fileList,"cpu",null);
         }
         if(aiFilePath == null || aiFilePath.length < 1)
         {
            aiFilePath = findAssetPathByExtension(fileList,"cns","ai");
         }
         if(aiFilePath == null || aiFilePath.length < 1)
         {
            aiFilePath = findAssetPathByExtension(fileList,"cns",characterFolderName);
         }
         if(aiFilePath == null || aiFilePath.length < 1)
         {
            aiFilePath = findAssetPathByExtension(fileList,"cmd","ai");
         }
         if(aiFilePath == null || aiFilePath.length < 1)
         {
            aiFilePath = findAssetPathByExtension(fileList,"cmd",characterFolderName);
         }
         if(aiFilePath != null && aiFilePath.length > 0)
         {
            fallbackConfig.ai = aiFilePath;
         }
         fallbackConfig.selectable = true;
         return fallbackConfig;
      }
      
      private static function findAssetPathByExtension(fileList:Array, extensionName:String, preferredBaseName:String) : String
      {
         if(fileList == null || extensionName == null)
         {
            return null;
         }
         var normalizedExtension:String = "." + extensionName.toLowerCase();
         var preferredFileName:String = preferredBaseName != null ? preferredBaseName.toLowerCase() + normalizedExtension : null;
         var candidateFile:File = null;
         for each(var assetFile:File in fileList)
         {
            if(assetFile == null || assetFile.isDirectory)
            {
               continue;
            }
            var lowerFileName:String = assetFile.name.toLowerCase();
            if(lowerFileName.indexOf(normalizedExtension,lowerFileName.length - normalizedExtension.length) == -1)
            {
               continue;
            }
            if(preferredFileName != null && lowerFileName == preferredFileName)
            {
               return assetFile.name;
            }
            if(candidateFile == null)
            {
               candidateFile = assetFile;
            }
         }
         return candidateFile != null ? candidateFile.name : null;
      }
      
      private static function findFallbackCharacterSwfPath(fileList:Array, characterFolderName:String) : String
      {
         if(fileList == null)
         {
            return null;
         }
         var swfFileNameList:Array = [];
         for each(var fileItem:File in fileList)
         {
            if(fileItem == null || fileItem.isDirectory)
            {
               continue;
            }
            var fileNameLower:String = fileItem.name.toLowerCase();
            if(fileNameLower.lastIndexOf(".swf") == fileNameLower.length - 4)
            {
               swfFileNameList.push(fileItem.name);
            }
         }
         if(swfFileNameList.length < 1)
         {
            return null;
         }
         var preferredFileName:String = findFileNameIgnoreCase(swfFileNameList,[characterFolderName + ".swf","fighter.swf","char.swf","character.swf","main.swf"]);
         if(preferredFileName != null)
         {
            return preferredFileName;
         }
         var folderNameLower:String = characterFolderName.toLowerCase();
         for each(var candidateFileName:String in swfFileNameList)
         {
            var candidateFileNameLower:String = candidateFileName.toLowerCase();
            if(candidateFileNameLower.indexOf(folderNameLower) != -1 || candidateFileNameLower.indexOf("fighter") != -1 || candidateFileNameLower.indexOf("char") != -1 || candidateFileNameLower.indexOf("main") != -1)
            {
               return candidateFileName;
            }
         }
         if(swfFileNameList.length == 1)
         {
            return swfFileNameList[0];
         }
         trace("ExternalCharacterConfigLoader :: ambiguous swf files, please set swf in character config",characterFolderName,swfFileNameList);
         return null;
      }
      
      private static function findFileNameIgnoreCase(fileNameList:Array, preferredNameList:Array) : String
      {
         if(fileNameList == null || preferredNameList == null)
         {
            return null;
         }
         for each(var preferredName:String in preferredNameList)
         {
            var preferredNameLower:String = preferredName.toLowerCase();
            for each(var currentFileName:String in fileNameList)
            {
               if(currentFileName != null && currentFileName.toLowerCase() == preferredNameLower)
               {
                  return currentFileName;
               }
            }
         }
         return null;
      }
      
      private static function createFighterByConfig(characterConfig:Object, characterFolderName:String) : FighterVO
      {
         var fighterID:String = firstNonEmptyString(characterConfig,["id","fighter_id"]);
         if(fighterID.length < 1)
         {
            fighterID = characterFolderName;
         }
         var fighterName:String = firstNonEmptyString(characterConfig,["name","display_name"]);
         if(fighterName.length < 1)
         {
            fighterName = fighterID;
         }
         var fighterFilePath:String = resolveCharacterAssetPath(firstNonEmptyString(characterConfig,["swf","file","file_url","swf_path"]),characterFolderName,fighterID + ".swf");
         if(!fighterFilePath || fighterFilePath.length < 1)
         {
            trace("ExternalCharacterConfigLoader :: swf path invalid",fighterID);
            return null;
         }
         var fighterData:FighterVO = new FighterVO();
         fighterData.id = fighterID;
         fighterData.name = fighterName;
         fighterData.comicType = readIntValue(characterConfig,["comic_type","comicType"],0);
         fighterData.fileUrl = fighterFilePath;
         var configuredStartFrame:int = readIntValue(characterConfig,["start_frame","startFrame"],1);
         if(configuredStartFrame < 1)
         {
            configuredStartFrame = 1;
         }
         fighterData.startFrame = configuredStartFrame;
         fighterData.faceUrl = resolveCharacterAssetPath(firstNonEmptyString(characterConfig,["face","face_url","face_small","face_small_url"]),characterFolderName,fighterID + ".png");
         fighterData.faceBigUrl = resolveCharacterAssetPath(firstNonEmptyString(characterConfig,["face_big","face_big_url","big_url"]),characterFolderName,fighterID + ".png");
         fighterData.faceBarUrl = resolveCharacterAssetPath(firstNonEmptyString(characterConfig,["face_bar","face_bar_url","bar_url"]),characterFolderName,fighterID + ".png");
         fighterData.faceWinUrl = resolveCharacterAssetPath(firstNonEmptyString(characterConfig,["face_win","face_win_url","win_url"]),characterFolderName,fighterID + ".png");
         fighterData.contactFriends = normalizeStringArray(characterConfig.hasOwnProperty("contact_friends") ? characterConfig["contact_friends"] : characterConfig["friend"]);
         fighterData.contactEnemys = normalizeStringArray(characterConfig.hasOwnProperty("contact_enemies") ? characterConfig["contact_enemies"] : characterConfig["enemy"]);
         fighterData.says = normalizeStringArray(characterConfig["says"]);
         applyBgmConfig(fighterData,characterConfig,characterFolderName);
         fighterData.aiLevelOverride = clampAILevel(readIntValue(characterConfig,["ai_level","aiLevel"],0));
         var customAiPath:String = firstNonEmptyString(characterConfig,["ai","ai_cpu","cpu","ai_file","ai_cmd","ai_path","aiFile"]);
         if(customAiPath && customAiPath.length > 0)
         {
            fighterData.aiFile = resolveCharacterAssetPath(customAiPath,characterFolderName,null);
         }
         var rawLocalCoord:* = characterConfig.hasOwnProperty("localcoord") ? characterConfig["localcoord"] : (characterConfig.hasOwnProperty("local_coord") ? characterConfig["local_coord"] : null);
         if(rawLocalCoord)
         {
            var parsedPoint:Point = null;
            if(rawLocalCoord is Array && (rawLocalCoord as Array).length >= 2)
            {
               var arrCoord:Array = rawLocalCoord as Array;
               var coordXVal:Number = Number(arrCoord[0]);
               var coordYVal:Number = Number(arrCoord[1]);
               if(coordXVal > 0 && coordYVal > 0)
               {
                  parsedPoint = new Point(coordXVal, coordYVal);
               }
            }
            else if(rawLocalCoord is String)
            {
               parsedPoint = LocalCoordManager.parseCoord(String(rawLocalCoord));
            }
            if(parsedPoint)
            {
               fighterData.localcoord = parsedPoint;
               LocalCoordManager.register(fighterID, parsedPoint.x, parsedPoint.y);
            }
         }
         return fighterData;
      }
      
      private static function applyBgmConfig(fighterData:FighterVO, characterConfig:Object, characterFolderName:String) : void
      {
         var bgmValue:* = characterConfig["bgm"];
         if(bgmValue is Object)
         {
            var bgmObject:Object = bgmValue as Object;
            fighterData.bgm = resolveCharacterAssetPath(firstNonEmptyString(bgmObject,["url","path"]),characterFolderName,null);
            fighterData.bgmRate = normalizeBgmRate(readNumberValue(bgmObject,["rate"],1));
            if(fighterData.bgm && fighterData.bgm.length > 0)
            {
               return;
            }
         }
         fighterData.bgm = resolveCharacterAssetPath(firstNonEmptyString(characterConfig,["bgm","bgm_url"]),characterFolderName,null);
         fighterData.bgmRate = normalizeBgmRate(readNumberValue(characterConfig,["bgm_rate","bgmRate"],1));
      }
      
      private static function normalizeBgmRate(rateValue:Number) : Number
      {
         if(isNaN(rateValue) || rateValue <= 0)
         {
            return 1;
         }
         if(rateValue > 1)
         {
            return rateValue / 100;
         }
         return rateValue;
      }
      
      private static function shouldIncludeInSelect(characterConfig:Object) : Boolean
      {
         if(readBooleanValue(characterConfig,["hidden"],false))
         {
            return false;
         }
         return readBooleanValue(characterConfig,["selectable","show_in_select"],true);
      }
      
      private static function clampAILevel(levelValue:int) : int
      {
         if(levelValue < 0)
         {
            return 0;
         }
         if(levelValue > 4)
         {
            return 4;
         }
         return levelValue;
      }
      
      private static function resolveCharacterAssetPath(rawAssetPath:String, characterFolderName:String, defaultFileName:String) : String
      {
         var assetPath:String = trimText(rawAssetPath);
         if(assetPath.length < 1 && defaultFileName != null)
         {
            assetPath = trimText(defaultFileName);
         }
         if(assetPath.length < 1)
         {
            return null;
         }
         var lowerAssetPath:String = assetPath.toLowerCase();
         if(lowerAssetPath.indexOf("http://") == 0 || lowerAssetPath.indexOf("https://") == 0 || lowerAssetPath.indexOf("file://") == 0)
         {
            return assetPath;
         }
         if(assetPath.indexOf("/") == 0 || assetPath.indexOf(ROOT_FOLDER_NAME + "/") == 0)
         {
            return assetPath;
         }
         return ROOT_FOLDER_NAME + "/" + CHARACTERS_FOLDER_NAME + "/" + characterFolderName + "/" + assetPath;
      }
      
      private static function firstNonEmptyString(sourceObject:Object, keyList:Array) : String
      {
         if(!sourceObject || !keyList)
         {
            return "";
         }
         for each(var keyName:String in keyList)
         {
            if(sourceObject.hasOwnProperty(keyName))
            {
               var valueText:String = trimText(String(sourceObject[keyName]));
               if(valueText.length > 0)
               {
                  return valueText;
               }
            }
         }
         return "";
      }
      
      private static function normalizeStringArray(rawValue:*) : Array
      {
         var valueList:Array = [];
         if(rawValue == null)
         {
            return valueList;
         }
         if(rawValue is Array)
         {
            for each(var itemValue:* in rawValue)
            {
               var itemText:String = trimText(String(itemValue));
               if(itemText.length > 0)
               {
                  valueList.push(itemText);
               }
            }
            return valueList;
         }
         var rawText:String = trimText(String(rawValue));
         if(rawText.length < 1)
         {
            return valueList;
         }
         var splitValues:Array = rawText.split(",");
         for each(var splitText:String in splitValues)
         {
            var normalizedText:String = trimText(splitText);
            if(normalizedText.length > 0)
            {
               valueList.push(normalizedText);
            }
         }
         return valueList;
      }
      
      private static function readIntValue(sourceObject:Object, keyList:Array, defaultValue:int) : int
      {
         var rawNumber:Number = readNumberValue(sourceObject,keyList,Number(defaultValue));
         if(isNaN(rawNumber))
         {
            return defaultValue;
         }
         return int(rawNumber);
      }
      
      private static function readNumberValue(sourceObject:Object, keyList:Array, defaultValue:Number) : Number
      {
         var textValue:String = firstNonEmptyString(sourceObject,keyList);
         if(textValue.length < 1)
         {
            return defaultValue;
         }
         var parsedValue:Number = Number(textValue);
         if(isNaN(parsedValue))
         {
            return defaultValue;
         }
         return parsedValue;
      }
      
      private static function readBooleanValue(sourceObject:Object, keyList:Array, defaultValue:Boolean) : Boolean
      {
         if(!sourceObject || !keyList)
         {
            return defaultValue;
         }
         for each(var keyName:String in keyList)
         {
            if(!sourceObject.hasOwnProperty(keyName))
            {
               continue;
            }
            var rawValue:* = sourceObject[keyName];
            if(rawValue is Boolean)
            {
               return Boolean(rawValue);
            }
            if(rawValue is Number)
            {
               return Number(rawValue) != 0;
            }
            var valueText:String = trimText(String(rawValue)).toLowerCase();
            if(valueText == "true" || valueText == "1" || valueText == "yes" || valueText == "on")
            {
               return true;
            }
            if(valueText == "false" || valueText == "0" || valueText == "no" || valueText == "off")
            {
               return false;
            }
         }
         return defaultValue;
      }
      
      private static function readTextFile(file:File) : String
      {
         if(!file || !file.exists || file.isDirectory)
         {
            return null;
         }
         var fileStream:FileStream = null;
         try
         {
            fileStream = new FileStream();
            fileStream.open(file,FileMode.READ);
            return fileStream.readUTFBytes(fileStream.bytesAvailable);
         }
         catch(e:Error)
         {
            trace("ExternalCharacterConfigLoader.readTextFile",file.nativePath,e);
            return null;
         }
         finally
         {
            if(fileStream)
            {
               try
               {
                  fileStream.close();
               }
               catch(closeError:Error)
               {
               }
            }
         }
         return null;
      }
      
      private static function writeTextFile(file:File, textValue:String) : void
      {
         var fileStream:FileStream = null;
         try
         {
            fileStream = new FileStream();
            fileStream.open(file,FileMode.WRITE);
            fileStream.writeUTFBytes(textValue);
         }
         catch(e:Error)
         {
            trace("ExternalCharacterConfigLoader.writeTextFile",file.nativePath,e);
         }
         finally
         {
            if(fileStream)
            {
               try
               {
                  fileStream.close();
               }
               catch(closeError:Error)
               {
               }
            }
         }
      }
      
      private static function trimText(sourceText:String) : String
      {
         if(!sourceText)
         {
            return "";
         }
         return sourceText.replace(/\uFEFF/g,"").replace(/^\s+|\s+$/g,"");
      }
      
      private static function normalizeFolderName(folderName:String) : String
      {
         var normalizedName:String = trimText(folderName);
         while(normalizedName.indexOf("/") == 0 || normalizedName.indexOf("\\") == 0)
         {
            normalizedName = normalizedName.substr(1);
         }
         while(normalizedName.length > 0 && (normalizedName.charAt(normalizedName.length - 1) == "/" || normalizedName.charAt(normalizedName.length - 1) == "\\"))
         {
            normalizedName = normalizedName.substr(0,normalizedName.length - 1);
         }
         return trimText(normalizedName);
      }
   }
}
