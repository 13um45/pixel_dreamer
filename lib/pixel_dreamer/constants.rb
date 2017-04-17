module PixelDreamer
  module Constants
    SETTINGS = { sharp: { vertical: true, min: 20, max: 60, method: 'uniqueness' },
                 soft: { vertical: true, min: 100, max: 300 },
                 soft_diagonal: { diagonal: true, min: 100, max: 300 },
                 side_glitch: { vertical: false, min: 40, middle: -1 },
                 side_glitch_soft: { vertical: false, min: 100, max: 300, middle: -1 },
                 side_glitch_erratic: { vertical: false, min: 100, max: 300, middle: -4 },
                 vertical_glitch_soft: { vertical: true, min: 100, max: 300, middle: -1 },
                 soft_unique: { vertical: true, min: 100, max: 300, method: 'uniqueness' },
                 side_soft_unique: { vertical: false, min: 100, max: 300, method: 'uniqueness' },
                 side_soft_aggressive: { vertical: false, min: 100, max: 300, method: 'sum-hsb', smooth: true },
                 side_soft_harsh: { vertical: false, min: 100, max: 300, method: 'hue', smooth: true },
                 side_soft_sand: { vertical: false, min: 100, max: 300, method: 'random', smooth: true },
                 side_soft_yellow: { vertical: false, min: 100, max: 300, method: 'yellow', smooth: true },
                 soft_reverse: { vertical: true, min: 100, max: 300, reverse: true },
                 soft_min: { diagonal: true, max: 6 },
                 cinna: { vertical: true, min: 150, max: 300 },
                 cami: { vertical: true, min: 60, max: 120 } }.freeze

    SORTING_METHODS = ['sum-rgb', 'red', 'green', 'blue', 'sum-hsb', 'hue', 'saturation', 'brightness', 'uniqueness',
                       'luma', 'random', 'magenta', 'cyan', 'yellow', 'alpha', 'sum-rgba', 'sum-hsba', 'none'].freeze

    RANDOMIZE_SETTINGS = { reverse: [true, false], vertical: [true, false], diagonal: [true, false],
                           smooth: [true, false], method: SORTING_METHODS, min: (1..1000).to_a,
                           max: (1..1000).to_a, trusted: [true, false], middle: [true, false], verbose: [true] }.freeze

    RANDOMIZE_DEFAULTS = { gif: false, compress: true, speed: 84, image_number: 10 }.freeze

    SEQUENCE_SETTINGS = { high_long: { counter: 1, max_multiple: 3, increment: 1, break_point: 101 },
                          high_short: { counter: 1, max_multiple: 3, increment: 1, break_point: 31 },
                          high_short_late: { counter: 70, max_multiple: 3, increment: 1, break_point: 101 },
                          cinna: { counter: 120, max_multiple: 2, increment: 1, break_point: 151 },
                          cami: { counter: 60, max_multiple: 2, increment: 1, break_point: 91 },
                          high_short_late_middle: { counter: 45, max_multiple: 3, increment: 1, break_point: 76 },
                          high_short_early: { counter: 20, max_multiple: 3, increment: 1, break_point: 51 },
                          low_short: { counter: 1, max_multiple: 3, increment: 3, break_point: 31 },
                          low_long: { counter: 1, max_multiple: 3, increment: 3, break_point: 101 } }.freeze

    DEFAULTS = { reverse: false, vertical: false, diagonal: false,
                 smooth: false, method: 'sum-rgb', verbose: false,
                 min: Float::INFINITY, max: Float::INFINITY,
                 trusted: false, middle: false }.freeze

    GLITCH_SEQUENCE_DEFAULTS = { settings: SETTINGS[:soft], sequence_settings: SEQUENCE_SETTINGS[:high_short],
                                 compress: true, speed: 84, gif: true }.freeze

    BARRAGE_DEFAULTS = { gif: false, compress: true, speed: 84 }.freeze

    BRUTE_SORT_SAVE_WITH_SETTINGS_DEFAULTS = { settings: {}, output_name: nil, gif: false,
                                               output_folder: false, resize: false, compress: false }.freeze
    IMAGE_DELAY_DEFAULTS = { active: false, image_to_delay: 1, delay_length: 1000 }.freeze

    DITHER_DEFAULTS = { active: false, number_of_colors: 200 }.freeze

    GIF_DEFAULTS = { speed: 84, dither: DITHER_DEFAULTS, image_delay: IMAGE_DELAY_DEFAULTS }.freeze
  end
end