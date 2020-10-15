require 'simple/mu/application/event_adapters/adapter'
require 'simple/mu/application/event_adapters/http'
require 'simple/mu/application/event_adapters/s3'
require 'simple/mu/application/event_adapters/sqs'
require 'support/events/http'
require 'support/events/s3'
require 'support/events/sns'
require 'support/events/sqs'

RSpec.describe Simple::Mu::Application::EventAdapters::Adapter do

  let(:record){ event['Records'].first } 
  let(:context){ {} }
  let(:trigger_event){ { event_name: 'some.event', version: 1, payload: { foo: 'foo', bar: 'bar' }} }

  context 'sns event' do

    let(:aws_event){ MockSnsEvent.event(trigger_event) }
   
    subject{ described_class.events(aws_event: aws_event, context: context).first }
    
    it 'should populate the event with the payload' do
      expect(subject.event).to eq trigger_event
    end
  end
  
  context 'sqs event' do

    let(:aws_event){ MockSqsEvent.event(trigger_event) }
   
    subject{ described_class.events(aws_event: aws_event, context: context).first }
    
    it 'should populate the event with the payload' do
      expect(subject.event).to eq trigger_event
    end
  end

  context 's3 event' do

    let(:aws_event){ MockS3Event.event(bucket, key) }
    let(:payload){ { key: key, bucket: bucket } } # this isn't a 'topic' from sns or sqs
    let(:key){ '/some/key/to.json' }
    let(:bucket){ 'some-bucket' }

    subject{ described_class.events(aws_event: aws_event, context: context).first }
    
    it 'should populate the event with the payload' do
      expect(subject.payload).to eq payload
    end
  end

  # we can't use a trigger event here as this event is generated outside our code by AWS
  context 'http event' do

    let(:message){ { foo: 'foo', bar: 'bar' } } #http events  won't have any of our typical event parameters in the message
    let(:aws_event){ MockHttpEvent.event(message) }
   
    subject{ described_class.events(aws_event: aws_event, context: context).first }
    
    it 'should populate the event with the payload' do
      expect(subject).to eq message 
    end
  end
end
