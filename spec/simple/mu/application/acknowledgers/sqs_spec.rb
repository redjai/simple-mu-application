require 'simple/mu/application/acknowledgers/sqs'
require 'simple/mu/application/event_adapters/sqs'
require 'support/events/event'

RSpec.describe Simple::Mu::Application::Acknowledgers::Sqs do

  let(:sqs_event){ MockEvent.event(sqs: [{ foo: 'foo'}, {bar: 'bar'}]) }
  let(:records){ sqs_event['Records'] }
  let(:record1){ Simple::Mu::Application::EventAdapters::SqsRecord.new(records.first) }
  let(:record2){ Simple::Mu::Application::EventAdapters::SqsRecord.new(records.last) }
 
  let(:processed){ [record1, record2] }
  let(:ack_1){ { id: record1.message_id, receipt_handle: record1.receipt_handle} } 
  let(:ack_2){ { id: record2.message_id, receipt_handle: record2.receipt_handle} } 

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

  context 'by_queue' do

    it 'should group the adapters by queue' do
      expect(subject.by_queue(processed: processed)).to eq({record1.queue_name => [record1], record2.queue_name => [record2]})
    end

  end

  context 'queue' do
   
    let(:queue_1){ double("Queue") }
    let(:queue_name_1){ processed.first.queue_name }
    let(:queue_2){ double("Queue") }
    let(:queue_name_2){ processed.last.queue_name }
    
    before(:each) do
      allow(subject.resource).to receive(:get_queue_by_name).with(queue_name: queue_name_1).and_return(queue_1)
      allow(subject.resource).to receive(:get_queue_by_name).with(queue_name: queue_name_2).and_return(queue_2)
    end

    it 'should return a queue' do
      expect(subject.queue(queue_name_1)).to eq queue_1
      expect(subject.queue(queue_name_2)).to eq queue_2
    end
    
    it 'should only call get_queue_by_name once per queue' do
      expect(subject.resource).to receive(:get_queue_by_name).with(queue_name: queue_name_1).once.and_return(queue_1)
      subject.queue(queue_name_1)
      subject.queue(queue_name_1)
    end
    
    it 'should call delete_message' do
      expect(queue_1).to receive(:delete_messages).with(entries: [ack_1])
      expect(queue_2).to receive(:delete_messages).with(entries: [ack_2])
      subject.acknowledge(processed: processed)
    end

  end
end
