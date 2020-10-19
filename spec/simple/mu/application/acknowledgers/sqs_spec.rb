require 'simple/mu/application/acknowledgers/sqs'
require 'simple/mu/application/event_adapters/sqs'
require 'support/events/sqs'

RSpec.describe Simple::Mu::Application::Acknowledgers::Sqs do

  let(:sqs_event_1){ Simple::Mu::Application::EventAdapters::SqsRecord.new(MockSqsEvent.event({})['Records'].first) }
  let(:sqs_event_2){ Simple::Mu::Application::EventAdapters::SqsRecord.new(MockSqsEvent.event({})['Records'].first) }
  let(:processed){ [sqs_event_1, sqs_event_2] }
  let(:ack_1){ { id: sqs_event_1.message_id, receipt_handle: sqs_event_1.receipt_handle} } 
  let(:ack_2){ { id: sqs_event_2.message_id, receipt_handle: sqs_event_2.receipt_handle} } 

  around do |example|
    ClimateControl.modify REGION: 'eu-east-1' do
      example.run
    end
  end

  it 'should return an instance of SQS Resource' do
    expect(subject.resource).to be_a Aws::SQS::Resource
  end 

  it 'should only return sqs adapters' do
    expect(subject.entries(processed: processed)).to eq [ack_1, ack_2]
  end

  context 'queue' do
   
    let(:queue){ double("Queue") }
    let(:queue_name){ 'foo' }
    
    before(:each) do
      allow(subject.resource).to receive(:get_queue_by_name).with(queue_name: queue_name).and_return(queue)
    end

    it 'should return a queue' do
      expect(subject.queue(queue_name)).to eq queue
    end
    
    it 'should call delete_message' do
      expect(queue).to receive(:delete_messages).with(entries: [ack_1, ack_2])
      subject.acknowledge(queue_name: queue_name, processed: processed)
    end

  end

end
