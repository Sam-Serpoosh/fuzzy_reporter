require 'digest'

class Event
  attr_reader :id

  def initialize
    @id = Digest::MD5.hexdigest self.object_id.to_s
    @done = false
    Storage::DB.save_start_event self
  end

  def finish
    @done = true
    Storage::DB.save_end_event self
  end

  def done?
    @done
  end

  def to_s
    "#{@id}-#{done?}"
  end
end

class Reconciler
  def unfinished_events(start_events, end_events)
    start_events.reject do |start_event|
      end_events.any? { |event| start_event.id == event.id }
    end
  end
end

module Storage
  class DB
    def self.find_event id
      @@start_events.find { |event| event.id == id }
    end

    def self.start_events
      @@start_events
    end

    def self.end_events
      @@end_events
    end

    def self.save_start_event event
      @@start_events ||= []
      @@start_events << event
    end

    def self.save_end_event event
      @@end_events ||= []
      @@end_events << event
    end

    def self.clear_data
      @@start_events ||= []
      @@end_events ||= []
      @@start_events.clear 
      @@end_events.clear 
    end
  end
end

class Reporter
  def initialize(reconciler = Reconciler.new)
    @reconciler = reconciler
  end

  def report_unfinished_events
    start_events = Storage::DB.start_events
    end_events= Storage::DB.end_events
    @reconciler.unfinished_events start_events, end_events
  end
end