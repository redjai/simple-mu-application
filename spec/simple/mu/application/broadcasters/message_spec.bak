require 'spec_helper'
require 'simple/mu/application/topics/event'

RSpec.describe Simple::Mu::Application::Topics::Event do

  let(:event_name){ :test_message }
  let(:version){ 1.1 }
  let(:payload){ { foo: 1, bar: 2 } }
  let(:message){ { event_name: event_name, version: version, payload: payload }}

  let(:klazz) { Class.new { include Simple::Mu::Application::Topics::Event } }

  subject{ klazz.new }

  it 'should convert the argumnets into a message hash' do
    expect(subject.event(event_name: event_name, version: version, payload: payload)).to eq message
  end
  
  it 'should convert the  message to json' do
    expect(subject.event_json(event_name: event_name, version: version, payload: payload)).to eq message.to_json
  end
end
