require 'support/events/event'
require 'support/events/http'
require 'simple/mu/application/framework'

RSpec.describe Simple::Mu::Application::Framework do
 
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
        expect{ |b| subject.handle(event: aws_event, context: context, &b) }.to yield_with_args(Simple::Mu::Application::EventAdapters::Http)
      end

    end

    context 'one event with s3, sqs, sns records' do
    
      it 'should yield the record adapters' do
        expect{ |b| subject.handle(event: aws_event, context: context, &b) }.to yield_successive_args(Simple::Mu::Application::EventAdapters::SqsRecord,
                                                                                                      Simple::Mu::Application::EventAdapters::SqsRecord,
                                                                                                      Simple::Mu::Application::EventAdapters::SnsRecord,
                                                                                                      Simple::Mu::Application::EventAdapters::S3Record)
      end

    end 



  end

  context 'errors' do

    context 'notifier' do
      context 'honeybadger api key' do
        context 'present' do

          around(:each) do |example|
            ClimateControl.modify HONEYBADGER_API_KEY: 'abc' do
              example.run
            end
          end
        
          it 'should notify honeybadger 4 times and raise an error' do
            expect(Honeybadger).to receive(:notify).exactly(4).times
            expect{
              subject.handle(event: aws_event, context: context) do |event|
                raise "boom"
              end
            }.to raise_error
          end

        end

        context 'not present' do

          it 'should not notify honeybadger' do
            expect(Honeybadger).to receive(:notify).never
          end
    
        end
      end
    end

    context 'ack messages' do

      context 'no messages error' do

         

      end

      context 'some messages error' do

      end

    end
    
  end

end
