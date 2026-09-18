package net.play5d.game.bvn.fighter.ctrler
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.fighter.FighterMC;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.models.FighterHitModel;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class FighterCtrler
   {
      
      public var hitModel:FighterHitModel;
      
      private var _effectCtrl:FighterEffectCtrl;
      
      private var _fighterMcCtrl:FighterMcCtrler;
      
      private var _voiceCtrl:FighterVoiceCtrler;
      
      private var _fighter:FighterMain;
      
      private var _rectCache:Object = {};
      
      private var _doingWankai:Boolean;
      
      public function FighterCtrler()
      {
         super();
      }
      
      public function destory() : void
      {
         if(_effectCtrl)
         {
            _effectCtrl.destory();
            _effectCtrl = null;
         }
         if(_fighterMcCtrl)
         {
            _fighterMcCtrl.destory();
            _fighterMcCtrl = null;
         }
         if(_voiceCtrl)
         {
            _voiceCtrl.destory();
            _voiceCtrl = null;
         }
         if(_rectCache)
         {
            _rectCache = null;
         }
         if(hitModel)
         {
            hitModel.destory();
            hitModel = null;
         }
         _fighter = null;
      }
      
      public function getEffectCtrl() : FighterEffectCtrl
      {
         return _effectCtrl;
      }
      
      public function getVoiceCtrl() : FighterVoiceCtrler
      {
         return _voiceCtrl;
      }
      
      public function get hp() : Number
      {
         return _fighter.hp;
      }
      
      public function set hp(param1:Number) : void
      {
         _fighter.hp = _fighter.hpMax = _fighter.customHpMax = param1;
      }
      
      public function get energy() : Number
      {
         return _fighter.energyMax;
      }
      
      public function set energy(param1:Number) : void
      {
         _fighter.energy = _fighter.energyMax = param1;
      }
      
      public function get speed() : Number
      {
         return _fighter.speed;
      }
      
      public function set speed(param1:Number) : void
      {
         _fighter.speed = param1;
      }
      
      public function get jumpPower() : Number
      {
         return _fighter.jumpPower;
      }
      
      public function set jumpPower(param1:Number) : void
      {
         _fighter.jumpPower = param1;
      }
      
      public function get heavy() : Number
      {
         return _fighter.heavy;
      }
      
      public function set heavy(param1:Number) : void
      {
         _fighter.heavy = param1;
      }
      
      public function get defenseType() : int
      {
         return _fighter.defenseType;
      }
      
      public function set defenseType(param1:int) : void
      {
         _fighter.defenseType = param1;
      }
      
      public function addHp(param1:Number) : void
      {
         _fighter.addHp(param1);
      }
      
      public function addHpPercent(param1:Number) : void
      {
         _fighter.addHp(_fighter.hpMax * param1);
      }
      
      public function loseHp(param1:Number) : void
      {
         _fighter.loseHp(param1);
      }
      
      public function loseHpPercent(param1:Number) : void
      {
         _fighter.loseHp(param1 * _fighter.hpMax);
      }
      
      public function getEnergy() : Number
      {
         return _fighter.energy;
      }
      
      public function getEnergyOverload() : Boolean
      {
         return _fighter.energyOverLoad;
      }
      
      public function loseEnergy(param1:Number) : void
      {
         _fighter.useEnergy(param1);
      }
      
      public function loseQi(param1:Number) : void
      {
         _fighter.useQi(param1);
      }
      
      public function get self() : DisplayObject
      {
         return _fighter.getDisplay();
      }
      
      public function get target() : DisplayObject
      {
         var _loc1_:IGameSprite = _fighter.getCurrentTarget();
         if(!_loc1_)
         {
            return null;
         }
         return _loc1_.getDisplay();
      }
      
      public function getTargetSP() : IGameSprite
      {
         var _loc1_:IGameSprite = _fighter.getCurrentTarget();
         if(!_loc1_)
         {
            return null;
         }
         return _loc1_;
      }
      
      public function getTargetState() : int
      {
         var _loc1_:FighterMain = _fighter.getCurrentTarget() as FighterMain;
         if(!_loc1_)
         {
            return 0;
         }
         return _loc1_.actionState;
      }
      
      public function setTargetVelocity(param1:Number, param2:Number) : void
      {
         var _loc3_:IGameSprite = _fighter.getCurrentTarget();
         if(_loc3_ && _loc3_ is BaseGameSprite)
         {
            (_loc3_ as BaseGameSprite).setVelocity(param1,param2);
         }
      }
      
      public function setTargetDamping(param1:Number, param2:Number) : void
      {
         var _loc3_:IGameSprite = _fighter.getCurrentTarget();
         if(_loc3_ && _loc3_ is BaseGameSprite)
         {
            (_loc3_ as BaseGameSprite).setDamping(param1,param2);
         }
      }
      
      public function targetInRange(param1:Array = null, param2:Array = null) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc5_:DisplayObject = this.target;
         if(!target)
         {
            return false;
         }
         var _loc6_:DisplayObject = this.self;
         if(_fighter.direct > 0)
         {
            _loc3_ = _loc5_.x - _loc6_.x;
         }
         else
         {
            _loc3_ = _loc6_.x - _loc5_.x;
         }
         var _loc8_:Number = _loc5_.y - _loc6_.y;
         var _loc7_:Boolean = true;
         var _loc4_:Boolean = true;
         if(param1)
         {
            _loc7_ = _loc3_ >= param1[0] && _loc3_ <= param1[1];
         }
         if(param2)
         {
            _loc4_ = _loc8_ >= param2[0] && _loc8_ <= param2[1];
         }
         return _loc7_ && _loc4_;
      }
      
      public function justHit(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc4_:HitVO = null;
         var _loc3_:HitVO = null;
         var _loc5_:IGameSprite = _fighter.getCurrentTarget();
         if(_loc5_ && _loc5_ is FighterMain)
         {
            _loc4_ = (_loc5_ as FighterMain).hurtHit;
            if(_loc4_)
            {
               return _loc4_.id == param1;
            }
            if(param2)
            {
               _loc3_ = (_loc5_ as FighterMain).defenseHit;
               if(_loc3_)
               {
                  return _loc3_.id == param1;
               }
            }
         }
         return false;
      }
      
      public function getMcCtrl() : FighterMcCtrler
      {
         return _fighterMcCtrl;
      }
      
      public function initFighter(param1:FighterMain) : void
      {
         var _loc2_:Object = null;
         _fighter = param1;
         hitModel = new FighterHitModel(_fighter);
         _voiceCtrl = new FighterVoiceCtrler();
         _effectCtrl = new FighterEffectCtrl(param1);
         _fighterMcCtrl = new FighterMcCtrler(param1);
         _fighterMcCtrl.effectCtrler = _effectCtrl;
         if(param1.mc.initFighter)
         {
            _loc2_ = {
               "fighter_ctrler":this,
               "mc_ctrler":_fighterMcCtrl,
               "effect_ctrler":_effectCtrl
            };
            param1.mc.initFighter(_loc2_);
         }
         else
         {
            if(!param1.mc.setFighterCtrler)
            {
               throw new Error("初始化失败，SWF未定义setFighterCtrler()");
            }
            param1.mc.setFighterCtrler(this);
            if(!param1.mc.setEffectCtrler)
            {
               throw new Error("初始化效果接口失败，SWF未定义setEffectCtrler()");
            }
            param1.mc.setEffectCtrler(_effectCtrl);
            if(!param1.mc.setFighterMcCtrler)
            {
               throw new Error("初始化效果接口失败，SWF未定义setFighterMcCtrler()");
            }
            param1.mc.setFighterMcCtrler(_fighterMcCtrl);
         }
      }
      
      public function renderAnimate() : void
      {
         if(_fighterMcCtrl)
         {
            _fighterMcCtrl.renderAnimate();
         }
      }
      
      public function render() : void
      {
         if(_fighterMcCtrl)
         {
            _fighterMcCtrl.render();
         }
      }
      
      public function setActionCtrl(param1:IFighterActionCtrl) : void
      {
         if(_fighterMcCtrl)
         {
            _fighterMcCtrl.setActionCtrler(param1);
         }
         else
         {
            trace("设置ctrler失败！");
         }
      }
      
      public function defineAction(param1:String, param2:Object) : void
      {
         hitModel.addHitVO(param1,param2);
      }
      
      public function defineBishaFace(param1:String, param2:Class) : void
      {
         _effectCtrl.setBishaFace(param1,param2);
      }
      
      public function defineHurtSound(... rest) : void
      {
         _voiceCtrl.setVoice(0,rest);
      }
      
      public function defineHurtFlySound(... rest) : void
      {
         _voiceCtrl.setVoice(1,rest);
      }
      
      public function defineDieSound(... rest) : void
      {
         _voiceCtrl.setVoice(2,rest);
      }
      
      public function initMc(param1:MovieClip) : void
      {
         var _loc2_:FighterMC = null;
         if(param1)
         {
            _loc2_ = _fighterMcCtrl.initMc(param1);
            if(_doingWankai)
            {
               _fighter.actionState = 50;
               _loc2_.goFrame("开场");
               _doingWankai = false;
            }
            else
            {
               _fighterMcCtrl.idle();
            }
            _fighter.onMcInited();
            return;
         }
         throw new Error("FighterCtrler.initMc Error :: mc is null!");
      }
      
      public function getCurrentHits() : Array
      {
         var _loc1_:Array;
         var _loc6_:Array = null;
         var _loc4_:int = 0;
         var _loc8_:Object = null;
         var _loc3_:HitVO = null;
         var _loc5_:* = null;
         var _loc2_:Rectangle = null;
         var _loc7_:String = null;
         try
         {
            _loc6_ = _fighter.getMC().getCurrentHitArea();
         }
         catch(e:Error)
         {
            trace("FighterCtrler.getCurrentHits::",e);
         }
         if(!_loc6_ || _loc6_.length < 1)
         {
            return null;
         }
         _loc1_ = [];
         _loc4_;
         while(_loc4_ < _loc6_.length)
         {
            _loc8_ = _loc6_[_loc4_];
            _loc7_ = _loc8_.name;
            _loc3_ = _loc8_.hitVO;
            if(_loc3_)
            {
               _loc2_ = _loc8_.area;
               _loc3_.currentArea = getCurrentRect(_loc2_,"hit" + _loc4_);
               _loc1_.push(_loc3_);
            }
            _loc4_++;
         }
         return _loc1_;
      }
      
      public function getBodyArea() : Rectangle
      {
         var _loc1_:Rectangle = null;
         var _loc2_:FighterMC = null;
         try
         {
            _loc2_ = _fighter.getMC();
            _loc1_ = _loc2_.getCurrentBodyArea();
         }
         catch(e:Error)
         {
            trace(_fighter.data.name);
            trace("FighterCtrler.getBodyArea::",e);
         }
         if(_loc1_ == null)
         {
            return null;
         }
         return getCurrentRect(_loc1_,"body");
      }
      
      public function getHitCheckRect(param1:String) : Rectangle
      {
         var _loc2_:Rectangle = _fighter.getMC().getCheckHitRect(param1);
         if(_loc2_ == null)
         {
            return null;
         }
         return getCurrentRect(_loc2_,"hit_check");
      }
      
      public function getCurrentRect(rawRect:Rectangle, cacheKey:String = null) : Rectangle
      {
         var targetRect:Rectangle = null;
         if(cacheKey == null)
         {
            targetRect = new Rectangle();
         }
         else if(_rectCache[cacheKey])
         {
            targetRect = _rectCache[cacheKey];
         }
         else
         {
            targetRect = new Rectangle();
            _rectCache[cacheKey] = targetRect;
         }
         var sc:Number = _fighter ? _fighter.scale : 1;
         targetRect.x = (rawRect.x * _fighter.direct) * sc + _fighter.x;
         if(_fighter.direct < 0)
         {
            targetRect.x -= rawRect.width * sc;
         }
         targetRect.y = rawRect.y * sc + _fighter.y;
         targetRect.width = rawRect.width * sc;
         targetRect.height = rawRect.height * sc;
         return targetRect;
      }
      
      public function doWanKai(param1:int = 0) : void
      {
         _doingWankai = true;
         if(param1 == 0)
         {
            _fighter.mc.nextFrame();
         }
         else
         {
            _fighter.mc.gotoAndStop(param1);
         }
      }
      
      public function setDirectToTarget() : void
      {
         var _loc1_:IGameSprite = _fighter.getCurrentTarget();
         if(!_loc1_)
         {
            return;
         }
         _fighter.direct = _fighter.x < _loc1_.x ? 1 : -1;
      }
      
      public function moveOnce(param1:Number = 0, param2:Number = 0) : void
      {
         _fighter.x += param1 * _fighter.direct;
         _fighter.y += param2;
      }
      
      public function moveToTarget(param1:Object = null, param2:Object = null, param3:Boolean = true) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:IGameSprite = _fighter.getCurrentTarget();
         if(!_loc6_)
         {
            return;
         }
         if(param1 != null)
         {
            _loc4_ = Number(param1);
            _loc5_ = _loc6_.x + _loc4_ * _fighter.direct;
            if(_loc4_ > 0)
            {
               try
               {
                  if(_loc6_.x < _loc4_)
                  {
                     _loc5_ = _loc6_.x + _loc4_;
                  }
                  else if(_loc6_.x > GameCtrl.I.gameState.getMap().right - _loc4_)
                  {
                     _loc5_ = _loc6_.x - _loc4_;
                  }
               }
               catch(e:Error)
               {
               }
            }
            _fighter.x = _loc5_;
         }
         if(param2 != null)
         {
            _fighter.y = _loc6_.y + Number(param2);
         }
         if(param3)
         {
            _fighter.direct = _fighter.x < _loc6_.x ? 1 : -1;
         }
      }
      
      public function setCross(param1:Boolean) : void
      {
         _fighter.isCross = param1;
      }
      
      public function getHitRange(param1:String) : Rectangle
      {
         var _loc2_:Rectangle = _fighter.getMC().getHitRange(param1);
         if(_loc2_ == null)
         {
            return null;
         }
         return getCurrentRect(_loc2_,"hitRange_" + param1);
      }
   }
}

