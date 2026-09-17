package net.play5d.game.bvn.ctrl.game_ctrls
{
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.data.TeamMap;
   import net.play5d.game.bvn.data.TeamVO;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.game.bvn.map.MapMain;
   import net.play5d.game.bvn.state.GameState;
   
   public class GameMainLogicCtrler
   {
      public var renderHit:Boolean = true;
      
      private var _gameState:GameState;
      
      private var _leftSide:Number = 0;
      
      private var _rightSide:Number = 0;
      
      private var _teamMap:TeamMap;
      
      private var _renderAnimate:Boolean;
      
      public function GameMainLogicCtrler()
      {
         super();
      }
      
      public function initlize(param1:GameState, param2:TeamMap) : void
      {
         _gameState = param1;
         _teamMap = param2;
         var _loc3_:MapMain = param1.getMap();
         _leftSide = _loc3_.left + 10;
         _rightSide = _loc3_.right - 10;
      }
      
      public function setSpeedPlus(param1:Number) : void
      {
         var _loc5_:TeamVO = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc7_:IGameSprite = null;
         var _loc4_:int = 0;
         GameConfig.SPEED_PLUS = param1;
         var _loc6_:int = int(_teamMap.teams.length);
         _loc2_ = 0;
         while(_loc2_ < _loc6_)
         {
            _loc5_ = _teamMap.teams[_loc2_];
            _loc3_ = int(_loc5_.children.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc7_ = _loc5_.children[_loc4_];
               if(_loc7_ && !_loc7_.isDestoryed())
               {
                  _loc7_.setSpeedRate(param1);
               }
               _loc4_++;
            }
            _loc2_++;
         }
      }
      
      public function destory() : void
      {
      }
      
      public function render() : void
      {
         renderMainLogic();
      }
      
      private function renderMainLogic() : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         var _loc12_:IGameSprite = null;
         var _loc14_:IGameSprite = null;
         var _loc2_:TeamVO = null;
         var _loc6_:TeamVO = null;
         var _loc11_:* = undefined;
         var _loc13_:* = undefined;
         var _loc10_:int = 0;
         var _loc1_:Vector.<TeamVO> = _teamMap.teams;
         var _loc9_:int = int(_loc1_.length);
         var _loc8_:Vector.<IGameSprite> = _gameState.getGameSprites();
         _loc3_ = 0;
         while(_loc3_ < _loc8_.length)
         {
            renderGameSprite(_loc8_[_loc3_]);
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc9_)
         {
            _loc6_ = _loc1_[_loc3_];
            _loc13_ = _loc6_.children;
            _loc4_ = 0;
            while(_loc4_ < _loc13_.length)
            {
               _loc14_ = _loc13_[_loc4_];
               if(!(_loc14_ == null || _loc14_.isDestoryed()))
               {
                  _loc5_ = _loc3_ + 1;
                  while(_loc5_ < _loc9_)
                  {
                     _loc2_ = _loc1_[_loc5_];
                     _loc11_ = _loc2_.children;
                     _loc10_ = int(_loc11_.length);
                     _loc7_ = 0;
                     while(_loc7_ < _loc10_)
                     {
                        _loc12_ = _loc11_[_loc7_];
                        if(!(_loc12_ == null || _loc12_.isDestoryed()))
                        {
                           checkBodyHit(_loc14_,_loc12_);
                           if(_renderAnimate)
                           {
                              checkHit(_loc14_,_loc12_);
                           }
                        }
                        _loc7_++;
                     }
                     _loc5_++;
                  }
               }
               _loc4_++;
            }
            _loc3_++;
         }
         _renderAnimate = false;
      }
      
      public function renderAnimate() : void
      {
         _renderAnimate = true;
      }
      
      private function checkBodyHit(param1:IGameSprite, param2:IGameSprite) : void
      {
         var ba:BaseGameSprite;
         var bb:BaseGameSprite;
         var bodyA:Rectangle;
         var bodyB:Rectangle;
         var bodyHit:Rectangle;
         var vecA:Number;
         var vecB:Number;
         var overVec:Object;
         var vo:Object;
         var vo2:Object;
         var A:IGameSprite = param1;
         var B:IGameSprite = param2;
         var getVec:* = function(param1:Number):Object
         {
            var _loc2_:Number = bb.heavy / ba.heavy * 0.5;
            if(_loc2_ > 0.9)
            {
               _loc2_ = 0.9;
            }
            if(_loc2_ < 0.1)
            {
               _loc2_ = 0.1;
            }
            var _loc4_:* = param1 * _loc2_;
            var _loc3_:* = param1 * (1 - _loc2_);
            if(A.getIsTouchSide() && B.getIsTouchSide())
            {
               _loc4_ = param1;
               _loc3_ = param1;
            }
            else if(A.getIsTouchSide())
            {
               _loc4_ = 0;
               _loc3_ = param1;
            }
            else if(B.getIsTouchSide())
            {
               _loc3_ = 0;
               _loc4_ = param1;
            }
            return {
               "A":_loc4_,
               "B":_loc3_
            };
         };
         if(!renderHit)
         {
            return;
         }
         if(A is BaseGameSprite == false)
         {
            return;
         }
         if(B is BaseGameSprite == false)
         {
            return;
         }
         ba = A as BaseGameSprite;
         bb = B as BaseGameSprite;
         if(ba.isCross || bb.isCross)
         {
            return;
         }
         bodyA = A.getBodyArea();
         bodyB = B.getBodyArea();
         if(bodyA == null)
         {
            return;
         }
         if(bodyB == null)
         {
            return;
         }
         bodyHit = bodyA.intersection(bodyB);
         if(!bodyHit || bodyHit.isEmpty())
         {
            return;
         }
         vecA = ba.getVecX();
         vecB = bb.getVecX();
         if(ba.x < bb.x)
         {
            if(vecA < 0 && vecA < vecB || vecB > 0 && vecB > vecA)
            {
               return;
            }
            if(bodyHit.width > 2)
            {
               if(!overVec)
               {
                  overVec = getVec(5 * GameConfig.SPEED_PLUS);
               }
               ba.move(-overVec.A);
               bb.move(overVec.B);
            }
         }
         else
         {
            if(vecA > 0 && vecA > vecB || vecB < 0 && vecB < vecA)
            {
               return;
            }
            if(bodyHit.width > 2)
            {
               if(!overVec)
               {
                  overVec = getVec(5 * GameConfig.SPEED_PLUS);
               }
               ba.move(overVec.A);
               bb.move(-overVec.B);
            }
         }
         if(vecA != 0)
         {
            vo = getVec(vecA);
            bb.move(vo.B);
            ba.move(-vo.A);
         }
         if(vecB != 0)
         {
            vo2 = getVec(vecB);
            ba.move(vo2.A);
            bb.move(-vo2.B);
         }
      }
      
      private function renderGameSprite(param1:IGameSprite) : void
      {
         var _loc2_:BaseGameSprite = null;
         var _loc3_:Boolean = false;
         try
         {
            GameLogic.fixGameSpritePosition(param1);
            if(param1 is BaseGameSprite)
            {
               _loc2_ = param1 as BaseGameSprite;
               _loc3_ = GameLogic.isInAir(_loc2_);
               if(_loc3_)
               {
                  _loc2_.applayG(12);
               }
               _loc2_.setInAir(_loc3_);
            }
            param1.render();
            if(_renderAnimate && !param1.isDestoryed())
            {
               param1.renderAnimate();
            }
         }
         catch(e:Error)
         {
            Debugger.log("GameMainLogicCtrler.renderGameSprite",e);
         }
      }
      
      private function checkHit(param1:IGameSprite, param2:IGameSprite) : void
      {
         var _loc5_:Rectangle = null;
         var _loc6_:Rectangle = null;
         if(!renderHit)
         {
            return;
         }
         var _loc8_:Array = param1.getCurrentHits();
         var _loc7_:Array = param2.getCurrentHits();
         if(param1 is BaseGameSprite && !(param1 as BaseGameSprite).isAllowBeHit)
         {
            _loc5_ = null;
         }
         else
         {
            _loc5_ = param1.getBodyArea();
         }
         if(param2 is BaseGameSprite && !(param2 as BaseGameSprite).isAllowBeHit)
         {
            _loc6_ = null;
         }
         else
         {
            _loc6_ = param2.getBodyArea();
         }
         var _loc4_:Object = getHitObj(_loc8_,_loc6_);
         var _loc3_:Object = getHitObj(_loc7_,_loc5_);
         if(_loc4_)
         {
            param2.beHit(_loc4_.hitVO,_loc4_.hitRect);
            param1.hit(_loc4_.hitVO,param2);
         }
         if(_loc3_)
         {
            param1.beHit(_loc3_.hitVO,_loc3_.hitRect);
            param2.hit(_loc3_.hitVO,param1);
         }
      }
      
      private function getHitObj(param1:Array, param2:Rectangle) : Object
      {
         var _loc6_:int = 0;
         var _loc7_:Rectangle = null;
         var _loc5_:HitVO = null;
         var _loc3_:Rectangle = null;
         if(!param2)
         {
            return null;
         }
         if(!param1 || param1.length < 1)
         {
            return null;
         }
         var _loc4_:int = int(param1.length);
         _loc6_ = 0;
         while(_loc6_ < _loc4_)
         {
            _loc5_ = param1[_loc6_];
            if(_loc5_ != null)
            {
               _loc3_ = _loc5_.currentArea;
               if(_loc3_ != null)
               {
                  _loc7_ = _loc3_.intersection(param2);
                  if(_loc7_ && _loc7_.isEmpty() == false)
                  {
                     return {
                        "hitVO":_loc5_,
                        "hitRect":_loc7_
                     };
                  }
               }
            }
            _loc6_++;
         }
         return null;
      }
      
      public function renderPause() : void
      {
      }
   }
}

