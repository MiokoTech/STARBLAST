package net.play5d.game.bvn.ui
{
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import net.play5d.game.bvn.GameConfig;
    import net.play5d.game.bvn.data.ConfigVO;
    import net.play5d.game.bvn.data.GameData;
    import net.play5d.game.bvn.events.SetBtnEvent;
    import net.play5d.game.bvn.input.GameInputer;
    import net.play5d.game.bvn.mob.GameInterfaceManager;
    import net.play5d.game.bvn.utils.ResUtils;
    import net.play5d.game.bvn.MainGame;

    public class SetChar extends Sprite
    {
        private var _btnGroup:SetBtnGroup;
        private var _parentMenu:MenuBtnGroup;
        private var _parentChild:MenuBtn;
        private var _childLabel:String;
        private var _ui:MovieClip;

        public function SetChar(parentMenu:MenuBtnGroup, parentChild:MenuBtn = null, childLabel:String = null)
        {
            _parentMenu = parentMenu;
            _parentChild = parentChild;
            _childLabel = childLabel;

            // Setup tombol pilihan jumlah karakter
            _ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.menu, "menu_gameSet") as MovieClip;
            addChild(_ui);

            _btnGroup = new SetBtnGroup();
            _btnGroup.startY = 220;
            _btnGroup.startX = 225;
            _btnGroup.endY = 300;
            _btnGroup.gap = 40;
            _btnGroup._isSubMenu = true;

            _btnGroup.initSimpleBtns([
            { label: "Start Game", cn: "" },
            { label: "Game Difficulty", cn:"返回", cn_y: 200,
               options: [
                  { label: "Easy", cn: "fps", cn_y: 255, value: 1 },
                  { label: "Normal", cn: "fps", cn_y: 255, value: 2 },
                  { label: "Hard", cn: "fps", cn_y: 255, value: 3 },
                  { label: "Very Hard", cn: "fps", cn_y: 255, value: 4 }
               ],
               optoinKey:"difficulty"
            },
            { label: "Rounds to Wins", cn:"返回", cn_y: 200,
               options: [
                  { label: "1", cn: "fps", cn_y: 255, value: 1 },
                  { label: "2", cn: "fps", cn_y: 255, value: 2 },
                  { label: "3", cn: "fps", cn_y: 255, value: 3 }
               ],
               optoinKey:"roundGame"
            },
            { label: "Team Player 1", cn: "",
               options: [
                  { label:"1", cn:"", value:1 },
                  { label:"2", cn:"", value:2 },
                  { label:"3", cn:"", value:3 }
               ],
               optoinKey: "player1"
            },
            { label: "Team Player 2", cn: "",
               options: [
                  { label:"1", cn:"", value:1 },
                  { label:"2", cn:"", value:2 },
                  { label:"3", cn:"", value:3 }
               ],
               optoinKey: "player2"
            },
            { label: "Return", cn: "" },
            ]);

            _btnGroup.addEventListener("SELECT", onBtnSelect);
            _btnGroup.addEventListener(SetBtnEvent.OPTION_CHANGE, onOptionChange);
            addChild(_btnGroup);
        }

        private function onOptionChange(e:SetBtnEvent) : void
        {
           var config:ConfigVO = GameData.I.config;
           config.setValueByKey(e.optionKey, e.optionValue);
        }

        private function onBtnSelect(e:SetBtnEvent) : void
        {
            switch (e.selectedLabel)
            {
                case "Return":
                    closeSelf();
                    break;
                case "Start Game":
                    GameData.I.saveOptionsData();
                    GameData.I.config.applyConfig();
                    closeSelf();
                    MainGame.I.goSelect();
                    break;
            }
        }

        private function closeSelf() : void
        {
            if (_btnGroup) {
                try {
                    _btnGroup.destory();
                    this.removeChild(_btnGroup);
                    _btnGroup = null;
                } catch(err:Error) {
                    trace(err);
                }
            }

            if (_ui) {
               _ui.visible = false;
               _ui = null;
            }

            try {
                this.parent.removeChild(this);
            } catch(err:Error) {
                trace(err);
            }

            _parentMenu.restoreInputAfterSubmenu(_parentChild, _childLabel);
        }
    }
}
