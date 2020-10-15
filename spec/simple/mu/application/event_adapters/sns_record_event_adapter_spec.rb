require 'simple/mu/application/event_adapters/sns'
require 'support/events/sns'

RSpec.describe Simple::Mu::Application::EventAdapters::SnsRecord do

  let(:post_data){ { text: 'hello world', payload: { foo: 'foo', bar: 'bar' } } }
  let(:sns_event){ MockSnsEvent.event(post_data) }
  let(:record){ sns_event['Records'].first }

  subject{ described_class.new(record) }

  it 'should return the payload with keys as symbols' do
    expect(subject.event).to eq post_data
  end

end
