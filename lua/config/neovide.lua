-- NeoVide configurations ====================================================
if vim.g.neovide then
    vim.o.linespace = 6

    vim.g.neovide_padding_top    = 6
    vim.g.neovide_padding_left   = 12
    vim.g.neovide_padding_right  = 12
    vim.g.neovide_padding_bottom = 6

    vim.g.neovide_opacity = 0.95

    vim.g.neovide_floating_corner_radius = 0.2
    vim.g.neovide_floating_blur_amount_x = 0.2
    vim.g.neovide_floating_blur_amount_y = 0.2
    vim.g.neovide_floating_shadow = true
    vim.g.neovide_floating_z_height = 10
    vim.g.neovide_light_angle_degrees = 45
    vim.g.neovide_light_radius = 5

    -- Options: "ripple" "sonicboom" "torpedo" "wireframe" "railgun"
    vim.g.neovide_cursor_vfx_mode = ""

    vim.g.neovide_cursor_animation_length = 0.0
    vim.g.neovide_scroll_animation_length = 0.1
    vim.g.neovide_touch_drag_timeout      = 0.0
end
