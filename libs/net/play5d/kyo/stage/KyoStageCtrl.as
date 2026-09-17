package net.play5d.kyo.stage
{
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.utils.getQualifiedClassName;
   import flash.utils.setTimeout;
   import net.play5d.kyo.stage.effect.IStageFadEffect;
   import net.play5d.kyo.stage.events.KyoStageEvent;
   
   public class KyoStageCtrl extends EventDispatcher
   {
      private var _mainStage:Sprite;
      
      private var _curStage:Istage;
      
      public var changeStateMouseGap:int = 0;
      
      private var _layers:Array = [];
      
      public function KyoStageCtrl(param1:Sprite)
      {
         super();
         this._mainStage = param1;
      }
      
      public function get currentStage() : Istage
      {
         return this._curStage;
      }
      
      public function goStage(param1:Istage, param2:Boolean = false, param3:Boolean = false) : Boolean
      {
         var detoryComplete:Function = null;
         var classname:String = null;
         var classname2:String = null;
         var stg:Istage = param1;
         var sameChange:Boolean = param2;
         var buildAfterDestory:Boolean = param3;
         detoryComplete = function():void
         {
            try
            {
               _mainStage.removeChild(_curStage.display);
            }
            catch(e:Error)
            {
               trace("KyoStageCtrl: goStage:",e);
            }
            _curStage = null;
            newStage();
         };
         var newStage:Function = function():void
         {
            if(changeStateMouseGap > 0)
            {
               stageMouseChildren = false;
               setTimeout(function():void
               {
                  stageMouseChildren = true;
               },changeStateMouseGap);
            }
            _curStage = stg;
            _curStage.build();
            _mainStage.addChild(_curStage.display);
            _curStage.afterBuild();
         };
         if(!sameChange)
         {
            classname = getQualifiedClassName(stg);
            classname2 = getQualifiedClassName(this._curStage);
            if(classname == classname2)
            {
               return false;
            }
         }
         if(this._curStage)
         {
            if(buildAfterDestory)
            {
               this._curStage.destory(detoryComplete);
            }
            else
            {
               this._curStage.destory();
               detoryComplete();
            }
         }
         else
         {
            newStage();
         }
         dispatchEvent(new KyoStageEvent(KyoStageEvent.CHANGE_STATE,stg));
         return true;
      }
      
      public function addLayer(param1:Istage, param2:Number = 0, param3:Number = 0, param4:Boolean = false, param5:IStageFadEffect = null, param6:Function = null) : void
      {
         var sw:Number;
         var sh:Number;
         var dw:Number;
         var dh:Number;
         var effectBack:Function = null;
         var layer:Istage = param1;
         var x:Number = param2;
         var y:Number = param3;
         var removeElse:Boolean = param4;
         var effect:IStageFadEffect = param5;
         var addBack:Function = param6;
         effectBack = function():void
         {
            layer.afterBuild();
            if(addBack != null)
            {
               addBack();
            }
         };
         if(removeElse)
         {
            this.removeAllLayer();
         }
         layer.build();
         sw = this._mainStage.stage.stageWidth;
         sh = this._mainStage.stage.stageHeight;
         dw = layer.display.width * this._mainStage.scaleX;
         dh = layer.display.height * this._mainStage.scaleY;
         if(isNaN(x))
         {
            layer.display.x = (sw - dw) / 2;
         }
         else
         {
            layer.display.x = x;
         }
         if(isNaN(y))
         {
            layer.display.y = (sh - dh) / 2;
         }
         else
         {
            layer.display.y = y;
         }
         this._mainStage.addChild(layer.display);
         if(effect)
         {
            effect.fadIn(layer,effectBack);
         }
         else
         {
            effectBack();
         }
         this._layers.push(layer);
      }
      
      public function hasLayer(param1:Object) : Boolean
      {
         var _loc2_:Istage = null;
         var _loc3_:Class = null;
         for each(_loc2_ in this._layers)
         {
            if(param1 is Istage)
            {
               if(_loc2_ == param1)
               {
                  return true;
               }
            }
            if(param1 is Class)
            {
               _loc3_ = param1 as Class;
               if(_loc2_ is _loc3_)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get noneLayer() : Boolean
      {
         return this._layers.length == 0;
      }
      
      public function removeLayer(param1:Istage, param2:IStageFadEffect = null, param3:Function = null) : void
      {
         var effectFin:Function = null;
         var layer:Istage = param1;
         var effect:IStageFadEffect = param2;
         var removeBack:Function = param3;
         effectFin = function():void
         {
            var ix:int;
            try
            {
               _mainStage.removeChild(layer.display);
               layer.destory();
            }
            catch(e:Error)
            {
               trace("KyoStageCtrl: removeLayer:",e);
            }
            ix = int(_layers.indexOf(layer));
            if(ix != -1)
            {
               _layers.splice(ix,1);
            }
            if(removeBack != null)
            {
               removeBack();
            }
         };
         if(effect)
         {
            effect.fadOut(layer,effectFin);
         }
         else
         {
            effectFin();
         }
      }
      
      public function removeAllLayer() : void
      {
         var _loc1_:Istage = null;
         for each(_loc1_ in this._layers)
         {
            this.removeLayer(_loc1_);
         }
         this._layers = [];
      }
      
      public function clean(param1:Boolean = true) : void
      {
         if(param1)
         {
            this.removeAllLayer();
         }
         if(this._curStage)
         {
            this._curStage.destory();
            this._mainStage.removeChild(this._curStage.display);
            this._curStage = null;
         }
      }
      
      private function set stageMouseChildren(param1:Boolean) : void
      {
         if(this._mainStage.stage)
         {
            this._mainStage.stage.mouseChildren = param1;
         }
      }
   }
}

