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
import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
 * <code>BitmapData</code> 按尺寸分桶的轻量对象池。
 *
 * <p>用于反复栅格化场景，减少 <code>new BitmapData</code> 与 GC 压力。
 * 战斗结束等时机应调用 <code>clear</code>。</p>
 *
 * @see #acquire()
 * @see #release()
 * @example
 * <listing version="3.0">
 * var bd:BitmapData = BitmapDataPool.I.acquire(64, 64, true, 0);
 * // ... draw ...
 * BitmapDataPool.I.release(bd);
 * </listing>
 */
public class BitmapDataPool {

    /** @private */
    private static var _i:BitmapDataPool;

    /**
     * 单例。
     * @return 单例实例。
     */
    public static function get I():BitmapDataPool {
        _i ||= new BitmapDataPool();

        return _i;
    }

    /** @private 每尺寸桶最大空闲数 */
    private static const MAX_PER_BUCKET:int = 8;
    /** @private 池内 BitmapData 总数上限 */
    private static const MAX_TOTAL:int = 64;

    /** @private */
    private var _buckets:Object = {};
    /** @private */
    private var _total:int;
    /** @private */
    private var _tmpRect:Rectangle = new Rectangle();

    /**
     * 取得指定尺寸的位图；池中无则新建。
     *
     * @param width 宽。
     * @param height 高。
     * @param transparent 是否透明。
     * @param fillColor 填充色（含 alpha）。
     * @return 位图；尺寸非法或创建失败时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var bd:BitmapData = BitmapDataPool.I.acquire(32, 32);
     * </listing>
     */
    public function acquire(
        width       :int,
        height      :int,
        transparent :Boolean = true,
        fillColor   :uint = KyoColor.BLACK
    ):BitmapData {
        if (width < 1 || height < 1) {
            return null;
        }

        var key:String               = bucketKey(width, height, transparent);
        var list:Vector.<BitmapData> = _buckets[key] as Vector.<BitmapData>;
        var bd:BitmapData;
        if (list && list.length > 0) {
            bd = list.pop();
            _total--;
            _tmpRect.setTo(0, 0, width, height);
            bd.fillRect(_tmpRect, fillColor);

            return bd;
        }

        try {
            return new BitmapData(width, height, transparent, fillColor);
        }
        catch (e:Error) {
        }

        return null;
    }

    /**
     * 归还位图；桶满或总量超限时直接 dispose。
     *
     * @param bd 由 <code>acquire</code> 取得或同尺寸的位图。
     * @example
     * <listing version="3.0">
     * BitmapDataPool.I.release(bd);
     * </listing>
     */
    public function release(bd:BitmapData):void {
        if (!bd) {
            return;
        }

        var key:String               = bucketKey(bd.width, bd.height, bd.transparent);
        var list:Vector.<BitmapData> = _buckets[key] as Vector.<BitmapData>;
        if (!list) {
            list           = new Vector.<BitmapData>();
            _buckets[key]  = list;
        }

        if (list.length >= MAX_PER_BUCKET || _total >= MAX_TOTAL) {
            try {
                bd.dispose();
            }
            catch (e:Error) {
            }

            return;
        }

        list.push(bd);
        _total++;
    }

    /**
     * 清空并释放池内全部位图。
     * @example
     * <listing version="3.0">
     * BitmapDataPool.I.clear();
     * </listing>
     */
    public function clear():void {
        for each (var list:Vector.<BitmapData> in _buckets) {
            if (!list) {
                continue;
            }
            for each (var bd:BitmapData in list) {
                if (!bd) {
                    continue;
                }
                try {
                    bd.dispose();
                }
                catch (e:Error) {
                }
            }
            list.length = 0;
        }
        _buckets = {};
        _total   = 0;
    }

    /** @private */
    private static function bucketKey(width:int, height:int, transparent:Boolean):String {
        return width + 'x' + height + (transparent ? 't' : 'o');
    }

}
}
