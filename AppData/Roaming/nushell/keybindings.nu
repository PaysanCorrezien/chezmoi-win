let keybindings = [
    {
        name: completion_menu
        modifier: none
        keycode: tab
        mode: [emacs vi_normal vi_insert]
        event: {
            until: [
                { send: menu name: completion_menu }
                { send: menunext }
            ]
        }
    }
    {
        name: completion_previous_menu
        modifier: shift
        keycode: backtab
        mode: [emacs, vi_normal, vi_insert]
        event: { send: menuprevious }
    }
    {
        name: help_menu
        modifier: control
        keycode: f1
        mode: [emacs, vi_insert, vi_normal]
        event: { send: menu name: help_menu }
    }
    {
        name: select_all
        modifier: control
        keycode: char_a
        mode: emacs
        event: { edit: selectall }
    }
    # {
    #     name: cut_selection
    #     modifier: control
    #     keycode: char_x
    #     mode: emacs
    #     event: { edit: cutselectionsystem }  # Fixed case
    # }
    {
        name: delete_word_forward
        modifier: control
        keycode: char_w
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: deleteword }
    }
    {
        name: delete_line
        modifier: control
        keycode: char_d
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: cutcurrentline }
    }
    {
        name: undo
        modifier: control
        keycode: char_u
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: undo }
    }
    {
        name: redo
        modifier: control
        keycode: char_h
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: redo }
    }
    {
        name: escape
        modifier: none
        keycode: escape
        mode: [emacs, vi_normal, vi_insert]
        event: { send: esc }
    }
    {
        name: cancel_command
        modifier: control
        keycode: char_c
        mode: [emacs, vi_normal, vi_insert]
        event: { send: ctrlc }
    }
    {
        name: clear_screen
        modifier: control
        keycode: char_l
        mode: [emacs, vi_normal, vi_insert]
        event: { send: clearscreen }
    }
    {
        name: open_command_editor
        modifier: control
        keycode: char_e
        mode: [emacs, vi_normal, vi_insert]
        event: { send: openeditor }
    }
    {
        name: move_to_previous_word
        modifier: control
        keycode: char_b
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: movewordleft }
    }
    {
        name: move_right_or_take_history_hint
        modifier: control
        keycode: char_f
        mode: [emacs, vi_normal, vi_insert]
        event: {
            until: [
                {send: historyhintwordcomplete}
                {send: menuright}
                {send: right}
            ]
        }
    }
    {
        name: move_word_left
        modifier: control
        keycode: left
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: movewordleft }
    }
    {
        name: move_word_right
        modifier: control
        keycode: right
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: movewordright }
    }
    {
        name: select_word_left
        modifier: shift_control
        keycode: left
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: movewordleft select: true }
    }
    {
        name: select_word_right
        modifier: shift_control
        keycode: right
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: movewordright select: true }
    }
    {
        name: select_line_start
        modifier: shift
        keycode: home
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: movetolinestart select: true }
    }
    {
        name: select_line_end
        modifier: shift
        keycode: end
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: movetolineend select: true }
    }
    {
        name: cut_to_line_end
        modifier: control
        keycode: char_k
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: cuttolineend }
    }
    {
        name: cut_to_line_start
        modifier: control_shift
        keycode: char_k
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: cutfromlinestart }
    }
    {
        name: move_left
        modifier: none
        keycode: left
        mode: [emacs, vi_normal, vi_insert]
        event: {
            until: [
                {send: menuleft}
                {send: left}
            ]
        }
    }
    {
        name: move_one_word_left
        modifier: control
        keycode: left
        mode: [emacs, vi_normal, vi_insert]
        event: {edit: movewordleft}
    }
    {
        name: move_one_word_right_or_take_history_hint
        modifier: control
        keycode: right
        mode: [emacs, vi_normal, vi_insert]
        event: {
            until: [
                {send: historyhintwordcomplete}
                {edit: movewordright}
            ]
        }
    }
    {
        name: move_to_line_start
        modifier: none
        keycode: home
        mode: [emacs, vi_normal, vi_insert]
        event: {edit: movetolinestart}
    }
    {
        name: newline_or_run_command
        modifier: none
        keycode: enter
        mode: emacs
        event: {send: enter}
    }
    {
        name: swap_graphemes
        modifier: control
        keycode: char_s
        mode: emacs
        event: {edit: swapgraphemes}
    }
    {
        name: swap_words
        modifier: control
        keycode: char_u0060
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: swapwords }
    }
    {
        name: upper_case_word
        modifier: control
        keycode: char_m
        mode: [emacs]
        event: { edit: uppercaseword }
    }
    {
        name: lower_case_word
        modifier: control
        keycode: char_n
        mode: [emacs]
        event: { edit: lowercaseword }
    }
    {
        name: find_files_with_fzf
        modifier: control
        keycode: char_t
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "commandline edit --insert (fd --type f --strip-cwd-prefix --hidden --follow --exclude .git | fzf --preview 'bat -n --color=always {}' --layout=reverse)"
        }
    }
    {
        name: find_directories_with_fzf
        modifier: control
        keycode: char_y
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "commandline edit --insert (fd --type d --strip-cwd-prefix --hidden --follow --exclude .git | fzf --preview 'lsd --tree --depth=2 --icon=auto {}' --layout=reverse)"
        }
    }
    {
        name: custom_binding
        modifier: control_shift
        keycode: char_u002F
        mode: [emacs, vi_normal, vi_insert]
        event: { send: menu name: help_menu }
    }
    {
        name: zoxide_menu
        modifier: control
        keycode: char_z
        mode: [emacs, vi_normal, vi_insert]
        event: [
            { edit: clear }
            { edit: insertstring value: "z " }
            { send: menu name: zoxide_menu }
        ]
    }
    {
        name: insert_newline
        modifier: control
        keycode: enter
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: insertnewline }
    }
    {
        name: aichat_integration
        modifier: control
        keycode: char_p
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "_aichat_nushell"
        }
    }
]
