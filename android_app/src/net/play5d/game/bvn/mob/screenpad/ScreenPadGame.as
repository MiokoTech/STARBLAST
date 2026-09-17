package net.play5d.game.bvn.mob.screenpad {
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.EventDispatcher;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
import net.play5d.game.bvn.fighter.FighterActionState;
import net.play5d.game.bvn.fighter.FighterMain;
import net.play5d.game.bvn.mob.GameInterfaceManager;
import net.play5d.game.bvn.mob.RootSprite;
import net.play5d.game.bvn.mob.events.ScreenPadEvent;
import net.play5d.game.bvn.mob.input.ScreenPadInput;

public class ScreenPadGame extends EventDispatcher {

    public function ScreenPadGame(stage:Stage) {
        super();
        _stage = stage;
        build();
    }
    public var inputers:Vector.<ScreenPadInput>;
    public var menuInputer:ScreenPadInput;
    public var isShowing:Boolean;
    private var _arrow:ScreenPadArrow;
    private var _stage:Stage;
    private var _listened:Boolean;
    private var _downCache:Object = {};
    private var W:Number;
    private var H:Number;
    private var _btns:Vector.<ScreenPadBtnBase>;
    private var _autoHideSpecial:Boolean;
    private var _autoHideSuperSkill:Boolean;
    private var _autoHideWankai:Boolean;
    private var _editingBtn:ScreenPadBtnBase;
    private var _editingBtnDownPos:Point;
    private var _editingStageDownPos:Point;
    private var _editStageView:Sprite;
    private var _activeInputState:Object = {};

    public function onPause():void {
        _downCache = {};
        clearActiveInputState();
    }

    public function onResume():void {

    }

    public function getBtns():Vector.<ScreenPadBtnBase> {
        return _btns;
    }

    public function reBuild():void {
        var restoreShow:Boolean = isShowing;
        _downCache = {};
        try {
            for (var i:int; i < _btns.length; i++) {
                _stage.removeChild(_btns[i].display);
                _btns[i].onRemove();
            }
        }
        catch (e:Error) {
        }
        build();
        if (restoreShow) {
            show();
        }
    }

    public function show():void {
        isShowing = true;
        for (var i:int; i < _btns.length; i++) {
            _stage.addChild(_btns[i].display);
            _btns[i].onAdd();
        }
//			listen();
    }

    public function hide():void {
        isShowing = false;
        try {
            for (var i:int; i < _btns.length; i++) {
                _stage.removeChild(_btns[i].display);
                _btns[i].onRemove();
            }
        }
        catch (e:Error) {
        }

        for each(var p:ScreenPadInput in inputers) {
            p.clear();
        }
        clearActiveInputState();
    }

    public function render():void {
        var fighter:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
        if (!fighter) {
            return;
        }
        syncLayoutByFighter(fighter);

//			fighter.qi >= 100
        try {
            if (_autoHideSuperSkill) {
                setBtnVisible(getLayoutKey('superSkill'), fighter.qi >= 100);
            }
            if (_autoHideSpecial) {
                setBtnVisible(getLayoutKey('special'), specialEnabled(fighter));
            }
            if (_autoHideWankai) {
                setBtnVisible(getLayoutKey('wankai'), fighter.qi >= 300 && fighter.hasWankai());
            }
        }
        catch (e:Error) {
            trace('ScreenPadGame.render', e);
        }

        renderTouch();

    }

    public function getEditingBtn():ScreenPadBtnBase {
        return _editingBtn;
    }

    public function showEditMode():void {
        isShowing = true;

        for (var i:int; i < _btns.length; i++) {
            _stage.addChild(_btns[i].display);
        }

        for each(var b:ScreenPadBtnBase in _btns) {
            b.display.alpha = 1;
        }

        RootSprite.STAGE.addEventListener(TouchEvent.TOUCH_BEGIN, btnTouchEditHandler);
        RootSprite.STAGE.addEventListener(TouchEvent.TOUCH_MOVE, btnTouchEditHandler);
        RootSprite.STAGE.addEventListener(TouchEvent.TOUCH_END, btnTouchEditHandler);

        _editStageView               = new Sprite();
        _editStageView.mouseChildren = _editStageView.mouseChildren = false;
        RootSprite.STAGE.addChild(_editStageView);
    }

    public function getBtnPosData():Object {
        var o:Object = {};
        for each(var i:ScreenPadBtnBase in _btns) {
            o[i.keyId] = i.getPosData();
        }
        return o;
    }

    public function destory():void {

        isShowing = false;

        RootSprite.STAGE.removeEventListener(TouchEvent.TOUCH_BEGIN, btnTouchEditHandler);
        RootSprite.STAGE.removeEventListener(TouchEvent.TOUCH_MOVE, btnTouchEditHandler);
        RootSprite.STAGE.removeEventListener(TouchEvent.TOUCH_END, btnTouchEditHandler);

        if (_editStageView) {
            try {
                _editStageView.parent.removeChild(_editStageView);
            }
            catch (e:Error) {
                trace(e);
            }
            _editStageView = null;
        }

        if (_btns) {
            for each(var i:ScreenPadBtnBase in _btns) {
                try {
                    i.display.removeEventListener(TouchEvent.TOUCH_BEGIN, btnTouchEditHandler);
                    i.display.parent.removeChild(i.display);
                    i.onRemove();
                    i.display.bitmapData.dispose();
                }
                catch (e:Error) {
                    trace(e);
                }
            }
            _btns = null;
        }
    }

    private function build():void {
        W     = RootSprite.FULL_SCREEN_SIZE.x;
        H     = RootSprite.FULL_SCREEN_SIZE.y;
        _btns = new Vector.<ScreenPadBtnBase>();

        _autoHideSuperSkill = GameInterfaceManager.config.screenPadConfig.superSkillAutoHide;
        _autoHideSpecial    = GameInterfaceManager.config.screenPadConfig.specialAutoHide;
        _autoHideWankai     = GameInterfaceManager.config.screenPadConfig.wankaiAutoHide;

        _arrow = addArrow(['up', 'down', 'left', 'right'], ScreenPadAsset.arrow, 0.2, 0, 0, 0.2, 0.5);

        switch (GameInterfaceManager.config.screenPadConfig.joyMode) {
        case 0:
            addBtnMode1();
            break;
        case 1:
            addBtnMode2();
            break;
        }

        var pause:ScreenPadBtn = addBtn('back', ScreenPadAsset.pause, 0, 0, 0, 0.3, 0.5, 0.7);
        pause.display.x        = (
                                         W - pause.display.width
                                 ) / 2;

        var config:Object = GameInterfaceManager.config.screenPadConfig.joySet;
        if (config) {
            setBtnByConfig(config);
        }

        initBtns();
    }

    private function setBtnByConfig(config:Object):void {
        for each(var i:ScreenPadBtnBase in _btns) {
            var data:Object = config[i.keyId];
            if (!data) {
                continue;
            }

            if (data.scale != undefined) {
                i.setScale(data.scale);
            }
            if (data.x != undefined) {
                i.display.x = data.x;
            }
            if (data.y != undefined) {
                i.display.y = data.y;
            }
        }
    }

    private function addBtnMode1():void {
        addBtn('jump', ScreenPadAsset.jump, 0, 0, 0.1, 0.1);
        addBtn('attack', ScreenPadAsset.attack, 0, 0, 1.8, 0.15, 0.2);
        addBtn('skill', ScreenPadAsset.skill, 0, 0, 1.3, 1.4, 0.2);
        addBtn('dash', ScreenPadAsset.dash, 0, 0, 0.1, 1.8, 0.2);

        addBtn('superSkill', ScreenPadAsset.spskill, 0, 0, 0.2, 3.5, 0.3, 0.7);
        addBtn('special', ScreenPadAsset.special, 0.2, 0, 0, 3.2, 0.3, 0.7);

        addBtn('wankai', ScreenPadAsset.wanjie, 0.2, 0.5, 0, 0, 0.3, 0.7);
    }

    private function addBtnMode2():void {
        addBtn('attack', ScreenPadAsset.attack, 0, 0, 2.1, 1.0, 0.1);
        addBtn('jump', ScreenPadAsset.jump2, 0, 0, 1.1, 0.1, 0.1);
        addBtn('dash', ScreenPadAsset.dash, 0, 0, 0.1, 1.0, 0.1);
        addBtn('skill', ScreenPadAsset.skill, 0, 0, 1.1, 1.9, 0.1);

        addBtn("superSkill", ScreenPadAsset.spskill, 0, 0, 0.2, 4.5);
        addBtn("special", ScreenPadAsset.special, 0, 0, 2.3, 4.5);
        addBtn("wankai", ScreenPadAsset.wanjie, 0.1, 0, 0, 4.5);
    }

    private function addArrow(keyIds:Array, asset:Class, left:Number = 0, top:Number = 0, right:Number = 0, bottom:Number = 0, areaAdd:Number = 0, iconSize:Number = 3) : ScreenPadArrow
    {
        var size:Point = new Point();
        size.x         = ScreenPadUtils.cm2pixel(iconSize);

        var arrow:ScreenPadArrow = ScreenPadUtils.getArrow(asset, size);
        arrow.moveAble           = true;
        arrow.keyId              = 'arrow';
        arrow.setKeyIds(keyIds[0], keyIds[1], keyIds[2], keyIds[3]);
        arrow.areaAdd = ScreenPadUtils.cm2pixel(areaAdd);

        if (left != 0) {
            arrow.display.x = ScreenPadUtils.cm2pixel(left);
        }
        if (top != 0) {
            arrow.display.y = ScreenPadUtils.cm2pixel(top);
        }
        if (right != 0) {
            arrow.display.x = W - arrow.display.width - ScreenPadUtils.cm2pixel(right);
        }
        if (bottom != 0) {
            arrow.display.y = H - arrow.display.height - ScreenPadUtils.cm2pixel(bottom);
        }

        _btns.push(arrow);

        return arrow;
    }

    private function addBtn(keyId:String, asset:Class, left:Number = 0, top:Number = 0, right:Number = 0,
                            bottom:Number                                                            = 0, areaAdd:Number = 0,
                            btnSize:Number                                                           = 1.1
    ):ScreenPadBtn {
        var size:Point = new Point();
        size.x         = ScreenPadUtils.cm2pixel(btnSize);

        var btn:ScreenPadBtn = ScreenPadUtils.getButton(asset, size);
        btn.moveAble         = true;
        btn.keyId            = keyId;
        btn.areaAdd          = ScreenPadUtils.cm2pixel(areaAdd);

        if (left != 0) {
            btn.display.x = ScreenPadUtils.cm2pixel(left);
        }
        if (top != 0) {
            btn.display.y = ScreenPadUtils.cm2pixel(top);
        }
        if (right != 0) {
            btn.display.x = W - btn.display.width - ScreenPadUtils.cm2pixel(right);
        }
        if (bottom != 0) {
            btn.display.y = H - btn.display.height - ScreenPadUtils.cm2pixel(bottom);
        }

        _btns.push(btn);

        return btn;
    }

    private function initBtns():void {
        for each(var i:ScreenPadBtnBase in _btns) {
            i.initArea();
        }
    }

    private function getBtnArea(bp:Bitmap):Rectangle {
        var rect:Rectangle = new Rectangle();
        rect.x             = bp.x;
        rect.y             = bp.y;
        rect.width         = bp.width;
        rect.height        = bp.height;
        return rect;
    }

    private function specialEnabled(fighter:FighterMain):Boolean {
        if (fighter.actionState == FighterActionState.HURT_ING) {
            return fighter.qi >= 100 && fighter.hasEnergy(50);
        }
        return fighter.fzqi == fighter.fzqiMax;
    }
    
    private function syncLayoutByFighter(fighter:FighterMain):void {
    }
    
    private function getLayoutKey(baseKey:String):String {
        return baseKey;
    }
    
    private function normalizeInputKey(keyName:String):String {
        return keyName;
    }

    private function setBtnVisible(key:String, visible:Boolean):void {
        for (var i:int; i < _btns.length; i++) {
            if (_btns[i].keyId == key) {
                _btns[i].setVisible(visible);
                return;
            }
        }
    }

    private function renderTouch():void {
        var nextInputState:Object = {};
        for (var i:int; i < _btns.length; i++) {

            var btn:ScreenPadBtnBase = _btns[i];

            var isDown:Boolean = false;

            btn.touchUP();

            for (var j:String in _downCache) {
                var cache:Object  = _downCache[j];
                var touchX:Number = cache.x;
                var touchY:Number = cache.y;

                if (!btn.checkArea(touchX, touchY)) {
                    continue;
                }

                isDown = true;

                btn.touchDown(touchX, touchY);

                if (btn == _arrow) {
                    _arrow.touchMove(touchX, touchY);
                }

            }

            if (btn == _arrow) {
                if (isDown) {
                    appendInputState(nextInputState, _arrow.keyId);
                }
                else {
                    _arrow.clearKey();
                }
            }
            else {
                if (isDown) {
                    appendInputState(nextInputState, btn.keyId);
                }
            }

        }
        applyInputState(nextInputState);
    }

    private function appendInputState(out:Object, key:Object):void {
        var keys:Array = resolveInputKeys(key);
        if (!keys) {
            return;
        }
        for each (var k:String in keys) {
            if (k && k.length > 0) {
                out[k] = true;
            }
        }
    }

    private function resolveInputKeys(key:Object):Array {
        key = mapVirtualInputKey(key);
        if (key == null) {
            return null;
        }
        var out:Array = [];
        if (key is String) {
            var one:String = normalizeInputKey(String(key));
            if (one && one.length > 0) {
                out.push(one);
            }
            return out;
        }
        if (key is Array) {
            var src:Array = key as Array;
            for (var i:int = 0; i < src.length; i++) {
                if (src[i] == null) {
                    continue;
                }
                var item:String = normalizeInputKey(String(src[i]));
                if (item == null || item.length < 1 || out.indexOf(item) != -1) {
                    continue;
                }
                out.push(item);
            }
            return out;
        }
        return null;
    }

    private function applyInputState(nextState:Object):void {
        var k:String;
        for (k in _activeInputState) {
            if (!nextState[k]) {
                setInputerDown(k, false);
            }
        }
        for (k in nextState) {
            if (!_activeInputState[k]) {
                setInputerDown(k, true);
            }
        }
        _activeInputState = nextState;
    }

    private function clearActiveInputState():void {
        for (var k:String in _activeInputState) {
            setInputerDown(k, false);
        }
        _activeInputState = {};
    }

    private function setInputerDown(key:Object, down:Boolean):void {

        key = mapVirtualInputKey(key);
        if (key == null) {
            return;
        }

//			trace('setInputerDown' , key , down);

        if (menuInputer) {
            var menuInputKey:String = key is String ? normalizeInputKey(String(key)) : null;
            switch (key) {
            case 'attack':
            case 'jump':
                menuInputer.setDown('select', down);
                break;
            case 'back':
                menuInputer.setDown('back', down);
                break;
            }
            if (menuInputKey == 'attack' || menuInputKey == 'jump') {
                menuInputer.setDown('select', down);
            }
            if (menuInputKey == 'back') {
                menuInputer.setDown('back', down);
            }
        }

        var t:ScreenPadInput;
        var i:int, j:int;
        var ks:Array;
        var k:String;
        var il:int, kl:int;

        il = inputers.length;

        for (i = 0; i < il; i++) {
            t = inputers[i];

            if (key is String) {
                t.setDown(normalizeInputKey(key as String), down);
            }

            if (key is Array) {
                ks = key as Array;
                kl = ks.length;
                for (j = 0; j < kl; j++) {
                    if (ks[j] == null) {
                        continue;
                    }
                    k = normalizeInputKey(String(ks[j]));
                    if (k == null || k.length < 1) {
                        continue;
                    }
                    t.setDown(k, down);
                }
            }

        }
    }

    private function mapVirtualInputKey(key:Object):Object {
        return key;
    }

    private function updateEditRect():void {
        if (!_editStageView) {
            return;
        }

        _editStageView.graphics.clear();

        if (_editingBtn) {
            _editStageView.graphics.lineStyle(2, 0x00FFFF, 1);
            _editStageView.graphics.drawRect(
                    _editingBtn.display.x, _editingBtn.display.y, _editingBtn.display.width,
                    _editingBtn.display.height
            );
            _editStageView.graphics.endFill();
        }
    }

    public function touchHandler(e:TouchEvent):void {
        var touchId:int   = e.touchPointID;
        var touchX:Number = e.stageX;
        var touchY:Number = e.stageY;

        switch (e.type) {
        case TouchEvent.TOUCH_BEGIN:
        case TouchEvent.TOUCH_MOVE:
            _downCache[touchId] = {x: touchX, y: touchY};
            break;
        case TouchEvent.TOUCH_END:
            delete _downCache[touchId];
            break;
        }

    }

    private function btnTouchEditHandler(e:TouchEvent):void {
        switch (e.type) {
        case TouchEvent.TOUCH_BEGIN:
            for each(var b:ScreenPadBtnBase in _btns) {
                if (b.checkArea(e.stageX, e.stageY)) {
                    _editingBtn          = b;
                    _editingBtnDownPos   = new Point(b.display.x, b.display.y);
                    _editingStageDownPos = new Point(e.stageX, e.stageY);
                    updateEditRect();
                    return;
                }
            }
            break;
        case TouchEvent.TOUCH_END:
            if (_editingBtn) {
                _editingBtn.initArea();
                _editingBtnDownPos   = null;
                _editingStageDownPos = null;
                updateEditRect();
                dispatchEvent(new ScreenPadEvent(ScreenPadEvent.CUSTOM_SELECT, _editingBtn));
            }
            break;
        case TouchEvent.TOUCH_MOVE:
            if (_editingBtn && _editingBtnDownPos && _editingStageDownPos) {
                _editingBtn.display.x = _editingBtnDownPos.x + (
                        e.stageX - _editingStageDownPos.x
                );
                _editingBtn.display.y = _editingBtnDownPos.y + (
                        e.stageY - _editingStageDownPos.y
                );
                updateEditRect();
                dispatchEvent(new ScreenPadEvent(ScreenPadEvent.CUSTOM_MOVING, _editingBtn));
            }
            break;
        }

    }


}
}
