require 'simple/mu/application/event_adapters/sqs'
require 'support/events/sqs'

RSpec.describe Simple::Mu::Application::EventAdapters::SqsRecord do

  let(:post_data){ { text: 'hello world', payload: { foo: 'foo', bar: 'bar' } } }
  let(:sqs_event){ MockSqsEvent.event(post_data) }
  let(:record){ sqs_event['Records'].first }

  subject{ described_class.new(record) }

  it 'should return the payload with keys as symbols' do
    expect(subject.payload).to eq post_data
  end

end
