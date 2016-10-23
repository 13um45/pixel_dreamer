require 'spec_helper'

describe PixelDreamer do
  let(:uri) { "/Users/#{ENV['USER']}/desktop/test.png" }
  let(:parent_path) { "/Users/#{ENV['USER']}/desktop/" }
  let(:image) { PixelDreamer::Image.new(uri) }
  let(:mock_image) { PixelDreamer::Image.new("../support/test.png") }
  let(:counter) { 1 }
  let(:counter_2) { 2 }

  it 'has a version number' do
    expect(PixelDreamer::VERSION).not_to be nil
  end

  describe :uri_helper do
    it 'returns a full path of a png file on the desktop' do
      expect(image.uri_helper('desktop', 'test')).to eq(uri)
    end

    it 'returns a full path of a png file in the downloads' do
      expect(image.uri_helper('downloads', 'test')).to eq("/Users/#{ENV['USER']}/downloads/test.png")
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
      expect(File).to be_directory("../support/output/test/sequence/")
    end
  end

  describe :path_choser do
    it 'returns the sequence_frame_path if compress is true and counter is less than 1' do
      expect(image.send(:path_choser, counter, true, 'test')).to eq("#{parent_path}output/test/sequence/test.png")
    end

    it 'returns the image_path if compress is true and counter is more than 1' do
      expect(image.send(:path_choser, counter_2, true, 'test')).to eq("#{parent_path}output/test/test.png")
    end

    # it 'returns the input if compress is true and counter is more than 1' do
    #   expect(image.send(:path_choser, counter_2, false, 'test')).to eq("uri")
    # end
  end
end
