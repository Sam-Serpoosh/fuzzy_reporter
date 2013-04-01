class Detector
  def unfinished_events(start_events, end_events)
    [] 
  end
end

describe Detector do
  let(:detector) { Detector.new }

  describe "no events at all" do
    it "returns an empty collection" do
      detector.unfinished_events([], []).should == []
    end
  end
end