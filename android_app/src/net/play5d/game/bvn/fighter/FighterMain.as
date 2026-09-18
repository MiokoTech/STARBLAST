package net.play5d.game.bvn.fighter
{
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.filters.ColorMatrixFilter;
   import flash.display.BlendMode;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.ctrl.mosou_ctrls.MosouLogic;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.TeamVO;
   import net.play5d.game.bvn.data.mosou.MosouEnemyVO;
   import net.play5d.game.bvn.data.mosou.MosouFighterLogic;
   import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
   import net.play5d.game.bvn.fighter.ctrler.FighterBuffCtrler;
   import net.play5d.game.bvn.fighter.ctrler.FighterCtrler;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class FighterMain extends BaseGameSprite
   {
      
      public var qi:Number = 0;
      
      public var qiMax:Number = GameConfig.BISHA_QI_MAX;
      
      public var energy:Number = 100;
      
      public var energyMax:Number = 100;
      
      public var energyOverLoad:Boolean = false;
      
      public var customHpMax:int = 0;
      
      public var fzqi:Number = 100;
      
      public const fzqiMax:Number = 100;
      
      private var _speed:Number = 6;
      
      public var speed:Number = 6;
      
      public var jumpPower:Number = 15;
      
      public var isSteelBody:Boolean = false;
      
      public var isSuperSteelBody:Boolean = false;
      
      private var _data:FighterVO;
      
      public function get data() : FighterVO
      {
         return _data;
      }
      
      public function set data(val:FighterVO) : void
      {
         _data = val;
         if(_data)
         {
            this.scale = LocalCoordManager.getScale(_data.id);
         }
      }
      
      public function updateScale(isStageCustom:Boolean = false, stageCoordX:Number = 0, stageCoordY:Number = 0) : void
      {
         if(_data)
         {
            this.scale = LocalCoordManager.getScaleForStage(_data.id, isStageCustom, stageCoordX, stageCoordY);
         }
      }
      
      
      
      public var mosouPlayerData:MosouFighterVO;
      
      public var mosouEnemyData:MosouEnemyVO;
      
      public var airHitTimes:int = 1;
      
      public var jumpTimes:int = 2;
      
      public var actionState:int = 0;
      
      public var defenseType:int = 0;
      
      public var lastHitVO:HitVO;
      
      public var introSaid:Boolean = false;
      
      public var mosouLogic:MosouFighterLogic;
      
      private var _buffCtrler:FighterBuffCtrler;
      
      private var _currentHurts:Vector.<HitVO>;
      
      private var _mosouPlayerLogic:MosouFighterLogic;
      
      public var hurtHit:HitVO;
      
      public var defenseHit:HitVO;
      
      public var targetTeams:Vector.<TeamVO>;
      
      private var _currentTarget:IGameSprite;
      
      private var _fighterCtrl:FighterCtrler;
      
      private var _energyAddGap:int;
      
      private var _explodeHitVO:HitVO;
      
      private var _explodeHitFrame:int;
      
      private var _explodeSteelFrame:int;
      
      private var _replaceSkillFrame:int;
      
      private var _speedBack:Number = 0;
      
            private var _bnoColor:ColorMatrixFilter;      

      public function FighterMain(param1:MovieClip)
      {
         super(param1);
         introSaid = false;
         _area = null;
         if(!param1)
         {
            throw new Error("人物创建失败, mainMc is null !");
         }
      }
      
            
      public function changeColor(param1:ColorTransform) : void
      {
         _mainMc.transform.colorTransform = param1;
      }
      
      public function resumeColor() : void
      {
         _mainMc.transform.colorTransform = _colorTransform ? _colorTransform : new ColorTransform();
      }

      public function getMosouLogic() : MosouFighterLogic
      {
         return _mosouPlayerLogic;
      }
      
      override public function setActive(param1:Boolean) : void
      {
         super.setActive(param1);
         if(!param1 && _fighterCtrl && _fighterCtrl.getEffectCtrl())
         {
            _fighterCtrl.getEffectCtrl().clean();
         }
      }
      
      override public function destory(param1:Boolean = true) : void
      {
         if(!param1)
         {
            return;
         }
         if(_fighterCtrl)
         {
            _fighterCtrl.destory();
            _fighterCtrl = null;
         }
         if(_mainMc)
         {
            _mainMc.filters = null;
            _mainMc.gotoAndStop(1);
         }
         if(_buffCtrler)
         {
            _buffCtrler.destory();
            _buffCtrler = null;
         }
         if(data)
         {
            data = null;
         }
         if(mosouEnemyData)
         {
            mosouEnemyData = null;
         }
         targetTeams = null;
         _currentTarget = null;
         _currentHurts = null;
         super.destory(param1);
      }
      
      override public function set attackRate(param1:Number) : void
      {
         super.attackRate = param1;
         if(_fighterCtrl && _fighterCtrl.hitModel)
         {
            _fighterCtrl.hitModel.setPowerRate(param1);
         }
      }
      
      public function currentHurtDamage() : int
      {
         if(!_currentHurts)
         {
            return 0;
         }
         var _loc1_:int = 0;
         for each(var _loc2_:HitVO in _currentHurts)
         {
            _loc1_ += _loc2_.getDamage();
         }
         return _loc1_;
      }
      
      public function getLastHurtHitVO() : HitVO
      {
         if(!_currentHurts)
         {
            return null;
         }
         return _currentHurts[_currentHurts.length - 1];
      }
      
      public function hurtBreakHit() : Boolean
      {
         for each(var _loc1_:HitVO in _currentHurts)
         {
            if(_loc1_.isBreakDef)
            {
               return true;
            }
         }
         return false;
      }
      
      public function clearHurtHits() : void
      {
         _currentHurts = null;
      }
      
      public function getCtrler() : FighterCtrler
      {
         return _fighterCtrl;
      }
      
      public function getBuffCtrl() : FighterBuffCtrler
      {
         return _buffCtrler;
      }
      
      public function getCurrentTarget() : IGameSprite
      {
         var _loc4_:BaseGameSprite = null;
         var _loc5_:MosouEnemyVO = null;
         if(_currentTarget)
         {
            _loc4_ = _currentTarget as BaseGameSprite;
            if(_loc4_ && _loc4_.isAlive && _loc4_.getActive())
            {
               return _currentTarget;
            }
         }
         var _loc3_:Vector.<IGameSprite> = getTargets();
         var _loc1_:Array = [];
         if(_loc3_ && _loc3_.length > 0)
         {
            for each(var _loc2_:IGameSprite in _loc3_)
            {
               if(_loc2_.getBodyArea() == null)
               {
                  _loc1_.push({
                     "fighter":_loc2_,
                     "order":5
                  });
               }
               else if(_loc2_ is FighterMain && (_loc2_ as FighterMain).isAlive && _loc2_.getActive())
               {
                  _loc5_ = (_loc2_ as FighterMain).mosouEnemyData;
                  if(_loc5_)
                  {
                     if(_loc5_.isBoss)
                     {
                        _loc1_.push({
                           "fighter":_loc2_,
                           "order":0
                        });
                     }
                     else
                     {
                        _loc1_.push({
                           "fighter":_loc2_,
                           "order":1
                        });
                     }
                  }
                  else
                  {
                     _loc1_.push({
                        "fighter":_loc2_,
                        "order":0
                     });
                  }
               }
               else if(_loc2_ is BaseGameSprite && (_loc2_ as BaseGameSprite).isAlive && _loc2_.getActive())
               {
                  _loc1_.push({
                     "fighter":_loc2_,
                     "order":10
                  });
               }
               else
               {
                  _loc1_.push({
                     "fighter":_loc2_,
                     "order":20
                  });
               }
            }
            _loc1_.sortOn("order",16);
            _currentTarget = _loc1_[0].fighter;
         }
         return _currentTarget;
      }
      
      public function getTargets() : Vector.<IGameSprite>
      {
         var _loc1_:int = 0;
         if(!targetTeams || targetTeams.length < 1)
         {
            return null;
         }
         var _loc2_:Vector.<IGameSprite> = new Vector.<IGameSprite>();
         while(_loc1_ < targetTeams.length)
         {
            _loc2_ = _loc2_.concat(targetTeams[_loc1_].getAliveChildren());
            _loc1_++;
         }
         return _loc2_;
      }
      
      public function getMC() : FighterMC
      {
         if(!_fighterCtrl)
         {
            return null;
         }
         if(!_fighterCtrl.getMcCtrl())
         {
            return null;
         }
         return _fighterCtrl.getMcCtrl().getFighterMc();
      }
      
      public function disableShadow() : void
      {
         var fmc:FighterMC = getMC();
         if(fmc)
         {
            fmc.disableShadow();
         }
      }
      
      public function initMosouFighter(param1:MosouFighterVO) : void
      {
         mosouPlayerData = param1;
         _mosouPlayerLogic = new MosouFighterLogic(param1);
         updateProperties();
      }
      
      public function initMosouEnemy(param1:MosouEnemyVO) : void
      {
         mosouEnemyData = param1;
      }
      
      public function updateProperties() : void
      {
         if(!mosouPlayerData || !_mosouPlayerLogic)
         {
            return;
         }
         hp = hpMax = _mosouPlayerLogic.getHP();
         qiMax = _mosouPlayerLogic.getQI();
         energy = energyMax = _mosouPlayerLogic.getEnergy();
         qi = qiMax;
         if(_mosouPlayerLogic)
         {
            _mosouPlayerLogic.initFighterProps(this);
         }
      }
      
      public function setActionCtrl(param1:IFighterActionCtrl) : void
      {
         if(_fighterCtrl)
         {
            _fighterCtrl.setActionCtrl(param1);
            param1.initlize();
         }
      }
      
      public function initlized() : Boolean
      {
         return _fighterCtrl != null;
      }
      
      public function initlize() : void
      {
         if(_fighterCtrl)
         {
            throw new Error("fighter 已完成化！");
         }
         qiMax = GameConfig.BISHA_QI_MAX;
         if(qi > qiMax)
         {
            qi = qiMax;
         }
         _fighterCtrl = new FighterCtrler();
         _buffCtrler = new FighterBuffCtrler(this);
         _fighterCtrl.initFighter(this);
         var configuredStartFrame:int = 1;
         if(data && data.startFrame > 0)
         {
            configuredStartFrame = data.startFrame;
         }
         var preferredTimelineFrame:int = configuredStartFrame + 1;
         if(preferredTimelineFrame < 2 || (_mainMc && preferredTimelineFrame > _mainMc.totalFrames))
         {
            preferredTimelineFrame = 2;
         }
         try
         {
            _mainMc.gotoAndStop(preferredTimelineFrame);
         }
         catch(e:Error)
         {
            try
            {
               _mainMc.gotoAndStop(configuredStartFrame);
            }
            catch(e2:Error)
            {
               try
               {
                  _mainMc.gotoAndStop(2);
               }
               catch(e3:Error)
               {
               }
            }
         }
      }
      
      public function onMcInited() : void
      {
         if(_mosouPlayerLogic)
         {
            _mosouPlayerLogic.initFighterProps(this);
         }
         if(mosouEnemyData)
         {
            MosouLogic.I.initEnemyProps(this);
         }
      }
      
      public function initAttackAddDmg(param1:int, param2:int = 0, param3:int = 0) : void
      {
         var _loc6_:HitVO = null;
         if(!_fighterCtrl || !_fighterCtrl.hitModel)
         {
            return;
         }
         var _loc4_:Object = _fighterCtrl.hitModel.getAll();
         for(var _loc5_:String in _loc4_)
         {
            _loc6_ = _loc4_[_loc5_];
            if(_loc6_.isBisha())
            {
               _loc6_.powerAdd = param3;
            }
            else if(_loc6_.isSkill())
            {
               _loc6_.powerAdd = param2;
            }
            else
            {
               _loc6_.powerAdd = param1;
            }
         }
      }
      
      override public function renderAnimate() : void
      {
         super.renderAnimate();
         if(_destoryed)
         {
            return;
         }
         renderEnergy();
         renderFzQi();
         if(_fighterCtrl)
         {
            _fighterCtrl.renderAnimate();
         }
         if(_explodeHitFrame > 0)
         {
            _explodeHitFrame--;
            if(_explodeHitFrame == 8)
            {
               idle();
               isAllowBeHit = false;
            }
            if(_explodeHitFrame <= 0)
            {
               _explodeHitVO = null;
               isAllowBeHit = true;
            }
         }
         if(_explodeSteelFrame > 0)
         {
            _explodeSteelFrame--;
            _fighterCtrl.getMcCtrl().setSteelBody(true,true);
            if(_explodeSteelFrame <= 0)
            {
               _fighterCtrl.getMcCtrl().setSteelBody(false);
            }
         }
         if(_replaceSkillFrame > 0)
         {
            _replaceSkillFrame--;
            if(_replaceSkillFrame <= 0)
            {
               isAllowBeHit = true;
            }
         }
      }
      
      override public function render() : void
      {
         super.render();
         if(_destoryed)
         {
            return;
         }
         if(_fighterCtrl)
         {
            _fighterCtrl.render();
         }
         if(_buffCtrler)
         {
            _buffCtrler.render();
         }
         if(hp < 0)
         {
            hp = 0;
         }
         if(hp > hpMax)
         {
            hp = hpMax;
         }
         if(qi < 0)
         {
            qi = 0;
         }
         if(qi > qiMax)
         {
            qi = qiMax;
         }
         if(fzqi < 0)
         {
            fzqi = 0;
         }
         if(fzqi > 100)
         {
            fzqi = 100;
         }
      }
      
      public function jump() : void
      {
         _g = 0;
         setVelocity(0,-jumpPower);
         setDamping(0,0.5);
      }
      
      override public function getCurrentHits() : Array
      {
         if(_explodeHitVO && _explodeHitFrame < 8)
         {
            return [_explodeHitVO];
         }
         return _fighterCtrl.getCurrentHits();
      }
      
      override public function getBodyArea() : Rectangle
      {
         if(!_fighterCtrl)
         {
            return null;
         }
         return _fighterCtrl.getBodyArea();
      }
      
      override public function hit(param1:HitVO, param2:IGameSprite) : void
      {
         super.hit(param1,param2);
         lastHitVO = param1;
         var _loc3_:Number = 0;
         if(param2 is FighterMain)
         {
            if(param1.isBisha())
            {
               _loc3_ = param1.power * GameConfig.QI_ADD_HIT_BISHA_RATE;
            }
            else
            {
               _loc3_ = param1.power * GameConfig.QI_ADD_HIT_RATE;
            }
            _loc3_ *= GameConfig.QI_GAIN_RATE;
            if(_loc3_ > GameConfig.QI_ADD_HIT_MAX * GameConfig.QI_GAIN_RATE)
            {
               _loc3_ = GameConfig.QI_ADD_HIT_MAX * GameConfig.QI_GAIN_RATE;
            }
         }
         addQi(_loc3_);
         GameLogic.hitTarget(param1,this,param2);
      }
      
      override public function beHit(param1:HitVO, param2:Rectangle = null) : void
      {
         if(!isAllowBeHit)
         {
            return;
         }
         super.beHit(param1,param2);
         _fighterCtrl.getMcCtrl().beHit(param1,param2);
         var _loc3_:Number = param1.power * GameConfig.QI_ADD_HURT_RATE;
         _loc3_ *= GameConfig.QI_GAIN_RATE;
         if(_loc3_ > GameConfig.QI_ADD_HURT_MAX * GameConfig.QI_GAIN_RATE)
         {
            _loc3_ = GameConfig.QI_ADD_HURT_MAX * GameConfig.QI_GAIN_RATE;
         }
         addQi(_loc3_);
         if(actionState == 21 || actionState == 22)
         {
            if(!_currentHurts)
            {
               _currentHurts = new Vector.<HitVO>();
            }
            _currentHurts.push(param1);
         }
      }
      
      private function renderEnergy() : void
      {
         if(_energyAddGap > 0)
         {
            _energyAddGap--;
            return;
         }
         if(energy < energyMax)
         {
            if(energyOverLoad)
            {
               energy += 0.6;
               if(energy > 30)
               {
                  energyOverLoad = false;
               }
            }
            else if(actionState == 20)
            {
               energy += 0.8;
            }
            else if(FighterActionState.isAttacking(actionState))
            {
               energy += 1.1;
            }
            else
            {
               energy += 2;
            }
         }
      }
      
      private function renderFzQi() : void
      {
         if(fzqi < 100)
         {
            fzqi += 0.2;
         }
      }
      
      public function hasEnergy(param1:Number, param2:Boolean = false) : Boolean
      {
         if(energy >= param1)
         {
            return true;
         }
         if(param2)
         {
            if(!energyOverLoad)
            {
               return true;
            }
         }
         return false;
      }
      
      public function useEnergy(param1:Number) : void
      {
         energy -= param1;
         _energyAddGap = 0.8 * 30;
         if(energy < 0)
         {
            energy = 0;
            energyOverLoad = true;
         }
      }
      
      public function useQi(param1:Number) : Boolean
      {
         if(qi < param1)
         {
            return false;
         }
         qi -= param1;
         return true;
      }
      
      public function addQi(param1:Number) : void
      {
         qi += param1;
         if(qi > qiMax)
         {
            qi = qiMax;
         }
      }
      
      public function sayIntro() : void
      {
         introSaid = true;
         _fighterCtrl.getMcCtrl().sayIntro();
      }
      
      public function win() : void
      {
         _fighterCtrl.getMcCtrl().doWin();
      }
      
      public function idle() : void
      {
         _fighterCtrl.getMcCtrl().idle();
      }
      
      public function lose() : void
      {
         _fighterCtrl.getMcCtrl().doLose();
      }
      
      public function getHitRange(param1:String) : Rectangle
      {
         return _fighterCtrl.getHitRange(param1);
      }
      
      public function energyExplode() : void
      {
         _fighterCtrl.getEffectCtrl().energyExplode();
         _fighterCtrl.getMcCtrl().setSteelBody(true,true);
         _explodeHitVO = new HitVO();
         var _loc1_:Rectangle = new Rectangle(-100,-200,200,210);
         _explodeHitVO.currentArea = _fighterCtrl.getCurrentRect(_loc1_);
         _explodeHitVO.power = 50;
         _explodeHitVO.hitx = 15 * direct;
         _explodeHitVO.hitType = 5;
         _explodeHitVO.hurtType = 1;
         _explodeHitFrame = 10;
         _explodeSteelFrame = 60;
         isAllowBeHit = false;
      }
      
      public function replaceSkill() : void
      {
         _fighterCtrl.getEffectCtrl().replaceSkill();
         move(250 * direct);
         idle();
         isAllowBeHit = false;
         super.render();
         renderAnimate();
         _fighterCtrl.setDirectToTarget();
         _replaceSkillFrame = 30;
      }
      
      override public function getArea() : Rectangle
      {
         if(!_area)
         {
            _area = getBodyArea();
         }
         return _area;
      }
      
      public function hasWankai() : Boolean
      {
         return _fighterCtrl.getMcCtrl().getFighterMc().checkFrame("万解");
      }
      
      public function die() : void
      {
         hp = 0;
         isAlive = false;
         if(!FighterActionState.isHurting(actionState) && actionState != 30)
         {
            _fighterCtrl.getMcCtrl().getFighterMc().playHurtDown();
         }
      }
      
      public function relive(param1:Boolean = false) : void
      {
         isAlive = true;
         if(param1)
         {
            hp = hpMax;
            qi = 0;
         }
         idle();
      }
      
      public function isMosouEnemy() : Boolean
      {
         if(!mosouEnemyData)
         {
            return false;
         }
         return !mosouEnemyData.isBoss;
      }
      
      public function isMosouBoss() : Boolean
      {
         if(!mosouEnemyData)
         {
            return false;
         }
         return mosouEnemyData.isBoss;
      }
   }
}

