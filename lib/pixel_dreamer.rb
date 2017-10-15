require 'pixel_dreamer/version'
require 'pxlsrt'
require 'rmagick'
require 'image_optim'
require 'image_optim_pack'
require 'pixel_dreamer/constants'

##
# to use pixel dreamer you must first create a new PixelDreamer::ImageDreamer class
# to do this you must pass in the uri of the image you will be pixel sorting
# example: image = PixelDreamer::ImageDreamer.new('/uri/image.png')
# you can also pass in an image overlay on top of the image that is outputs
# now you can use the instance methods


module PixelDreamer
  class ImageDreamer
    include Magick
    attr_accessor :image, :overlay_image

    def initialize(image, overlay_image = nil, app = false)
      @image = prepare_image(image)
      @overlay_image = overlay_image
      @input_name = name_parser(image)
      @parent_path = parent_path(image)
      @sequence_folder = sequence_folder
      @sequence_frame_path = sequence_frame_path
      @image_path = image_path
      @output_folder = output_folder
      @app = app
    end

    def show_sequence_folder
      @sequence_folder
    end

    def show_output_folder
      @output_folder
    end

    ##
    # converts image to png
    def convert_to_png(image_uri)
      path_without_ext = File.join(File.dirname(image_uri), File.basename(image_uri, '.*'))
      end_image = path_without_ext + '.png'
      image = Image.read(image_uri).first
      image.write(end_image)
      end_image
    end

    # pixel sorts an image and outputs a text file with settings used
    # once the image has been instantiated you can run this method without passing in any parameters
    # by default it runs with these paramaters:
    # { settings: DEFAULTS, output_name: nil, gif: false, output_folder: false }
    # example:
    # image.brute_sort_save_with_settings
    # or with these parameters
    #
    # image.brute_sort_save_with_settings(settings: PixelDreamer::Constants::DEFAULTS, output_name: nil, gif: false, output_folder: false)
    # or
    # image.brute_sort_save_with_settings(settings: { reverse: false, vertical: false, diagonal: false,
    #                                                 smooth: false, method: 'sum-rgb', verbose: false,
    #                                                 min: Float::INFINITY, max: Float::INFINITY,
    #                                                 trusted: false, middle: false })
    # also read the documentation for pxlsrt
    def brute_sort_save_with_settings(options = {})
      options[:image] ||= @image
      options = Constants::BRUTE_SORT_SAVE_WITH_SETTINGS_DEFAULTS.merge(options)
      image = options[:image]
      resize!(image) if options[:resize]
      compress!(image) if options[:compress]
      settings = Constants::DEFAULTS.merge(options[:settings])
      output_name = options[:output_name]
      gif = options[:gif]
      output_folder = options[:output_folder]

      f = Pxlsrt::Brute.brute(image, reverse: settings[:reverse], vertical: settings[:vertical],
                              diagonal: settings[:diagonal], smooth: settings[:smooth], method: settings[:method],
                              verbose: settings[:verbose], min: settings[:min], max: settings[:max],
                              trusted: settings[:trusted], middle: settings[:middle]
      ).save(file_name_with_settings(image, settings, output_name, gif, output_folder))
      if @overlay_image
        pixel_sorted = Magick::Image.read(f.path).first
        overlay = Magick::Image.read(@overlay_image).first

        result = pixel_sorted.composite(overlay, Magick::CenterGravity, Magick::OverCompositeOp)
        result.write(f.path)
      end
      f.path
    end

    ##
    # creates a sequence of pixel sorted images based on the setting hash and a sequence_setting hash chosen
    # once the image has been instantiated you can run this method without passing in any parameters
    # by default it is executed with these settings:
    # settings: SETTINGS[:soft], sequence_settings: SEQUENCE_SETTINGS[:high_short], compress: true, speed: 84
    # example: image.glitch_sequence
    # or with parameters, an output name can be passed in as well (string)
    # image.glitch_sequence({ settings: SETTINGS[:sharp], sequence_settings: SEQUENCE_SETTINGS[:high_long],
    #                         compress: false, speed: 42, output_name: 'image_glitched' })
    # the output name must only include the name of the output image not the file extension
    # this creates a sequence of of images that have been pixel sorted in with increments specified
    #
    # the settings_hash can be pulled from the SETTINGS, defaults to SETTINGS[:soft]
    # the sequence_settings cans be pulled from the SEQUENCE_SETTINGS, defaults to SEQUENCE_SETTINGS[:high_short]
    # compress defaults to true, copies and compresses input file and creates sequence from compressed file
    # the fps is set by the speed which is in milliseconds, defaults to 84ms (12fps)
    # the uri_helper method can be used to create the input uri
    def glitch_sequence(options = {})
      options[:output_name] ||= @input_name
      options = Constants::GLITCH_SEQUENCE_DEFAULTS.merge(options)
      settings = options[:settings]
      sequence_settings = options[:sequence_settings]
      output_name = options[:output_name]
      counter = sequence_settings[:counter]
      prepare(counter, options[:compress])
      puts 'Begin glitch sequence.'

      image_number = 1
      while counter < sequence_settings[:break_point]
        settings[:min] = counter
        settings[:max] = counter * sequence_settings[:max_multiple]
        brute_sort_save_with_settings(image: @path, settings: settings, output_name: (output_name + "_#{image_number}"),
                                      gif: true, output_folder: true)
        puts "IMAGE #{image_number}/#{sequence_settings[:break_point] - sequence_settings[:counter]} COMPLETE"
        image_number += 1
        counter += sequence_settings[:increment]
      end
      gif(options) if options[:gif]
    end


    ##
    # creates an image for each setting from the settings hash
    # quickest way to see how all of the settings effect the image supplied
    # once the image has been instantiated you can run this method without passing in any parameters
    # by default it is executed with these settings:
    # gif: false, compress: true, speed: 84
    #
    # example: image.barrage
    # or with parameters, an output name (string) can be passed in as well
    # image.barrage({ gif: true, compress: false, speed: 42, output_name: 'image_glitched' })
    #
    # the output name must only include the name of the output image not the file extension
    # the uri_helper can be used to create the input uri
    # example using the uri_helper:
    def barrage(options = {})
      options[:output_name] ||= @input_name
      options = Constants::BARRAGE_DEFAULTS.merge(options)
      output_name = options[:output_name]
      gif = options[:gif]
      counter = 1
      prepare(counter, options[:compress])
      puts 'Begin barrage.'

      Constants::SETTINGS.each do |key, setting_hash|
        brute_sort_save_with_settings(image: image, settings: setting_hash, output_name: (output_name + "_#{key}"),
                                      gif: gif, output_folder: true)
        puts "Image #{counter}/#{Constants::SETTINGS.length} complete."
        counter += 1
      end
      gif(options) if gif
    end

    ##
    # creates a series of images that are pixel sorted with randomized settings
    # the output is very hectic
    # once the image has been instantiated you can run this method without passing in any parameters
    # by default it is executed with these settings:
    # gif: false, compress: true, speed: 84, image_number: 10
    #
    # example: image.randomize
    # or with parameters, an output name (string) can be passed in as well
    # image.randomize({ gif: trues, compress: false, speed: 42, image_number: 20, output_name: 'image_glitched' })
    #
    # the output name must only include the name of the output image not the file extension
    # the amount of images that are created are based on the image_number (integer)
    def randomize(options = {})
      options[:output_name] ||= @input_name
      options = Constants::RANDOMIZE_DEFAULTS.merge(options)
      prepare(1, options[:compress])
      puts 'Being randomizing.'

      options[:image_number].times do
        brute_sort_save_with_settings(image: image, settings: randomize_settings, output_name: (options[:output_name] + random_name),
                                      gif: options[:gif], output_folder: true)
      end
    end

    ##
    # copies and compresses file passed
    # cannot compress b&w images
    def compress(img, path)
      puts 'Compressing image.'
      image_optim = ImageOptim.new(allow_lossy: true, verbose: false, skip_missing_workers: true, optipng: false,
                                   pngcrush: false, pngquant: { allow_lossy: true },
                                   advpng: false, pngout: false, svgo: false)
      File.rename(image_optim.optimize_image(img), path)
      puts 'Image copied and compressed.'
    end

    ##
    # compresses image in place
    def compress!(img)
      puts 'Compressing image.'
      image_optim = ImageOptim.new(allow_lossy: true, verbose: false, skip_missing_workers: true, optipng: false,
                                   pngcrush: false, pngquant: { allow_lossy: true },
                                   advpng: false, pngout: false, svgo: false)
      image_optim.optimize_image(img)
      puts 'compressed.'
    end

    ##
    # creates a gif using the @sequence_folder path and outputs gif into the @output_folder path
    # once the image has been instantiated you can run this method without passing in any parameters
    # by default it is executed with these settings:
    # speed: 84, dither: DITHER_DEFAULTS, image_delay: IMAGE_DELAY_DEFAULTS
    #
    # example: image.gif
    # or with parameters, an output name (string) can be passed in as well
    # image.gif({speed: 42, dither: DITHER_DEFAULTS, image_delay: IMAGE_DELAY_DEFAULTS, output_name: 'image_gif'})
    #
    # or image.gif({speed: 42, dither: {active: false, number_of_colors: 200},
    #                image_delay: {active: false, image_to_delay: 1, delay_length: 1000}, patrol: true, output_name: 'image_gif'})
    #
    # speed is used to set the length of time for each frame of the gif, it defaults to milliseconds
    #   - 12 fps: length of frame = 84 ms
    #   - 24 fps: length of frame = 42 ms
    #   - 30 fps: length of frame = 33 ms
    #   - 60 fps: length of frame = 17 ms
    # the dither hash used to set the dither settings
    # the image_delay hash is used to pause the sequence on an image for a set amount of time
    # the patrol boolean is used to have the animation reverse at the end of it's cycle
    def gif(options = {})
      options[:output_name] ||= @input_name
      options = Constants::GIF_DEFAULTS.merge(options)
      options[:image_delay] = Constants::IMAGE_DELAY_DEFAULTS.merge(options[:image_delay])
      options[:dither] = Constants::DITHER_DEFAULTS.merge(options[:dither])
      image_delay = options[:image_delay]
      dither = options[:dither]

      sorted_dir = Dir["#{@sequence_folder}*.png"].sort_by do |x|
        b = x[/_(\d+)/]
        if b.nil?
          0
        else
          b.delete('_').to_i
        end
      end
      animation = ImageList.new(*sorted_dir)
      animation.concat(patrol(animation)) unless options[:patrol].nil?
      animation.ticks_per_second = 1000
      puts 'Got images.'
      animation.delay = options[:speed]
      animation[(image_delay[:image_to_delay] - 1)].delay = image_delay[:delay_length] if image_delay[:active]
      puts 'Creating GIF.'
      animation = dither(animation, dither[:number_of_colors]) if dither[:active]
      animation = animation.deconstruct if @overlay_image && @app
      animation.write("#{@output_folder}#{options[:output_name]}.gif")

      if (File.size("#{@output_folder}#{options[:output_name]}.gif") / 1000000) > 8 && @app
        animation = dither(animation, 256)
        animation.write("#{@output_folder}#{options[:output_name]}.gif")
      end

      puts 'Complete.'
      "#{@output_folder}#{options[:output_name]}.gif"
    end

    ##
    # creates a uri by adding the name to common paths
    # example: test = uri_helper('desktop', 'test.png')
    def self.uri_helper(location, file_name)
      "/Users/#{ENV['USER']}/#{location}/" + file_name
    end

    private

    def patrol(animation)
      animation_reversed = animation.copy.reverse
      animation_reversed.delete_at(0)
      animation_reversed.delete_at(animation_reversed.length - 1)
      animation_reversed
    end

    ##
    # checks if image is png, if it is, returns the uri passed else it converts to png
    def prepare_image(image_uri)
      if image_png?(image_uri)
        image_uri
      else
        convert_to_png(image_uri)
      end
    end

    ##
    # check if image is png
    def image_png?(image_uri)
      File.extname(image_uri) == '.png'
    end

    def randomize_settings
      hash = {}
      Constants::RANDOMIZE_SETTINGS.each do |key, setting|
        setting.sample
        hash[key] = setting.sample
      end
      hash
    end

    def random_name
      '_' + (0...4).map { 65.+(rand(26)).chr }.join.downcase
    end

    def dither(animation, number_of_colors)
      animation.quantize(number_of_colors, Magick::RGBColorspace, true, 0, false)
    end

    def prepare(counter, compress)
      make_dir?
      path_selector(counter, compress, image)
      compress(image, @path) if compress
      resize!(@path) if @app
    end

    ##
    # creates an instance variable with the name from the file/uri passed
    # example: name_parser('/Users/user/desktop/test.png') => @input_name = 'test'
    # only .png files can be passed
    def name_parser(uri)
      base_uri = uri.dup
      File.basename(base_uri, '.*')
    end

    ##
    # creates an instance variable with the parent directory of the file path passed
    # example: path('/Users/user/desktop/test.png') => @parent_path = '/Users/user/desktop/'
    # can only be run after the name_parser
    def parent_path(uri)
      parent_path = uri.dup
      length = @input_name.length + 4
      uri_length = parent_path.length
      start = uri_length - length
      parent_path[start..uri_length] = ''
      parent_path
    end

    def output_folder
      "#{@parent_path}output/#{@input_name}/"
    end


    ##
    # creates an instance variable with the parent directory of the output
    # example: output_folder => @sequence_folder = '/Users/user/desktop/output/test/sequence/'
    # can only be run after the name_parser and parent_path
    def sequence_folder
      "#{@parent_path}output/#{@input_name}/sequence/"
    end

    ##
    # creates an instance variable with the full path of the output
    # example: output_path => @sequence_frame_path = '/Users/user/desktop/output/test/sequence/test.png'
    # can only be run after the name_parser and parent_path
    def sequence_frame_path
      "#{@parent_path}output/#{@input_name}/sequence/#{@input_name}.png"
    end

    ##
    # creates an instance variable with the image path, used when a glitch sequence is created but
    #   the original image is not need in said sequence
    # example: image_path => @image_path = '/Users/user/desktop/output/test/test.png'
    # can only be run after the name_parser and parent_path
    def image_path
      "#{@parent_path}output/#{@input_name}/#{@input_name}.png"
    end

    ##
    # creates directory using @sequence_folder for the output for either the glitch_sequence or barrage methods
    def make_dir?
      FileUtils.mkdir_p(@sequence_folder) unless Dir.exist?(@sequence_folder)
    end

    def path_selector(counter, compress, input)
      if compress
        @path = if counter > 1
                  @image_path
                else
                  @sequence_frame_path
                end
      else
        @path = input
        FileUtils.copy(input, @sequence_frame_path)
      end
    end

    def resize!(image_uri)
      i = Image.read(image_uri).first
      h = i.columns
      w = i.rows
      s = h * w

      if s > 1500000
        resized = i.change_geometry('@1500000') {|col, row, img| img.resize(col, row)}
        resized.write(image_uri)
      end
    end

    ##
    # still being used but partially deprecated
    def output(base_uri, input_name, output_name, options, gif, output_folder)
      base_uri = base_uri + 'output/'
      if gif
      else
        Dir.mkdir(base_uri) unless Dir.exist?(base_uri)
      end

      if output_name.nil?
        rando = '_' + (0...4).map { 65.+(rand(26)).chr }.join.downcase
        settings_file = File.new(base_uri + input_name + rando + '.txt', 'w')
        settings_file.puts(options.to_s)
        settings_file.close
        base_uri + input_name + rando + '.png'
      elsif gif || output_folder
        @base_uri = base_uri + "#{input_name}/"
        # needs to be refactored to create an output folder instead of a sequence folder
        FileUtils.mkdir_p(@sequence_folder) unless Dir.exist?(@sequence_folder)
        settings_file = File.new(@sequence_folder + output_name + '.txt', 'w')
        settings_file.puts(options.to_s)
        settings_file.close
        @sequence_folder + output_name + '.png'
      elsif !gif && !output_folder
        settings_file = File.new(base_uri + output_name + '.txt', 'w')
        settings_file.puts(options.to_s)
        settings_file.close
        base_uri + output_name + '.png'
      end
    end

    def file_name_with_settings(input_uri, options, output_name, gif, output_folder)
      base_uri = input_uri.dup
      input_name = File.basename(base_uri, '.png')
      length = input_name.length + 4
      uri_length = base_uri.length
      start = uri_length - length
      base_uri[start..uri_length] = ''
      if output_name.nil?
        output(base_uri, input_name, nil, options, gif, output_folder)
      else
        output(base_uri, input_name, output_name, options, gif, output_folder)
      end
    end
  end
end
