package net.play5d.game.bvn.data
{
   public class FighterModel
   {
      private static var _i:FighterModel;
      
      private var _fighterObj:Object;
      
      public function FighterModel()
      {
         super();
      }
      
      public static function get I() : FighterModel
      {
         if(!_i)
         {
            _i = new FighterModel();
         }
         return _i;
      }
      
      public function getAllFighters() : Object
      {
         return _fighterObj;
      }
      
      public function getFighters(param1:int = -1, param2:Function = null) : Vector.<FighterVO>
      {
         var _loc3_:Vector.<FighterVO> = new Vector.<FighterVO>();
         for each(var _loc4_:FighterVO in _fighterObj)
         {
            if((param2 != null && !param2(_loc4_)))
            {
               if(param1 == -1 || _loc4_.comicType == param1)
               {
                  _loc3_.push(_loc4_);
               }
            }
         }
         return _loc3_;
      }
      
      public function getFighter(param1:String, param2:Boolean = false) : FighterVO
      {
         var _loc3_:FighterVO = _fighterObj[param1];
         if(!_loc3_)
         {
            return null;
         }
         return param2 ? _loc3_.clone() : _loc3_;
      }
      
      public function getFighterName(param1:String) : String
      {
         var _loc2_:FighterVO = _fighterObj[param1];
         if(!_loc2_)
         {
            return "N/A";
         }
         return _loc2_.name;
      }
      
      public function getFighterBGM(param1:String) : BgmVO
      {
         var _loc2_:FighterVO = getFighter(param1);
         if(!_loc2_ || !_loc2_.bgm || _loc2_.bgmRate <= 0)
         {
            return null;
         }
         var _loc3_:BgmVO = new BgmVO();
         _loc3_.id = _loc2_.id;
         _loc3_.url = _loc2_.bgm;
         _loc3_.rate = _loc2_.bgmRate;
         return _loc3_;
      }
      
      public function getBossBGM(param1:String) : BgmVO
      {
         var _loc2_:BgmVO = new BgmVO();
         _loc2_.id = param1;
         _loc2_.rate = 1;
         switch(param1)
         {
            case "boss_naruto":
               _loc2_.url = "bgm/narutoboss.mp3";
               break;
            case "boss_bleach":
               _loc2_.url = "bgm/bleachboss.mp3";
               break;
            default:
               return null;
         }
         return _loc2_;
      }
      
      public function initByXML(param1:XML) : void
      {
         var _loc2_:FighterVO = null;
         _fighterObj = {};
         for each(var _loc3_:XML in param1.fighter)
         {
            _loc2_ = new FighterVO();
            _loc2_.initByXML(_loc3_);
            _fighterObj[_loc2_.id] = _loc2_;
         }
      }
      
      public function addOrReplaceFighter(fighterData:FighterVO) : void
      {
         if(!fighterData || !fighterData.id)
         {
            return;
         }
         if(!_fighterObj)
         {
            _fighterObj = {};
         }
         _fighterObj[fighterData.id] = fighterData;
      }
   }
}

