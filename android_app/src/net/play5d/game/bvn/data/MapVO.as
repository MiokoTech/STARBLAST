package net.play5d.game.bvn.data
{
   public class MapVO
   {
      public var id:String;
      
      public var name:String;
      
      public var fileUrl:String;
      
      public var picUrl:String;
      
      public var bgm:String;
      
      public function MapVO()
      {
         super();
      }
      
      public function initByXML(param1:XML) : void
      {
         id = param1.@id;
         name = param1.@name;
         fileUrl = param1.file.@url;
         picUrl = param1.img.@url;
         bgm = param1.bgm.@url;
      }
   }
}

