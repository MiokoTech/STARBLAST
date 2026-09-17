package net.play5d.game.bvn.data.mosou
{
   public class MosouWorldMapVO
   {
      public var id:String;
      
      public var name:String;
      
      public var areas:Vector.<MosouWorldMapAreaVO>;
      
      private var _areaMap:Object;
      
      public function MosouWorldMapVO()
      {
         super();
      }
      
      public function initWay(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:MosouWorldMapAreaVO = null;
         var _loc4_:int = 0;
         areas = new Vector.<MosouWorldMapAreaVO>();
         _areaMap = {};
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = param1[_loc4_];
            _loc3_ = new MosouWorldMapAreaVO();
            _loc3_.id = _loc2_.P;
            areas.push(_loc3_);
            _areaMap[_loc3_.id] = _loc3_;
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = param1[_loc4_];
            _loc3_ = _areaMap[_loc2_.P];
            if(!(!_loc3_ || !_loc2_.N))
            {
               _loc3_.preOpens = new Vector.<MosouWorldMapAreaVO>();
               if(_loc2_.N is Array)
               {
                  for each(var _loc5_:String in _loc2_.N)
                  {
                     if(_areaMap[_loc5_])
                     {
                        _loc3_.preOpens.push(_areaMap[_loc5_]);
                     }
                  }
               }
               else if(_areaMap[_loc2_.N])
               {
                  _loc3_.preOpens.push(_areaMap[_loc2_.N]);
               }
            }
            _loc4_++;
         }
      }
      
      public function getArea(param1:String) : MosouWorldMapAreaVO
      {
         return _areaMap[param1];
      }
   }
}

