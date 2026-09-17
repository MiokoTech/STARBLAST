package net.play5d.game.bvn.mob.utils
{
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.utils.ByteArray;
   
   public class FileUtils
   {
      private static const ROOT_FOLDER_NAME:String = "STARBLAST";
      
      public function FileUtils()
      {
         super();
      }
      
      public static function getRootFolderName() : String
      {
         return ROOT_FOLDER_NAME;
      }
      
      public static function getRootFolderPath() : String
      {
         return ROOT_FOLDER_NAME;
      }
      
      public static function ensureRootFolderExists() : void
      {
         try
         {
            var rootFolder:File = File.userDirectory.resolvePath(ROOT_FOLDER_NAME);
            if(!rootFolder.exists)
            {
               rootFolder.createDirectory();
            }
            var aiFolder:File = rootFolder.resolvePath("ai");
            if(!aiFolder.exists)
            {
               aiFolder.createDirectory();
            }
         }
         catch(e:Error)
         {
            trace("FileUtils.ensureRootFolderExists",e);
         }
      }
      
      public static function getSaveFilePath() : String
      {
         return ROOT_FOLDER_NAME + "/bvnsave.json";
      }
      
      public static function getOptionsFilePath() : String
      {
         return ROOT_FOLDER_NAME + "/options.json";
      }
      
      public static function getConfigFilePath() : String
      {
         return ROOT_FOLDER_NAME + "/config.json";
      }
      
      public static function getRulesFilePath() : String
      {
         return ROOT_FOLDER_NAME + "/rules.json";
      }
      
      public static function getSwfPath() : String
      {
         return ROOT_FOLDER_NAME + "/chars/";
      }
      
      public static function getExternalCharacterListFilePath() : String
      {
         return ROOT_FOLDER_NAME + "/character.conf";
      }
      
      public static function getExternalCharactersRootPath() : String
      {
         return ROOT_FOLDER_NAME + "/characters/";
      }
      
      public static function getExternalCharacterConfigFilePath(characterFolderName:String) : String
      {
         return getExternalCharactersRootPath() + characterFolderName + "/character.json";
      }
      
      public static function getExternalAiRootPath() : String
      {
         return ROOT_FOLDER_NAME + "/ai/";
      }
      
      public static function getExternalCharacterAiFilePath(characterFolderName:String) : String
      {
         return getExternalCharactersRootPath() + characterFolderName + "/ai.cpu";
      }

      public static function getExternalAiFilePath(characterId:String) : String
      {
         return getExternalAiRootPath() + characterId + ".cpu";
      }
      
      public static function writeFile(filePath:String, fileData:*, openMode:String = null) : void
      {
         var targetFile:File = null;
         var stream:FileStream = null;
         var byteBuffer:ByteArray = null;
         if(!openMode)
         {
            openMode = "write";
         }
         try
         {
            targetFile = new File(filePath);
            if(targetFile.parent && !targetFile.parent.exists)
            {
               targetFile.parent.createDirectory();
            }
            stream = new FileStream();
            stream.open(targetFile,openMode);
            if(fileData is String)
            {
               stream.writeUTFBytes(fileData);
            }
            if(fileData is ByteArray)
            {
               byteBuffer = fileData as ByteArray;
               stream.writeBytes(byteBuffer,0,byteBuffer.bytesAvailable);
            }
            stream.close();
         }
         catch(e:Error)
         {
            trace("FileUtils.writeFile",e);
         }
      }
      
      public static function writeAppFloderFile(filePath:String, fileData:*, openMode:String = null) : void
      {
         var targetUrl:String = getAppFloderFileUrl(filePath);
         writeFile(targetUrl,fileData,openMode);
      }
      
      public static function getAppFloderFileUrl(filePath:String) : String
      {
         var appDir:File = File.applicationDirectory;
         var basePath:String = appDir.nativePath;
         return basePath + "/" + filePath;
      }
      
      public static function createFloder(folderPath:String) : void
      {
         var targetDir:File = null;
         try
         {
            targetDir = new File(folderPath);
            targetDir.createDirectory();
         }
         catch(e:Error)
         {
            trace("FileUtils.createFloder",e);
         }
      }
      
      public static function readTextFile(filePath:String) : String
      {
         var resultText:String = null;
         var targetFile:File = null;
         var stream:FileStream = null;
         try
         {
            targetFile = new File(filePath);
            stream = new FileStream();
            stream.open(targetFile,"read");
            resultText = stream.readUTFBytes(stream.bytesAvailable);
            stream.close();
         }
         catch(e:Error)
         {
            trace("FileUtils.readTextFile",filePath,e);
         }
         return resultText;
      }
      
      public static function del(filePath:String) : void
      {
         var targetFile:File = new File(filePath);
         try
         {
            targetFile.deleteFile();
         }
         catch(e:Error)
         {
            trace("FileUtils.del",e);
         }
      }
   }
}
