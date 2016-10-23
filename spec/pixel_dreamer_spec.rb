require 'spec_helper'

describe PixelDreamer do
  let(:image) { PixelDreamer::Image.new }
  let(:uri) { '/Users/user/desktop/test.png' }
  let(:name) { image.send(:name_parser,uri) }
  it 'has a version number' do
    expect(PixelDreamer::VERSION).not_to be nil
  end

  describe :name_parser do
    it 'extracts the filename without its extension ' do
      expect(name).to eq('test')
    end
  end
end
