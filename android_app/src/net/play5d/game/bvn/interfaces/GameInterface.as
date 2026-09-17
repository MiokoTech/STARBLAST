package net.play5d.game.bvn.interfaces
{
   import flash.utils.ByteArray;
   
   public class GameInterface
   {
      public static var instance:IGameInterface;
      
      public function GameInterface()
      {
         super();
      }
      
      public static function getDefaultMenu() : Array
      {
         return [{
            "txt":"TEAM PLAY",
            "cn":"小队模式",
            "children":[{
               "txt":"TEAM ACRADE",
               "cn":"闯关模式"
            },{
               "txt":"TEAM VS PEOPLE",
               "cn":"2P对战"
            },{
               "txt":"TEAM VS CPU",
               "cn":"对战电脑"
            }]
         },{
            "txt":"SINGLE PLAY",
            "cn":"单人模式",
            "children":[{
               "txt":"SINGLE ACRADE",
               "cn":"闯关模式"
            },{
               "txt":"SINGLE VS PEOPLE",
               "cn":"2P对战"
            },{
               "txt":"SINGLE VS CPU",
               "cn":"对战电脑"
            }]
         },{
            "txt":"MUSOU PLAY",
            "cn":"无双模式",
            "children":[{
               "txt":"MUSOU ACRADE",
               "cn":"无双模式"
            }]
         },{
            "txt":"OPTION",
            "cn":"游戏设置"
         },{
            "txt":"TRAINING",
            "cn":"练习模式"
         },{
            "txt":"CREDITS",
            "cn":"制作组"
         },{
            "txt":"MORE GAMES",
            "cn":"更多游戏"
         }];
      }
      
      public static function checkFile(param1:String, param2:ByteArray) : Boolean
      {
         if(instance)
         {
            return instance.checkFile(param1,param2);
         }
         return true;
      }
      
      public static function addMoney(param1:Function) : void
      {
         var back:Function = param1;
         var addMoneyBack:* = function(param1:*):void
         {
            var _loc2_:int = param1;
            if(_loc2_ < 1)
            {
               return;
            }
            if(_loc2_ > 5000)
            {
               return;
            }
            back(_loc2_);
         };
         if(instance)
         {
            instance.addMosouMoney(addMoneyBack);
            return;
         }
         addMoneyBack(100 + Math.random() * 500);
      }
   }
}

