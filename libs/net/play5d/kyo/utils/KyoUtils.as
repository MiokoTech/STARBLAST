package net.play5d.kyo.utils
{
   import com.adobe.utils.StringUtil;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.ContextMenuEvent;
   import flash.filters.BitmapFilter;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.SoundTransform;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.utils.ByteArray;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class KyoUtils
   {
      public function KyoUtils()
      {
         super();
      }
      
      public static function array_findOneByPortal(param1:Array, param2:*, param3:*) : *
      {
         var _loc4_:* = undefined;
         for each(_loc4_ in param1)
         {
            if(_loc4_[param2] == param3)
            {
               return _loc4_;
            }
         }
         return null;
      }
      
      public static function array_removeByPortal(param1:Array, param2:*, param3:*) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = undefined;
         while(_loc4_ < param1.length)
         {
            _loc5_ = param1[_loc4_];
            if(_loc5_[param2] == param3)
            {
               param1.splice(_loc4_,1);
            }
            _loc4_++;
         }
      }
      
      public static function array_findAllByPortal(param1:Array, param2:*, param3:*) : *
      {
         var _loc5_:* = undefined;
         var _loc4_:Array = [];
         for each(_loc5_ in param1)
         {
            if(_loc5_[param2] == param3)
            {
               _loc4_.push(_loc5_);
            }
         }
         return _loc4_;
      }
      
      public static function array_hasItem(param1:Array, param2:*) : Boolean
      {
         var _loc3_:int = int(param1.indexOf(param2));
         return _loc3_ != -1;
      }
      
      public static function array_push_notHas(param1:Array, param2:*) : Boolean
      {
         if(param2 == null)
         {
            return false;
         }
         var _loc3_:int = int(param1.indexOf(param2));
         if(_loc3_ == -1)
         {
            param1.push(param2);
            return true;
         }
         return false;
      }
      
      public static function array_pushAt(param1:Array, param2:*, param3:int) : void
      {
         var _loc4_:Array = null;
         var _loc7_:int = 0;
         if(param2 is Array)
         {
            _loc4_ = param2 as Array;
         }
         else
         {
            _loc4_ = [param2];
         }
         var _loc5_:int = int(param1.length);
         while(_loc5_ > param3)
         {
            _loc7_ = _loc5_ + (_loc4_.length - 1);
            param1[_loc7_] = param1[_loc5_ - 1];
            _loc5_--;
         }
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_.length)
         {
            param1[param3 + _loc6_] = _loc4_[_loc6_];
            _loc6_++;
         }
      }
      
      public static function array_removeItem(param1:Object, param2:*) : void
      {
         var _loc3_:int = int(param1.indexOf(param2));
         if(_loc3_ != -1)
         {
            param1.splice(_loc3_,1);
         }
      }
      
      public static function array_deleteSames(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc2_:Object = param1.concat();
         param1.splice(0,param1.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_];
            if(param1.indexOf(_loc4_) == -1)
            {
               param1.push(_loc4_);
            }
            _loc3_++;
         }
      }
      
      public static function array_countItem(param1:Object, param2:*) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            if(param1[_loc4_] == param2)
            {
               _loc3_++;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function sprite_removeAllChildren(param1:Sprite) : void
      {
         while(param1.numChildren > 0)
         {
            param1.removeChildAt(0);
         }
      }
      
      public static function array_fixID(param1:Array) : Array
      {
         var _loc3_:* = undefined;
         var _loc2_:Array = [];
         for each(_loc3_ in param1)
         {
            _loc2_.push(_loc3_);
         }
         return _loc2_;
      }
      
      public static function array_getSamePortalItems(param1:Array, param2:String) : Array
      {
         var _loc5_:* = undefined;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc8_:* = undefined;
         var _loc3_:Object = {};
         var _loc4_:Object = {};
         for each(_loc5_ in param1)
         {
            _loc8_ = _loc5_[param2];
            if(_loc3_[_loc8_])
            {
               _loc4_[_loc8_] = 1;
            }
            else
            {
               _loc3_[_loc8_] = 1;
            }
         }
         _loc6_ = [];
         for(_loc7_ in _loc4_)
         {
            for each(_loc5_ in param1)
            {
               if(_loc5_[param2] == _loc7_)
               {
                  _loc6_.push(_loc5_);
               }
            }
         }
         return _loc6_;
      }
      
      public static function array_groupByPortal(param1:Array, param2:String) : Object
      {
         var _loc4_:* = undefined;
         var _loc5_:* = undefined;
         var _loc3_:Object = {};
         for each(_loc4_ in param1)
         {
            _loc5_ = _loc4_[param2];
            _loc3_[_loc5_] = _loc3_[_loc5_] || [];
            (_loc3_[_loc5_] as Array).push(_loc4_);
         }
         return _loc3_;
      }
      
      public static function getBitmapDatasByMC(param1:DisplayObject) : Array
      {
         var _loc3_:BitmapData = null;
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc2_:Array = [];
         if(param1 is MovieClip)
         {
            _loc4_ = param1 as MovieClip;
            while(_loc5_ < _loc4_.totalFrames)
            {
               _loc4_.gotoAndStop(_loc5_);
               _loc3_ = new BitmapData(_loc4_.width,_loc4_.height,true,0);
               _loc3_.draw(_loc4_);
               _loc2_.push(_loc3_);
               _loc5_++;
            }
         }
         else
         {
            _loc3_ = new BitmapData(param1.width,param1.height,true,0);
            _loc3_.draw(param1);
            _loc2_.push(_loc3_);
         }
         return _loc2_;
      }
      
      public static function drawDisplay(displayObj:DisplayObject, autoOffset:Boolean = true, transparent:Boolean = true, fillColor:uint = 0, colorTransform:ColorTransform = null) : Bitmap
      {
         var matrix:Matrix = null;
         var bounds:Rectangle = null;
         if(!displayObj || displayObj.width <= 0 || displayObj.height <= 0)
         {
            return null;
         }
         var bmp:Bitmap = new Bitmap(new BitmapData(displayObj.width, displayObj.height, transparent, fillColor));
         if(autoOffset)
         {
            bounds = displayObj.getBounds(displayObj);
            matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
         }
         bmp.bitmapData.draw(displayObj, matrix, colorTransform);
         return bmp;
      }
      
      public static function drawBitmapFilter(param1:DisplayObject, param2:BitmapFilter, param3:Boolean = true, param4:Point = null) : BitmapData
      {
         var _loc6_:Matrix = null;
         var _loc9_:Rectangle = null;
         var _loc5_:BitmapData = new BitmapData(param1.width,param1.height,true,0);
         if(param3)
         {
            _loc9_ = param1.getBounds(param1);
            _loc6_ = new Matrix(1,0,0,1,-_loc9_.x,-_loc9_.y);
         }
         _loc5_.draw(param1,_loc6_);
         var _loc7_:Rectangle = new Rectangle(0,0,param1.width,param1.height);
         if(param4)
         {
            _loc7_.x -= param4.x;
            _loc7_.y -= param4.y;
            _loc7_.width += param4.x * 2;
            _loc7_.height += param4.y * 2;
         }
         var _loc8_:BitmapData = new BitmapData(_loc7_.width,_loc7_.height,true,0);
         _loc8_.applyFilter(_loc5_,_loc7_,new Point(),param2);
         _loc5_.dispose();
         return _loc8_;
      }
      
      public static function drawInverted(param1:DisplayObject, param2:Number, param3:Number = 0.3) : Bitmap
      {
         var _loc4_:Bitmap = new Bitmap(new BitmapData(param1.width,param2,true,0));
         var _loc5_:Matrix = new Matrix();
         _loc5_.ty = -param2;
         _loc4_.bitmapData.draw(param1,_loc5_);
         _loc4_.scaleY = -1;
         _loc4_.y = param1.height + param2 / 1.7;
         _loc4_.alpha = param3;
         return _loc4_;
      }
      
      public static function translateMC(param1:MovieClip, param2:String) : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:DisplayObject = null;
         if(param2 == null)
         {
            return;
         }
         for each(_loc3_ in param1.currentLabels)
         {
            if(_loc3_.name == param2)
            {
               param1.gotoAndStop(param2);
               return;
            }
         }
         while(_loc4_ < param1.numChildren)
         {
            _loc5_ = param1.getChildAt(_loc4_);
            if(_loc5_ is MovieClip)
            {
               translateMC(_loc5_ as MovieClip,param2);
            }
            _loc4_++;
         }
      }
      
      public static function transparent(param1:*, param2:* = null, param3:* = null) : BitmapData
      {
         var _loc4_:uint = 0;
         var _loc5_:BitmapData = param1 is Bitmap ? param1.bitmapData : param1;
         if(param2 == null)
         {
            _loc4_ = _loc5_.getPixel(0,0);
         }
         else if(param3 == null)
         {
            _loc4_ = param2;
         }
         else
         {
            _loc4_ = _loc5_.getPixel(param2,param3);
         }
         var _loc6_:Rectangle = new Rectangle(0,0,_loc5_.width,_loc5_.height);
         var _loc7_:Point = new Point(0,0);
         var _loc8_:BitmapData = new BitmapData(_loc5_.width,_loc5_.height,true);
         _loc8_.copyPixels(_loc5_,_loc6_,_loc7_);
         _loc8_.threshold(_loc5_,_loc6_,_loc7_,"==",_loc4_,0,15790320,true);
         return _loc8_;
      }
      
      public static function getToChildPoint(param1:DisplayObject, param2:DisplayObjectContainer) : Point
      {
         var _loc3_:Point = new Point(param1.x,param1.y);
         var _loc4_:DisplayObjectContainer = param1.parent;
         while(_loc4_ != null)
         {
            _loc3_.x += _loc4_.x;
            _loc3_.y += _loc4_.y;
            if(_loc4_ == param2)
            {
               return _loc3_;
            }
            _loc4_ = _loc4_.parent;
         }
         trace(param2,"is not",param1,"\'s parent!");
         return _loc3_;
      }
      
      public static function moveDisplay(param1:DisplayObject, param2:DisplayObjectContainer, param3:Boolean = true) : void
      {
         var _loc4_:Point = null;
         if(param3)
         {
            _loc4_ = getToChildPoint(param1,param2);
            param1.x = _loc4_.x;
            param1.y = _loc4_.y;
         }
         param2.addChild(param1);
      }
      
      public static function addZeroBeforNumber(param1:Number, param2:int = 2) : String
      {
         var _loc8_:int = 0;
         var _loc3_:String = param1.toString();
         var _loc4_:int = int(_loc3_.indexOf(".",0));
         var _loc5_:String = _loc4_ == -1 ? "" : _loc3_.substr(_loc4_);
         var _loc6_:String = _loc4_ == -1 ? _loc3_ : _loc3_.substr(0,_loc4_);
         var _loc7_:String = "";
         while(_loc8_ < param2 - _loc6_.length)
         {
            _loc7_ += "0";
            _loc8_++;
         }
         return _loc7_ + _loc6_ + _loc5_;
      }
      
      public static function getPostfix(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc2_:int = int(param1.indexOf("?"));
         if(_loc2_ == -1)
         {
            _loc3_ = int(param1.lastIndexOf("."));
            _loc4_ = param1.substr(_loc3_ + 1);
         }
         else
         {
            _loc5_ = param1.substr(_loc2_ - 5,5);
            _loc3_ = int(_loc5_.indexOf("."));
            _loc4_ = _loc5_.substr(_loc3_ + 1);
         }
         return _loc4_.toLowerCase();
      }
      
      public static function removeAllChildren(param1:DisplayObjectContainer, param2:Function = null) : void
      {
         var _loc3_:DisplayObject = null;
         while(param1.numChildren)
         {
            _loc3_ = param1.removeChildAt(0);
            if(param2 != null)
            {
               param2(_loc3_);
            }
         }
      }
      
      public static function removeChildByName(param1:DisplayObjectContainer, param2:String) : void
      {
         var _loc3_:DisplayObject = param1.getChildByName(param2);
         if(_loc3_)
         {
            param1.removeChild(_loc3_);
         }
      }
      
      public static function number2CN(param1:int) : String
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = "";
         if(param1 >= 10000)
         {
            _loc2_ = int(param1 / 10000);
            param1 -= 10000;
            _loc6_ += num2cnbase(_loc2_) + "万";
         }
         if(param1 >= 1000)
         {
            _loc3_ = int(param1 / 1000);
            param1 -= 1000;
            _loc6_ += num2cnbase(_loc3_) + "千";
         }
         else if(_loc2_ > 0)
         {
            _loc6_ += "零";
         }
         if(param1 >= 100)
         {
            _loc4_ = int(param1 / 100);
            param1 -= _loc4_ * 100;
            _loc6_ += num2cnbase(_loc4_) + "百";
         }
         if(param1 >= 10)
         {
            _loc5_ = int(param1 / 10);
            param1 -= _loc5_ * 10;
            if(_loc4_ > 0)
            {
               if(_loc5_ > 0)
               {
                  _loc6_ += num2cnbase(_loc5_) + "十";
               }
            }
            if(_loc4_ == 0)
            {
               if(_loc5_ == 1)
               {
                  _loc6_ += "十";
               }
               if(_loc5_ > 1)
               {
                  _loc6_ += num2cnbase(_loc5_) + "十";
               }
            }
         }
         if(param1 > 0 && _loc5_ == 0 && _loc4_ > 0)
         {
            _loc6_ += "零";
         }
         return _loc6_ + num2cnbase(param1,_loc6_ == "");
      }
      
      private static function num2cnbase(param1:int, param2:Boolean = true) : String
      {
         if(!param2 && param1 == 0)
         {
            return "";
         }
         var _loc3_:Array = ["零","一","二","三","四","五","六","七","八","九"];
         return _loc3_[param1];
      }
      
      public static function appendTextAutoLine(param1:TextField, param2:String) : Boolean
      {
         var _loc3_:int = param1.maxScrollV;
         var _loc4_:String = param1.text;
         param1.appendText(param2);
         if(param1.maxScrollV > _loc3_)
         {
            param1.text = _loc4_ + "\n" + param2;
            return true;
         }
         return false;
      }
      
      public static function appendTextBottom(param1:TextField, param2:String, param3:int, param4:Boolean = false) : void
      {
         var _loc6_:int = 0;
         if(param1.numLines <= 1)
         {
            while(_loc6_ < param3)
            {
               if(param4)
               {
                  param1.htmlText += "<br/>";
               }
               else
               {
                  param1.appendText("\n");
               }
               _loc6_++;
            }
         }
         if(param4)
         {
            param1.htmlText += param2;
         }
         else
         {
            param1.appendText("\n" + param2);
         }
         var _loc5_:int = param1.getLineOffset(1);
         if(_loc5_ != -1)
         {
            param1.replaceText(0,_loc5_,"");
         }
      }
      
      public static function math_is_between(param1:Number, param2:Number, param3:Number) : Boolean
      {
         return param1 >= param2 && param1 <= param3 || param1 >= param3 && param1 <= param2;
      }
      
      public static function num_wake(param1:Number, param2:Number) : Number
      {
         if(param1 > 0)
         {
            param1 -= param2;
            if(param1 < 0)
            {
               param1 = 0;
            }
         }
         if(param1 < 0)
         {
            param1 += param2;
            if(param1 > 0)
            {
               param1 = 0;
            }
         }
         return param1;
      }
      
      public static function num_strong(param1:Number, param2:Number) : Number
      {
         if(param1 < 0)
         {
            param1 -= param2;
         }
         else
         {
            param1 += param2;
         }
         return param1;
      }
      
      public static function num_fixRange(param1:Number, param2:Point) : Number
      {
         if(param1 < param2.x)
         {
            param1 = param2.x;
         }
         if(param1 > param2.y)
         {
            param1 = param2.y;
         }
         return param1;
      }
      
      public static function point_fixRange(param1:Point, param2:Rectangle) : void
      {
         if(param1.x < param2.x)
         {
            param1.x = param2.x;
         }
         if(param1.x > param2.width)
         {
            param1.x = param2.width;
         }
         if(param1.y < param2.y)
         {
            param1.y = param2.y;
         }
         if(param1.y > param2.height)
         {
            param1.y = param2.height;
         }
      }
      
      public static function num_decimal(param1:Number, param2:int = 1) : Number
      {
         var _loc3_:int = int(param1);
         var _loc4_:String = param1.toString();
         var _loc5_:int = int(_loc4_.indexOf("."));
         if(_loc5_ == -1)
         {
            return _loc3_;
         }
         var _loc6_:String = _loc4_.substr(_loc5_,param2 + 1);
         var _loc7_:Number = Number(_loc6_);
         return _loc3_ + _loc7_;
      }
      
      public static function num_toPersent(param1:Number, param2:int = -1) : String
      {
         var _loc3_:Number = param1 * 1000 / 10;
         if(param2 != -1)
         {
            if(param2 == 0)
            {
               _loc3_ = int(_loc3_);
            }
            else
            {
               _loc3_ = num_decimal(_loc3_,param2);
            }
         }
         return _loc3_.toString() + "%";
      }
      
      public static function setValueByObject(param1:*, param2:Object) : void
      {
         var i:String = null;
         var tmp:* = undefined;
         var vv:Object = null;
         var setter:* = param1;
         var obj:Object = param2;
         if(!obj)
         {
            return;
         }
         for(i in obj)
         {
            tmp = undefined;
            try
            {
               tmp = setter[i];
            }
            catch(e:Error)
            {
            }
            vv = obj[i];
            if(tmp === undefined)
            {
               try
               {
                  setter[i] = vv;
               }
               catch(e:Error)
               {
                  trace("KyoUtils.setValueByObject :",e);
               }
               continue;
            }
            if(setter[i] is Boolean)
            {
               if(vv is Boolean)
               {
                  setter[i] = vv;
               }
               else if(vv is Number)
               {
                  setter[i] = vv == 1;
               }
               else if(vv is String)
               {
                  setter[i] = vv == "true" || vv == "1";
               }
            }
            else if(setter[i] is Number)
            {
               setter[i] = Number(vv);
            }
            else
            {
               setter[i] = vv;
            }
         }
      }
      
      public static function cloneValue(param1:*, param2:*, param3:Array = null) : *
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         if(param3)
         {
            for each(_loc4_ in param3)
            {
               param1[_loc4_] = param2[_loc4_];
            }
         }
         else
         {
            for(_loc5_ in param2)
            {
               param1[_loc5_] = param2[_loc5_];
            }
         }
         return param1;
      }
      
      public static function cloneObject(param1:Object) : Object
      {
         var _loc3_:String = null;
         var _loc2_:Object = {};
         for(_loc3_ in param1)
         {
            _loc2_[_loc3_] = param1[_loc3_];
         }
         return _loc2_;
      }
      
      public static function setText(param1:TextField, param2:Object = "", param3:Boolean = false, param4:String = "null", param5:Boolean = false) : void
      {
         var _loc6_:String = String(param2);
         if(_loc6_ == null)
         {
            _loc6_ = param4;
         }
         param1.mouseEnabled = param3;
         param1.text = _loc6_;
         if(param5)
         {
            textFieldAutoSize(param1);
         }
      }
      
      public static function textFieldAutoSize(param1:TextField) : void
      {
         var _loc2_:TextFormat = param1.getTextFormat();
         if(param1.multiline == true)
         {
            while(param1.textHeight > param1.height)
            {
               _loc2_.size = int(_loc2_.size) - 1;
               param1.setTextFormat(_loc2_);
            }
         }
         else
         {
            while(param1.textWidth > param1.width)
            {
               _loc2_.size = int(_loc2_.size) - 1;
               param1.setTextFormat(_loc2_);
            }
         }
      }
      
      public static function alignTexts(param1:Array, param2:Number = NaN, param3:int = 0, param4:String = null, param5:Point = null) : void
      {
         var _loc7_:TextField = null;
         var _loc8_:TextField = null;
         param4 ||= TextFieldAutoSize.LEFT;
         var _loc6_:Number = param2;
         if(isNaN(_loc6_))
         {
            _loc8_ = param1[0] as TextField;
            _loc6_ = param3 == 0 ? _loc8_.x : _loc8_.y;
         }
         for each(_loc7_ in param1)
         {
            _loc7_.autoSize = param4;
            if(param5)
            {
               _loc7_.width += param5.x;
               _loc7_.height += param5.y;
            }
            switch(param3)
            {
               case 0:
                  _loc7_.x = _loc6_;
                  _loc6_ += _loc7_.width;
                  break;
               case 1:
                  _loc7_.y = _loc6_;
                  _loc6_ += _loc7_.height;
            }
         }
      }
      
      public static function matchPoint(param1:Point, param2:Point) : Boolean
      {
         if(!param1 || !param2)
         {
            return false;
         }
         return param1.x == param2.x && param1.y == param2.y;
      }
      
      public static function matchRectangel(param1:Rectangle, param2:Rectangle) : Boolean
      {
         if(!param1 || !param2)
         {
            return false;
         }
         return param1.x == param2.x && param1.y == param2.y && param1.width == param2.width && param1.height == param2.height;
      }
      
      public static function rect_is_hit(param1:Rectangle, param2:Rectangle) : Rectangle
      {
         var r:Rectangle;
         var rectA:Rectangle = param1;
         var rectB:Rectangle = param2;
         var checkRect:Function = function(param1:Rectangle):void
         {
            if(param1.width < 0)
            {
               param1.width *= -1;
               param1.x -= param1.width;
            }
            if(param1.height < 0)
            {
               param1.height *= -1;
               param1.y -= param1.height;
            }
         };
         checkRect(rectA);
         checkRect(rectB);
         r = rectA.intersection(rectB);
         if(!r.isEmpty())
         {
            return r;
         }
         return null;
      }
      
      public static function addFrameScript(param1:MovieClip, param2:Function, param3:int = -1) : void
      {
         var _loc4_:uint = 0;
         if(param3 == -1)
         {
            _loc4_ = uint(param1.totalFrames - 1);
         }
         param1.addFrameScript(_loc4_,param2);
      }
      
      public static function string_length(param1:String, param2:String = "gb2312") : int
      {
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeMultiByte(param1,param2);
         return _loc3_.length;
      }
      
      public static function str_removePrefix(param1:String) : String
      {
         var _loc2_:int = int(param1.indexOf("."));
         if(_loc2_ == -1)
         {
            return param1;
         }
         return param1.substr(0,_loc2_);
      }
      
      public static function str_replaceALL(param1:String, param2:*, param3:*) : String
      {
         return param1.split(param2).join(param3);
      }
      
      public static function str_matchALL(param1:String, param2:*) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc3_:Array = [];
         while(_loc4_ < 10000)
         {
            _loc5_ = param1.match(param2);
            if(!_loc5_ || _loc5_.length < 1)
            {
               break;
            }
            _loc6_ = _loc5_[1];
            param1 = param1.replace(_loc6_,"");
            _loc3_.push(_loc6_);
            _loc4_++;
         }
         return _loc3_.reverse();
      }
      
      public static function getPrefix(param1:String) : String
      {
         var _loc2_:int = int(param1.indexOf("."));
         var _loc3_:String = param1.substr(_loc2_ + 1);
         return _loc3_.toLocaleLowerCase();
      }
      
      public static function grayMC(param1:DisplayObject, param2:Boolean = false) : void
      {
         var _loc5_:Array = null;
         var _loc6_:* = undefined;
         if(!param1)
         {
            return;
         }
         if(param2)
         {
            _loc5_ = param1.filters.concat();
            param1.filters = null;
            for each(_loc6_ in _loc5_)
            {
               if(_loc6_ is ColorMatrixFilter)
               {
                  array_removeItem(_loc5_,_loc6_);
               }
            }
            param1.filters = _loc5_;
            return;
         }
         var _loc3_:Array = new Array();
         _loc3_ = _loc3_.concat([0.3086,0.6094,0.082,0,0]);
         _loc3_ = _loc3_.concat([0.3086,0.6094,0.082,0,0]);
         _loc3_ = _loc3_.concat([0.3086,0.6094,0.082,0,0]);
         _loc3_ = _loc3_.concat([0,0,0,1,0]);
         var _loc4_:ColorMatrixFilter = new ColorMatrixFilter(_loc3_);
         param1.filters = [_loc4_];
      }
      
      public static function getObjLength(param1:Object) : int
      {
         var _loc3_:* = undefined;
         if(!param1)
         {
            return 0;
         }
         var _loc2_:int = 0;
         for each(_loc3_ in param1)
         {
            if(_loc3_)
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public static function clone(param1:Object) : *
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeObject(param1);
         _loc2_.position = 0;
         return _loc2_.readObject();
      }
      
      public static function readTextVariables(param1:String) : Object
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:Object = null;
         var _loc2_:Object = {};
         param1 = StringUtil.replace(param1,"\r","");
         var _loc3_:Array = param1.split("\n");
         var _loc4_:Array = [];
         for each(_loc6_ in _loc3_)
         {
            if(_loc6_.substr(0,2) != "//")
            {
               _loc7_ = _loc6_.split("=");
               _loc8_ = _loc7_[0];
               _loc9_ = _loc7_[1];
               _loc2_[_loc8_] = _loc9_;
            }
         }
         return _loc2_;
      }
      
      public static function getClass(param1:Object) : Class
      {
         var _loc2_:String = getQualifiedClassName(param1);
         return getDefinitionByName(_loc2_) as Class;
      }
      
      public static function customMenu(param1:Sprite, param2:Array, param3:Function = null) : void
      {
         var i:String = null;
         var menuItem:ContextMenuItem = null;
         var main:Sprite = param1;
         var menu:Array = param2;
         var select:Function = param3;
         var cm:ContextMenu = new ContextMenu();
         for each(i in menu)
         {
            menuItem = new ContextMenuItem(i);
            if(select != null)
            {
               menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(param1:ContextMenuEvent):void
               {
                  select((param1.currentTarget as ContextMenuItem).caption);
               });
            }
            cm.customItems.push(menuItem);
         }
         if(main.stage)
         {
            main.stage.showDefaultContextMenu = false;
         }
         main.contextMenu = cm;
      }
      
      public static function itemToObject(param1:*) : Object
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc2_:XML = describeType(param1);
         var _loc3_:Object = {};
         for each(_loc4_ in _loc2_.variable)
         {
            _loc5_ = _loc4_.@name;
            _loc3_[_loc5_] = param1[_loc5_];
         }
         return _loc3_;
      }
      
      public static function getItemVaribles(param1:*) : Array
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc2_:XML = describeType(param1);
         var _loc3_:Array = [];
         for each(_loc4_ in _loc2_.variable)
         {
            _loc5_ = _loc4_.@name;
            _loc3_.push(_loc5_);
         }
         return _loc3_;
      }
      
      public static function cloneSimpleClassObject(param1:*) : *
      {
         var _loc2_:Object = itemToObject(param1);
         var _loc3_:Class = getDefinitionByName(getQualifiedClassName(param1)) as Class;
         var _loc4_:* = new _loc3_();
         setValueByObject(_loc4_,_loc2_);
         return _loc4_;
      }
      
      public static function setMcVolume(param1:Sprite, param2:Number) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc3_:SoundTransform = param1.soundTransform;
         if(_loc3_)
         {
            _loc3_.volume = param2;
            param1.soundTransform = _loc3_;
         }
      }
      
      public static function cloneColorTransform(param1:ColorTransform) : *
      {
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.alphaMultiplier = param1.alphaMultiplier;
         _loc2_.alphaOffset = param1.alphaOffset;
         _loc2_.blueMultiplier = param1.blueMultiplier;
         _loc2_.blueOffset = param1.blueOffset;
         _loc2_.greenMultiplier = param1.greenMultiplier;
         _loc2_.greenOffset = param1.greenOffset;
         _loc2_.redMultiplier = param1.redMultiplier;
         _loc2_.redOffset = param1.redOffset;
         return _loc2_;
      }
   }
}

