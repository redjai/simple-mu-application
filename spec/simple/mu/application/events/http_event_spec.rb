require 'spec_helper'
require 'simple/mu/application/events/http'
require 'support/events/http'

RSpec.describe Simple::Mu::Application::Events::HttpEventAdapter do

  let(:post_data){ {text: 'hello world', payload: {foo: 'foo', bar: 'bar' } } }
  let(:event){ MockHttpEvent.event(post_data) }
  let(:path){ event['requestContext']['path'] }
  let(:method){ event['requestContext']['httpMethod'] }

  subject{ described_class.new(event) }

  it 'should extract the path from the event - /dev/hello' do
    expect(subject.path).to eq path 
  end

  it 'should return POST' do
    expect(subject.method).to eq method
  end

  it 'should return the event payload' do
    expect(subject.payload).to eq post_data 
  end

end
