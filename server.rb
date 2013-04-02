require 'sinatra'
require 'json'
require_relative './reporter'

events = []
5.times do 
  events << Event.new
end

reporter = Reporter.new Reconciler.new

get '/events' do
  JSON.dump events
end

get '/unfinished_events' do
  JSON.dump reporter.report_unfinished_events
end

get '/finish' do
  event = Storage::DB.find_event params[:id]
  event.finish
  "Finished the Event!"
end