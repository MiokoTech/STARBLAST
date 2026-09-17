package net.play5d.game.bvn.ctrl.mosou_ctrls
{
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.mosou.MosouFighterSellVO;
   import net.play5d.game.bvn.data.mosou.MosouMissionVO;
   import net.play5d.game.bvn.data.mosou.MosouModel;
   import net.play5d.game.bvn.data.mosou.MosouWorldMapAreaVO;
   import net.play5d.game.bvn.data.mosou.MosouWorldMapVO;
   import net.play5d.game.bvn.data.mosou.player.MosouMissionPlayerVO;
   import net.play5d.game.bvn.data.mosou.player.MosouPlayerData;
   import net.play5d.game.bvn.data.mosou.player.MosouWorldMapAreaPlayerVO;
   import net.play5d.game.bvn.data.mosou.player.MosouWorldMapPlayerVO;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.ui.GameUI;
   
   public class MosouLogic
   {
      private static var _i:MosouLogic;
      
      private var _hitNum:int;
      
      private var _hitTargets:Vector.<FighterMain> = new Vector.<FighterMain>();
      
      public function MosouLogic()
      {
         super();
      }
      
      public static function get I() : MosouLogic
      {
         if(!_i)
         {
            _i = new MosouLogic();
         }
         return _i;
      }
      
      public function checkCurrentArea(param1:String) : Boolean
      {
         var _loc2_:MosouPlayerData = GameData.I.mosouData;
         if(!_loc2_.getCurrentArea())
         {
            return false;
         }
         return _loc2_.getCurrentArea().id == param1;
      }
      
      public function checkAreaIsOpen(param1:String) : Boolean
      {
         var _loc2_:MosouPlayerData = GameData.I.mosouData;
         var _loc3_:MosouWorldMapPlayerVO = GameData.I.mosouData.getCurrentMap();
         return _loc3_.getOpenArea(param1) != null;
      }
      
      public function getNextMission(param1:MosouWorldMapAreaVO) : MosouMissionVO
      {
         var _loc5_:MosouPlayerData = GameData.I.mosouData;
         var _loc6_:MosouWorldMapPlayerVO = GameData.I.mosouData.getCurrentMap();
         var _loc2_:MosouWorldMapAreaPlayerVO = _loc6_.getOpenArea(param1.id);
         if(!_loc2_)
         {
            return null;
         }
         var _loc3_:MosouMissionPlayerVO = _loc2_.getLastPassedMission();
         if(!_loc3_)
         {
            return param1.missions[0];
         }
         var _loc4_:MosouMissionVO = param1.getNextMission(_loc3_.id);
         if(_loc4_)
         {
            return _loc4_;
         }
         return param1.missions[param1.missions.length - 1];
      }
      
      public function getAreaPercent(param1:String) : Number
      {
         var _loc3_:MosouPlayerData = GameData.I.mosouData;
         var _loc6_:MosouWorldMapPlayerVO = GameData.I.mosouData.getCurrentMap();
         var _loc2_:MosouWorldMapAreaPlayerVO = _loc6_.getOpenArea(param1);
         if(!_loc2_)
         {
            return 0;
         }
         var _loc4_:MosouWorldMapAreaVO = MosouModel.I.getMapArea(_loc6_.id,_loc2_.id);
         if(!_loc4_ || !_loc4_.missions)
         {
            return 0;
         }
         return _loc2_.getPassedMissionAmount() / _loc4_.missions.length;
      }
      
      public function openMapArea(param1:String, param2:String) : void
      {
         trace("openMapArea",param2);
         var _loc3_:MosouPlayerData = GameData.I.mosouData;
         var _loc4_:MosouWorldMapPlayerVO = GameData.I.mosouData.getMapById(param1);
         _loc4_.openArea(param2);
      }
      
      public function passMission(param1:MosouMissionVO) : void
      {
         var _loc2_:MosouWorldMapAreaPlayerVO = GameData.I.mosouData.getCurrentArea();
         if(_loc2_.passMission(param1.id))
         {
            GameData.I.mosouData.addMoney(2000);
         }
         else
         {
            GameData.I.mosouData.addMoney(500);
         }
         updateMapAreas();
         GameData.I.saveData();
      }
      
      public function updateMapAreas() : void
      {
         var pmap:MosouWorldMapPlayerVO = GameData.I.mosouData.getCurrentMap();
         var map:MosouWorldMapVO = MosouModel.I.getMap(pmap.id);
         for each(var i:MosouWorldMapAreaVO in map.areas)
         {
            if (i.preOpens && i.preOpens.length > 0)
            {
                var isOpenArea:Boolean = true;
                for each(var p:MosouWorldMapAreaVO in i.preOpens)
                {
                    if (!canPassNextArea(p.id))
                     {
                        isOpenArea = false;
                        break;
                    }
                }
                if (isOpenArea)
                {
                    openMapArea(pmap.id, i.id);
                }

            }
         }
      }
      
      private function canPassNextArea(param1:String) : Boolean
      {
         return getAreaPercent(param1) > 0.6;
      }
      
      public function buyFighter(param1:MosouFighterSellVO, param2:Function = null) : void
      {
         var data:MosouFighterSellVO = param1;
         var succback:Function = param2;
         var mosouData:MosouPlayerData = GameData.I.mosouData;
         if(mosouData.getMoney() < data.getPrice())
         {
            GameUI.alert("NEED MORE MONEY","金币不足，需要" + data.getPrice() + "金币！");
            return;
         }
         GameUI.confrim("CONFRIM","确认使用" + data.getPrice() + "金币解锁人物？",function():void
         {
            mosouData.loseMoney(data.getPrice());
            mosouData.addFighter(data.id);
            GameData.I.saveData();
            if(succback != null)
            {
               succback();
            }
         });
      }
      
      public function initEnemyProps(param1:FighterMain) : void
      {
         var _loc4_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(!param1.mosouEnemyData)
         {
            return;
         }
         var _loc6_:MosouMissionVO = MosouModel.I.currentMission;
         var _loc8_:int = _loc6_.enemyLevel;
         param1.mosouEnemyData.level = _loc8_;
         if(param1.mosouEnemyData.isBoss)
         {
            if(param1.mosouEnemyData.maxHp > 0)
            {
               param1.hp = param1.hpMax = param1.mosouEnemyData.maxHp;
            }
            else
            {
               param1.hp = param1.hpMax = 1000 + _loc8_ * 400;
            }
            param1.energy = param1.energyMax = 80 + _loc8_ * 10;
            _loc7_ = _loc8_ * 13;
            _loc5_ = _loc8_ * 14;
            _loc2_ = _loc8_ * 15;
            param1.initAttackAddDmg(_loc7_,_loc5_,_loc2_);
         }
         else
         {
            if(param1.mosouEnemyData.maxHp > 0)
            {
               param1.hp = param1.hpMax = param1.mosouEnemyData.maxHp;
            }
            else
            {
               _loc3_ = 1 + (_loc8_ - 1) * 0.08;
               if(_loc3_ > 1)
               {
                  param1.hp = param1.hpMax = param1.hp * _loc3_;
               }
            }
            _loc7_ = _loc8_ * 5;
            _loc5_ = _loc8_ * 10;
            _loc2_ = _loc8_ * 20;
            param1.initAttackAddDmg(_loc7_,_loc5_,_loc2_);
         }
      }
      
      public function addHits(param1:FighterMain) : int
      {
         if(_hitTargets.indexOf(param1) == -1)
         {
            _hitTargets.push(param1);
         }
         _hitNum++;
         if(_hitNum > 1 && GameUI.I.getUI())
         {
            GameUI.I.getUI().showHits(_hitNum,1);
         }
         return _hitNum;
      }
      
      public function removeHitTarget(param1:FighterMain) : void
      {
         var _loc2_:int = int(_hitTargets.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         _hitTargets.splice(_loc2_,1);
         if(_hitTargets.length < 1)
         {
            _hitNum = 0;
            if(GameUI.I && GameUI.I.getUI())
            {
               GameUI.I.getUI().hideHits(1);
            }
         }
      }
      
      public function clearHits() : void
      {
         _hitNum = 0;
         _hitTargets = new Vector.<FighterMain>();
      }
   }
}

