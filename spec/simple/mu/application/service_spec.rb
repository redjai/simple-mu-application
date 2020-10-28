require 'support/events/event'
require 'support/events/http'
require 'simple/mu/application/service'

RSpec.describe Simple::Mu::Application::Service do
 
  let(:payload1){ { foo: 1 } }
  let(:payload2){ { foo: 2 } }
  let(:payload3){ { foo: 3 } }
  let(:payload4){ { foo: 4 } }
  let(:context){ {} }
  let(:aws_event){ MockEvent.event(sqs: [payload1, payload4], sns: [payload3], s3: [payload2]) }
  let(:error_message){ "events #{[payload1,payload2,payload3,payload4].map(&:to_s).join(",")}" }

  subject{ described_class.new(event: aws_event, context: context) } 
   
  context 'yield' do

    context 'http event' do

      let(:aws_event){ MockHttpEvent.event(payload1) }

      it 'should yield the single http adapter' do
        expect{ |b| subject.handle(&b) }.to yield_with_args(subject, Simple::Mu::Application::EventAdapters::Http)
      end

    end

    context 'one event with s3, sqs, sns records' do
    
      it 'should yield the service (self) and the record adapters' do
        expect{ |b| subject.handle(&b) }.to yield_successive_args([subject, Simple::Mu::Application::EventAdapters::SqsRecord],
                                                                                                      [subject, Simple::Mu::Application::EventAdapters::SqsRecord],
                                                                                                      [subject, Simple::Mu::Application::EventAdapters::SnsRecord],
                                                                                                      [subject, Simple::Mu::Application::EventAdapters::S3Record])
      end

    end 



  end

  context 'errors' do

    context 'notifier' do
      it 'should notify the notifier of any errors and raise the error on each of the 4 reecords in the aws_event' do
        expect(subject.notifier).to receive(:notify).with(StandardError).exactly(4).times
          expect {
            subject.handle do
              raise "boom"
            end
          }.to raise_error(Simple::Mu::Application::ServiceError)
      end
    end

    context 'acknowledger' do

      it 'should acknowledge the sqs messages that do not error and return an error' do
        expect(subject.acknowledger).to receive(:acknowledge).with(processed: [Simple::Mu::Application::EventAdapters::SqsRecord]).once
        expect {
           subject.handle do |service, adapter|
             raise if adapter.event == payload1
           end
        }.to raise_error(Simple::Mu::Application::ServiceError)
      end
    end
  end

  context 'no errors' do

    it 'should NOT use the acknowledger to acknowledge processed messages - let AWS do that naturally' do
      expect(subject.acknowledger).to receive(:acknowledge).never
      subject.handle {|service, adapter|} #empty block
    end

  end

  context 'response' do

    let(:aws_event){ MockHttpEvent.event(payload1) }

    it 'should return the value passed to respond' do
      expect(subject.handle do |service, adapter|
        service.respond 'foo-bar'
      end).to eq 'foo-bar'
    end
    
    it 'should return nil' do
      expect(subject.handle do |service, adapter|
        'foo-bar'
      end).to be_nil 
    end
  end

end
