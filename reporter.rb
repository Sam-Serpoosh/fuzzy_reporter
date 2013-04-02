class Detector
  def unfinished_events(start_events, end_events)
    start_events.reject do |start_event|
      end_events.any? { |event| start_event.id == event.id }
    end
  end
end

describe Detector do
  let(:detector) { Detector.new }

  describe "no events at all" do
    it "returns an empty collection" do
      detector.unfinished_events([], []).should == []
    end
  end

  describe "all events are finished" do
    it "returns empty collection when all ids match" do
      event1 = stub(id: 1)
      event2 = stub(id: 2)
      start_events = [event1, event2]
      end_events = [event1, event2]

      detector.unfinished_events(start_events, end_events).should == []
    end
  end

  describe "some events are not finished" do
    it "returns unfinished events" do
      event1 = stub(id: 1)
      event2 = stub(id: 2)
      start_events = [event1, event2]
      end_events = [event1, stub(id: 3)]

      detector.unfinished_events(start_events, end_events).should == [event2]
    end
  end
end