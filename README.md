# PixelDreamer

## Installation

Install RMagick and ImageMagick from here: [RMagick](https://github.com/rmagick/rmagick)

Add this line to your application's Gemfile:

```ruby
gem 'pixel_dreamer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pixel_dreamer

## Usage

### ImageDreamer

To use pixel dreamer you must first create a new `PixelDreamer::ImageDreamer` instance
to do this you must pass in the uri of the image you will be pixel sorting:
 ```ruby
 image = PixelDreamer::ImageDreamer.new('/uri/image.png')
 ```
 
you can also pass in an image to be laid on top of the image that is pixel sorted,
overlay image is optional:


 ```ruby
 image = PixelDreamer::ImageDreamer.new('/uri/image.png', 'overlay/image.png')
 ```
 #### brute_sort_save_with_settings
 
pixel sorts an image and outputs a text file with settings used.
once the image has been instantiated you can run this method without passing in any parameters.
by default it runs with these paramaters:
`{ settings: DEFAULTS, output_name: nil, gif: false, output_folder: false }`

```ruby
image.brute_sort_save_with_settings
```

or with these parameters

```ruby
image.brute_sort_save_with_settings(settings: PixelDreamer::Constants::DEFAULTS, output_name: nil, 
                                    gif: false, output_folder: false)
```

or

```ruby
image.brute_sort_save_with_settings(settings: { reverse: false, vertical: false, diagonal: false,
                                                 smooth: false, method: 'sum-rgb', verbose: false,
                                                 min: Float::INFINITY, max: Float::INFINITY,
                                                 trusted: false, middle: false })
```

also read the documentation for [pxlsrt](https://github.com/czycha/pxlsrt) to get an idea of what these parameters do
 
 
 #### glitch_sequence
 

creates a sequence of pixel sorted images based on the setting hash and a sequence_setting hash chosen.
once the image has been instantiated you can run this method without passing in any parameters
by default it is executed with these settings:

`settings: SETTINGS[:soft], sequence_settings: SEQUENCE_SETTINGS[:high_short], compress: true, speed: 84 `

example: 

```ruby
image.glitch_sequence
```

or with parameters, an output name can be passed in as well (string)

```ruby
image.glitch_sequence({ settings: PixelDreamer::Constants::SETTINGS[:sharp], 
                        sequence_settings: PixelDreamer::Constants::SEQUENCE_SETTINGS[:high_long],
                        compress: false, speed: 42, output_name: 'image_glitched' })
```

the output name must only include the name of the output image not the file extension.
this creates a sequence of of images that have been pixel sorted with the increments specified.
the settings_hash can be pulled from the `SETTINGS` constant, defaults to `SETTINGS[:soft]`.
the sequence_settings can be pulled from the `SEQUENCE_SETTINGS` constant, defaults to `SEQUENCE_SETTINGS[:high_short]`.
compress defaults to true, copies and compresses input file and creates sequence from compressed file
the fps is set by the speed which is in milliseconds, defaults to 84ms (12fps)
the uri_helper method can be used to create the input uri

#### barrage

creates an image for each setting from the settings hash. quickest way to see how all of the settings effect the image supplied.
once the image has been instantiated you can run this method without passing in any parameters
by default it is executed with these settings:
`gif: false, compress: true, speed: 84`

```ruby
image.barrage
```

or with parameters, an output name (string) can be passed in as well

```ruby
image.barrage({ gif: true, compress: false, speed: 42, output_name: 'image_glitched' })
```

the output name must only include the name of the output image not the file extension
the uri_helper can be used to create the input uri

#### randomize

creates a series of images that are pixel sorted with randomized settings, the output is very hectic.
once the image has been instantiated you can run this method without passing in any parameters
by default it is executed with these settings:
`gif: false, compress: true, speed: 84, image_number: 10`

```ruby
image.randomize
```

or with parameters, an output name (string) can be passed in as well

```ruby
image.randomize({ gif: trues, compress: false, speed: 42, image_number: 20, output_name: 'image_glitched' })
```

the output name must only include the name of the output image not the file extension
the amount of images that are created are based on the image_number (integer)

#### gif

creates a gif using the images created from using either the randomize, glitch_sequence or barrage methods.
once the image has been instantiated you can run this method without passing in any parameters
by default it is executed with these settings:
`speed: 84, dither: DITHER_DEFAULTS, image_delay: IMAGE_DELAY_DEFAULTS`

```ruby
image.gif
```

or with parameters, an output name (string) can be passed in as well

```ruby
image.gif({speed: 42, dither: PixelDreamer::Constants::DITHER_DEFAULTS, 
           image_delay: PixelDreamer::Constants::IMAGE_DELAY_DEFAULTS, output_name: 'image_gif'})
```
or

```ruby
image.gif({speed: 42, dither: {active: false, number_of_colors: 200},
                image_delay: {active: false, image_to_delay: 1, delay_length: 1000}, output_name: 'image_gif'})
```

speed is used to set the length of time for each frame of the gif, it defaults to milliseconds
   - 12 fps: length of frame = 84 ms
   - 24 fps: length of frame = 42 ms
   - 30 fps: length of frame = 33 ms
   - 60 fps: length of frame = 17 ms
the dither hash used to set the dither settings
the image_delay hash is used to pause the sequence on an image for a set amount of time
the patrol boolean is used to have the animation reverse at the end of it's cycle 

#### uri_helper

creates a uri by adding the name to common paths

```ruby
test = uri_helper('desktop', 'test.png')
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/13um45/pixel_dreamer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

