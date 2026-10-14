# Ryoku palette for fish and fzf. Rendered by the theme daemon; do not edit.
#
# Dropped straight into conf.d, which fish sources on its own, so nothing in the
# shipped config has to include it. Your ~/.config/fish/user.fish loads last and
# still wins.

# Syntax highlighting.
set -g fish_color_normal e0e2e8
set -g fish_color_command 9dcbfc
set -g fish_color_keyword d4bee5
set -g fish_color_quote bac8da
set -g fish_color_redirection c2c7cf
set -g fish_color_end d4bee5
set -g fish_color_error ffb4ab
set -g fish_color_param e0e2e8
set -g fish_color_comment c2c7cf
set -g fish_color_selection --background=134a74
set -g fish_color_operator d4bee5
set -g fish_color_escape bac8da
set -g fish_color_autosuggestion c2c7cf
set -g fish_color_cancel ffb4ab
set -g fish_color_search_match --background=134a74
set -g fish_color_valid_path --underline

# Completion pager.
set -g fish_pager_color_progress c2c7cf
set -g fish_pager_color_prefix 9dcbfc
set -g fish_pager_color_completion e0e2e8
set -g fish_pager_color_description c2c7cf
set -g fish_pager_color_selected_background --background=134a74

# fzf takes the same palette, so Ctrl-R and Ctrl-T match the terminal they open
# in. Appended to whatever options are already set rather than replacing them.
set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS \
--color=fg:#e0e2e8,bg:-1,hl:#9dcbfc \
--color=fg+:#e0e2e8,bg+:#134a74,hl+:#9dcbfc \
--color=info:#bac8da,prompt:#9dcbfc,pointer:#d4bee5 \
--color=marker:#d4bee5,spinner:#bac8da,header:#c2c7cf \
--color=border:#42474e"
