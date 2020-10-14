require 'spec_helper'
require 'simple/mu/application/topics/message'

RSpec.describe Simple::Mu::Application::Topics::Message do

  let(:event_name){ :test_message }
  let(:version){ 1.1 }
  let(:payload){ { foo: 1, bar: 2 } }
  let(:message){ { event_name: event_name, version: version, payload: payload }}

  let(:klazz) { Class.new { include Simple::Mu::Application::Topics::Message } }

  subject{ klazz.new }

  it 'should convert the argumnets into a message hash' do
    expect(subject.message(event_name: event_name, version: version, payload: payload)).to eq message
  end
  
  it 'should convert the  message to json' do
    expect(subject.message_json(event_name: event_name, version: version, payload: payload)).to eq message.to_json
  end
end
