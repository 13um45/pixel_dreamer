require "pixel_dreamer/version"
require 'pxlsrt'
require 'pry'
require 'rmagick'
require 'image_optim'
require 'image_optim_pack'


module PixelDreamer
  class Image
    include Magick
    attr_accessor :input

    def initialize(input)
      @input = input
      @input_name = name_parser(input)
      @parent_path = parent_path(input)
      @sequence_folder = sequence_folder
      @sequence_frame_path = sequence_frame_path
      @image_path = image_path
      @output_folder = output_folder
    end

    ############# Constants ############

    SETTINGS = { sharp: {verbose: true, vertical: true, min:20, max: 60, method: 'uniqueness'},
                 soft: {verbose: true, vertical: true, min: 100, max: 300},
                 soft_diagonal: {verbose: true, diagonal: true, min: 100, max: 300},
                 side_glitch: {verbose: true, vertical: false, min: 40, middle: -1},
                 side_glitch_soft: {verbose: true, vertical: false, min: 100, max: 300, middle: -1},
                 side_glitch_erratic: {verbose: true, vertical: false, min: 100, max: 300, middle: -4},
                 vertical_glitch_soft: {verbose: true, vertical: true, min: 100, max: 300, middle: -1},
                 soft_unique: {verbose: true, vertical: true, min: 100, max: 300, method: 'uniqueness'},
                 side_soft_unique: {verbose: true, vertical: false, min: 100, max: 300, method: 'uniqueness'},
                 side_soft_aggressive: {verbose: true, vertical: false, min: 100, max: 300, method: 'sum-hsb', smooth: true},
                 side_soft_harsh: {verbose: true, vertical: false, min: 100, max: 300, method: 'hue', smooth: true},
                 side_soft_sand: {verbose: true, vertical: false, min: 100, max: 300, method: 'random', smooth: true},
                 side_soft_yellow: {verbose: true, vertical: false, min: 100, max: 300, method: 'yellow', smooth: true},
                 soft_reverse: {verbose: true, vertical: true, min: 100, max: 300, reverse: true},
                 soft_min: {verbose: true, diagonal: true, max: 6},
                 cinna: {verbose: true, vertical: true, min: 150, max: 300}  }

    DEFAULTS = {reverse: false, vertical: false, diagonal: false,
                smooth: false, method: 'sum-rgb', verbose: false,
                min: Float::INFINITY, max: Float::INFINITY,
                trusted: false, middle: false}


    SEQUENCE_SETTINGS = { high_long: { counter: 1, max_multiple: 3, increment: 1, break_point: 101 },
                          high_short: { counter: 1, max_multiple: 3, increment: 1, break_point: 31 },
                          high_short_late: { counter: 70, max_multiple: 3, increment: 1, break_point: 101 },
                          cinna: { counter: 120, max_multiple: 2, increment: 1, break_point: 151 },
                          high_short_late_middle: { counter: 45, max_multiple: 3, increment: 1, break_point: 76 },
                          high_short_early: { counter: 20, max_multiple: 3, increment: 1, break_point: 51 },
                          low_short: { counter: 1, max_multiple: 3, increment: 3, break_point: 31 },
                          low_long: { counter: 1, max_multiple: 3, increment: 3, break_point: 101 } }

    def brute_sort_save_with_settings(input, options = {}, output_name = nil, gif = false, output_folder = false)
      options = DEFAULTS.merge(options)
      Pxlsrt::Brute.brute(input, reverse: options[:reverse], vertical: options[:vertical],
                          diagonal: options[:diagonal], smooth: options[:smooth], method: options[:method],
                          verbose: options[:verbose], min: options[:min], max: options[:max],
                          trusted: options[:trusted], middle: options[:middle]
                          ).save(file_name_with_settings(input, options, output_name, gif, output_folder))
    end

    ##
    # creates a sequence of pixel sorted images based on the setting hash and a sequence_setting hash chosen
    # an input(string), settings_hash(hash), settings(hash), compress(boolean), output_name(string)
    # the input must be the full path of the file
    # the settings_hash can be pulled from the SETTINGS
    # the settings must be pulled from the SEQUENCE_SETTINGS, defaults to SEQUENCE_SETTINGS[:high_short]
    # compress defaults to true, copies and compresses input file and creates sequence from compressed file
    # the output name must only include the name of the output image not the file extension
    # the uri_helper can be used to create the input uri
    # defaults to the :high_short sequence setting
    # example: glitch_sequence(test, SETTINGS[:side_glitch], 'test')
    # or
    # glitch_sequence(test, SETTINGS[:side_glitch], SEQUENCE_SETTINGS[:high_long],'test')
    def glitch_sequence(input, setting_hash, settings = SEQUENCE_SETTINGS[:high_short], compress = true, output_name)
      counter = settings[:counter]
      prepare(input)
      path_choser(counter, compress, input)
      # convert(input)

      if compress
        compress(input, counter)
      end
      puts 'Begin glitch sequence.'

      image_number = 1
      while counter < settings[:break_point]
        setting_hash[:min] = counter
        setting_hash[:max] = counter * settings[:max_multiple]
        brute_sort_save_with_settings(@path, setting_hash, output_name + "_#{image_number}", true, true)
        puts "IMAGE #{image_number}/#{settings[:break_point] - settings[:counter]} COMPLETE"
        image_number += 1
        counter += settings[:increment]
      end
      gif(output_name, 84)
    end


    ##
    # creates an image for each setting from the settings hash
    # quickest way to see how all of the settings effect the image supplied
    # an input uri(string) and an output_name(string) must be provided
    # the output name must only include the name of the output image not the file extension
    # the uri_helper can be used to create the input uri
    # example using the uri_helper:
    # barrage(test, 'test')
    # or
    # barrage("/Users/user/desktop/test.png", 'test')
    def barrage(input, output_name, gif = false, speed = 84)
      prepare(input)
      compress(input)
      counter = 1
      SETTINGS.each do |key, setting_hash|
        brute_sort_save_with_settings(input, setting_hash, (output_name + "_#{key}"), gif, true)
        puts "Image #{counter}/#{SETTINGS.length} Complete."
        counter += 1
      end
      gif(output_name, speed) unless !gif
    end

    ##
    # creates a uri by adding the name to common paths and appending .png
    # example: test = uri_helper('desktop', 'test')
    def self.uri_helper(location, file_name)
      if location == 'desktop'
        "/Users/#{ENV['USER']}/desktop/" + file_name + '.png'
      elsif location == 'downloads'
        "/Users/#{ENV['USER']}/downloads/" + file_name + '.png'
      end
    end

    private

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
    # creates an instance variable with the image path, used when a glitch sequence is created but the original image is not need in said sequence
    # example: image_path => @image_path = '/Users/user/desktop/output/test/test.png'
    # can only be run after the name_parser and parent_path
    def image_path
      "#{@parent_path}output/#{@input_name}/#{@input_name}.png"
    end

    ##
    # creates directory using @sequence_folder for the output for either the glitch_sequence or barrage methods
    def make_dir?
      FileUtils.mkdir_p(@sequence_folder) unless Dir.exists?(@sequence_folder)
    end

    def path_choser(counter, compress, input)
      if compress
        if counter > 1
          @path = @image_path
        else
          @path = @sequence_frame_path
        end
      else
        @path = input
        FileUtils.copy(input, @sequence_frame_path)
      end
    end

    def prepare(input)
      make_dir?
    end

    ##
    # still being used but partially deprecated
    def output(base_uri, input_name, output_name, options, gif, output_folder)
      base_uri = base_uri + 'output/'
      if gif
      else
        Dir.mkdir(base_uri) unless Dir.exists?(base_uri)
      end

      if output_name.nil?
        rando = '_' + (0...4).map{65.+(rand(26)).chr}.join.downcase
        settings_file = File.new(base_uri + input_name + rando + '.txt', "w")
        settings_file.puts(options.to_s)
        settings_file.close
        return base_uri +  input_name + rando + '.png'


      elsif gif || output_folder
        @base_uri = base_uri + "#{input_name}/"
        # FileUtils.mkdir_p(@base_uri) unless Dir.exists?(@base_uri)
        settings_file = File.new(@sequence_folder + output_name + '.txt', "w")
        settings_file.puts(options.to_s)
        settings_file.close
        return @sequence_folder + output_name + '.png'


      elsif !gif && !output_folder
        settings_file = File.new(base_uri + output_name + '.txt', "w")
        settings_file.puts(options.to_s)
        settings_file.close
        return base_uri + output_name + '.png'


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
        return output(base_uri, input_name, nil, options, gif, output_folder)
      else
        return output(base_uri, input_name,  output_name, options, gif, output_folder)
      end
    end

    ##
    # creates a gif using the @sequence_folder path and outputs gif into the @output_folder path
    # an output_name(string) and a speed(integer) must be passed
    # speed is used to set the length of time for each frame of the gif, it defaults to milliseconds
    #   - 12 fps: length of frame = 84 ms
    #   - 24 fps: length of frame = 42 ms
    #   - 30 fps: length of frame = 33 ms
    #   - 60 fps: length of frame = 17 ms
    # example: gif(test, 84) => creates a gif at 12fps
    # at the moment, must be used with the glitch_sequence and barrage methods
    #
    def gif(output_name, speed)
      animation = ImageList.new(*Dir["#{@sequence_folder}*.png"].sort_by { |x| x[/\d+/].to_i })
      animation.ticks_per_second=1000
      puts 'got images'
      animation.delay = speed
      puts 'creating gif'
      animation.write("#{@output_folder}#{output_name}.gif")
      puts 'COMPLETE'
    end

    ##
    # has only been tested not used
    def convert(img)
      image = ImageList.new(img)
      image.write("#{@parent_path}#{@input_name}.png") { self.quality = 10 }
      data = File.open("#{@parent_path}#{@input_name}.png", 'rb').read(9)
      File.write(f = "#{@parent_path}#{@input_name}.png", File.read(f).gsub(/#{data}/,"\x89PNG\r\n\x1A\n"))
    end

    ##
    # copies and compresses file passed
    # at the moment can only be used with the glitch_sequence and barrage methods
    def compress(img, counter = 1)
      puts 'Compressing image.'
      image_optim = ImageOptim.new(allow_lossy: true, verbose: false, skip_missing_workers: true, optipng: false,
                                   pngcrush: false, pngquant: {allow_lossy: true}, advpng: false, pngout: false, svgo: false)
      File.rename(image_optim.optimize_image(img), @path)
      puts 'Image copied and compressed.'
    end
  end
end