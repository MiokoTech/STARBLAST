package net.play5d.game.bvn.fighter.ctrler.ai
{
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.fighter.FighterMain;

   public class FighterAIProfileLoader
   {
      private static var _profileCache:Object = {};

      public function FighterAIProfileLoader()
      {
         super();
      }

      public static function getProfile(fighter:FighterMain) : FighterAIProfile
      {
         if(fighter == null || fighter.data == null)
         {
            return null;
         }
         var fighterData:FighterVO = fighter.data as FighterVO;
         if(fighterData == null || !fighterData.id)
         {
            return null;
         }
         var characterId:String = fighterData.id;
         if(_profileCache[characterId] !== undefined)
         {
            return _profileCache[characterId] as FighterAIProfile;
         }
         var loadedProfile:FighterAIProfile = loadProfileForFighter(fighterData);
         _profileCache[characterId] = loadedProfile;
         return loadedProfile;
      }

      public static function clearCache() : void
      {
         _profileCache = {};
      }

      private static function loadProfileForFighter(fighterData:FighterVO) : FighterAIProfile
      {
         var characterId:String = fighterData.id;
         var candidateFiles:Array = buildCandidateFileList(fighterData);
         for each(var targetFile:File in candidateFiles)
         {
            if(targetFile == null || !targetFile.exists || targetFile.isDirectory)
            {
               continue;
            }
            var fileContent:String = readTextFile(targetFile);
            if(!fileContent)
            {
               continue;
            }
            var profile:FighterAIProfile = parseProfileText(characterId,fileContent);
            if(profile != null && profile.hasContent())
            {
               return profile;
            }
         }
         return null;
      }

      private static function buildCandidateFileList(fighterData:FighterVO) : Array
      {
         var candidateList:Array = [];
         if(fighterData == null)
         {
            return candidateList;
         }
         var characterId:String = fighterData.id ? fighterData.id : "";
         var fileUrl:String = fighterData.fileUrl ? fighterData.fileUrl : "";
         var customAiFile:String = fighterData.aiFile ? fighterData.aiFile : "";
         var checkedDirectories:Object = {};
         
         try
         {
            var userDir:File = File.userDirectory;
            var starblastFolder:File = userDir != null ? userDir.resolvePath("STARBLAST") : null;

            // =========================================================================
            // 1. Explicit AI path from character config (if specified in character.json)
            // =========================================================================
            if(customAiFile.length > 0)
            {
               var explicitFile:File = null;
               if(customAiFile.charAt(0) == "/")
               {
                  explicitFile = new File(customAiFile);
               }
               else if(userDir != null && customAiFile.indexOf("STARBLAST/") == 0)
               {
                  explicitFile = userDir.resolvePath(customAiFile);
               }
               else if(starblastFolder != null && starblastFolder.exists)
               {
                  explicitFile = starblastFolder.resolvePath(customAiFile);
               }
               else if(userDir != null)
               {
                  explicitFile = userDir.resolvePath(customAiFile);
               }
               if(explicitFile != null)
               {
                  candidateList.push(explicitFile);
               }
            }

            // =========================================================================
            // 2. Character's OWN folder in internal storage: STARBLAST/characters/<char>/
            // =========================================================================
            // 2A. Deduced directly from SWF fileUrl (e.g. "STARBLAST/characters/ibuki/ibuki.swf")
            if(fileUrl.length > 0)
            {
               var normalizedUrl:String = fileUrl.replace(/\\/g,"/");
               var charactersMarker:String = "characters/";
               var charIdx:int = normalizedUrl.indexOf(charactersMarker);
               if(charIdx != -1)
               {
                  var subPath:String = normalizedUrl.substr(charIdx + charactersMarker.length);
                  var folderSlash:int = subPath.indexOf("/");
                  var extractedFolderName:String = folderSlash > 0 ? subPath.substr(0,folderSlash) : subPath;
                  if(extractedFolderName.length > 0 && starblastFolder != null && starblastFolder.exists)
                  {
                     var folderDirect:File = starblastFolder.resolvePath("characters/" + extractedFolderName);
                     addDirectoryCandidates(candidateList,folderDirect,characterId,extractedFolderName,checkedDirectories);
                  }
               }
               
               // SWF parent directory check
               var swfFileRef:File = null;
               if(normalizedUrl.charAt(0) == "/")
               {
                  swfFileRef = new File(normalizedUrl);
               }
               else if(userDir != null && normalizedUrl.indexOf("STARBLAST/") == 0)
               {
                  swfFileRef = userDir.resolvePath(normalizedUrl);
               }
               else if(userDir != null)
               {
                  swfFileRef = userDir.resolvePath(normalizedUrl);
               }
               if(swfFileRef != null && swfFileRef.parent != null)
               {
                  addDirectoryCandidates(candidateList,swfFileRef.parent,characterId,null,checkedDirectories);
               }
            }

            // 2B. Direct Character folder by ID: STARBLAST/characters/<characterId>/
            if(starblastFolder != null && starblastFolder.exists && characterId.length > 0)
            {
               var charFolderById:File = starblastFolder.resolvePath("characters/" + characterId);
               addDirectoryCandidates(candidateList,charFolderById,characterId,null,checkedDirectories);
            }

            // 2C. Direct Character folder without STARBLAST prefix: <userDir>/characters/<characterId>/
            if(userDir != null && characterId.length > 0)
            {
               var plainCharFolder:File = userDir.resolvePath("characters/" + characterId);
               addDirectoryCandidates(candidateList,plainCharFolder,characterId,null,checkedDirectories);
            }

            // =========================================================================
            // 3. Built-in character assets in File.applicationDirectory
            // =========================================================================
            var appDir:File = File.applicationDirectory;
            if(appDir != null)
            {
               if(fileUrl.length > 0)
               {
                  var swfDirUrl:String = fileUrl.replace(/\\/g,"/");
                  var lastSlashIndex:int = swfDirUrl.lastIndexOf("/");
                  var baseFolderPath:String = lastSlashIndex > 0 ? swfDirUrl.substr(0,lastSlashIndex) : "";
                  if(baseFolderPath.length > 0)
                  {
                     var appCharFolder:File = appDir.resolvePath(baseFolderPath.indexOf("assets/") == 0 ? baseFolderPath : "assets/" + baseFolderPath);
                     addDirectoryCandidates(candidateList,appCharFolder,characterId,null,checkedDirectories);
                  }
               }
               if(characterId.length > 0)
               {
                  var appDirectCharFolder:File = appDir.resolvePath("assets/characters/" + characterId);
                  addDirectoryCandidates(candidateList,appDirectCharFolder,characterId,null,checkedDirectories);
               }
            }

            // =========================================================================
            // 4. Fallback global AI folders (ONLY used if character folder has no AI)
            // =========================================================================
            if(starblastFolder != null && starblastFolder.exists && characterId.length > 0)
            {
               var centralAiFolder:File = starblastFolder.resolvePath("ai");
               if(centralAiFolder.exists)
               {
                  candidateList.push(centralAiFolder.resolvePath(characterId + ".cpu"));
                  candidateList.push(centralAiFolder.resolvePath("ai.cpu"));
                  candidateList.push(centralAiFolder.resolvePath(characterId + ".cns"));
                  candidateList.push(centralAiFolder.resolvePath(characterId + ".cmd"));
                  candidateList.push(centralAiFolder.resolvePath(characterId + ".json"));
                  candidateList.push(centralAiFolder.resolvePath(characterId + ".conf"));
                  candidateList.push(centralAiFolder.resolvePath(characterId + "_ai.json"));
               }
            }
            if(appDir != null && characterId.length > 0)
            {
               var assetsAiFolder:File = appDir.resolvePath("assets/data/ai");
               if(assetsAiFolder.exists)
               {
                  candidateList.push(assetsAiFolder.resolvePath(characterId + ".cpu"));
                  candidateList.push(assetsAiFolder.resolvePath("ai.cpu"));
                  candidateList.push(assetsAiFolder.resolvePath(characterId + ".cns"));
                  candidateList.push(assetsAiFolder.resolvePath(characterId + ".cmd"));
                  candidateList.push(assetsAiFolder.resolvePath(characterId + ".json"));
                  candidateList.push(assetsAiFolder.resolvePath(characterId + "_ai.json"));
               }
            }
         }
         catch(fileListError:Error)
         {
            trace("FighterAIProfileLoader.buildCandidateFileList error:",fileListError);
         }
         return candidateList;
      }

      private static function addDirectoryCandidates(candidateList:Array, targetDirectory:File, characterId:String, folderName:String, checkedDirectories:Object) : void
      {
         if(candidateList == null || targetDirectory == null || !targetDirectory.exists || !targetDirectory.isDirectory)
         {
            return;
         }
         var dirKey:String = targetDirectory.url;
         if(checkedDirectories != null)
         {
            if(checkedDirectories[dirKey])
            {
               return;
            }
            checkedDirectories[dirKey] = true;
         }

         // 1. STARBLAST Unified .cpu format (Highest priority AI profile)
         candidateList.push(targetDirectory.resolvePath("ai.cpu"));
         candidateList.push(targetDirectory.resolvePath("AI.cpu"));
         if(characterId && characterId.length > 0)
         {
            candidateList.push(targetDirectory.resolvePath(characterId + ".cpu"));
            candidateList.push(targetDirectory.resolvePath(characterId + "_ai.cpu"));
         }
         if(folderName && folderName.length > 0 && folderName != characterId)
         {
            candidateList.push(targetDirectory.resolvePath(folderName + ".cpu"));
         }
         scanDirectoryForCpuFiles(candidateList,targetDirectory);

         // 2. MUGEN .def file parsing (checks st1 = AI.cns, ai.cpu, etc.)
         parseDefFilesForAI(candidateList,targetDirectory);

         // 3. MUGEN CNS format (Secondary/Legacy compatibility)
         candidateList.push(targetDirectory.resolvePath("AI.cns"));
         candidateList.push(targetDirectory.resolvePath("ai.cns"));
         if(characterId && characterId.length > 0)
         {
            candidateList.push(targetDirectory.resolvePath(characterId + ".cns"));
            candidateList.push(targetDirectory.resolvePath(characterId + "_ai.cns"));
         }
         if(folderName && folderName.length > 0 && folderName != characterId)
         {
            candidateList.push(targetDirectory.resolvePath(folderName + ".cns"));
         }

         // 4. MUGEN CMD format (Legacy fallback)
         candidateList.push(targetDirectory.resolvePath("ai.cmd"));
         candidateList.push(targetDirectory.resolvePath("AI.cmd"));
         if(characterId && characterId.length > 0)
         {
            candidateList.push(targetDirectory.resolvePath(characterId + ".cmd"));
         }
         if(folderName && folderName.length > 0 && folderName != characterId)
         {
            candidateList.push(targetDirectory.resolvePath(folderName + ".cmd"));
         }

         // 5. JSON-style AI file: ai.json (Legacy fallback)
         candidateList.push(targetDirectory.resolvePath("ai.json"));
         if(characterId && characterId.length > 0)
         {
            candidateList.push(targetDirectory.resolvePath(characterId + "_ai.json"));
            candidateList.push(targetDirectory.resolvePath(characterId + ".json"));
         }

         // 6. Conf-style AI file: ai.conf, <charId>.conf (Legacy fallback)
         candidateList.push(targetDirectory.resolvePath("ai.conf"));
         if(characterId && characterId.length > 0)
         {
            candidateList.push(targetDirectory.resolvePath(characterId + ".conf"));
         }
      }

      private static function scanDirectoryForCpuFiles(candidateList:Array, targetDirectory:File) : void
      {
         try
         {
            var dirList:Array = targetDirectory.getDirectoryListing();
            if(dirList == null)
            {
               return;
            }
            for each(var fileItem:File in dirList)
            {
               if(fileItem == null || fileItem.isDirectory)
               {
                  continue;
               }
               var lowerName:String = fileItem.name.toLowerCase();
               if(lowerName.indexOf(".cpu",lowerName.length - 4) != -1)
               {
                  var fileUrl:String = fileItem.url;
                  var existsAlready:Boolean = false;
                  for each(var existingFile:File in candidateList)
                  {
                     if(existingFile != null && existingFile.url == fileUrl)
                     {
                        existsAlready = true;
                        break;
                     }
                  }
                  if(!existsAlready)
                  {
                     candidateList.push(fileItem);
                  }
               }
            }
         }
         catch(scanErr:Error)
         {
         }
      }

      private static function parseDefFilesForAI(candidateList:Array, targetDirectory:File) : void
      {
         try
         {
            var dirList:Array = targetDirectory.getDirectoryListing();
            if(dirList == null)
            {
               return;
            }
            for each(var fileItem:File in dirList)
            {
               if(fileItem == null || fileItem.isDirectory)
               {
                  continue;
               }
               var lowerName:String = fileItem.name.toLowerCase();
               if(lowerName.indexOf(".def",lowerName.length - 4) != -1)
               {
                  var defContent:String = readTextFile(fileItem);
                  if(!defContent)
                  {
                     continue;
                  }
                  var lines:Array = defContent.split("\r").join("\n").split("\n");
                  for each(var rawLine:String in lines)
                  {
                     var lineText:String = trimText(rawLine);
                     if(lineText.length < 1 || lineText.charAt(0) == ";" || lineText.charAt(0) == "#")
                     {
                        continue;
                     }
                     var eqIndex:int = lineText.indexOf("=");
                     if(eqIndex <= 0)
                     {
                        continue;
                     }
                     var valText:String = trimText(lineText.substr(eqIndex + 1)).replace(/^["']|["']$/g,"");
                     var valLower:String = valText.toLowerCase();
                     if(valLower.indexOf(".cpu") != -1 || valLower.indexOf(".cns") != -1 || valLower.indexOf(".cmd") != -1)
                     {
                        if(valLower.indexOf("ai") != -1 || valLower.indexOf(".cpu") != -1)
                        {
                           var resolvedAiFile:File = targetDirectory.resolvePath(valText);
                           if(resolvedAiFile.exists)
                           {
                              candidateList.push(resolvedAiFile);
                           }
                        }
                     }
                  }
               }
            }
         }
         catch(e:Error)
         {
         }
      }

      public static function parseProfileText(characterId:String, contentText:String) : FighterAIProfile
      {
         if(!contentText)
         {
            return null;
         }
         var trimmedText:String = trimText(contentText);
         if(trimmedText.length < 1)
         {
            return null;
         }
         if(trimmedText.charAt(0) == "{")
         {
            return parseJsonProfile(characterId,trimmedText);
         }
         return parseCmdProfile(characterId,trimmedText);
      }

      private static function parseJsonProfile(characterId:String, jsonString:String) : FighterAIProfile
      {
         try
         {
            var rawObject:Object = JSON.parse(jsonString);
            if(rawObject == null)
            {
               return null;
            }
            var profile:FighterAIProfile = new FighterAIProfile(characterId);
            if(rawObject.style)
            {
               profile.style = String(rawObject.style);
            }
            if(rawObject.preferred_spacing != undefined)
            {
               profile.preferredSpacing = Number(rawObject.preferred_spacing);
            }
            if(rawObject.aggression != undefined)
            {
               profile.aggression = Number(rawObject.aggression);
            }
            if(rawObject.defensiveness != undefined)
            {
               profile.defensiveness = Number(rawObject.defensiveness);
            }
            if(rawObject.ranges)
            {
               profile.ranges = rawObject.ranges;
            }
            if(rawObject.combos)
            {
               profile.combos = rawObject.combos;
            }
            if(rawObject.rules is Array)
            {
               for each(var ruleObject:Object in rawObject.rules)
               {
                  var rule:FighterAIRule = parseRuleObject(ruleObject);
                  if(rule != null)
                  {
                     profile.rules.push(rule);
                  }
               }
            }
            return profile;
         }
         catch(jsonError:Error)
         {
            trace("FighterAIProfileLoader.parseJsonProfile error:",characterId,jsonError);
         }
         return null;
      }

      private static function parseRuleObject(ruleObject:Object) : FighterAIRule
      {
         if(ruleObject == null || !ruleObject.action)
         {
            return null;
         }
         var rule:FighterAIRule = new FighterAIRule();
         rule.name = ruleObject.name ? String(ruleObject.name) : "custom_rule";
         rule.action = String(ruleObject.action);
         if(ruleObject.priority != undefined)
         {
            rule.priority = int(ruleObject.priority);
         }
         if(ruleObject.chance != undefined)
         {
            rule.chance = Number(ruleObject.chance);
         }
         if(ruleObject.trigger_action is Array)
         {
            rule.triggerActions = ruleObject.trigger_action as Array;
         }
         else if(ruleObject.trigger_action is String)
         {
            rule.triggerActions = parseCsvString(String(ruleObject.trigger_action));
         }
         if(ruleObject.trigger_dist_x is Array && ruleObject.trigger_dist_x.length >= 2)
         {
            rule.triggerDistXMin = Number(ruleObject.trigger_dist_x[0]);
            rule.triggerDistXMax = Number(ruleObject.trigger_dist_x[1]);
         }
         if(ruleObject.trigger_dist_y is Array && ruleObject.trigger_dist_y.length >= 2)
         {
            rule.triggerDistYMin = Number(ruleObject.trigger_dist_y[0]);
            rule.triggerDistYMax = Number(ruleObject.trigger_dist_y[1]);
         }
         if(ruleObject.trigger_target_state != undefined)
         {
            rule.triggerTargetState = int(ruleObject.trigger_target_state);
         }
         if(ruleObject.trigger_hit != undefined)
         {
            rule.triggerHitConfirmed = Boolean(ruleObject.trigger_hit);
         }
         if(ruleObject.trigger_qi != undefined)
         {
            rule.triggerQiMin = int(ruleObject.trigger_qi);
         }
         if(ruleObject.trigger_energy != undefined)
         {
            rule.triggerEnergyMin = int(ruleObject.trigger_energy);
         }
         return rule;
      }

      private static function parseCmdProfile(characterId:String, cmdString:String) : FighterAIProfile
      {
         var profile:FighterAIProfile = new FighterAIProfile(characterId);
         var normalizedText:String = cmdString.split("\r").join("\n");
         var lines:Array = normalizedText.split("\n");
         var currentSection:String = "AI";
         var currentRule:FighterAIRule = null;
         for each(var rawLine:String in lines)
         {
            var lineText:String = trimText(rawLine);
            if(lineText.length < 1 || lineText.charAt(0) == "#" || lineText.charAt(0) == ";")
            {
               continue;
            }
            if(lineText.charAt(0) == "[" && lineText.charAt(lineText.length - 1) == "]")
            {
               if(currentRule != null)
               {
                  if(currentRule.action)
                  {
                     profile.rules.push(currentRule);
                  }
                  currentRule = null;
               }
               var headerContent:String = lineText.substr(1,lineText.length - 2);
               var commaIndex:int = headerContent.indexOf(",");
               var sectionPrefix:String = (commaIndex > 0 ? headerContent.substr(0,commaIndex) : headerContent).toUpperCase();
               sectionPrefix = trimText(sectionPrefix);
               if(sectionPrefix.indexOf("STATEDEF") == 0)
               {
                  currentSection = "STATEDEF";
                  currentRule = null;
                  continue;
               }
               currentSection = sectionPrefix;
               if(currentSection == "RULE" || currentSection.indexOf("STATE") == 0)
               {
                  currentRule = new FighterAIRule();
                  if(commaIndex > 0)
                  {
                     currentRule.name = trimText(headerContent.substr(commaIndex + 1));
                  }
               }
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
            var key:String = trimText(lineText.substr(0,equalSignIndex)).toLowerCase();
            var value:String = trimText(lineText.substr(equalSignIndex + 1));
            if(key.length < 1 || value.length < 1)
            {
               continue;
            }
            if(currentRule != null)
            {
               applyCmdRuleProperty(currentRule,key,value);
            }
            else if(currentSection == "RANGES")
            {
               var rangeValues:Array = parseNumberList(value);
               if(rangeValues.length >= 2)
               {
                  profile.ranges[key] = [rangeValues[0],rangeValues[1]];
               }
            }
            else if(currentSection == "COMBO")
            {
               profile.combos[key] = parseCsvString(value);
            }
            else
            {
               if(key == "style")
               {
                  profile.style = value;
               }
               else if(key == "preferred_spacing" || key == "spacing")
               {
                  profile.preferredSpacing = Number(value);
               }
               else if(key == "aggression")
               {
                  profile.aggression = Number(value);
               }
               else if(key == "defensiveness")
               {
                  profile.defensiveness = Number(value);
               }
            }
         }
         if(currentRule != null && currentRule.action)
         {
            profile.rules.push(currentRule);
         }
         return profile;
      }

      private static function applyCmdRuleProperty(rule:FighterAIRule, key:String, value:String) : void
      {
         if(key == "name")
         {
            rule.name = value;
         }
         else if(key == "action" || key == "command" || key == "value" || key == "changestate")
         {
            if(value.indexOf("ifelse(") == 0 || value.indexOf("ifelse (") == 0)
            {
               var openParen:int = value.indexOf("(");
               var closeParen:int = value.lastIndexOf(")");
               if(openParen != -1 && closeParen > openParen)
               {
                  var ifArgs:Array = value.substring(openParen + 1,closeParen).split(",");
                  if(ifArgs.length >= 2)
                  {
                     value = trimText(ifArgs[1]);
                  }
               }
            }
            value = value.replace(/^["']|["']$/g,"");
            rule.action = value;
         }
         else if(key == "priority" || key == "order")
         {
            rule.priority = int(value);
         }
         else if(key == "chance" || key == "rate")
         {
            rule.chance = Number(value);
         }
         else if(key == "trigger_action" || key == "trigger_curaction" || key == "current_action" || key == "curaction" || key == "trigger1_action")
         {
            rule.triggerActions = parseCsvString(value);
         }
         else if(key == "trigger_dist_x" || key == "dist_x" || key == "p2dist_x" || key == "p2dist x" || key == "p2bodydist x")
         {
            parseDistanceXExpr(rule,value);
         }
         else if(key == "trigger_dist_y" || key == "dist_y" || key == "p2dist_y" || key == "p2dist y" || key == "p2bodydist y")
         {
            parseDistanceYExpr(rule,value);
         }
         else if(key == "trigger_hit" || key == "movehit" || key == "hit_confirmed" || key == "hit")
         {
            rule.triggerHitConfirmed = value == "1" || value.toLowerCase() == "true" || value.toLowerCase() == "yes";
         }
         else if(key == "trigger_qi" || key == "power" || key == "qi")
         {
            var powerVal:int = int(value);
            rule.triggerQiMin = powerVal >= 1000 ? int(powerVal / 10) : powerVal;
         }
         else if(key == "trigger_energy" || key == "energy")
         {
            rule.triggerEnergyMin = int(value);
         }
         else if(key == "trigger_target_state" || key == "p2state" || key == "p2_state" || key == "target_state")
         {
            rule.triggerTargetState = int(value);
         }
         else if(key == "triggerall" || key.indexOf("trigger") == 0)
         {
            parseMugenTriggerExpr(rule,value);
         }
      }

      private static function parseMugenTriggerExpr(rule:FighterAIRule, rawExpr:String) : void
      {
         if(!rawExpr || !rule)
         {
            return;
         }
         var expr:String = rawExpr.toLowerCase();
         if(expr.indexOf("p2bodydist x") != -1 || expr.indexOf("p2dist x") != -1)
         {
            parseDistanceXExpr(rule,expr);
         }
         if(expr.indexOf("p2bodydist y") != -1 || expr.indexOf("p2dist y") != -1)
         {
            parseDistanceYExpr(rule,expr);
         }
         if(expr.indexOf("power") != -1)
         {
            var powerMatch:Array = expr.match(/power\s*(?:>=|>|=)\s*([0-9]+)/);
            if(powerMatch != null && powerMatch.length > 1)
            {
               var pNum:int = int(powerMatch[1]);
               rule.triggerQiMin = pNum >= 1000 ? int(pNum / 10) : pNum;
            }
         }
         if(expr.indexOf("statetype") != -1)
         {
            if(expr.indexOf("statetype != a") != -1 || expr.indexOf("statetype = s") != -1 || expr.indexOf("statetype = c") != -1)
            {
               rule.triggerAir = -1;
            }
            else if(expr.indexOf("statetype = a") != -1 || expr.indexOf("statetype == a") != -1)
            {
               rule.triggerAir = 1;
            }
         }
         if(expr.indexOf("p2movetype = a") != -1 || expr.indexOf("p2movetype == a") != -1)
         {
            rule.triggerOpponentAttacking = true;
         }
         if(expr.indexOf("movehit") != -1)
         {
            rule.triggerHitConfirmed = true;
         }
         if(expr.indexOf("random") != -1)
         {
            var randNumMatch:Array = expr.match(/random\s*<\s*([0-9]+)/);
            if(randNumMatch != null && randNumMatch.length > 1)
            {
               rule.chance = Math.min(1.0,Number(randNumMatch[1]) / 1000);
            }
            else if(expr.indexOf("ailevel") != -1)
            {
               rule.chance = 0.8;
            }
         }
         if(expr.indexOf("stateno =") != -1 || expr.indexOf("stateno ==") != -1)
         {
            var stateNumMatch:Array = expr.match(/stateno\s*={1,2}\s*([0-9a-zA-Z_\u4e00-\u9fa5]+)/);
            if(stateNumMatch != null && stateNumMatch.length > 1)
            {
               if(rule.triggerActions == null)
               {
                  rule.triggerActions = [];
               }
               rule.triggerActions.push(stateNumMatch[1]);
            }
         }
      }

      private static function parseDistanceXExpr(rule:FighterAIRule, expr:String) : void
      {
         var bracketIndex:int = expr.indexOf("[");
         var closeBracket:int = expr.indexOf("]");
         if(bracketIndex != -1 && closeBracket > bracketIndex)
         {
            var rangeStr:String = expr.substring(bracketIndex + 1,closeBracket);
            var nums:Array = parseNumberList(rangeStr);
            if(nums.length >= 2)
            {
               rule.triggerDistXMin = Number(nums[0]);
               rule.triggerDistXMax = Number(nums[1]);
               return;
            }
         }
         var lessMatch:Array = expr.match(/(?:<|<=)\s*([0-9.]+)/);
         if(lessMatch != null && lessMatch.length > 1)
         {
            rule.triggerDistXMin = 0;
            rule.triggerDistXMax = Number(lessMatch[1]);
            return;
         }
         var greaterMatch:Array = expr.match(/(?:>|>=)\s*([0-9.]+)/);
         if(greaterMatch != null && greaterMatch.length > 1)
         {
            rule.triggerDistXMin = Number(greaterMatch[1]);
            rule.triggerDistXMax = 9999;
            return;
         }
         var fallbackNums:Array = parseNumberList(expr);
         if(fallbackNums.length >= 2)
         {
            rule.triggerDistXMin = Number(fallbackNums[0]);
            rule.triggerDistXMax = Number(fallbackNums[1]);
         }
         else if(fallbackNums.length == 1)
         {
            rule.triggerDistXMin = 0;
            rule.triggerDistXMax = Number(fallbackNums[0]);
         }
      }

      private static function parseDistanceYExpr(rule:FighterAIRule, expr:String) : void
      {
         var bracketIndex:int = expr.indexOf("[");
         var closeBracket:int = expr.indexOf("]");
         if(bracketIndex != -1 && closeBracket > bracketIndex)
         {
            var rangeStr:String = expr.substring(bracketIndex + 1,closeBracket);
            var nums:Array = parseNumberList(rangeStr);
            if(nums.length >= 2)
            {
               rule.triggerDistYMin = Number(nums[0]);
               rule.triggerDistYMax = Number(nums[1]);
               return;
            }
         }
         var lessMatch:Array = expr.match(/(?:<|<=)\s*([0-9.]+)/);
         if(lessMatch != null && lessMatch.length > 1)
         {
            var yVal:Number = Math.abs(Number(lessMatch[1]));
            rule.triggerDistYMin = -yVal;
            rule.triggerDistYMax = yVal;
            return;
         }
         var greaterMatch:Array = expr.match(/(?:>|>=)\s*([0-9.]+)/);
         if(greaterMatch != null && greaterMatch.length > 1)
         {
            rule.triggerDistYMin = Number(greaterMatch[1]);
            rule.triggerDistYMax = 9999;
            return;
         }
         var fallbackNums:Array = parseNumberList(expr);
         if(fallbackNums.length >= 2)
         {
            rule.triggerDistYMin = Number(fallbackNums[0]);
            rule.triggerDistYMax = Number(fallbackNums[1]);
         }
         else if(fallbackNums.length == 1)
         {
            var singleY:Number = Math.abs(Number(fallbackNums[0]));
            rule.triggerDistYMin = -singleY;
            rule.triggerDistYMax = singleY;
         }
      }

      private static function parseCsvString(csvText:String) : Array
      {
         var result:Array = [];
         if(!csvText)
         {
            return result;
         }
         var rawItems:Array = csvText.split(",");
         for each(var item:String in rawItems)
         {
            var trimmed:String = trimText(item);
            if(trimmed.length > 0)
            {
               result.push(trimmed);
            }
         }
         return result;
      }

      private static function parseNumberList(textList:String) : Array
      {
         var result:Array = [];
         if(!textList)
         {
            return result;
         }
         var rawList:Array = textList.split(",");
         for each(var itemText:String in rawList)
         {
            var trimmed:String = trimText(itemText);
            var numValue:Number = Number(trimmed);
            if(!isNaN(numValue))
            {
               result.push(numValue);
            }
         }
         return result;
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
         catch(readError:Error)
         {
            trace("FighterAIProfileLoader.readTextFile error:",file.nativePath,readError);
            return null;
         }
         finally
         {
            if(fileStream != null)
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

      private static function trimText(sourceText:String) : String
      {
         if(!sourceText)
         {
            return "";
         }
         return sourceText.replace(/\uFEFF/g,"").replace(/^\s+|\s+$/g,"");
      }
   }
}
