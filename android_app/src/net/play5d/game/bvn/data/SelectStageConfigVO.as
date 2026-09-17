package net.play5d.game.bvn.data
{
   import flash.geom.Point;
   import net.play5d.game.bvn.utils.LegacyResolutionAdapter;
   
   public class SelectStageConfigVO
   {
      public var x:Number = 0;
      
      public var y:Number = 0;
      
      public var width:Number = 800;
      
      public var height:Number = 600;
      
      public var top:Number = 0;
      
      public var bottom:Number = 0;
      
      public var left:Number = 0;
      
      public var right:Number = 0;
      
      public var charList:SelectCharListConfigVO;
      
      public var assistList:SelectCharListConfigVO;
      
      public var unitSize:Point = new Point(50,50);
      
      public function SelectStageConfigVO()
      {
         super();
      }
      
      public function setByXML(xml:XML) : void
      {
         var layoutNode:XML = xml.stage_setting.layout[0];
         var layoutX:Number = Number(layoutNode.@x);
         var layoutY:Number = Number(layoutNode.@y);
         var layoutWidth:Number = Number(layoutNode.@width);
         var layoutHeight:Number = Number(layoutNode.@height);
         var layoutTop:Number = Number(layoutNode.@top);
         var layoutBottom:Number = Number(layoutNode.@bottom);
         var layoutLeft:Number = Number(layoutNode.@left);
         var layoutRight:Number = Number(layoutNode.@right);
         var useLegacyLayoutScale:Boolean = LegacyResolutionAdapter.shouldScaleLegacyLayout(layoutWidth,layoutHeight);
         x = useLegacyLayoutScale ? LegacyResolutionAdapter.scaleX(layoutX) : layoutX;
         y = useLegacyLayoutScale ? LegacyResolutionAdapter.scaleY(layoutY) : layoutY;
         width = useLegacyLayoutScale ? LegacyResolutionAdapter.scaleX(layoutWidth) : layoutWidth;
         height = useLegacyLayoutScale ? LegacyResolutionAdapter.scaleY(layoutHeight) : layoutHeight;
         top = useLegacyLayoutScale ? LegacyResolutionAdapter.scaleY(layoutTop) : layoutTop;
         bottom = useLegacyLayoutScale ? LegacyResolutionAdapter.scaleY(layoutBottom) : layoutBottom;
         left = useLegacyLayoutScale ? LegacyResolutionAdapter.scaleX(layoutLeft) : layoutLeft;
         right = useLegacyLayoutScale ? LegacyResolutionAdapter.scaleX(layoutRight) : layoutRight;
         unitSize = new Point(useLegacyLayoutScale ? LegacyResolutionAdapter.scaleX(50) : 50,useLegacyLayoutScale ? LegacyResolutionAdapter.scaleY(50) : 50);
         charList = parseListByXML(xml.char_list,useLegacyLayoutScale);
         assistList = parseListByXML(xml.assist_list,useLegacyLayoutScale);
      }
      
      private function parseListByXML(listXml:XMLList, useLegacyLayoutScale:Boolean) : SelectCharListConfigVO
      {
         var listConfig:SelectCharListConfigVO = new SelectCharListConfigVO();
         listConfig.VCount = listXml.children().length();
         var rowIndex:int = 0;
         while(rowIndex < listXml.children().length())
         {
            var rowXML:XML = listXml.children()[rowIndex];
            if(listConfig.HCount < rowXML.children().length())
            {
               listConfig.HCount = rowXML.children().length();
            }
            var rowOffset:Point = parseOffset(rowXML.@offset,useLegacyLayoutScale);
            var columnIndex:int = 0;
            while(columnIndex < rowXML.children().length())
            {
               var itemXML:XML = rowXML.children()[columnIndex];
               var moreFighterRaw:String = itemXML.@moreFighter;
               var moreFighterIDs:Array = null;
               if(moreFighterRaw && moreFighterRaw.length > 0)
               {
                  moreFighterIDs = moreFighterRaw.split(",");
               }
               var fighterID:String = itemXML.toString();
               if(fighterID && fighterID.length < 1)
               {
                  fighterID = null;
               }
               var itemOffset:Point = rowOffset ? rowOffset.clone() : null;
               var localOffset:Point = parseOffset(itemXML.@offset,useLegacyLayoutScale);
               if(localOffset)
               {
                  if(itemOffset)
                  {
                     itemOffset.x += localOffset.x;
                     itemOffset.y += localOffset.y;
                  }
                  else
                  {
                     itemOffset = localOffset;
                  }
               }
               var selectItem:SelectCharListItemVO = new SelectCharListItemVO(columnIndex,rowIndex,fighterID,itemOffset);
               selectItem.moreFighterIDs = moreFighterIDs;
               listConfig.list.push(selectItem);
               columnIndex++;
            }
            rowIndex++;
         }
         return listConfig;
      }
      
      private function parseOffset(offsetRaw:String, useLegacyLayoutScale:Boolean) : Point
      {
         if(!offsetRaw || offsetRaw.length < 1)
         {
            return null;
         }
         var offsetValues:Array = offsetRaw.split(",");
         if(offsetValues.length < 2)
         {
            return null;
         }
         var offsetX:Number = Number(offsetValues[0]);
         var offsetY:Number = Number(offsetValues[1]);
         if(useLegacyLayoutScale)
         {
            return new Point(LegacyResolutionAdapter.scaleX(offsetX),LegacyResolutionAdapter.scaleY(offsetY));
         }
         return new Point(offsetX,offsetY);
      }
   }
}
