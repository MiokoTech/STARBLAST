package net.play5d.game.bvn.factory
{
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.ctrl.game_stage_loader.GameStageLoadCtrl;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.MapVO;
   import net.play5d.game.bvn.data.mosou.MosouEnemyVO;
   import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.map.MapMain;
   
   public class GameRunFactory
   {
      private static var _fighterCache:Dictionary = new Dictionary();
      
      public function GameRunFactory()
      {
         super();
      }
      
      public static function createEnemyByData(param1:MosouEnemyVO) : FighterMain
      {
         var _loc2_:FighterVO = FighterModel.I.getFighter(param1.fighterID,true);
         if(!_loc2_)
         {
            return null;
         }
         var _loc3_:FighterMain = createFighterByData(_loc2_,"2");
         if(!_loc3_)
         {
            return null;
         }
         _loc3_.mosouEnemyData = param1;
         _loc3_.hp = _loc3_.hpMax = param1.maxHp;
         return _loc3_;
      }
      
      public static function createFighterByData(param1:FighterVO, param2:String) : FighterMain
      {
         var _loc3_:MovieClip = GameStageLoadCtrl.I.getFighterMc(param1.fileUrl,param2);
         var _loc4_:FighterMain = new FighterMain(_loc3_);
         _loc4_.data = param1;
         return _loc4_;
      }
      
      public static function createFighterByMosouData(param1:FighterVO, param2:MosouFighterVO, param3:*) : FighterMain
      {
         var _loc4_:FighterMain = createFighterByData(param1,param3);
         if(!_loc4_)
         {
            return null;
         }
         _loc4_.initMosouFighter(param2);
         return _loc4_;
      }
      
      public static function createMapByData(mapVO:MapVO) : MapMain
      {
         var cachedMap:* = GameStageLoadCtrl.I.getMapMc(mapVO.fileUrl);
         if(cachedMap is MapMain)
         {
            var jsonMap:MapMain = cachedMap as MapMain;
            jsonMap.data = mapVO;
            return jsonMap;
         }
         var mapDisplay:MovieClip = cachedMap as MovieClip;
         var mapInstance:MapMain = new MapMain(mapDisplay);
         mapInstance.data = mapVO;
         return mapInstance;
      }
      
      public static function createAssisterByData(fighterVO:FighterVO, teamId:String) : Assister
      {
         if(!fighterVO)
         {
            return null;
         }
         var assisterMc:MovieClip = GameStageLoadCtrl.I.getAssisterMc(fighterVO.fileUrl,teamId);
         if(!assisterMc)
         {
            return null;
         }
         var assister:Assister = new Assister(assisterMc);
         assister.data = fighterVO;
         return assister;
      }
   }
}
