require 'simple/mu/application/event_adapters/sqs'
require 'support/events/event'

RSpec.describe Simple::Mu::Application::EventAdapters::SqsRecord do

  let(:post_data){ { text: 'hello world', payload: { foo: 'foo', bar: 'bar' } } }
  let(:sqs_event){ MockEvent.event(sqs: post_data) }
  let(:record){ sqs_event['Records'].first }
  let(:queue_name){ 'my-queue-0' } #taken from event ARN
  let(:to_s){ "sqs::#{record['messageId']}" }

  subject{ described_class.new(record) }

  it 'should return the payload with keys as symbols' do
    expect(subject.event).to eq post_data
  end

  it 'should return the to_s in the form of sqs::{messageId}' do
    expect(subject.to_s).to eq to_s
  end

  it 'should return the sqs queue name taken from the arn' do
    expect(subject.queue_name).to eq queue_name
  end

  it 'should return the message_id' do
    expect(subject.message_id).to eq record['messageId']
  end
  
  it 'should return the receipt_handle' do
    expect(subject.receipt_handle).to eq record['receiptHandle']
  end

  context 'delete?' do
    
    it 'should return true if DELETE_EVENT ENV is TRUE' do
      ClimateControl.modify DELETE_EVENT: 'TRUE' do
        expect(subject.delete?).to be true
      end    
    end

    it 'should return false DELETE_EVENT ENV is not TRUE' do
      ClimateControl.modify DELETE_EVENT: 'FALSE' do
        expect(subject.delete?).to be false
      end    
    end
    
    it 'should return false' do
      expect(subject.delete?).to be false
    end

  end
end
