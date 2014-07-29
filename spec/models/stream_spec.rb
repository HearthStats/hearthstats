require 'spec_helper'

describe Stream do
  describe '#get_streamer_with_status' do
    it 'should get proper streamer status' do
      Stream.get_streamer_with_status('trigun0x2').status.should == "Offline"
    end
  end
end
