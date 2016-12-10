require 'spec_helper'

describe PixelDreamer do
  after :all do
    FileUtils.remove_dir('support/output')
  end
  let(:uri) { "/Users/#{ENV['USER']}/desktop/test.png" }
  let(:parent_path) { "/Users/#{ENV['USER']}/desktop/" }
  let(:image) { PixelDreamer::Image.new(uri) }
  let(:mock_image) { PixelDreamer::Image.new('support/test.png') }
  let(:counter) { 1 }
  let(:counter_2) { 2 }
  let(:output_name) { 'test_output' }
  let(:options) { PixelDreamer::Constants::SETTINGS[:sharp] }
  let(:base_uri) { 'support/' }

  it 'has a version number' do
    expect(PixelDreamer::VERSION).not_to be nil
  end

  describe :uri_helper do
    it 'returns a full path of a png file on the desktop' do
      expect(PixelDreamer::Image.uri_helper('desktop', 'test')).to eq(uri)
    end

    it 'returns a full path of a png file in the downloads' do
      expect(PixelDreamer::Image.uri_helper('downloads', 'test')).to eq("/Users/#{ENV['USER']}/downloads/test.png")
    end
  end

  describe :name_parser do
    it 'extracts the filename without its extension' do
      expect(image.send(:name_parser, uri)).to eq('test')
    end
  end

  describe :parent_path do
    it 'returns the parent directory of the input uri' do
      expect(image.send(:parent_path, uri)).to eq(parent_path)
    end
  end

  describe :output_folder do
    it 'returns the output directory' do
      expect(image.send(:output_folder)).to eq("#{parent_path}output/test/")
    end
  end

  describe :sequence_folder do
    it 'returns the output sequence directory' do
      expect(image.send(:sequence_folder)).to eq("#{parent_path}output/test/sequence/")
    end
  end

  describe :sequence_frame_path do
    it 'returns the output sequence frame path' do
      expect(image.send(:sequence_frame_path)).to eq("#{parent_path}output/test/sequence/test.png")
    end
  end

  describe :image_path do
    it 'returns the output sequence frame path' do
      expect(image.send(:image_path)).to eq("#{parent_path}output/test/test.png")
    end
  end

  describe :make_dir? do
    it 'creates the sequence folder director if it does not exist' do
      mock_image.send(:make_dir?)
      expect(File).to be_directory("support/output/test/sequence/")
    end
  end

  describe :path_choser do
    it 'returns the sequence_frame_path if compress is true and counter is less than 1' do
      expect(image.send(:path_selector, counter, true, 'test')).to eq("#{parent_path}output/test/sequence/test.png")
    end

    it 'returns the image_path if compress is true and counter is more than 1' do
      expect(image.send(:path_selector, counter_2, true, 'test')).to eq("#{parent_path}output/test/test.png")
    end

    it 'returns and copies the input if compress is true and counter is more than 1' do
      test = PixelDreamer::Image.new('support/test.png')
      test.send(:path_selector, counter_2, false, 'support/test.png')
      expect(File).to exist('support/output/test/sequence/test.png')
    end
  end

  describe :make_dir? do
    it 'creates a sequence folder if one does not exist' do
      test = PixelDreamer::Image.new('support/test.png')
      test.send(:make_dir?)
      expect(File.directory?('support/output/test/sequence/')).to be true
    end
  end

  describe :output do
    let(:input_name) { 'test' }
    let(:sequence_folder) { 'support/output/test/sequence/' }
    let(:test) { PixelDreamer::Image.new('support/test.png') }
    subject(:output_gif) { test.send(:output, base_uri, input_name, output_name, options, true, false) }
    subject(:output) { test.send(:output, base_uri, input_name, output_name, options, false, false) }
    subject(:output_name_nil) { test.send(:output, base_uri, input_name, nil, options, false, false) }

    context 'when gif is true and output_folder is false' do
      it 'returns output path of the image in a sequence folder' do
        expect(output_gif).to eq(sequence_folder + output_name + '.png')
      end

      it 'creates a text file with settings in a sequence folder' do
        output_gif
        expect(File).to exist(sequence_folder + output_name + '.txt')
      end
    end

    context 'when both gif and output_folder are false' do
      it 'returns output path of the image the output folder' do
        expect(output).to eq(base_uri + 'output/' + output_name + '.png')
      end

      it 'creates a text file with settings the output folder' do
        output
        expect(File).to exist(base_uri + 'output/' + output_name + '.txt')
      end
    end

    context 'when the output_name is nil' do
      it 'returns output path of the image with a random string appended to the name' do
        expect(output_name_nil).to match(/^support\/output\/test_.+.png$/)
      end
    end
  end

  describe :file_name_with_settings do
    before do
      FileUtils.mkdir_p('support/output/test/sequence/')
    end
    let(:input_uri) { 'support/test.png' }
    let(:test) { PixelDreamer::Image.new(input_uri) }
    subject(:output_with_name) { test.send(:file_name_with_settings, input_uri, options, output_name, false, false ) }
    subject(:output_name_nil) { test.send(:file_name_with_settings, input_uri, options, nil, false, false ) }

    context 'when output_name exist' do
      it 'should return the output of the image' do
        expect(output_with_name).to eq(base_uri + 'output/' + output_name + '.png')
      end
    end

    context 'when output_name is nil' do
      it 'should return the output of the image' do
        expect(output_name_nil).to match(/^support\/output\/test_.+.png$/)
      end
    end
  end

  describe :gif do
    before do
      FileUtils.mkdir_p('support/output/test/sequence/')
      FileUtils.copy('support/test.png', 'support/output/test/sequence/test_1.png')
      FileUtils.copy('support/test.png', 'support/output/test/sequence/test_2.png')
    end

    it 'should create a gif' do
      mock_image.gif({output_name: output_name})
      expect(File).to exist('support/output/test/test_output.gif')
    end
  end

  describe :compress do
    before do
      FileUtils.mkdir_p('support/output/test/sequence/')
    end

    it 'should compress and copy an image' do
      mock_image.compress('support/test.png', 'support/output/test/sequence/comp_test.png')
      expect(File).to exist('support/output/test/sequence/comp_test.png')
    end
  end

  describe :brute_sort_save_with_settings do
    context 'with output_name' do
      it 'should create a new glitched named with the output_name' do
        mock_image.brute_sort_save_with_settings({ output_name: 'test_bssws' })
        expect(File).to exist('support/output/test_bssws.png')
      end
    end

    context 'with output_folder' do
      it 'should create a new file in the output folder' do
        mock_image.brute_sort_save_with_settings({ output_folder: true, output_name: 'test_bssws' })
        expect(File).to exist('support/output/test/sequence/test_bssws.png')
      end
    end
  end

  describe :glitch_sequence do
    # need to test every setting??
    it 'creates a sequence of glitched images' do
      # need to figure out how to test how many files are in a folder
      mock_image.glitch_sequence
      expect(File).to exist('support/output/test/sequence/test_30.png')
    end
  end

  describe :barrage  do
    it 'creates multiple images from teh sequence_setting hash' do
      mock_image.barrage
      expect(File).to exist('support/output/test/sequence/test_soft.png')
    end
  end
end
