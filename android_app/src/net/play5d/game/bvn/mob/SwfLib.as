package net.play5d.game.bvn.mob {
import net.play5d.game.bvn.interfaces.ISwfLib;

public class SwfLib implements ISwfLib {

    public function SwfLib() {
    }

    [Embed(source="/../../common/swf/common_ui.swf")]
    private var _common_ui:Class;

    public function get common_ui():Class {
        return _common_ui;
    }

    [Embed(source="/../../common/swf/fight.swf")]
    private var _fight:Class;

    public function get fight():Class {
        return _fight;
    }

    [Embed(source="/../../common/swf/gameover.swf")]
    private var _gameover:Class;

    public function get gameover():Class {
        return _gameover;
    }

    [Embed(source="/../../common/swf/howtoplay.swf")]
    private var _howtoplay:Class;

    public function get howtoplay():Class {
        return _howtoplay;
    }

    [Embed(source="/../../common/swf/loadGame.swf")]
    private var _loading:Class;

    public function get loadGame():Class {
        return _loading;
    }

    [Embed(source="/../../common/swf/select.swf")]
    private var _select:Class;

    public function get select():Class {
        return _select;
    }

    [Embed(source="/../../common/swf/setting.swf")]
    private var _setting:Class;

    public function get setting():Class {
        return _setting;
    }

    [Embed(source="/../../common/swf/menu.swf")]
    private var _menu:Class;

    public function get menu():Class {
        return _menu;
    }

    [Embed(source="/../../common/swf/mosou.swf")]
    private var _mosou:Class;

    public function get mosou():Class {
        return _mosou;
    }

    [Embed(source="/../../common/swf/bigmap.swf")]
    private var _bigmap:Class;

    public function get bigmap():Class {
        return _bigmap;
    }

    [Embed(source="/../../common/swf/dialog_ui.swf")]
    private var _dialog:Class;

    public function get dialog():Class {
        return _dialog;
    }

}
}
