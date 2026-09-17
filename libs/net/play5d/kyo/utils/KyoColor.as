/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.kyo.utils {

/**
 * CSS 命名色常量与颜色运算工具。
 *
 * <p>常量对应 CSS Color Module Level 4 全部 148 个命名色关键字
 * （24 位 RGB <code>0xRRGGBB</code>）；不含半透明的 <code>transparent</code>。</p>
 * <p>注意：CSS <code>green</code> 为 <code>0x008000</code>；亮绿请用 <code>LIME</code>
 * （<code>0x00FF00</code>）。</p>
 * <p>运算 API 对齐常用 CSS 能力：<code>rgb</code> / <code>hsl</code>、
 * <code>color-mix</code> 式混合、明度/饱和调整、对比色与十六进制互转。</p>
 *
 * @example
 * <listing version="3.0">
 * var c:uint = KyoColor.hsl(30, 1, 0.5);
 * var hex:String = KyoColor.toHex(KyoColor.ORANGE);
 * </listing>
 * @see #rgb()
 * @see #hsl()
 * @see #mix()
 * @see #toHex()
 * @see net.play5d.kyo.utils.KyoRandom#getRandomColor()
 */
public class KyoColor {
    // ----- CSS Color Module Level 4 命名色（字母序） -----

    /** 爱丽丝蓝 <code>0xF0F8FF</code>（CSS <code>aliceblue</code>） */
    public static const ALICE_BLUE:uint             = 0xF0F8FF;
    /** 古董白 <code>0xFAEBD7</code>（CSS <code>antiquewhite</code>） */
    public static const ANTIQUE_WHITE:uint          = 0xFAEBD7;
    /** 水色 <code>0x00FFFF</code>（CSS <code>aqua</code>） */
    public static const AQUA:uint                   = 0x00FFFF;
    /** 碧绿 <code>0x7FFFD4</code>（CSS <code>aquamarine</code>） */
    public static const AQUA_MARINE:uint            = 0x7FFFD4;
    /** 天蓝白 <code>0xF0FFFF</code>（CSS <code>azure</code>） */
    public static const AZURE:uint                  = 0xF0FFFF;
    /** 米色 <code>0xF5F5DC</code>（CSS <code>beige</code>） */
    public static const BEIGE:uint                  = 0xF5F5DC;
    /** 陶坯黄 <code>0xFFE4C4</code>（CSS <code>bisque</code>） */
    public static const BISQUE:uint                 = 0xFFE4C4;
    /** 黑 <code>0x000000</code>（CSS <code>black</code>） */
    public static const BLACK:uint                  = 0x000000;
    /** 杏仁白 <code>0xFFEBCD</code>（CSS <code>blanchedalmond</code>） */
    public static const BLANCHED_ALMOND:uint        = 0xFFEBCD;
    /** 蓝 <code>0x0000FF</code>（CSS <code>blue</code>） */
    public static const BLUE:uint                   = 0x0000FF;
    /** 蓝紫 <code>0x8A2BE2</code>（CSS <code>blueviolet</code>） */
    public static const BLUE_VIOLET:uint            = 0x8A2BE2;
    /** 褐 <code>0xA52A2A</code>（CSS <code>brown</code>） */
    public static const BROWN:uint                  = 0xA52A2A;
    /** 硬木色 <code>0xDEB887</code>（CSS <code>burlywood</code>） */
    public static const BURLY_WOOD:uint             = 0xDEB887;
    /** 军服蓝 <code>0x5F9EA0</code>（CSS <code>cadetblue</code>） */
    public static const CADET_BLUE:uint             = 0x5F9EA0;
    /** 查特酒绿 <code>0x7FFF00</code>（CSS <code>chartreuse</code>） */
    public static const CHARTREUSE:uint             = 0x7FFF00;
    /** 巧克力 <code>0xD2691E</code>（CSS <code>chocolate</code>） */
    public static const CHOCOLATE:uint              = 0xD2691E;
    /** 珊瑚 <code>0xFF7F50</code>（CSS <code>coral</code>） */
    public static const CORAL:uint                  = 0xFF7F50;
    /** 矢车菊蓝 <code>0x6495ED</code>（CSS <code>cornflowerblue</code>） */
    public static const CORNFLOWER_BLUE:uint        = 0x6495ED;
    /** 玉米丝色 <code>0xFFF8DC</code>（CSS <code>cornsilk</code>） */
    public static const CORN_SILK:uint              = 0xFFF8DC;
    /** 猩红 <code>0xDC143C</code>（CSS <code>crimson</code>） */
    public static const CRIMSON:uint                = 0xDC143C;
    /** 青 <code>0x00FFFF</code>（CSS <code>cyan</code>） */
    public static const CYAN:uint                   = 0x00FFFF;
    /** 深蓝 <code>0x00008B</code>（CSS <code>darkblue</code>） */
    public static const DARK_BLUE:uint              = 0x00008B;
    /** 深青 <code>0x008B8B</code>（CSS <code>darkcyan</code>） */
    public static const DARK_CYAN:uint              = 0x008B8B;
    /** 深金菊 <code>0xB8860B</code>（CSS <code>darkgoldenrod</code>） */
    public static const DARK_GOLDENROD:uint         = 0xB8860B;
    /** 深灰 <code>0xA9A9A9</code>（CSS <code>darkgray</code>） */
    public static const DARK_GRAY:uint              = 0xA9A9A9;
    /** 深绿 <code>0x006400</code>（CSS <code>darkgreen</code>） */
    public static const DARK_GREEN:uint             = 0x006400;
    /** 深灰 <code>0xA9A9A9</code>（CSS <code>darkgrey</code>，等同 <code>DARK_GRAY</code>） */
    public static const DARK_GREY:uint              = DARK_GRAY;
    /** 深卡其 <code>0xBDB76B</code>（CSS <code>darkkhaki</code>） */
    public static const DARK_KHAKI:uint             = 0xBDB76B;
    /** 深品红 <code>0x8B008B</code>（CSS <code>darkmagenta</code>） */
    public static const DARK_MAGENTA:uint           = 0x8B008B;
    /** 深橄榄绿 <code>0x556B2F</code>（CSS <code>darkolivegreen</code>） */
    public static const DARK_OLIVE_GREEN:uint       = 0x556B2F;
    /** 深橙 <code>0xFF8C00</code>（CSS <code>darkorange</code>） */
    public static const DARK_ORANGE:uint            = 0xFF8C00;
    /** 深兰花紫 <code>0x9932CC</code>（CSS <code>darkorchid</code>） */
    public static const DARK_ORCHID:uint            = 0x9932CC;
    /** 深红 <code>0x8B0000</code>（CSS <code>darkred</code>） */
    public static const DARK_RED:uint               = 0x8B0000;
    /** 深鲑红 <code>0xE9967A</code>（CSS <code>darksalmon</code>） */
    public static const DARK_SALMON:uint            = 0xE9967A;
    /** 深海绿 <code>0x8FBC8F</code>（CSS <code>darkseagreen</code>） */
    public static const DARK_SEA_GREEN:uint         = 0x8FBC8F;
    /** 深石板蓝 <code>0x483D8B</code>（CSS <code>darkslateblue</code>） */
    public static const DARK_SLATE_BLUE:uint        = 0x483D8B;
    /** 深石板灰 <code>0x2F4F4F</code>（CSS <code>darkslategray</code>） */
    public static const DARK_SLATE_GRAY:uint        = 0x2F4F4F;
    /** 深石板灰 <code>0x2F4F4F</code>（CSS <code>darkslategrey</code>，等同 <code>DARK_SLATE_GRAY</code>） */
    public static const DARK_SLATE_GREY:uint        = DARK_SLATE_GRAY;
    /** 深绿松石 <code>0x00CED1</code>（CSS <code>darkturquoise</code>） */
    public static const DARK_TURQUOISE:uint         = 0x00CED1;
    /** 深紫 <code>0x9400D3</code>（CSS <code>darkviolet</code>） */
    public static const DARK_VIOLET:uint            = 0x9400D3;
    /** 深粉 <code>0xFF1493</code>（CSS <code>deeppink</code>） */
    public static const DEEP_PINK:uint              = 0xFF1493;
    /** 深天蓝 <code>0x00BFFF</code>（CSS <code>deepskyblue</code>） */
    public static const DEEP_SKY_BLUE:uint          = 0x00BFFF;
    /** 暗灰 <code>0x696969</code>（CSS <code>dimgray</code>） */
    public static const DIM_GRAY:uint               = 0x696969;
    /** 暗灰 <code>0x696969</code>（CSS <code>dimgrey</code>，等同 <code>DIM_GRAY</code>） */
    public static const DIM_GREY:uint               = DIM_GRAY;
    /** 道奇蓝 <code>0x1E90FF</code>（CSS <code>dodgerblue</code>） */
    public static const DODGER_BLUE:uint            = 0x1E90FF;
    /** 砖红 <code>0xB22222</code>（CSS <code>firebrick</code>） */
    public static const FIRE_BRICK:uint             = 0xB22222;
    /** 花卉白 <code>0xFFFAF0</code>（CSS <code>floralwhite</code>） */
    public static const FLORAL_WHITE:uint           = 0xFFFAF0;
    /** 森林绿 <code>0x228B22</code>（CSS <code>forestgreen</code>） */
    public static const FOREST_GREEN:uint           = 0x228B22;
    /** 紫红 <code>0xFF00FF</code>（CSS <code>fuchsia</code>） */
    public static const FUCHSIA:uint                = 0xFF00FF;
    /** 庚斯伯勒灰 <code>0xDCDCDC</code>（CSS <code>gainsboro</code>） */
    public static const GAINSBORO:uint              = 0xDCDCDC;
    /** 幽灵白 <code>0xF8F8FF</code>（CSS <code>ghostwhite</code>） */
    public static const GHOST_WHITE:uint            = 0xF8F8FF;
    /** 金 <code>0xFFD700</code>（CSS <code>gold</code>） */
    public static const GOLD:uint                   = 0xFFD700;
    /** 金菊 <code>0xDAA520</code>（CSS <code>goldenrod</code>） */
    public static const GOLDENROD:uint              = 0xDAA520;
    /** 灰 <code>0x808080</code>（CSS <code>gray</code>） */
    public static const GRAY:uint                   = 0x808080;
    /** 绿 <code>0x008000</code>（CSS <code>green</code>） */
    public static const GREEN:uint                  = 0x008000;
    /** 绿黄 <code>0xADFF2F</code>（CSS <code>greenyellow</code>） */
    public static const GREEN_YELLOW:uint           = 0xADFF2F;
    /** 灰 <code>0x808080</code>（CSS <code>grey</code>，等同 <code>GRAY</code>） */
    public static const GREY:uint                   = GRAY;
    /** 蜜瓜色 <code>0xF0FFF0</code>（CSS <code>honeydew</code>） */
    public static const HONEY_DEW:uint              = 0xF0FFF0;
    /** 艳粉 <code>0xFF69B4</code>（CSS <code>hotpink</code>） */
    public static const HOT_PINK:uint               = 0xFF69B4;
    /** 印度红 <code>0xCD5C5C</code>（CSS <code>indianred</code>） */
    public static const INDIAN_RED:uint             = 0xCD5C5C;
    /** 靛 <code>0x4B0082</code>（CSS <code>indigo</code>） */
    public static const INDIGO:uint                 = 0x4B0082;
    /** 象牙 <code>0xFFFFF0</code>（CSS <code>ivory</code>） */
    public static const IVORY:uint                  = 0xFFFFF0;
    /** 卡其 <code>0xF0E68C</code>（CSS <code>khaki</code>） */
    public static const KHAKI:uint                  = 0xF0E68C;
    /** 薰衣草紫 <code>0xE6E6FA</code>（CSS <code>lavender</code>） */
    public static const LAVENDER:uint               = 0xE6E6FA;
    /** 淡紫红 <code>0xFFF0F5</code>（CSS <code>lavenderblush</code>） */
    public static const LAVENDER_BLUSH:uint         = 0xFFF0F5;
    /** 草坪绿 <code>0x7CFC00</code>（CSS <code>lawngreen</code>） */
    public static const LAWN_GREEN:uint             = 0x7CFC00;
    /** 柠檬绸 <code>0xFFFACD</code>（CSS <code>lemonchiffon</code>） */
    public static const LEMON_CHIFFON:uint          = 0xFFFACD;
    /** 浅蓝 <code>0xADD8E6</code>（CSS <code>lightblue</code>） */
    public static const LIGHT_BLUE:uint             = 0xADD8E6;
    /** 浅珊瑚 <code>0xF08080</code>（CSS <code>lightcoral</code>） */
    public static const LIGHT_CORAL:uint            = 0xF08080;
    /** 浅青 <code>0xE0FFFF</code>（CSS <code>lightcyan</code>） */
    public static const LIGHT_CYAN:uint             = 0xE0FFFF;
    /** 浅金菊黄 <code>0xFAFAD2</code>（CSS <code>lightgoldenrodyellow</code>） */
    public static const LIGHT_GOLDENROD_YELLOW:uint = 0xFAFAD2;
    /** 浅灰 <code>0xD3D3D3</code>（CSS <code>lightgray</code>） */
    public static const LIGHT_GRAY:uint             = 0xD3D3D3;
    /** 浅绿 <code>0x90EE90</code>（CSS <code>lightgreen</code>） */
    public static const LIGHT_GREEN:uint            = 0x90EE90;
    /** 浅灰 <code>0xD3D3D3</code>（CSS <code>lightgrey</code>，等同 <code>LIGHT_GRAY</code>） */
    public static const LIGHT_GREY:uint             = LIGHT_GRAY;
    /** 浅粉 <code>0xFFC0CB</code>（CSS <code>lightpink</code>） */
    public static const LIGHT_PINK:uint             = 0xFFC0CB;
    /** 浅鲑红 <code>0xFFA07A</code>（CSS <code>lightsalmon</code>） */
    public static const LIGHT_SALMON:uint           = 0xFFA07A;
    /** 浅海绿 <code>0x20B2AA</code>（CSS <code>lightseagreen</code>） */
    public static const LIGHT_SEA_GREEN:uint        = 0x20B2AA;
    /** 浅天蓝 <code>0x87CEFA</code>（CSS <code>lightskyblue</code>） */
    public static const LIGHT_SKY_BLUE:uint         = 0x87CEFA;
    /** 浅石板灰 <code>0x778899</code>（CSS <code>lightslategray</code>） */
    public static const LIGHT_SLATE_GRAY:uint       = 0x778899;
    /** 浅石板灰 <code>0x778899</code>（CSS <code>lightslategrey</code>，等同 <code>LIGHT_SLATE_GRAY</code>） */
    public static const LIGHT_SLATE_GREY:uint       = LIGHT_SLATE_GRAY;
    /** 浅钢蓝 <code>0xB0C4DE</code>（CSS <code>lightsteelblue</code>） */
    public static const LIGHT_STEEL_BLUE:uint       = 0xB0C4DE;
    /** 浅黄 <code>0xFFFFE0</code>（CSS <code>lightyellow</code>） */
    public static const LIGHT_YELLOW:uint           = 0xFFFFE0;
    /** 亮绿 <code>0x00FF00</code>（CSS <code>lime</code>） */
    public static const LIME:uint                   = 0x00FF00;
    /** 酸橙绿 <code>0x32CD32</code>（CSS <code>limegreen</code>） */
    public static const LIME_GREEN:uint             = 0x32CD32;
    /** 亚麻色 <code>0xFAF0E6</code>（CSS <code>linen</code>） */
    public static const LINEN:uint                  = 0xFAF0E6;
    /** 品红 <code>0xFF00FF</code>（CSS <code>magenta</code>） */
    public static const MAGENTA:uint                = 0xFF00FF;
    /** 栗色 <code>0x800000</code>（CSS <code>maroon</code>） */
    public static const MAROON:uint                 = 0x800000;
    /** 中碧绿 <code>0x66CDAA</code>（CSS <code>mediumaquamarine</code>） */
    public static const MEDIUM_AQUA_MARINE:uint     = 0x66CDAA;
    /** 中蓝 <code>0x0000CD</code>（CSS <code>mediumblue</code>） */
    public static const MEDIUM_BLUE:uint            = 0x0000CD;
    /** 中兰花紫 <code>0xBA55D3</code>（CSS <code>mediumorchid</code>） */
    public static const MEDIUM_ORCHID:uint          = 0xBA55D3;
    /** 中紫 <code>0x9370DB</code>（CSS <code>mediumpurple</code>） */
    public static const MEDIUM_PURPLE:uint          = 0x9370DB;
    /** 中海绿 <code>0x3CB371</code>（CSS <code>mediumseagreen</code>） */
    public static const MEDIUM_SEA_GREEN:uint       = 0x3CB371;
    /** 中石板蓝 <code>0x7B68EE</code>（CSS <code>mediumslateblue</code>） */
    public static const MEDIUM_SLATE_BLUE:uint      = 0x7B68EE;
    /** 中春绿 <code>0x00FA9A</code>（CSS <code>mediumspringgreen</code>） */
    public static const MEDIUM_SPRING_GREEN:uint    = 0x00FA9A;
    /** 中绿松石 <code>0x48D1CC</code>（CSS <code>mediumturquoise</code>） */
    public static const MEDIUM_TURQUOISE:uint       = 0x48D1CC;
    /** 中紫红 <code>0xC71585</code>（CSS <code>mediumvioletred</code>） */
    public static const MEDIUM_VIOLET_RED:uint      = 0xC71585;
    /** 午夜蓝 <code>0x191970</code>（CSS <code>midnightblue</code>） */
    public static const MIDNIGHT_BLUE:uint          = 0x191970;
    /** 薄荷奶油 <code>0xF5FFFA</code>（CSS <code>mintcream</code>） */
    public static const MINT_CREAM:uint             = 0xF5FFFA;
    /** 雾玫红 <code>0xFFE4E1</code>（CSS <code>mistyrose</code>） */
    public static const MISTY_ROSE:uint             = 0xFFE4E1;
    /** 鹿皮鞋色 <code>0xFFE4B5</code>（CSS <code>moccasin</code>） */
    public static const MOCCASIN:uint               = 0xFFE4B5;
    /** 纳瓦霍白 <code>0xFFDEAD</code>（CSS <code>navajowhite</code>） */
    public static const NAVAJO_WHITE:uint           = 0xFFDEAD;
    /** 海军蓝 <code>0x000080</code>（CSS <code>navy</code>） */
    public static const NAVY:uint                   = 0x000080;
    /** 旧蕾丝 <code>0xFDF5E6</code>（CSS <code>oldlace</code>） */
    public static const OLD_LACE:uint               = 0xFDF5E6;
    /** 橄榄 <code>0x808000</code>（CSS <code>olive</code>） */
    public static const OLIVE:uint                  = 0x808000;
    /** 橄榄褐 <code>0x6B8E23</code>（CSS <code>olivedrab</code>） */
    public static const OLIVE_DRAB:uint             = 0x6B8E23;
    /** 橙 <code>0xFFA500</code>（CSS <code>orange</code>） */
    public static const ORANGE:uint                 = 0xFFA500;
    /** 橙红 <code>0xFF4500</code>（CSS <code>orangered</code>） */
    public static const ORANGE_RED:uint             = 0xFF4500;
    /** 兰花紫 <code>0xDA70D6</code>（CSS <code>orchid</code>） */
    public static const ORCHID:uint                 = 0xDA70D6;
    /** 淡金菊 <code>0xEEE8AA</code>（CSS <code>palegoldenrod</code>） */
    public static const PALE_GOLDENROD:uint         = 0xEEE8AA;
    /** 淡绿 <code>0x98FB98</code>（CSS <code>palegreen</code>） */
    public static const PALE_GREEN:uint             = 0x98FB98;
    /** 淡绿松石 <code>0xAFEEEE</code>（CSS <code>paleturquoise</code>） */
    public static const PALE_TURQUOISE:uint         = 0xAFEEEE;
    /** 淡紫红 <code>0xDB7093</code>（CSS <code>palevioletred</code>） */
    public static const PALE_VIOLET_RED:uint        = 0xDB7093;
    /** 番木瓜鞭 <code>0xFFEFD5</code>（CSS <code>papayawhip</code>） */
    public static const PAPAYA_WHIP:uint            = 0xFFEFD5;
    /** 桃肉色 <code>0xFFDAB9</code>（CSS <code>peachpuff</code>） */
    public static const PEACH_PUFF:uint             = 0xFFDAB9;
    /** 秘鲁褐 <code>0xCD853F</code>（CSS <code>peru</code>） */
    public static const PERU:uint                   = 0xCD853F;
    /** 粉红 <code>0xFFC0CB</code>（CSS <code>pink</code>） */
    public static const PINK:uint                   = 0xFFC0CB;
    /** 李紫 <code>0xDDA0DD</code>（CSS <code>plum</code>） */
    public static const PLUM:uint                   = 0xDDA0DD;
    /** 粉蓝 <code>0xB0E0E6</code>（CSS <code>powderblue</code>） */
    public static const POWDER_BLUE:uint            = 0xB0E0E6;
    /** 紫 <code>0x800080</code>（CSS <code>purple</code>） */
    public static const PURPLE:uint                 = 0x800080;
    /** 丽贝卡紫 <code>0x663399</code>（CSS <code>rebeccapurple</code>） */
    public static const REBECCA_PURPLE:uint         = 0x663399;
    /** 红 <code>0xFF0000</code>（CSS <code>red</code>） */
    public static const RED:uint                    = 0xFF0000;
    /** 玫瑰褐 <code>0xBC8F8F</code>（CSS <code>rosybrown</code>） */
    public static const ROSY_BROWN:uint             = 0xBC8F8F;
    /** 皇家蓝 <code>0x4169E1</code>（CSS <code>royalblue</code>） */
    public static const ROYAL_BLUE:uint             = 0x4169E1;
    /** 鞍褐 <code>0x8B4513</code>（CSS <code>saddlebrown</code>） */
    public static const SADDLE_BROWN:uint           = 0x8B4513;
    /** 鲑红 <code>0xFA8072</code>（CSS <code>salmon</code>） */
    public static const SALMON:uint                 = 0xFA8072;
    /** 沙棕 <code>0xF4A460</code>（CSS <code>sandybrown</code>） */
    public static const SANDY_BROWN:uint            = 0xF4A460;
    /** 海绿 <code>0x2E8B57</code>（CSS <code>seagreen</code>） */
    public static const SEA_GREEN:uint              = 0x2E8B57;
    /** 贝壳白 <code>0xFFF5EE</code>（CSS <code>seashell</code>） */
    public static const SEA_SHELL:uint              = 0xFFF5EE;
    /** 赭 <code>0xA0522D</code>（CSS <code>sienna</code>） */
    public static const SIENNA:uint                 = 0xA0522D;
    /** 银 <code>0xC0C0C0</code>（CSS <code>silver</code>） */
    public static const SILVER:uint                 = 0xC0C0C0;
    /** 天蓝 <code>0x87CEEB</code>（CSS <code>skyblue</code>） */
    public static const SKY_BLUE:uint               = 0x87CEEB;
    /** 石板蓝 <code>0x6A5ACD</code>（CSS <code>slateblue</code>） */
    public static const SLATE_BLUE:uint             = 0x6A5ACD;
    /** 石板灰 <code>0x708090</code>（CSS <code>slategray</code>） */
    public static const SLATE_GRAY:uint             = 0x708090;
    /** 石板灰 <code>0x708090</code>（CSS <code>slategrey</code>，等同 <code>SLATE_GRAY</code>） */
    public static const SLATE_GREY:uint             = SLATE_GRAY;
    /** 雪白 <code>0xFFFAFA</code>（CSS <code>snow</code>） */
    public static const SNOW:uint                   = 0xFFFAFA;
    /** 春绿 <code>0x00FF7F</code>（CSS <code>springgreen</code>） */
    public static const SPRING_GREEN:uint           = 0x00FF7F;
    /** 钢蓝 <code>0x4682B4</code>（CSS <code>steelblue</code>） */
    public static const STEEL_BLUE:uint             = 0x4682B4;
    /** 棕褐 <code>0xD2B48C</code>（CSS <code>tan</code>） */
    public static const TAN:uint                    = 0xD2B48C;
    /** 青绿 <code>0x008080</code>（CSS <code>teal</code>） */
    public static const TEAL:uint                   = 0x008080;
    /** 蓟紫 <code>0xD8BFD8</code>（CSS <code>thistle</code>） */
    public static const THISTLE:uint                = 0xD8BFD8;
    /** 番茄红 <code>0xFF6347</code>（CSS <code>tomato</code>） */
    public static const TOMATO:uint                 = 0xFF6347;
    /** 绿松石 <code>0x40E0D0</code>（CSS <code>turquoise</code>） */
    public static const TURQUOISE:uint              = 0x40E0D0;
    /** 紫罗兰 <code>0xEE82EE</code>（CSS <code>violet</code>） */
    public static const VIOLET:uint                 = 0xEE82EE;
    /** 麦色 <code>0xF5DEB3</code>（CSS <code>wheat</code>） */
    public static const WHEAT:uint                  = 0xF5DEB3;
    /** 白 <code>0xFFFFFF</code>（CSS <code>white</code>） */
    public static const WHITE:uint                  = 0xFFFFFF;
    /** 白烟 <code>0xF5F5F5</code>（CSS <code>whitesmoke</code>） */
    public static const WHITE_SMOKE:uint            = 0xF5F5F5;
    /** 黄 <code>0xFFFF00</code>（CSS <code>yellow</code>） */
    public static const YELLOW:uint                 = 0xFFFF00;
    /** 黄绿 <code>0x9ACD32</code>（CSS <code>yellowgreen</code>） */
    public static const YELLOW_GREEN:uint           = 0x9ACD32;

    /**
     * 由 RGB 分量合成颜色。
     * @param r 红 0–255。
     * @param g 绿 0–255。
     * @param b 蓝 0–255。
     * @return <code>0xRRGGBB</code>。
     * @example
     * <listing version="3.0">
     * KyoColor.rgb(255, 128, 0); // 0xFF8000
     * </listing>
     */
    public static function rgb(r:uint, g:uint, b:uint):uint {
        return ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
    }

    /**
     * 由 HSL 合成颜色（对齐 CSS <code>hsl()</code> 语义）。
     * @param h 色相，度；会归一到 <code>[0, 360)</code>。
     * @param s 饱和度 <code>[0, 1]</code>。
     * @param l 明度 <code>[0, 1]</code>。
     * @return <code>0xRRGGBB</code>。
     * @example
     * <listing version="3.0">
     * KyoColor.hsl(0, 1, 0.5); // 约等于 RED
     * </listing>
     * @see #toHsl()
     */
    public static function hsl(h:Number, s:Number, l:Number):uint {
        s = clamp01(s);
        l = clamp01(l);
        h = ((h % 360) + 360) % 360;

        if (s == 0) {
            var gray:int = Math.round(l * 255);

            return rgb(gray, gray, gray);
        }

        var q:Number  = l < 0.5 ? l * (1 + s) : l + s - l * s;
        var p:Number  = 2 * l - q;
        var hk:Number = h / 360;
        var r:Number  = hueToRgb(p, q, hk + 1 / 3);
        var g:Number  = hueToRgb(p, q, hk);
        var b:Number  = hueToRgb(p, q, hk - 1 / 3);

        return rgb(Math.round(r * 255), Math.round(g * 255), Math.round(b * 255));
    }

    /**
     * 取红色分量。
     * @param color <code>0xRRGGBB</code>。
     * @return 0–255。
     * @example
     * <listing version="3.0">
     * KyoColor.getR(0xFF8000); // 255
     * </listing>
     */
    public static function getR(color:uint):uint {
        return (color >> 16) & 0xFF;
    }

    /**
     * 取绿色分量。
     * @param color <code>0xRRGGBB</code>。
     * @return 0–255。
     * @example
     * <listing version="3.0">
     * KyoColor.getG(0xFF8000); // 128
     * </listing>
     */
    public static function getG(color:uint):uint {
        return (color >> 8) & 0xFF;
    }

    /**
     * 取蓝色分量。
     * @param color <code>0xRRGGBB</code>。
     * @return 0–255。
     * @example
     * <listing version="3.0">
     * KyoColor.getB(0xFF8000); // 0
     * </listing>
     */
    public static function getB(color:uint):uint {
        return color & 0xFF;
    }

    /**
     * 转为 HSL 分量对象。
     * @param color <code>0xRRGGBB</code>。
     * @return <code>&#123;h:Number, s:Number, l:Number&#125;</code>；
     * <code>h</code> 为度 <code>[0, 360)</code>，<code>s</code>/<code>l</code> 为 <code>[0, 1]</code>。
     * @example
     * <listing version="3.0">
     * var o:Object = KyoColor.toHsl(KyoColor.RED);
     * // o.h ≈ 0, o.s ≈ 1, o.l ≈ 0.5
     * </listing>
     * @see #hsl()
     */
    public static function toHsl(color:uint):Object {
        var r:Number   = getR(color) / 255;
        var g:Number   = getG(color) / 255;
        var b:Number   = getB(color) / 255;
        var max:Number = Math.max(r, g, b);
        var min:Number = Math.min(r, g, b);
        var h:Number   = 0;
        var s:Number   = 0;
        var l:Number   = (max + min) / 2;
        var d:Number   = max - min;

        if (d != 0) {
            s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
            if (max == r) {
                h = (g - b) / d + (g < b ? 6 : 0);
            }
            else if (max == g) {
                h = (b - r) / d + 2;
            }
            else {
                h = (r - g) / d + 4;
            }
            h *= 60;
        }

        return {
            h: h,
            s: s,
            l: l
        };
    }

    /**
     * 线性插值两色（sRGB 通道）。
     * @param from 起始色。
     * @param to 目标色。
     * @param ratio 偏向 <code>to</code> 的比例，建议 <code>[0, 1]</code>。
     * @return 插值结果。
     * @example
     * <listing version="3.0">
     * KyoColor.lerp(KyoColor.BLACK, KyoColor.WHITE, 0.5);
     * </listing>
     * @see #mix()
     */
    public static function lerp(from:uint, to:uint, ratio:Number):uint {
        if (ratio <= 0) {
            return from;
        }
        if (ratio >= 1) {
            return to;
        }
        var r:int = getR(from) + (int(getR(to)) - int(getR(from))) * ratio;
        var g:int = getG(from) + (int(getG(to)) - int(getG(from))) * ratio;
        var b:int = getB(from) + (int(getB(to)) - int(getB(from))) * ratio;
        return rgb(r, g, b);
    }

    /**
     * 按权重混合两色（对齐 CSS <code>color-mix(in srgb, …)</code> 思路）。
     * @param color1 第一色。
     * @param color2 第二色。
     * @param weight1 <code>color1</code> 的权重，建议 <code>[0, 1]</code>；默认 0.5。
     * @return 混合结果。
     * @example
     * <listing version="3.0">
     * KyoColor.mix(KyoColor.RED, KyoColor.BLUE, 0.4);
     * </listing>
     * @see #lerp()
     */
    public static function mix(color1:uint, color2:uint, weight1:Number = 0.5):uint {
        return lerp(color2, color1, clamp01(weight1));
    }

    /**
     * 提高明度（经 HSL 的 <code>l</code>）。
     * @param color 源色。
     * @param amount 增加量，建议 <code>[0, 1]</code>。
     * @return 新颜色。
     * @example
     * <listing version="3.0">
     * KyoColor.lighten(KyoColor.RED, 0.2);
     * </listing>
     * @see #darken()
     */
    public static function lighten(color:uint, amount:Number):uint {
        var o:Object = toHsl(color);
        return hsl(o.h, o.s, clamp01(o.l + amount));
    }

    /**
     * 降低明度（经 HSL 的 <code>l</code>）。
     * @param color 源色。
     * @param amount 减少量，建议 <code>[0, 1]</code>。
     * @return 新颜色。
     * @example
     * <listing version="3.0">
     * KyoColor.darken(KyoColor.RED, 0.2);
     * </listing>
     * @see #lighten()
     */
    public static function darken(color:uint, amount:Number):uint {
        var o:Object = toHsl(color);
        return hsl(o.h, o.s, clamp01(o.l - amount));
    }

    /**
     * 提高饱和度（经 HSL 的 <code>s</code>）。
     * @param color 源色。
     * @param amount 增加量，建议 <code>[0, 1]</code>。
     * @return 新颜色。
     * @example
     * <listing version="3.0">
     * KyoColor.saturate(KyoColor.GRAY, 0.5);
     * </listing>
     * @see #desaturate()
     */
    public static function saturate(color:uint, amount:Number):uint {
        var o:Object = toHsl(color);
        return hsl(o.h, clamp01(o.s + amount), o.l);
    }

    /**
     * 降低饱和度（经 HSL 的 <code>s</code>）。
     * @param color 源色。
     * @param amount 减少量，建议 <code>[0, 1]</code>；为 1 时接近灰度。
     * @return 新颜色。
     * @example
     * <listing version="3.0">
     * KyoColor.desaturate(KyoColor.RED, 1);
     * </listing>
     * @see #saturate()
     * @see #grayscale()
     */
    public static function desaturate(color:uint, amount:Number):uint {
        var o:Object = toHsl(color);
        return hsl(o.h, clamp01(o.s - amount), o.l);
    }

    /**
     * 转为灰度（饱和度置 0）。
     * @param color 源色。
     * @return 灰度色。
     * @example
     * <listing version="3.0">
     * KyoColor.grayscale(KyoColor.ORANGE);
     * </listing>
     */
    public static function grayscale(color:uint):uint {
        var o:Object = toHsl(color);
        return hsl(o.h, 0, o.l);
    }

    /**
     * 相对亮度（WCAG sRGB，约 <code>[0, 1]</code>）。
     * @param color 源色。
     * @return 相对亮度。
     * @example
     * <listing version="3.0">
     * KyoColor.luminance(KyoColor.WHITE); // ≈ 1
     * </listing>
     * @see #contrastColor()
     */
    public static function luminance(color:uint):Number {
        return 0.2126 * channelToLinear(getR(color) / 255)
                + 0.7152 * channelToLinear(getG(color) / 255)
                + 0.0722 * channelToLinear(getB(color) / 255);
    }

    /**
     * 选取黑或白作为对比色（对比度更高者），便于文字/图标叠色。
     * @param color 背景色。
     * @return <code>BLACK</code> 或 <code>WHITE</code>。
     * @example
     * <listing version="3.0">
     * KyoColor.contrastColor(KyoColor.YELLOW); // BLACK
     * </listing>
     * @see #luminance()
     */
    public static function contrastColor(color:uint):uint {
        // 与白/黑的对比度：(L1+0.05)/(L2+0.05)；选较大者
        var l:Number      = luminance(color);
        var cWhite:Number = (1.05) / (l + 0.05);
        var cBlack:Number = (l + 0.05) / 0.05;
        return cWhite >= cBlack ? WHITE : BLACK;
    }

    /**
     * 解析十六进制颜色字符串。
     * @param hex 支持 <code>#RGB</code> / <code>#RRGGBB</code> /
     * <code>0xRRGGBB</code> / <code>RRGGBB</code>；非法时返回 <code>BLACK</code>。
     * @return <code>0xRRGGBB</code>。
     * @example
     * <listing version="3.0">
     * KyoColor.fromHex('#f80'); // 0xFF8800
     * </listing>
     * @see #toHex()
     */
    public static function fromHex(hex:String):uint {
        if (!hex) {
            return BLACK;
        }
        var s:String = hex;
        if (s.charAt(0) == '#') {
            s = s.substr(1);
        }
        else if (s.length >= 2 && (s.charAt(0) == '0') && (s.charAt(1) == 'x' || s.charAt(1) == 'X')) {
            s = s.substr(2);
        }
        if (s.length == 3) {
            s = s.charAt(0) + s.charAt(0) + s.charAt(1) + s.charAt(1) + s.charAt(2) + s.charAt(2);
        }
        if (s.length != 6) {
            return BLACK;
        }
        var v:Number = parseInt(s, 16);
        if (isNaN(v)) {
            return BLACK;
        }
        return uint(v) & 0xFFFFFF;
    }

    /**
     * 转为 <code>#RRGGBB</code> 字符串。
     * @param color 颜色值。
     * @return 大写十六进制，含 <code>#</code>。
     * @example
     * <listing version="3.0">
     * KyoColor.toHex(KyoColor.RED); // '#FF0000'
     * </listing>
     * @see #fromHex()
     */
    public static function toHex(color:uint):String {
        var hex:String = (color & 0xFFFFFF).toString(16).toUpperCase();
        while (hex.length < 6) {
            hex = '0' + hex;
        }
        return '#' + hex;
    }

    /**
     * 转为 AS 十六进制字面量字符串。
     * @param color 颜色值。
     * @return 形如 <code>0xffffff</code>（小写，无引号）。
     * @example
     * <listing version="3.0">
     * KyoColor.toLiteral(KyoColor.RED); // '0xff0000'
     * </listing>
     * @see #toHex()
     */
    public static function toLiteral(color:uint):String {
        return '0x' + toHex(color).substring(1).toLowerCase();
    }

    /** @private 限制到 <code>[0, 1]</code>。 */
    private static function clamp01(n:Number):Number {
        if (n < 0) {
            return 0;
        }
        if (n > 1) {
            return 1;
        }
        return n;
    }

    /** @private HSL → RGB 辅助。 */
    private static function hueToRgb(p:Number, q:Number, t:Number):Number {
        if (t < 0) {
            t += 1;
        }
        if (t > 1) {
            t -= 1;
        }
        if (t < 1 / 6) {
            return p + (q - p) * 6 * t;
        }
        if (t < 1 / 2) {
            return q;
        }
        if (t < 2 / 3) {
            return p + (q - p) * (2 / 3 - t) * 6;
        }
        return p;
    }

    /** @private sRGB 通道 → 线性光（WCAG）。 */
    private static function channelToLinear(c:Number):Number {
        return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
    }

}
}
