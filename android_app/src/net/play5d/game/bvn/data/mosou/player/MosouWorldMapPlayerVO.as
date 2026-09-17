package net.play5d.game.bvn.data.mosou.player
{
   import net.play5d.game.bvn.data.ISaveData;
   
   public class MosouWorldMapPlayerVO implements ISaveData
   {
      public var id:String;
      
      private var _openAreas:Vector.<MosouWorldMapAreaPlayerVO> = new Vector.<MosouWorldMapAreaPlayerVO>();
      
      public function MosouWorldMapPlayerVO()
      {
         super();
      }
      
      public function getOpenArea(param1:String) : MosouWorldMapAreaPlayerVO
      {
         var _loc2_:int = 0;
         while(_loc2_ < _openAreas.length)
         {
            if(_openAreas[_loc2_].id == param1)
            {
               return _openAreas[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      public function openArea(param1:String) : void
      {
         var _loc2_:MosouWorldMapAreaPlayerVO = null;
         if(!getOpenArea(param1))
         {
            _loc2_ = new MosouWorldMapAreaPlayerVO();
            _loc2_.id = param1;
            _openAreas.push(_loc2_);
         }
      }
      
      public function toSaveObj() : Object
      {
         var _loc2_:int = 0;
         var _loc1_:Object = null;
         var _loc3_:Object = {};
         _loc3_.id = id;
         _loc3_.areas = [];
         while(_loc2_ < _openAreas.length)
         {
            _loc1_ = _openAreas[_loc2_].toSaveObj();
            _loc3_.areas.push(_loc1_);
            _loc2_++;
         }
         return _loc3_;
      }
      
      public function readSaveObj(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:MosouWorldMapAreaPlayerVO = null;
         if(param1.id)
         {
            id = param1.id;
         }
         if(param1.areas)
         {
            _openAreas = new Vector.<MosouWorldMapAreaPlayerVO>();
            while(_loc4_ < param1.areas.length)
            {
               _loc2_ = param1.areas[_loc4_];
               _loc3_ = new MosouWorldMapAreaPlayerVO();
               _loc3_.readSaveObj(_loc2_);
               _openAreas.push(_loc3_);
               _loc4_++;
            }
         }
      }
   }
}

