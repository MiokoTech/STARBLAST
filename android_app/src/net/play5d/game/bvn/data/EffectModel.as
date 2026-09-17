package net.play5d.game.bvn.data
{
   public class EffectModel
   {
      
      private static var _i:EffectModel;
      
      private var _effect:Object;
      
      public function EffectModel()
      {
         super();
      }
      
      public static function get I() : EffectModel
      {
         if(!_i)
         {
            _i = new EffectModel();
         }
         return _i;
      }
      
      public function initlize() : void
      {
         initEffects();
         cacheEffects();
      }
      
      private function initEffects() : void
      {
         _effect = {};
         _effect["bisha"] = new EffectVO("XG_bs",{
            "sound":"snd_bs",
            "blendMode":"add"
         });
         _effect["bisha_super"] = new EffectVO("XG_cbs",{
            "sound":"snd_cbs",
            "blendMode":"add"
         });
         _effect["dash"] = new EffectVO("XG_rush",{"sound":"snd_dash_air"});
         _effect["dash_air"] = new EffectVO("XG_rush_air",{"sound":"snd_dash_air"});
         _effect["jump"] = new EffectVO("XG_jump",{"sound":"snd_jump"});
         _effect["jump_air"] = new EffectVO("XG_jump_air",{
            "sound":"snd_jump",
            "blendMode":"add"
         });
         _effect["touch_floor"] = new EffectVO("XG_luodi",{"sound":"snd_luodi"});
         _effect["hit_floor"] = new EffectVO("XG_hitfloor",{"sound":"snd_hitfloor"});
         _effect["hit_floor_low"] = new EffectVO("xg_hitfloor_low",{"sound":"snd_hitfloor_low"});
         _effect["hit_floor_heavy"] = new EffectVO("xg_hitfllor_heavy",{"sound":"snd_hitfloor_heavy"});
         _effect["hit_floor_yan"] = new EffectVO("xg_hitfloor_yan",{"blendMode":"lighten"});
         _effect["hit_end"] = new EffectVO("xg_hitover");
         _effect["break_def"] = new EffectVO("XG_mfdjx",{
            "sound":"snd_mfdjx",
            "blendMode":"add",
            "slowDown":{
               "rate":1.5,
               "time":1500
            },
            "freeze":500,
            "shake":{
               "x":6,
               "time":400
            }
         });
         _effect["fz_bleach"] = new EffectVO("XG_fz_bleach_mc",{"sound":"snd_dash"});
         _effect["fz_naruto"] = new EffectVO("XG_fz_naruto_mc",{"sound":"snd_fz"});
         _effect["replaceSp"] = new EffectVO("XG_tishen",{"sound":"snd_fz"});
         _effect["replaceSp2"] = new EffectVO("XG_tishen2");
         _effect["explodeSp"] = new EffectVO("XG_bsq",{"sound":"snd_baoqi1"});
         _effect["explodeSp2"] = new EffectVO("XG_baoqi",{"sound":"snd_baoqi"});
         _effect["ghost_step"] = new EffectVO("XG_ghost_step",{
            "sound":"snd_ghost_step",
            "blendMode":"add"
         });
         _effect["kobg"] = new EffectVO("kobg_effect_mc");
         _effect["level_up"] = new EffectVO("xg_mc_levelup",{"sound":"snd_level_up"});
         _effect["level_up_new_act"] = new EffectVO("xg_mc_levelup_newaction",{"sound":"snd_level_up"});
         _effect["team_change"] = new EffectVO("xg_mc_change",{
            "sound":"snd_change1",
            "blendMode":"add"
         });
         initHitEffect();
         initDefenseEffect();
         initSpeicalEffect();
         initBuffEffect();
         initSteelHitEffect();
         initMosouEnemyHitEffect();
         initMosouEnemyDefenseEffect();
      }
      
      private function cacheEffects() : void
      {
         for each(var _loc1_:EffectVO in _effect)
         {
            _loc1_.cacheBitmapData();
         }
      }
      
      private function initHitEffect() : void
      {
         addHitEffect(11,"xg_catch_hit",{
            "freeze":400,
            "sound":"snd_hit_cache"
         });
         addHitEffect(1,"XG_kan2",{
            "sound":"snd_kan1",
            "freeze":50,
            "blendMode":"add",
            "randRotate":true
         });
         addHitEffect(6,"XG_kanx2",{
            "sound":"snd_kan2",
            "freeze":400,
            "blendMode":"add",
            "shine":{
               "color":16777215,
               "alpha":0.2
            },
            "randRotate":true,
            "shake":{
               "pow":6,
               "time":400
            }
         });
         addHitEffect(2,"XG_qdj",{
            "sound":"snd_hit2",
            "blendMode":"add",
            "freeze":50,
            "randRotate":true
         });
         addHitEffect(3,"XG_qdjx",{
            "sound":"snd_hit_heavy",
            "blendMode":"add",
            "randRotate":true,
            "freeze":400,
            "shine":{
               "color":16777215,
               "alpha":0.2
            },
            "shake":{
               "pow":6,
               "time":400
            }
         });
         addHitEffect(4,"XG_mfdj",{
            "sound":"snd_hit2",
            "freeze":50,
            "blendMode":"add",
            "randRotate":true
         });
         addHitEffect(5,"XG_mfdjx",{
            "sound":"snd_mfdjx",
            "freeze":400,
            "blendMode":"add",
            "randRotate":true,
            "shine":{
               "color":16777215,
               "alpha":0.2
            },
            "shake":{
               "pow":6,
               "time":400
            }
         });
         addHitEffect(7,"XG_fire",{
            "sound":"snd_hit_fire",
            "blendMode":"add",
            "specialEffectId":"fire_ing",
            "freeze":400,
            "shine":{
               "color":16777063,
               "alpha":0.2
            },
            "shake":{
               "pow":6,
               "time":400
            }
         });
         addHitEffect(8,"XG_ice",{
            "sound":"snd_hit_ice",
            "blendMode":"add",
            "specialEffectId":"ice_ing",
            "freeze":400,
            "shine":{
               "color":10741237,
               "alpha":0.2
            },
            "shake":{
               "pow":6,
               "time":400
            }
         });
         addHitEffect(9,"XG_leidian",{
            "sound":"snd_hit_dian",
            "blendMode":"hardlight",
            "specialEffectId":"shock_ing",
            "freeze":400,
            "shine":{
               "color":8554706,
               "alpha":0.2
            },
            "shake":{
               "pow":6,
               "time":400
            }
         });
      }
      
      private function initDefenseEffect() : void
      {
         addDefenseEffect(1,"XG_fykan",{
            "sound":"snd_fykan",
            "freeze":50,
            "blendMode":"add",
            "followDirect":true
         });
         addDefenseEffect(6,"XG_fykanx",{
            "sound":"snd_fykanx",
            "freeze":400,
            "blendMode":"add",
            "shine":{
               "color":16777215,
               "blendMode":"screen",
               "alpha":0.1
            },
            "followDirect":true,
            "shake":{
               "pow":6,
               "time":400
            }
         });
         addDefenseEffect(2,"XG_fyq",{
            "sound":"snd_def",
            "freeze":50,
            "blendMode":"add",
            "followDirect":true
         });
         addDefenseEffect(3,"XG_fyqx",{
            "sound":"snd_defx",
            "freeze":400,
            "blendMode":"add",
            "followDirect":true,
            "shine":{
               "color":16777215,
               "alpha":0.1
            },
            "shake":{
               "pow":6,
               "time":400
            }
         });
         addDefenseEffect(4,"XG_mffy",{
            "sound":"snd_def",
            "freeze":50,
            "blendMode":"add",
            "followDirect":true
         });
         addDefenseEffect(5,"XG_mffyx",{
            "sound":"snd_defx",
            "freeze":400,
            "blendMode":"add",
            "followDirect":true,
            "shine":{
               "color":16777215,
               "alpha":0.15
            },
            "shake":{
               "pow":6,
               "time":400
            }
         });
         addDefenseEffect(7,"XG_fire_fy",{
            "sound":"snd_defx",
            "freeze":400,
            "blendMode":"add",
            "followDirect":true,
            "shine":{
               "color":16777063,
               "alpha":0.2
            },
            "shake":{
               "pow":6,
               "time":400
            }
         });
         addDefenseEffect(8,"XG_ice_fy",{
            "sound":"snd_defx",
            "freeze":400,
            "blendMode":"add",
            "followDirect":true,
            "shine":{
               "color":10741237,
               "alpha":0.2
            },
            "shake":{
               "pow":6,
               "time":400
            }
         });
         addDefenseEffect(9,"XG_dian_fy",{
            "sound":"snd_defx",
            "freeze":400,
            "blendMode":"add",
            "followDirect":true,
            "shine":{
               "color":8554706,
               "alpha":0.2
            },
            "shake":{
               "pow":6,
               "time":400
            }
         });
      }
      
      private function initMosouEnemyHitEffect() : void
      {
         addEnemyHitEffect(11,"xg_catch_hit",{
            "freeze":200,
            "sound":"snd_hit_cache"
         });
         addEnemyHitEffect(1,"XG_kan2",{
            "sound":"snd_kan1",
            "freeze":50,
            "blendMode":"add",
            "randRotate":true
         });
         addEnemyHitEffect(6,"XG_kanx2",{
            "sound":"snd_kan2",
            "freeze":200,
            "blendMode":"add",
            "shine":{
               "color":16777215,
               "alpha":0.2
            },
            "randRotate":true,
            "shake":{
               "pow":2,
               "time":100
            }
         });
         addEnemyHitEffect(2,"XG_qdj",{
            "sound":"snd_hit2",
            "blendMode":"add",
            "freeze":0,
            "randRotate":true
         });
         addEnemyHitEffect(3,"XG_qdjx",{
            "sound":"snd_hit_heavy",
            "blendMode":"add",
            "randRotate":true,
            "freeze":200,
            "shine":{
               "color":16777215,
               "alpha":0.2
            },
            "shake":{
               "pow":2,
               "time":100
            }
         });
         addEnemyHitEffect(4,"XG_mfdj",{
            "sound":"snd_hit2",
            "freeze":0,
            "blendMode":"add",
            "randRotate":true
         });
         addEnemyHitEffect(5,"XG_mfdjx",{
            "sound":"snd_mfdjx",
            "freeze":200,
            "blendMode":"add",
            "randRotate":true,
            "shine":{
               "color":16777215,
               "alpha":0.2
            },
            "shake":{
               "pow":2,
               "time":100
            }
         });
         addEnemyHitEffect(7,"XG_fire",{
            "sound":"snd_hit_fire",
            "blendMode":"add",
            "specialEffectId":"fire_ing",
            "freeze":200,
            "shine":{
               "color":16777063,
               "alpha":0.2
            },
            "shake":{
               "pow":2,
               "time":100
            }
         });
         addEnemyHitEffect(8,"XG_ice",{
            "sound":"snd_hit_ice",
            "blendMode":"add",
            "specialEffectId":"ice_ing",
            "freeze":200,
            "shine":{
               "color":10741237,
               "alpha":0.2
            },
            "shake":{
               "pow":2,
               "time":100
            }
         });
         addEnemyHitEffect(9,"XG_leidian",{
            "sound":"snd_hit_dian",
            "blendMode":"hardlight",
            "specialEffectId":"shock_ing",
            "freeze":200,
            "shine":{
               "color":8554706,
               "alpha":0.2
            },
            "shake":{
               "pow":2,
               "time":100
            }
         });
      }
      
      private function initMosouEnemyDefenseEffect() : void
      {
         addEnemyDefenseEffect(1,"XG_fykan",{
            "sound":"snd_fykan",
            "freeze":50,
            "blendMode":"add",
            "followDirect":true
         });
         addEnemyDefenseEffect(6,"XG_fykanx",{
            "sound":"snd_fykanx",
            "freeze":100,
            "blendMode":"add",
            "shine":{
               "color":16777215,
               "blendMode":"screen",
               "alpha":0.1
            },
            "followDirect":true,
            "shake":{
               "pow":2,
               "time":100
            }
         });
         addEnemyDefenseEffect(2,"XG_fyq",{
            "sound":"snd_def",
            "freeze":50,
            "blendMode":"add",
            "followDirect":true
         });
         addEnemyDefenseEffect(3,"XG_fyqx",{
            "sound":"snd_defx",
            "freeze":100,
            "blendMode":"add",
            "followDirect":true,
            "shine":{
               "color":16777215,
               "alpha":0.1
            },
            "shake":{
               "pow":2,
               "time":100
            }
         });
         addEnemyDefenseEffect(4,"XG_mffy",{
            "sound":"snd_def",
            "freeze":50,
            "blendMode":"add",
            "followDirect":true
         });
         addEnemyDefenseEffect(5,"XG_mffyx",{
            "sound":"snd_defx",
            "freeze":100,
            "blendMode":"add",
            "followDirect":true,
            "shine":{
               "color":16777215,
               "alpha":0.15
            },
            "shake":{
               "pow":2,
               "time":100
            }
         });
         addEnemyDefenseEffect(7,"XG_fire_fy",{
            "sound":"snd_defx",
            "freeze":100,
            "blendMode":"add",
            "followDirect":true,
            "shine":{
               "color":16777063,
               "alpha":0.2
            },
            "shake":{
               "pow":2,
               "time":100
            }
         });
         addEnemyDefenseEffect(8,"XG_ice_fy",{
            "sound":"snd_defx",
            "freeze":100,
            "blendMode":"add",
            "followDirect":true,
            "shine":{
               "color":10741237,
               "alpha":0.2
            },
            "shake":{
               "pow":2,
               "time":100
            }
         });
         addEnemyDefenseEffect(9,"XG_dian_fy",{
            "sound":"snd_defx",
            "freeze":100,
            "blendMode":"add",
            "followDirect":true,
            "shine":{
               "color":8554706,
               "alpha":0.2
            },
            "shake":{
               "pow":2,
               "time":100
            }
         });
      }
      
      private function initSpeicalEffect() : void
      {
         _effect["fire_ing"] = new EffectVO("xg_fire_ing",{
            "blendMode":"add",
            "isSpecial":true,
            "targetColorOffset":[-255,-255,-255]
         });
         _effect["ice_ing"] = new EffectVO("xg_ice_ing",{
            "blendMode":"add",
            "isSpecial":true,
            "targetColorOffset":[0,0,255]
         });
         _effect["shock_ing"] = new EffectVO("xg_dian_ing",{
            "blendMode":"add",
            "isSpecial":true,
            "targetColorOffset":[50,-75,255]
         });
      }
      
      private function initBuffEffect() : void
      {
         _effect["buff_effect_speed"] = new EffectVO("xg_buff_effect_speed",{"blendMode":"add"});
         _effect["buff_effect_power"] = new EffectVO("xg_buff_effect_power",{"blendMode":"add"});
         _effect["buff_effect_defense"] = new EffectVO("xg_buff_effect_defense",{"blendMode":"add"});
         _effect["buff_speed"] = new EffectVO("xg_buff_speed",{
            "blendMode":"add",
            "isBuff":true
         });
         _effect["buff_power"] = new EffectVO("xg_buff_power",{
            "blendMode":"add",
            "isBuff":true
         });
         _effect["buff_defense"] = new EffectVO("xg_buff_defense",{
            "blendMode":"add",
            "isBuff":true
         });
      }
      
      private function initSteelHitEffect() : void
      {
         _effect["steel_hit_kan"] = new EffectVO("XG_kan2",{
            "sound":"snd_hit11",
            "freeze":400,
            "blendMode":"add",
            "shine":{
               "color":16777215,
               "alpha":0.2
            },
            "randRotate":true,
            "isSteelHit":true
         });
         _effect["steel_hit_qdj"] = new EffectVO("XG_qdj",{
            "sound":"snd_hit11",
            "freeze":400,
            "blendMode":"add",
            "shine":{
               "color":16777215,
               "alpha":0.2
            },
            "randRotate":true,
            "isSteelHit":true
         });
         _effect["steel_hit_mfdj"] = new EffectVO("XG_mfdj",{
            "sound":"snd_hit11",
            "freeze":400,
            "blendMode":"add",
            "shine":{
               "color":16777215,
               "alpha":0.2
            },
            "randRotate":true,
            "isSteelHit":true
         });
      }
      
      public function getEffect(param1:String) : EffectVO
      {
         return _effect[param1];
      }
      
      public function getHitEffect(param1:int) : EffectVO
      {
         return _effect["hit_" + param1];
      }
      
      public function getMosouEnemyHitEffect(param1:int) : EffectVO
      {
         return _effect["hit_enemy_" + param1];
      }
      
      public function getMosouEnemyDefenseEffect(param1:int, param2:int) : EffectVO
      {
         switch(param2)
         {
            case 1:
               if(param1 == 1)
               {
                  param1 = 2;
               }
               if(param1 == 6)
               {
                  param1 = 3;
               }
         }
         return _effect["defense_enemy_" + param1];
      }
      
      public function getDefenseEffect(param1:int, param2:int) : EffectVO
      {
         switch(param2)
         {
            case 1:
               if(param1 == 1)
               {
                  param1 = 2;
               }
               if(param1 == 6)
               {
                  param1 = 3;
               }
         }
         var _loc3_:EffectVO = _effect["defense_" + param1];
         return _loc3_ ? _loc3_ : _effect["defense_5"];
      }
      
      private function addHitEffect(param1:int, param2:String, param3:Object = null) : void
      {
         var _loc4_:EffectVO = new EffectVO(param2,param3);
         _effect["hit_" + param1] = _loc4_;
      }
      
      private function addDefenseEffect(param1:int, param2:String, param3:Object = null) : void
      {
         var _loc4_:EffectVO = new EffectVO(param2,param3);
         _effect["defense_" + param1] = _loc4_;
      }
      
      private function addEnemyHitEffect(param1:int, param2:String, param3:Object = null) : void
      {
         var _loc4_:EffectVO = new EffectVO(param2,param3);
         _effect["hit_enemy_" + param1] = _loc4_;
      }
      
      private function addEnemyDefenseEffect(param1:int, param2:String, param3:Object = null) : void
      {
         var _loc4_:EffectVO = new EffectVO(param2,param3);
         _effect["defense_enemy_" + param1] = _loc4_;
      }
   }
}

