package net.play5d.game.bvn.fighter
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.fighter.ctrler.AssisiterCtrler;
   import net.play5d.game.bvn.fighter.models.FighterHitModel;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.fighter.utils.McAreaCacher;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class Assister extends BaseGameSprite
   {
      public var onRemove:Function;
      
      public var data:FighterVO;
      
      public var isAttacking:Boolean;
      
      private var _hitAreaCache:McAreaCacher = new McAreaCacher("hit");
      
      private var _hitCheckAreaCache:McAreaCacher = new McAreaCacher("hit_check");
      
      private var _rectCache:Object = {};
      
      private var _mcOrgPoint:Point;
      
      private var _owner:IGameSprite;
      
      private var _isRenderMainAnimate:Boolean = true;
      
      private var _ctrler:AssisiterCtrler;
      
      public function Assister(param1:MovieClip)
      {
         super(param1);
         isAlive = false;
         if(_mainMc.setAssistCtrler)
         {
            _ctrler = new AssisiterCtrler();
            _ctrler.initAssister(this);
            _mainMc.setAssistCtrler(_ctrler);
            return;
         }
         throw new Error("初始化失败，SWF未定义setAssistCtrler()");
      }
      
      public function get name() : String
      {
         return _mainMc.name;
      }
      
      public function getOwner() : IGameSprite
      {
         return _owner;
      }
      
      public function setOwner(param1:IGameSprite) : void
      {
         _owner = param1;
      }
      
      public function getCtrler() : AssisiterCtrler
      {
         return _ctrler;
      }
      
      public function goFight() : void
      {
         gotoAndPlay(2);
         isAttacking = true;
      }
      
      override public function destory(param1:Boolean = true) : void
      {
         if(!param1)
         {
            return;
         }
         if(_hitAreaCache)
         {
            _hitAreaCache.destory();
            _hitAreaCache = null;
         }
         if(_hitCheckAreaCache)
         {
            _hitCheckAreaCache.destory();
            _hitCheckAreaCache = null;
         }
         if(_ctrler)
         {
            _ctrler.destory();
            _ctrler = null;
         }
         data = null;
         _rectCache = null;
         _mcOrgPoint = null;
         _owner = null;
         super.destory(param1);
      }
      
      public function stop() : void
      {
         _isRenderMainAnimate = false;
      }
      
      public function gotoAndPlay(param1:Object) : void
      {
         _mainMc.gotoAndStop(param1);
         _isRenderMainAnimate = true;
      }
      
      public function gotoAndStop(param1:Object) : void
      {
         _mainMc.gotoAndStop(param1);
         _isRenderMainAnimate = false;
      }
      
      public function getTargets() : Vector.<IGameSprite>
      {
         if(!_owner is FighterMain)
         {
            return null;
         }
         return (_owner as FighterMain).getTargets();
      }
      
      public function removeSelf() : void
      {
         isAttacking = false;
         isAlive = false;
         if(onRemove != null)
         {
            onRemove(this);
         }
      }
      
      override public function render() : void
      {
         super.render();
         _ctrler.render();
      }
      
      override public function renderAnimate() : void
      {
         if(!_isRenderMainAnimate)
         {
            return;
         }
         super.renderAnimate();
         renderChildren();
         mc.nextFrame();
         findHitArea();
         if(mc.currentFrame == mc.totalFrames - 1)
         {
            _ctrler.finish(true);
         }
      }
      
      private function renderChildren() : void
      {
         var _loc2_:int = 0;
         var _loc1_:MovieClip = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         while(_loc2_ < _mainMc.numChildren)
         {
            _loc1_ = _mainMc.getChildAt(_loc2_) as MovieClip;
            if(_loc1_)
            {
               _loc3_ = _loc1_.name;
               if(!(_loc3_ == "bdmn" || _loc3_.indexOf("atm") != -1))
               {
                  _loc4_ = _loc1_.totalFrames;
                  if(_loc4_ >= 2)
                  {
                     var _loc5_:* = _loc1_.currentFrameLabel;
                     if("stop" !== _loc5_)
                     {
                        if(_loc1_.currentFrame == _loc4_)
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
            _loc2_++;
         }
      }
      
      public function getHitCheckRect(param1:String) : Rectangle
      {
         var _loc2_:Rectangle = getCheckHitRect(param1);
         if(_loc2_ == null)
         {
            return null;
         }
         return getCurrentRect(_loc2_,"hit_check");
      }
      
      public function getCheckHitRect(param1:String) : Rectangle
      {
         var _loc3_:DisplayObject = _mainMc.getChildByName(param1);
         if(!_loc3_)
         {
            return null;
         }
         var _loc4_:Object = _hitCheckAreaCache.getAreaByDisplay(_loc3_);
         if(_loc4_)
         {
            return _loc4_.area;
         }
         var _loc2_:Rectangle = _loc3_.getBounds(_mainMc);
         _hitCheckAreaCache.cacheAreaByDisplay(_loc3_,_loc2_);
         return _loc2_;
      }
      
      private function getCurrentRect(param1:Rectangle, param2:String = null) : Rectangle
      {
         var _loc3_:Rectangle = null;
         if(param2 == null)
         {
            _loc3_ = new Rectangle();
         }
         else if(_rectCache[param2])
         {
            _loc3_ = _rectCache[param2];
         }
         else
         {
            _loc3_ = new Rectangle();
            _rectCache[param2] = _loc3_;
         }
         _loc3_.x = param1.x * direct + _x;
         if(direct < 0)
         {
            _loc3_.x -= param1.width;
         }
         _loc3_.y = param1.y + _y;
         _loc3_.width = param1.width;
         _loc3_.height = param1.height;
         return _loc3_;
      }
      
      private function findHitArea() : void
      {
         var _loc7_:int = 0;
         var _loc4_:DisplayObject = null;
         var _loc6_:HitVO = null;
         var _loc5_:Object = null;
         var _loc9_:Rectangle = null;
         var _loc3_:Object = null;
         if(!_hitAreaCache)
         {
            return;
         }
         if(_hitAreaCache.areaFrameDefined(_mainMc.currentFrame))
         {
            return;
         }
         var _loc1_:Object = _hitAreaCache.getAreaByFrame(_mainMc.currentFrame);
         if(_loc1_ != null)
         {
            return;
         }
         var _loc8_:FighterHitModel = _ctrler.hitModel;
         var _loc2_:Array = [];
         while(_loc7_ < _mainMc.numChildren)
         {
            _loc4_ = _mainMc.getChildAt(_loc7_);
            _loc6_ = _loc8_.getHitVO(_loc4_.name);
            if(!(_loc4_ == null || _loc6_ == null))
            {
               _loc5_ = _hitAreaCache.getAreaByDisplay(_loc4_);
               if(_loc5_ == null)
               {
                  _loc9_ = _loc4_.getBounds(_mainMc);
                  _loc3_ = _hitAreaCache.cacheAreaByDisplay(_loc4_,_loc9_,{"hitVO":_loc6_});
                  _loc2_.push(_loc3_);
               }
               else
               {
                  _loc2_.push(_loc5_);
               }
            }
            _loc7_++;
         }
         if(_loc2_.length < 1)
         {
            _loc2_ = null;
         }
         _hitAreaCache.cacheAreaByFrame(_mainMc.currentFrame,_loc2_);
      }
      
      override public function hit(param1:HitVO, param2:IGameSprite) : void
      {
         if(param2 && _owner && _owner is FighterMain)
         {
            (_owner as FighterMain).addQi(param1.power * GameConfig.QI_ADD_HIT_ASSISTER_RATE * GameConfig.QI_GAIN_RATE);
            GameLogic.hitTarget(param1,_owner,param2);
         }
      }
      
      override public function getCurrentHits() : Array
      {
         var _loc4_:int = 0;
         var _loc8_:Object = null;
         var _loc3_:HitVO = null;
         var _loc5_:* = null;
         var _loc2_:Rectangle = null;
         var _loc7_:String = null;
         if(!_hitAreaCache)
         {
            return null;
         }
         var _loc6_:Array = _hitAreaCache.getAreaByFrame(_mainMc.currentFrame) as Array;
         if(!_loc6_ || _loc6_.length < 1)
         {
            return null;
         }
         var _loc1_:Array = [];
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
      
      public function getCurrentTarget() : IGameSprite
      {
         if(_owner is FighterMain)
         {
            return (_owner as FighterMain).getCurrentTarget();
         }
         return null;
      }
   }
}

