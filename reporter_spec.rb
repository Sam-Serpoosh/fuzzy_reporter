require_relative "./reporter"

describe Event do
  after do
    Storage::DB.clear_data
  end

  it "has a unique id" do
    events = []
    50.times do
      events << Event.new
    end
    events_ids = events.map(&:id).uniq
    events_ids.count.should == events.count
  end

  it "is not done at creation" do
    Event.new.should_not be_done
  end

  it "can be finished" do
    event = Event.new
    event.finish
    event.should be_done
  end

  it "gets stored as start event at creation" do
    Storage::DB.should_receive(:save_start_event)
    event = Event.new
  end

  it "gets stored as end event at finish" do
    Storage::DB.should_receive(:save_end_event)
    event = Event.new

    event.finish
  end
end

describe Reconciler do
  let(:detector) { Reconciler.new }

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

describe Storage::DB do
  after do
    Storage::DB.clear_data
  end

  it "stores start events" do
    event = stub(id: 1)
    Storage::DB.save_start_event event
    Storage::DB.start_events.should == [event]
  end

  it "stores end events" do
    event = stub(id: 2)
    Storage::DB.save_end_event event
    Storage::DB.end_events.should == [event]
  end

  it "fetches event by id" do
    event = stub(id: 1) 
    Storage::DB.save_start_event event
    Storage::DB.find_event(1).should == event
  end
end

describe Reporter do
  it "feeds Reconciler with start events and end events" do
    start_events = [stub(id: 1), stub(id: 2)]
    end_events = [stub(id: 1)]
    Storage::DB.should_receive(:start_events) { start_events }
    Storage::DB.should_receive(:end_events) { end_events }
    reconciler = stub
    reconciler.should_receive(:unfinished_events).
      with(start_events, end_events)

    reporter = Reporter.new(reconciler)
    reporter.report_unfinished_events
  end
end
