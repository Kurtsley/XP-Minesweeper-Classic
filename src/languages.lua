-- MIT License, Copyright (c) 2025 Kurtsley

-- languages.lua

local lang = {
    en = {
        menu_titles = {
            game = "&Game",
            options = "&Options",
            help = "&Help",
        },
        game_menu = {
            new = "&New",
            beginner = "&Beginner",
            intermediate = "&Intermediate",
            expert = "&Expert",
            custom = "&Custom...",
            best_times = "Best &Times...",
            exit = "E&xit",
        },
        options_menu = {
            marks = "&Marks (?)",
            sound = "&Sound",
        },
        help_menu = {
            about = "&About",
        },
        custom_labels = {
            height = "&Height:",
            width = "&Width:",
            mines = "&Mines:",
        },
        best_times_labels = {
            easy = "Easy:",
            intermediate = "Intermediate:",
            expert = "Expert:",
        },
        buttons = {
            ok = "OK",
            reset = "&Reset",
            cancel = "Cancel",
        },
        dialogs = {
            save_error_title = "Error reading times file",
            save_error_body = "Unable to access save directory\ntimes will not be saved!",
            high_score = "You have the fastest time for %s level.",
            best_times_title = "Fastest Mine Sweepers",
        }
    },
    zh = {
        menu_titles = {
            game = "游戏(&G)",
            options = "选项(&O)",
            help = "帮助(&H)",
        },
        game_menu = {
            new = "开局(&N)",
            beginner = "初级(&B)",
            intermediate = "中级(&I)",
            expert = "高级(&E)",
            custom = "自定义(&C)...",
            best_times = "扫雷英雄榜(&T)...",
            exit = "退出(&X)",
        },
        options_menu = {
            marks = "标记(?)(&M)",
            sound = "声音(&S)",
        },
        help_menu = {
            about = "关于(&A)",
        },
        custom_labels = {
            height = "高度(&H):",
            width = "宽度(&W):",
            mines = "雷数(&M):",
        },
        best_times_labels = {
            easy = "初级:",
            intermediate = "中级:",
            expert = "高级:",
        },
        buttons = {
            ok = "确定",
            reset = "重新计分(&R)",
            cancel = "取消",
        },
        dialogs = {
            save_error_title = "读取记录文件时出错",
            save_error_body = "无法访问存档目录\n记录将不会被保存！",
            high_score = "已破%s记录",
            best_times_title = "扫雷英雄榜",
        }
    }
}

return lang
