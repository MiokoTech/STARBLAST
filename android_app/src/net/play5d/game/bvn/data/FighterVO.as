package net.play5d.game.bvn.data
{
   import flash.geom.Point;
   import net.play5d.game.bvn.fighter.LocalCoordManager;
   import net.play5d.kyo.utils.KyoRandom;
   
   public class FighterVO
   {
      public var id:String;
      
      public var name:String;
      
      public var comicType:int;
      
      public var fileUrl:String;
      
      public var startFrame:int;
      
      public var faceUrl:String;
      
      public var faceBigUrl:String;
      
      public var faceBarUrl:String;
      
      public var faceWinUrl:String;
      
      public var contactFriends:Array;
      
      public var contactEnemys:Array;
      
      public var says:Array;
      
      public var bgm:String;
      
      public var bgmRate:Number = 1;
      
      public var isAlive:Boolean;

      
      public var aiLevelOverride:int = 0;
      
      public var aiFile:String;
      
      public var localcoord:Point;
      
      private var _cloneKey:Array = ["id","name","comicType","fileUrl","startFrame","faceUrl","contactFriends","contactEnemys","says","faceBigUrl","faceBarUrl","bgm","bgmRate","faceWinUrl","aiLevelOverride","aiFile","localcoord"];
      
      public function FighterVO()
      {
         super();
      }
      
      public function initByXML(xml:XML) : void
      {
         id = xml.@id;
         name = xml.@name;
         comicType = int(xml.@comic_type);
         fileUrl = xml.file.@url;
         startFrame = int(xml.file.@startFrame);
         faceUrl = xml.face.@url;
         faceBigUrl = xml.face.@big_url;
         faceBarUrl = xml.face.@bar_url;
         faceWinUrl = xml.face.@win_url;
         contactFriends = xml.contact.friend.toString().split(",");
         contactEnemys = xml.contact.enemy.toString().split(",");
         bgm = xml.bgm.@url;
         bgmRate = Number(xml.bgm.@rate) / 100;
         aiLevelOverride = int(xml.@ai_level);
         if(xml.ai.@url.length() > 0)
         {
            aiFile = xml.ai.@url;
         }
         else if(xml.@ai.length() > 0)
         {
            aiFile = xml.@ai;
         }
         if(xml.@localcoord.length() > 0)
         {
            localcoord = LocalCoordManager.parseCoord(xml.@localcoord);
            if(localcoord && id)
            {
               LocalCoordManager.register(id, localcoord.x, localcoord.y);
            }
         }
         says = [];
         for each(var sayXml:XML in xml.says.say_item)
         {
            says.push(sayXml.children().toString());
         }
         if(startFrame != 0 && !bgm)
         {
            trace(id + "没有定义bgm!");
         }
      }
      
      public function getRandSay() : String
      {
         return KyoRandom.getRandomInArray(says);
      }
      
      public function clone() : FighterVO
      {
         var fighterData:FighterVO = new FighterVO();
         for each(var keyName:String in _cloneKey)
         {
            fighterData[keyName] = this[keyName];
         }
         return fighterData;
      }
   }
}

