package net.play5d.game.bvn.fighter
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.data.TeamVO;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.game.bvn.utils.MCUtils;
   import net.play5d.kyo.utils.KyoUtils;
   
   public class Bullet implements IGameSprite
   {
      private var _colorTransform:ColorTransform = new ColorTransform();
      
      public function get colorTransform() : ColorTransform
      {
         return _colorTransform;
      }
      
      public function set colorTransform(param1:ColorTransform) : void
      {
         _colorTransform = param1;
         if(mc)
         {
            mc.transform.colorTransform = param1 ? param1 : new ColorTransform();
         }
      }

      public var speed:Point = new Point(5,0);
      
      public var hp:int = 100;
      
      public var hpMax:int = 100;
      
      public var addSpeed:Point = new Point();
      
      public var maxSpeed:Point = new Point(999,999);
      
      public var minSpeed:Point = new Point(-999,-999);
      
      public var hitSpeed:Point = new Point(NaN,NaN);
      
      public var holdFrame:int = -1;
      
      public var onRemove:Function;
      
      public var mc:MovieClip;
      
      public var hitTimes:int = -1;
      
      public var owner:IGameSprite;
      
      private var _area:Rectangle;
      
      private var _orgScale:Point;
      
      private var _orgRotate:int;
      
      private var _team:TeamVO;
      
      private var _isHit:Boolean;
      
      private var _isTimeout:Boolean;
      
      private var _bulletArea:Rectangle;
      
      private var _hitVO:HitVO;
      
      private var _loopFrame:Object;
      
      private var _hitAble:Boolean = true;
      
      private var _speedPlus:Number = GameConfig.SPEED_PLUS;
      
      private var _isActive:Boolean;
      
      private var _destoryed:Boolean;
      
      private var _direct:int;
      
      private var _currentRect:Rectangle = new Rectangle();
      
      public function Bullet(param1:MovieClip, param2:Object = null)
      {
         super();
         this.mc = param1;
         _orgScale = new Point(param1.scaleX,param1.scaleY);
         _orgRotate = param1.rotation;
         if(param2)
         {
            if(param2.x)
            {
               if(param2.x is Number)
               {
                  speed.x = param2.x;
               }
               else
               {
                  if(param2.x.start != undefined)
                  {
                     speed.x = param2.x.start;
                  }
                  if(param2.x.add != undefined)
                  {
                     addSpeed.x = param2.x.add * 2;
                  }
                  if(param2.x.max != undefined)
                  {
                     maxSpeed.x = param2.x.max;
                  }
                  if(param2.x.min != undefined)
                  {
                     minSpeed.x = param2.x.min;
                  }
                  if(param2.x.hit != undefined)
                  {
                     hitSpeed.x = param2.x.hit;
                  }
               }
            }
            if(param2.y)
            {
               if(param2.y is Number)
               {
                  speed.y = param2.y;
               }
               else
               {
                  if(param2.y.start != undefined)
                  {
                     speed.y = param2.y.start;
                  }
                  if(param2.y.add != undefined)
                  {
                     addSpeed.y = param2.y.add * 2;
                  }
                  if(param2.y.max != undefined)
                  {
                     maxSpeed.y = param2.y.max;
                  }
                  if(param2.y.min != undefined)
                  {
                     minSpeed.y = param2.y.min;
                  }
                  if(param2.y.hit != undefined)
                  {
                     hitSpeed.y = param2.y.hit;
                  }
               }
            }
            if(param2.hold)
            {
               if(param2.hold == -1)
               {
                  holdFrame = -1;
               }
               else
               {
                  holdFrame = param2.hold * GameConfig.FPS_GAME;
               }
            }
            if(param2.hits)
            {
               hitTimes = param2.hits;
            }
            if(param2.hp)
            {
               hp = hpMax = param2.hp;
            }
         }
      }
      
      public function getActive() : Boolean
      {
         return _isActive;
      }
      
      public function setActive(param1:Boolean) : void
      {
         _isActive = param1;
      }
      
      public function get x() : Number
      {
         return mc.x;
      }
      
      public function set x(param1:Number) : void
      {
         mc.x = param1;
      }
      
      public function get y() : Number
      {
         return mc.y;
      }
      
      public function set y(param1:Number) : void
      {
         mc.y = param1;
      }
      
      public function get team() : TeamVO
      {
         return _team;
      }
      
      public function set team(param1:TeamVO) : void
      {
         _team = param1;
      }
      
      public function isAttacking() : Boolean
      {
         return _hitAble;
      }
      
      public function setSpeedRate(param1:Number) : void
      {
         _speedPlus = param1;
      }
      
      public function setVolume(param1:Number) : void
      {
         KyoUtils.setMcVolume(mc,param1);
      }
      
      public function get direct() : int
      {
         return _direct;
      }
      
      public function set direct(param1:int) : void
      {
         _direct = param1;
         mc.scaleX = _orgScale.x * _direct;
         mc.rotation = _orgRotate * _direct;
         mc.x *= _direct;
         speed.x *= param1;
         addSpeed.x *= param1;
         if(!isNaN(hitSpeed.x))
         {
            hitSpeed.x *= param1;
         }
      }
      
      public function setHitVO(param1:HitVO) : void
      {
         var _loc4_:FighterMC = null;
         owner = param1.owner;
         _hitVO = param1.clone();
         _hitVO.owner = this;
         var _loc3_:DisplayObject = mc.getChildByName("main");
         var _loc2_:DisplayObject = owner.getDisplay();
         if(_loc3_)
         {
            _bulletArea = _loc3_.getBounds(_loc2_);
            _bulletArea.x -= mc.x;
            _bulletArea.y -= mc.y;
         }
         else
         {
            _bulletArea = mc.getBounds(_loc2_);
            _bulletArea.x -= mc.x;
            _bulletArea.y -= mc.y;
         }
         direct = owner.direct;
         mc.x += owner.x;
         mc.y += owner.y;
         if(owner is FighterMain)
         {
            _loc4_ = (owner as FighterMain).getMC();
            mc.x += _loc4_.x;
            mc.y += _loc4_.y;
            _bulletArea.x -= _loc4_.x;
            _bulletArea.y -= _loc4_.y;
         }
      }
      
      public function destory(param1:Boolean = true) : void
      {
         _destoryed = true;
         if(mc)
         {
            try
            {
               mc.stopAllMovieClips();
            }
            catch(e:Error)
            {
               trace(e);
            }
            mc = null;
         }
         speed = null;
         addSpeed = null;
         maxSpeed = null;
         minSpeed = null;
         hitSpeed = null;
         owner = null;
         _area = null;
         _orgScale = null;
         _team = null;
         _bulletArea = null;
         _hitVO = null;
      }
      
      public function isDestoryed() : Boolean
      {
         return _destoryed;
      }
      
      public function renderAnimate() : void
      {
         mc.nextFrame();
         var _loc1_:String = mc.currentLabel;
         switch(_loc1_)
         {
            case "loop":
               if(_loopFrame == null)
               {
                  if(MCUtils.hasFrameLabel(mc,"loop_start"))
                  {
                     _loopFrame = "loop_start";
                  }
                  else
                  {
                     _loopFrame = 1;
                  }
               }
               mc.gotoAndStop(_loopFrame);
               break;
            case "remove":
               removeSelf();
               break;
            case "hit_over":
               _hitAble = false;
               break;
            default:
               if(mc.currentFrame == mc.totalFrames - 1)
               {
                  removeSelf();
               }
         }
      }
      
      public function render() : void
      {
         if(_isHit)
         {
            return;
         }
         mc.x += speed.x * _speedPlus;
         mc.y += speed.y * _speedPlus;
         speed.x += addSpeed.x * _speedPlus;
         speed.y += addSpeed.y * _speedPlus;
         if(_direct > 0)
         {
            if(speed.x > maxSpeed.x)
            {
               speed.x = maxSpeed.x;
            }
            if(speed.x < minSpeed.x)
            {
               speed.x = minSpeed.x;
            }
         }
         else
         {
            if(speed.x < -maxSpeed.x)
            {
               speed.x = -maxSpeed.x;
            }
            if(speed.x > -minSpeed.x)
            {
               speed.x = -minSpeed.x;
            }
         }
         if(speed.y > maxSpeed.y)
         {
            speed.y = maxSpeed.y;
         }
         if(speed.y < minSpeed.y)
         {
            speed.y = minSpeed.y;
         }
         if(holdFrame != -1 && !_isTimeout)
         {
            holdFrame--;
            if(holdFrame <= 0)
            {
               if(!MCUtils.hasFrameLabel(mc,"timeout"))
               {
                  removeSelf();
                  return;
               }
               _isTimeout = true;
               mc.gotoAndStop("timeout");
            }
         }
         if(GameLogic.isTouchBottomFloor(this))
         {
            hit(_hitVO,null);
            EffectCtrl.I.shake(0,1,200);
            return;
         }
         if(GameLogic.isOutRange(this))
         {
            removeSelf();
         }
      }
      
      public function getDisplay() : DisplayObject
      {
         return mc;
      }
      
      private function removeSelf() : void
      {
         if(onRemove != null)
         {
            onRemove(this);
         }
      }
      
      private function doHit() : void
      {
         if(!_isHit)
         {
            try
            {
               mc.gotoAndStop("hit");
            }
            catch(e:Error)
            {
               trace("Bullet",e);
            }
         }
         _isHit = true;
         _hitAble = false;
      }
      
      public function hit(param1:HitVO, param2:IGameSprite) : void
      {
         if(param2 is Bullet)
         {
            if(!isNaN(hitSpeed.x))
            {
               speed.x = hitSpeed.x;
            }
            if(!isNaN(hitSpeed.y))
            {
               speed.y = hitSpeed.y;
            }
            return;
         }
         if(hitTimes != -1)
         {
            if(--hitTimes <= 0)
            {
               doHit();
            }
         }
         if(param2 && owner && owner is FighterMain)
         {
            (owner as FighterMain).addQi(param1.power * GameConfig.QI_ADD_HIT_BULLET_RATE * GameConfig.QI_GAIN_RATE);
            GameLogic.hitTarget(param1,owner,param2);
         }
         if(param2)
         {
            if(hitSpeed.x == 0 && hitSpeed.y == 0)
            {
               return;
            }
            if(param2 is BaseGameSprite && (param2 as BaseGameSprite).getIsTouchSide())
            {
               if(isNaN(hitSpeed.x))
               {
                  hitSpeed.x = speed.x;
               }
               if(isNaN(hitSpeed.y))
               {
                  hitSpeed.y = speed.y;
               }
               hitSpeed.x = Math.abs(hitSpeed.x) < 1 ? 0 : hitSpeed.x * 0.5;
               hitSpeed.y = Math.abs(hitSpeed.y) < 1 ? 0 : hitSpeed.y * 0.5;
            }
            if(!isNaN(hitSpeed.x))
            {
               speed.x = hitSpeed.x;
            }
            if(!isNaN(hitSpeed.y))
            {
               speed.y = hitSpeed.y;
            }
         }
      }
      
      public function beHit(param1:HitVO, param2:Rectangle = null) : void
      {
         if(param1.owner && param1.owner is Bullet)
         {
            hp -= (param1.owner as Bullet).hpMax;
         }
         else
         {
            hp -= param1.power;
         }
         if(hp <= 0)
         {
            doHit();
         }
      }
      
      public function getCurrentHits() : Array
      {
         if(!_hitVO || !_bulletArea || !_hitAble)
         {
            return null;
         }
         _hitVO.currentArea = getCurrentRect(_bulletArea);
         return [_hitVO];
      }
      
      public function getArea() : Rectangle
      {
         if(!_bulletArea)
         {
            return null;
         }
         return getCurrentRect(_bulletArea);
      }
      
      public function getBodyArea() : Rectangle
      {
         if(!_bulletArea)
         {
            return null;
         }
         return getCurrentRect(_bulletArea);
      }
      
      private function getCurrentRect(param1:Rectangle) : Rectangle
      {
         var _loc2_:Rectangle = _currentRect;
         _loc2_.x = param1.x * _direct + mc.x;
         if(_direct < 0)
         {
            _loc2_.x -= param1.width;
         }
         _loc2_.y = param1.y + mc.y;
         _loc2_.width = param1.width;
         _loc2_.height = param1.height;
         return _loc2_;
      }
      
      public function allowCrossMapXY() : Boolean
      {
         return true;
      }
      
      public function allowCrossMapBottom() : Boolean
      {
         return false;
      }
      
      public function getIsTouchSide() : Boolean
      {
         return false;
      }
      
      public function setIsTouchSide(param1:Boolean) : void
      {
      }
   }
}

