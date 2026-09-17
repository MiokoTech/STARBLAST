package net.play5d.game.bvn.data
{
   public class MapModel
   {
      private static var _i:MapModel;
      
      private var _mapObj:Object;
      
      private var _mapArray:Array;
      
      public function MapModel()
      {
         super();
      }
      
      public static function get I() : MapModel
      {
         if(!_i)
         {
            _i = new MapModel();
         }
         return _i;
      }
      
      public function getMap(param1:String) : MapVO
      {
         return _mapObj[param1];
      }
      
      public function getMapBGM(param1:String) : BgmVO
      {
         var _loc3_:MapVO = getMap(param1);
         if(!_loc3_ || !_loc3_.bgm)
         {
            return null;
         }
         var _loc2_:BgmVO = new BgmVO();
         _loc2_.id = "map";
         _loc2_.url = _loc3_.bgm;
         _loc2_.rate = 1;
         return _loc2_;
      }
      
      public function getAllMaps() : Array
      {
         return _mapArray;
      }
      
      public function initByXML(xml:XML) : void
      {
         _mapObj = {};
         _mapArray = [];
         for each(var i:XML in xml.map)
         {
            var mv:MapVO = new MapVO();
            mv.initByXML(i);
            _mapObj[mv.id] = mv;
            _mapArray.push(mv);
         }
      }
   }
}

