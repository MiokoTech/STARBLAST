package net.play5d.game.bvn.fighter
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.fighter.ctrler.FighterMcCtrler;
   import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
   import net.play5d.game.bvn.fighter.models.FighterHitModel;
   import net.play5d.game.bvn.fighter.utils.McAreaCacher;
   import net.play5d.game.bvn.utils.MCUtils;
   import net.play5d.game.bvn.views.effects.ShadowEffectView;
   
   public class FighterMC
   {
      
      private var _mcCtrler:FighterMcCtrler;
      
      private var _fighter:FighterMain;
      
      private var _fighterDisplay:DisplayObject;
      
      private var _renderMainAnimate:Boolean = false;
      
      private var _renderMainAnimateFrame:int = 0;
      
      private var _curFrameName:String;
      
      private var _curMainFrameCount:int;
      
      private var _curFrameCount:int;
      
      private var _mc:MovieClip;
      
      private var _undefinedFrames:Array = [];
      
      private var _hurtFlyFrame:int = 0;
      
      private var _hurtDownFrame:int;
      
      private var _hurtFlyState:int;
      
      private var _hurtYMin:Number = 0;
      
      private var _isHeavyDownAttack:Boolean;
      
      private var _bodyAreaCache:McAreaCacher = new McAreaCacher("body");
      
      private var _hitAreaCache:McAreaCacher = new McAreaCacher("hit");
      
      private var _hitCheckAreaCache:McAreaCacher = new McAreaCacher("hit_check");
      
      private var _hitRangeInited:Boolean;
      
      private var _hitRangeObj:Object;
      
      private var _goFrameDelay:Object = null;
      
      private var _hitx:Number = 0;
      
      private var _hity:Number = 0;
      
      private var _hasHitWall:Boolean = false;
      
      private var _shadowEffect:ShadowEffectView;
      
      private var _shadowContainer:Sprite;
      
      private var _shadowEffects:Dictionary;
      
      public var shadowIng:Boolean = true;
      
      private var _pauseShadowBySuper:Boolean = false;
      
      private var _groundY:Number = NaN;
      
      public function FighterMC()
      {
         super();
      }
      
      public function get currentFrameName() : String
      {
         return this._curFrameName;
      }
      
      public function getCurrentFrame() : int
      {
         return this._mc.currentFrame;
      }
      
      public function getCurrentFrameCount() : int
      {
         return this._curFrameCount;
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      public function get x() : Number
      {
         return this._mc.x;
      }
      
      public function set x(param1:Number) : void
      {
         this._mc.x = param1;
      }
      
      public function get y() : Number
      {
         return this._mc.y;
      }
      
      public function set y(param1:Number) : void
      {
         this._mc.y = param1;
      }
      
      public function initlize(mcObj:MovieClip, fighterMain:FighterMain, mcCtrler:FighterMcCtrler) : void
      {
         this._mc = mcObj;
         this._fighter = fighterMain;
         this._fighterDisplay = fighterMain.getDisplay();
         this._mcCtrler = mcCtrler;
         this._groundY = NaN;
         this._shadowContainer = new Sprite();
         this._shadowEffects = new Dictionary();
         if(Boolean(this._mc) && Boolean(this._mc.parent))
         {
            this._mc.parent.addChildAt(this._shadowContainer,this._mc.parent.getChildIndex(this._mc));
         }
         this.startShadow(this._mc,0,0,0);
         MCUtils.applyPixelArtStyle(this._mc);
      }
      
      public function destory() : void
      {
         if(this._bodyAreaCache)
         {
            this._bodyAreaCache.destory();
            this._bodyAreaCache = null;
         }
         if(this._hitAreaCache)
         {
            this._hitAreaCache.destory();
            this._hitAreaCache = null;
         }
         if(this._hitCheckAreaCache)
         {
            this._hitCheckAreaCache.destory();
            this._hitCheckAreaCache = null;
         }
         if(this._shadowEffect)
         {
            this._shadowEffect.destory();
            this._shadowEffect = null;
         }
         if(Boolean(this._shadowContainer) && Boolean(this._shadowContainer.parent))
         {
            this._shadowContainer.parent.removeChild(this._shadowContainer);
            this._shadowContainer = null;
         }
         this._mc = null;
         this._fighter = null;
         this._fighterDisplay = null;
         this._undefinedFrames = null;
         if(this._shadowEffects)
         {
            for each(var sView:ShadowEffectView in this._shadowEffects)
            {
               if(sView)
               {
                  sView.destory();
               }
            }
            this._shadowEffects = null;
         }
      }
      
      public function getChildByName(param1:String) : DisplayObject
      {
         return this._mc.getChildByName(param1);
      }
      
      public function renderAnimate() : void
      {
         if(this._renderMainAnimate)
         {
            if(this._renderMainAnimateFrame > 0)
            {
               if(--this._renderMainAnimateFrame <= 0)
               {
                  this._renderMainAnimate = false;
               }
               ++this._curMainFrameCount;
            }
            try
            {
               this._mc.nextFrame();
            }
            catch(e:Error)
            {
            }
         }
         this.renderChildren();
         this.findBodyArea();
         this.findHitArea();
         if(!this._pauseShadowBySuper)
         {
            if(this._fighter)
            {
               if(!this._fighter.isInAir)
               {
                  this._groundY = this._fighter.y;
               }
               else if(isNaN(this._groundY) || this._fighter.y > this._groundY)
               {
                  this._groundY = this._fighter.y;
               }
            }
            var shadowView:ShadowEffectView = null;
            for each(shadowView in this._shadowEffects)
            {
               if(shadowView)
               {
                  shadowView.groundY = this._groundY;
                  shadowView.render();
               }
            }
            if(this._shadowContainer)
            {
               if(this._fighter && this._fighter.isInAir)
               {
                  var jumpDist:Number = Math.max(0, this._groundY - this._fighter.y);
                  var targetAirAlpha:Number = Math.max(0.18, 0.5 - (jumpDist / 600) * 0.32);
                  this._shadowContainer.alpha += (targetAirAlpha - this._shadowContainer.alpha) * 0.25;
               }
               else
               {
                  this._shadowContainer.alpha += (0.5 - this._shadowContainer.alpha) * 0.25;
               }
               this._shadowContainer.visible = this._shadowContainer.alpha > 0.05;
            }
         }
         if(this._hurtFlyState != 0)
         {
            this.renderHurtFly();
         }
         ++this._curFrameCount;
         if(this._goFrameDelay)
         {
            if(this._goFrameDelay.delay-- <= 0)
            {
               if(this._goFrameDelay.call != undefined)
               {
                  this._goFrameDelay.call();
               }
               else
               {
                  this.goFrame(this._goFrameDelay.name,this._goFrameDelay.isPlay,this._goFrameDelay.playFrame,null);
               }
               this._goFrameDelay = null;
            }
         }
      }
      
      public function startShadow(targetObj:DisplayObject, red:int = 0, green:int = 0, blue:int = 0) : void
      {
         this._pauseShadowBySuper = false;
         var shadowView:ShadowEffectView = this._shadowEffects[targetObj];
         if(shadowView)
         {
            shadowView.r = red;
            shadowView.g = green;
            shadowView.b = blue;
            shadowView.stopShadow = false;
            return;
         }
         shadowView = new ShadowEffectView(targetObj, red, green, blue);
         shadowView.onRemove = this.removeShadow;
         shadowView.container = this._shadowContainer;
         this._shadowEffects[targetObj] = shadowView;
      }
      
      public function endShadow() : void
      {
         var targetShadow:ShadowEffectView = this._shadowEffects[this._mc];
         if(targetShadow)
         {
            targetShadow.stopShadow = true;
         }
         this.shadowIng = false;
      }
      
      public function pauseShadowBySuper() : void
      {
         this._pauseShadowBySuper = true;
      }
      
      public function disableShadow() : void
      {
         this._pauseShadowBySuper = true;
         this.shadowIng = false;
         if(this._shadowEffects)
         {
            for each(var s:ShadowEffectView in this._shadowEffects)
            {
               if(s)
               {
                  s.stopShadow = true;
                  s.destory();
               }
            }
            this._shadowEffects = new Dictionary();
         }
         if(this._shadowContainer)
         {
            this._shadowContainer.visible = false;
            if(this._shadowContainer.parent)
            {
               this._shadowContainer.parent.removeChild(this._shadowContainer);
            }
            this._shadowContainer = null;
         }
      }
      
      private function removeShadow(shadowView:ShadowEffectView) : void
      {
         if(!this._shadowEffects || !shadowView)
         {
            return;
         }
         delete this._shadowEffects[shadowView.target];
      }
      
      private function renderChildren() : void
      {
         var _loc7_:* = undefined;
         var _loc3_:int = 0;
         var _loc1_:MovieClip = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc2_:int = this._mc.numChildren;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            try
            {
               _loc1_ = this._mc.getChildAt(_loc3_) as MovieClip;
               if(_loc1_)
               {
                  _loc4_ = _loc1_.name;
                  if(!(_loc4_ == "AImain" || _loc4_ == "bdmn" || _loc4_.indexOf("atm") != -1))
                  {
                     _loc5_ = _loc1_.totalFrames;
                     if(_loc5_ >= 2)
                     {
                        _loc7_ = _loc1_.currentFrameLabel;
                        if("stop" !== _loc7_)
                        {
                           if(_loc1_.currentFrame == _loc5_)
                           {
                              _loc1_.gotoAndStop(1);
                           }
                           else
                           {
                              _loc1_.nextFrame();
                           }
                        }
                     }
                  }
               }
            }
            catch(e:Error)
            {
            }
            _loc3_++;
         }
         MCUtils.applyPixelArtStyle(this._mc);
      }
      
      public function goFrame(param1:String, param2:Boolean = true, param3:int = 0, param4:Object = null, param5:Boolean = false) : void
      {
         this._curFrameName = param1;
         this._curMainFrameCount = 0;
         this._curFrameCount = 0;
         this._renderMainAnimate = param2;
         if(this._renderMainAnimate)
         {
            this._renderMainAnimateFrame = param3;
         }
         else
         {
            this._renderMainAnimateFrame = 0;
         }
         if(Boolean(param4) && (Boolean(param4.name || param4.call)) && int(param4.delay) > 0)
         {
            param4.isPlay = param4.isPlay != undefined ? param4.isPlay : true;
            param4.playFrame = param4.playFrame != undefined ? param4.playFrame : 0;
            this._goFrameDelay = param4;
         }
         else
         {
            this._goFrameDelay = null;
         }
         try
         {
            this._mc.gotoAndStop(param1);
         }
         catch(e:Error)
         {
         }
         this.renderChildren();
      }
      
      public function stopRenderMainAnimate() : void
      {
         this._renderMainAnimate = false;
      }
      
      public function resumeRenderMainAnimate() : void
      {
         this._renderMainAnimate = true;
      }
      
      public function checkFrame(param1:String) : Boolean
      {
         if(this._undefinedFrames.indexOf(param1) != -1)
         {
            return false;
         }
         if(MCUtils.hasFrameLabel(this._mc,param1))
         {
            return true;
         }
         this._undefinedFrames.push(param1);
         return false;
      }
      
      public function getCurrentHitSprite() : Array
      {
         var _loc1_:int = 0;
         var _loc2_:* = null;
         var _loc3_:Array = [];
         while(_loc1_ < this._mc.numChildren)
         {
            _loc2_ = this._mc.getChildAt(_loc1_);
            if(Boolean(_loc2_) && _loc2_.name.indexOf("atm") != -1)
            {
               _loc3_.push(_loc2_);
            }
            _loc1_++;
         }
         return _loc3_;
      }
      
      public function getCurrentBodyArea() : Rectangle
      {
         var _loc1_:Object = this._bodyAreaCache.getAreaByFrame(this._mc.currentFrame);
         if(_loc1_)
         {
            return _loc1_.area;
         }
         return null;
      }
      
      public function getCurrentHitArea() : Array
      {
         return this._hitAreaCache.getAreaByFrame(this._mc.currentFrame) as Array;
      }
      
      public function getCheckHitRect(param1:String) : Rectangle
      {
         var _loc2_:DisplayObject = this._mc.getChildByName(param1);
         if(!_loc2_)
         {
            return null;
         }
         var _loc3_:Object = this._hitCheckAreaCache.getAreaByDisplay(_loc2_);
         if(_loc3_ != null)
         {
            return _loc3_.area;
         }
         var _loc4_:Rectangle = _loc2_.getBounds(this._fighterDisplay);
         this._hitCheckAreaCache.cacheAreaByDisplay(_loc2_,_loc4_);
         return _loc4_;
      }
      
      private function findBodyArea() : void
      {
         var _loc1_:* = null;
         if(!this._bodyAreaCache)
         {
            return;
         }
         if(this._bodyAreaCache.areaFrameDefined(this._mc.currentFrame))
         {
            return;
         }
         var _loc2_:Object = this._bodyAreaCache.getAreaByFrame(this._mc.currentFrame);
         if(_loc2_ != null)
         {
            return;
         }
         var _loc3_:DisplayObject = this._mc.getChildByName("bdmn");
         if(_loc3_)
         {
            _loc2_ = this._bodyAreaCache.getAreaByDisplay(_loc3_);
            if(_loc2_ == null)
            {
               _loc1_ = _loc3_.getBounds(this._fighterDisplay);
               _loc2_ = this._bodyAreaCache.cacheAreaByDisplay(_loc3_,_loc1_);
            }
         }
         this._bodyAreaCache.cacheAreaByFrame(this._mc.currentFrame,_loc2_);
      }
      
      private function findHitArea() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc6_:* = null;
         if(!this._hitAreaCache)
         {
            return;
         }
         if(this._hitAreaCache.areaFrameDefined(this._mc.currentFrame))
         {
            return;
         }
         var _loc7_:Object = this._hitAreaCache.getAreaByFrame(this._mc.currentFrame);
         if(_loc7_ != null)
         {
            return;
         }
         var _loc8_:FighterHitModel = this._fighter.getCtrler().hitModel;
         var _loc9_:Array = [];
         while(_loc1_ < this._mc.numChildren)
         {
            _loc2_ = this._mc.getChildAt(_loc1_);
            _loc3_ = _loc8_.getHitVOByDisplayName(_loc2_.name);
            if(!(_loc2_ == null || _loc3_ == null))
            {
               _loc4_ = this._hitAreaCache.getAreaByDisplay(_loc2_);
               if(_loc4_ == null)
               {
                  _loc5_ = _loc2_.getBounds(this._fighterDisplay);
                  _loc6_ = this._hitAreaCache.cacheAreaByDisplay(_loc2_,_loc5_,{"hitVO":_loc3_});
                  _loc9_.push(_loc6_);
               }
               else
               {
                  _loc9_.push(_loc4_);
               }
            }
            _loc1_++;
         }
         if(_loc9_.length < 1)
         {
            _loc9_ = null;
         }
         this._hitAreaCache.cacheAreaByFrame(this._mc.currentFrame,_loc9_);
      }
      
      public function playHurtFly(hitX:Number, hitY:Number, isPlayFlyAnimate:Boolean = true) : void
      {
         this._hasHitWall = false;
         if(hitX != 0)
         {
            this._fighter.direct = hitX > 0 ? -1 : 1;
         }
         if(isPlayFlyAnimate)
         {
            this.goFrame("被打",false,0,{
               "name":"击飞",
               "delay":1,
               "isPlay":false
            });
         }
         else
         {
            this.goFrame("击飞",false);
         }
         if(hitY > 5)
         {
            this._hurtFlyFrame = 0;
            this._isHeavyDownAttack = true;
         }
         else
         {
            this._isHeavyDownAttack = false;
            this._hurtFlyFrame = this._fighter.isInAir ? 0 : 15;
         }
         this._fighter.setVelocity(hitX,hitY);
         this._fighter.setDamping(0,0.5);
         this._hurtFlyState = 1;
         this._hurtYMin = this._fighter.y;
         this._hitx = hitX;
         this._hity = hitY;
      }
      
      public function playHurtDown() : void
      {
         this.goFrame("击飞_弹",false,0,{
            "call":this.playHurtDown2,
            "delay":2
         });
         this._mcCtrler.effectCtrler.hitFloor(1,2);
         this._fighter.setVecY(0);
         this._fighter.setDampingY(0);
         this._fighter.isApplyG = true;
         this._fighter.setDamping(2);
      }
      
      private function playHurtDown2() : void
      {
         this.goFrame("击飞_倒",false);
         this._fighter.setVecY(0);
         this._fighter.setDampingY(0);
         this._fighter.isApplyG = true;
         this._hurtDownFrame = 15;
         this._hurtFlyState = 4;
         this._mcCtrler.touchFloor();
         this._fighter.actionState = 23;
         FighterEventDispatcher.dispatchEvent(this._fighter,"HURT_DOWN");
      }
      
      public function stopHurtFly() : void
      {
         this._hurtFlyState = 0;
         this._hasHitWall = false;
      }
      
      private function renderHurtFly() : void
      {
         var yDiff:Number = NaN;
         var vecY:Number = NaN;
         switch(this._hurtFlyState - 1)
         {
            case 0:
               if(!this._hasHitWall && this._fighter.getIsTouchSide() && Math.abs(this._hitx) > 2)
               {
                  this._hasHitWall = true;
                  this._mcCtrler.effectCtrler.hitWall(0,3);
                  this._fighter.setVecX(0);
                  this._fighter.setDamping(2,0.5);
                  this._hurtFlyFrame = 0;
                  if(!this._fighter.isInAir)
                  {
                     this.goFrame("击飞_落");
                     this._hurtFlyState = 2;
                     break;
                  }
               }
               if(--this._hurtFlyFrame <= 0 && !this._fighter.isInAir)
               {
                  this.goFrame("击飞_落");
                  this._hurtFlyState = 2;
               }
               if(this._hurtYMin > this._fighter.y)
               {
                  this._hurtYMin = this._fighter.y;
               }
               break;
            case 1:
               if(this._curFrameCount < 2)
               {
                  return;
               }
               if(this._isHeavyDownAttack)
               {
                  this._hurtDownFrame = 30;
                  this.goFrame("击飞_倒",false);
                  this._fighter.setVecY(0);
                  this._fighter.setDampingY(0);
                  this._fighter.isApplyG = true;
                  this._fighter.actionState = 23;
                  FighterEventDispatcher.dispatchEvent(this._fighter,"HURT_DOWN");
                  this._fighter.setDamping(4);
                  this._hurtFlyState = 4;
                  yDiff = this._fighter.y - this._hurtYMin;
                  vecY = yDiff * 0.04 * (1 + this._hity * 0.1);
                  if(vecY < 2)
                  {
                     vecY = 2;
                  }
                  if(vecY > 5)
                  {
                     vecY = 5;
                  }
                  this._mcCtrler.effectCtrler.hitFloor(2,vecY);
                  break;
               }
               this.goFrame("击飞_弹",false);
               yDiff = this._fighter.y - this._hurtYMin;
               vecY = yDiff / 25;
               if(vecY < 3)
               {
                  vecY = 3;
               }
               if(vecY > 8)
               {
                  vecY = 8;
               }
               this._fighter.setVecY(-vecY);
               this._fighter.setDamping(0,0.5);
               this._fighter.isApplyG = true;
               this._hurtFlyState = 3;
               this._fighter.actionState = 24;
               if(vecY < 0.5)
               {
                  vecY = 0.5;
               }
               if(vecY > 3)
               {
                  vecY = 3;
               }
               this._mcCtrler.effectCtrler.hitFloor(0,vecY);
               break;
            case 2:
               if(this._curFrameCount < 2)
               {
                  return;
               }
               if(this._fighter.isInAir)
               {
                  if(!this._hasHitWall && this._fighter.getIsTouchSide() && Math.abs(this._hitx) > 2)
                  {
                     this._hasHitWall = true;
                     this._mcCtrler.effectCtrler.hitWall(1,2);
                     this._fighter.setVecX(0);
                  }
                  return;
               }
               this.goFrame("击飞_倒",false);
               this._fighter.setVecY(0);
               this._fighter.setDampingY(0);
               this._fighter.isApplyG = true;
               this._fighter.setDamping(2);
               this._hurtDownFrame = 15;
               this._hurtFlyState = 4;
               this._mcCtrler.effectCtrler.hitFloor(1,1);
               this._fighter.actionState = 23;
               FighterEventDispatcher.dispatchEvent(this._fighter,"HURT_DOWN");
               break;
            case 3:
               if(!this._fighter.isAlive)
               {
                  this._hurtFlyState = 0;
                  this._fighter.actionState = 30;
                  FighterEventDispatcher.dispatchEvent(this._fighter,"DEAD");
                  return;
               }
               if(--this._hurtDownFrame <= 0)
               {
                  this.goFrame("击飞_起",true);
                  this._hurtFlyState = 0;
               }
         }
      }
      
      public function getHitRange(param1:String) : Rectangle
      {
         if(!this._hitRangeInited)
         {
            this.initHitRange();
            this._hitRangeInited = true;
         }
         return this._hitRangeObj[param1];
      }
      
      private function initHitRange() : void
      {
         var _loc3_:String = null;
         var _loc1_:DisplayObject = null;
         var _loc2_:MovieClip = this._mc.getChildByName("AImain") as MovieClip;
         _loc2_.gotoAndStop(2);
         this._hitRangeObj = {};
         for each(_loc3_ in FighterHitRange.getALL())
         {
            _loc1_ = _loc2_.getChildByName(_loc3_);
            if(_loc1_)
            {
               this._hitRangeObj[_loc3_] = _loc1_.getBounds(this._fighterDisplay);
            }
         }
         _loc2_.gotoAndStop(1);
         _loc2_.visible = false;
      }
      
      public function initAssisterHitRange(param1:Boolean) : void
      {
         if(!param1)
         {
            this._hitRangeObj["assistmian"] = new Rectangle();
            return;
         }
         var _loc2_:MovieClip = this._mc.getChildByName("AImain") as MovieClip;
         _loc2_.gotoAndStop(2);
         var _loc3_:DisplayObject = _loc2_.getChildByName("assistmian");
         if(_loc3_ != null)
         {
            this._hitRangeObj["assistmian"] = _loc3_.getBounds(this._fighterDisplay);
         }
         _loc2_.gotoAndStop(1);
         _loc2_.visible = false;
      }
      
      public function getCurrentLabel() : String
      {
         return this._mc.currentLabel;
      }
   }
}

