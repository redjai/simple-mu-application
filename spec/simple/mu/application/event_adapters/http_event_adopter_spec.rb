require 'simple/mu/application/event_adapters/http'
require 'support/events/http'

RSpec.describe Simple::Mu::Application::EventAdapters::Http do

  let(:post_data){ { text: 'hello world', payload: { foo: 'foo', bar: 'bar' } } }
  let(:event){ MockHttpEvent.event(post_data) }
  let(:path){ event['requestContext']['path'] }
  let(:method){ event['requestContext']['httpMethod'] }
  let(:to_s){ "http::#{event['requestContext']['requestId']}" }

  subject{ described_class.new(event) }

  it 'should extract the path from the event - /dev/hello' do
    expect(subject.path).to eq path 
  end

  it 'should return POST' do
    expect(subject.method).to eq method
  end

  it 'should return the event payload' do
    expect(subject.event).to eq post_data 
  end

  it 'should return false' do
    expect(subject.delete?).to be false
  end

  it 'should return the to_s in the form http::{requestId}' do
    expect(subject.to_s).to eq to_s
  end
end
