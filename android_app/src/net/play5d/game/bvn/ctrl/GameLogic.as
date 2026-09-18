package net.play5d.game.bvn.ctrl
{
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameEndCtrl;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.data.MessionModel;
   import net.play5d.game.bvn.data.MessionStageVO;
   import net.play5d.game.bvn.data.SelectCharListConfigVO;
   import net.play5d.game.bvn.data.SelectCharListItemVO;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.game.bvn.map.FloorVO;
   import net.play5d.game.bvn.map.MapMain;
   import net.play5d.game.bvn.state.GameCamera;
   import net.play5d.game.bvn.ui.select.SelectIndexUI;
   import net.play5d.game.bvn.utils.ResUtils;
   
   public class GameLogic
   {
      private static var _map:MapMain;
      
      private static var _camera:GameCamera;
      
      private static var _floorContact:Dictionary = new Dictionary();
      
      private static var _hitsObj:Object = {};
      
      public function GameLogic()
      {
         super();
      }
      
      public static function initGameLogic(param1:MapMain, param2:GameCamera) : void
      {
         _map = param1;
         _camera = param2;
      }
      
      public static function clear() : void
      {
         _map = null;
         _camera = null;
      }
      
      public static function isInAir(param1:BaseGameSprite) : Boolean
      {
         if(!_map)
         {
            trace("error:map is null!");
            return false;
         }
         if(param1.getVecY() < 0)
         {
            param1.isTouchBottom = false;
            return true;
         }
         if(param1.y > _map.playerBottom - 12)
         {
            param1.y = _map.playerBottom;
            param1.isTouchBottom = true;
            return false;
         }
         param1.isTouchBottom = false;
         var _loc3_:* = param1.getVecY() < 5 * GameConfig.SPEED_PLUS;
         if(!_loc3_)
         {
            return true;
         }
         var _loc4_:Number = 10 * GameConfig.SPEED_PLUS_DEFAULT;
         var _loc2_:FloorVO = _floorContact[param1];
         if(_loc2_)
         {
            if(_loc2_.hitTest(param1.x,param1.y,_loc4_))
            {
               param1.y = _loc2_.y;
               return false;
            }
            delete _floorContact[param1];
            return true;
         }
         _loc2_ = _map.getFloorHitTest(param1.x,param1.y,_loc4_);
         if(_loc2_)
         {
            param1.y = _loc2_.y;
            _floorContact[param1] = _loc2_;
            return false;
         }
         return true;
      }
      
      public static function isTouchBottomFloor(param1:IGameSprite) : Boolean
      {
         if(!_map)
         {
            trace("error:map is null!");
            return false;
         }
         return param1.y > _map.playerBottom;
      }
      
      public static function isOutRange(param1:IGameSprite) : Boolean
      {
         if(!_map)
         {
            trace("error:map is null!");
            return false;
         }
         var _loc2_:int = 20;
         return param1.x > _map.right + _loc2_ || param1.x < _map.left - _loc2_ || param1.y > _map.bottom + _loc2_;
      }

      public static function getMapCenterX() : Number
      {
         if(!_map)
         {
            return 0;
         }
         return (_map.left + _map.right) * 0.5;
      }

      public static function getPlayerBottomY() : Number
      {
         if(!_map)
         {
            return 0;
         }
         return _map.playerBottom;
      }

      public static function getMapSideDistanceX(param1:IGameSprite, param2:Number = 10) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(!_map || param1 == null)
         {
            return Number.MAX_VALUE;
         }
         _loc3_ = _map.left + param2;
         _loc4_ = _map.right - param2;
         return Math.min(Math.abs(param1.x - _loc3_),Math.abs(_loc4_ - param1.x));
      }

      public static function isNearMapSideX(param1:IGameSprite, param2:Number = 120, param3:Number = 10) : Boolean
      {
         if(!_map || param1 == null)
         {
            return false;
         }
         return getMapSideDistanceX(param1,param3) <= param2;
      }
      
      public static function addHits(param1:Object, param2:Object, param3:int) : int
      {
         if(_hitsObj[param1] == undefined)
         {
            _hitsObj[param1] = {
               "hits":0,
               "targetID":param2,
               "uiID":param3
            };
         }
         _hitsObj[param1].targetID = param2;
         _hitsObj[param1].hits++;
         return _hitsObj[param1].hits;
      }
      
      public static function clearHits(param1:Object) : void
      {
         _hitsObj[param1].hits = 0;
         _hitsObj[param1].targetID = null;
         _hitsObj[param1].uiID = null;
      }
      
      public static function getHitsObj(param1:Object) : Object
      {
         return _hitsObj[param1];
      }
      
      public static function getHitsObjByTargetId(id:Object) : Object
      {
         for each(var o:Object in _hitsObj)
         {
            if(o.targetID == id)
            {
               return o;
            }
         }
         return null;
      }
      
      public static function clearHitsByTargetId(id:Object) : void
      {
         for(var i:String in _hitsObj)
         {
            if(_hitsObj[i].targetID == id)
            {
               delete _hitsObj[i];
            }
         }
      }
      
      public static function checkFighterDie(param1:FighterMain) : Boolean
      {
         if(GameMode.currentMode == 40)
         {
            return false;
         }
         return param1.hp <= 0;
      }
      
      public static function hitTarget(param1:HitVO, param2:IGameSprite, param3:IGameSprite) : void
      {
         if(!param2 || !param3)
         {
            return;
         }
         if(param2 is FighterMain == false)
         {
            return;
         }
         if(param3 is FighterMain == false)
         {
            return;
         }
         if((param3 as FighterMain).actionState != 21 && (param3 as FighterMain).actionState != 22)
         {
            return;
         }
         var _loc4_:Object = {};
         _loc4_.target = param3;
         _loc4_.hitvo = param1;
         FighterEventDispatcher.dispatchEvent(param2 as FighterMain,"HIT_TARGET",_loc4_);
      }
      
      public static function addScoreByHitTarget(param1:HitVO) : void
      {
         var _loc5_:int;
         var _loc3_:* = _loc5_ = param1.power;
         if(param1.isBisha())
         {
            _loc3_ = _loc5_ * 2;
         }
         if(param1.id == "sh1" || param1.id == "sh2")
         {
            _loc3_ += 500;
         }
         if(param1.isBreakDef)
         {
            _loc3_ += 200;
         }
         if(param1.hurtType == 1)
         {
            _loc3_ += 200;
         }
         var _loc4_:Object = getHitsObj(1);
         var _loc2_:int = int(!!_loc4_ ? _loc4_.hits : 0);
         if(_loc2_ < 4)
         {
            _loc3_ += _loc2_ * 50;
         }
         else
         {
            _loc3_ += _loc2_ * 100;
         }
         addScore(_loc3_);
         GameEvent.dispatchEvent("SCORE_UPDATE");
      }
      
      public static function addScoreByKO() : void
      {
         var _loc1_:int = 0;
         if(GameCtrl.I.gameRunData.p1FighterGroup.currentFighter.lastHitVO && GameCtrl.I.gameRunData.p1FighterGroup.currentFighter.lastHitVO.isBisha())
         {
            addScore(2000);
         }
         if(GameCtrl.I.gameRunData.p1FighterGroup.currentFighter.hp == GameCtrl.I.gameRunData.p1FighterGroup.currentFighter.hpMax)
         {
            addScore(20000);
         }
         else
         {
            addScore(3000);
         }
         GameEvent.dispatchEvent("SCORE_UPDATE");
      }
      
      public static function addScoreByPassMission() : void
      {
         var p1Group:GameRunFighterGroup = GameCtrl.I.gameRunData.p1FighterGroup;
         if(GameMode.currentMode == GameMode.TEAM_ARCADE && p1Group.currentFighter && p1Group.currentFighter.data == p1Group.fighter1)
         {
            addScore(15000);
         }
         else
         {
            addScore(5000);
         }
      }
      
      private static function addScore(score:int) : void
      {
         var rate:Number = GameData.I.config.keyInputMode == 0 ? 1 : 0.8;
         GameData.I.score += score * rate;
      }
      
      public static function loseScoreByContinue() : void
      {
         GameData.I.score -= 10000;
         if(GameData.I.score < 0)
         {
            GameData.I.score = 0;
         }
      }
      
      public static function fixGameSpritePosition(sp:IGameSprite) : void
      {
         var left:Number = NaN;
         var right:Number = NaN;
         var offsetX:Number = NaN;
         var camZoom:Number = NaN;
         var camRect:Rectangle = null;
         var camLeft:Number = NaN;
         var camRight:Number = NaN;
         var isTouchSide:Boolean = false;
         if(sp.allowCrossMapXY() == false)
         {
            var edgeMarginL:Number = (_map && _map.screenLeft > 0) ? _map.screenLeft : 10;
            var edgeMarginR:Number = (_map && _map.screenRight > 0) ? _map.screenRight : 10;
            left = _map.left + edgeMarginL;
            right = _map.right - edgeMarginR;
            offsetX = edgeMarginL;
            camZoom = _camera.getZoom();
            camRect = _camera.getScreenRect();
            if(sp is FighterMain)
            {
               if((sp as FighterMain).getVecX() != 0)
               {
                  if(_camera && _camera.stageCameraMode)
                  {
                     var camCenterX:Number = _camera.getStageCamCenterX();
                     var halfVisibleSpan:Number = 640.0 / camZoom;
                     camLeft = camCenterX - halfVisibleSpan + edgeMarginL;
                     camRight = camCenterX + halfVisibleSpan - edgeMarginR;
                     if(left < camLeft)
                     {
                        left = camLeft;
                     }
                     if(right > camRight)
                     {
                        right = camRight;
                     }
                  }
                  else if(Math.abs(camZoom - _camera.autoZoomMin) < 0.01 || camZoom <= _camera.autoZoomMin)
                  {
                     camLeft = camRect.x / camZoom + offsetX;
                     camRight = camLeft + camRect.width - offsetX;
                     if(left < camLeft)
                     {
                        left = camLeft;
                     }
                     if(right > camRight)
                     {
                        right = camRight;
                     }
                  }
               }
            }
            isTouchSide = false;
            if(sp.x <= left)
            {
               sp.x = left;
               isTouchSide = true;
            }
            if(sp.x >= right)
            {
               sp.x = right;
               isTouchSide = true;
            }
            sp.setIsTouchSide(isTouchSide);
         }
         if(sp.allowCrossMapBottom() == false)
         {
            if(sp.y > _map.bottom)
            {
               sp.y = _map.bottom;
            }
         }
      }
      
      public static function resetFighterHP(param1:FighterMain) : void
      {
         var _loc2_:Number = 1;
         if(GameMode.isAcrade() && MessionModel.I.getCurrentMessionStage())
         {
            _loc2_ = MessionModel.I.getCurrentMessionStage().hpRate;
         }
         if(param1.customHpMax > 0)
         {
            param1.hp = param1.hpMax = param1.customHpMax * GameData.I.config.fighterHP * _loc2_;
         }
         else
         {
            param1.hp = param1.hpMax = 1000 * GameData.I.config.fighterHP * _loc2_;
         }
         param1.isAlive = true;
      }
      
      public static function setMessionEnemyAttack(param1:FighterMain) : void
      {
         var _loc2_:MessionStageVO = MessionModel.I.getCurrentMessionStage();
         if(_loc2_)
         {
            param1.attackRate = _loc2_.attackRate;
         }
      }
      
      public static function canSelectFighter(id:String) : Boolean
      {
         var charList:SelectCharListConfigVO = GameData.I.config.select_config.charList;
         for each(var c:SelectCharListItemVO in charList.list)
         {
            if(c.fighterID == id)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function canSelectAssist(id:String) : Boolean
      {
         var assisterList:SelectCharListConfigVO = GameData.I.config.select_config.assistList;
         for each(var c:SelectCharListItemVO in assisterList.list)
         {
            if(c.fighterID == id)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function setGameMode(param1:int) : void
      {
         trace("setGameMode",param1);
         switch(param1 - 1)
         {
            case 0:
               GameData.I.loadSelect("data/salect.xml");
               SelectIndexUI.SHOW_MODE = 1;
               GameConfig.SHOW_UI_STATUS = 1;
               GameEndCtrl.SHOW_CONTINUE = true;
               GameConfig.MAP_LOGO_STATE = 2;
               break;
            case 1:
               GameData.I.loadDebugSelect("salect.xml");
               SelectIndexUI.SHOW_MODE = 1;
               GameConfig.SHOW_UI_STATUS = 1;
               GameConfig.MAP_LOGO_STATE = 2;
               GameEndCtrl.SHOW_CONTINUE = true;
               break;
            default:
               GameData.I.loadSelect("data/select.xml");
               ResUtils.WINNER = "winner_stg_mc";
               SelectIndexUI.SHOW_MODE = 0;
               GameConfig.SHOW_UI_STATUS = 0;
               GameConfig.MAP_LOGO_STATE = 1;
               GameEndCtrl.SHOW_CONTINUE = false;
         }
      }
   }
}

