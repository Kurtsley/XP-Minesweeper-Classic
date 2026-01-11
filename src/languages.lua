-- MIT License, Copyright (c) 2025-2026 Kurtsley

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
        high_score_labels = {
            easy = "Beginner",
            medium = "Intermediate",
            hard = "Expert",
        },
        dialogs = {
            save_error_title = "Error reading times file",
            save_error_body = "Unable to access save directory\ntimes will not be saved!",
            high_score = "You have the fastest time for %s level.",
            best_times_title = "Fastest Mine Sweepers",
        }
    }
}

return lang
