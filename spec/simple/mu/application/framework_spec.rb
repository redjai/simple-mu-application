require 'simple/mu/application/framework'

RSpec.describe Simple::Mu::Application::Framework do
 
  let(:message){ { foo: 'foo', bar: 'bar' } }
  let(:context){ {} }

  let(:aws_event){ MockSqsEvent.event(message) }
   
   
  context 'yield' do

    it 'should yield the aws_event message' do
      expect{ |b| subject.handle(event: aws_event, context: context, &b) }.to yield_with_args(message)
    end

  end

  context 'errors' do

    context 'honeybadger api key missing' do

      it 'should raise an error' do
        expect{
          subject.handle(event: aws_event, context: context) do |event|
            raise "boom"
          end
        }.to raise_error("boom")
      end

    end

    context 'honeybadger api key present' do

      around(:each) do |example|
        ClimateControl.modify HONEYBADGER_API_KEY: 'abc' do
          example.run
        end
      end
    
      it 'should not raise an error if there is a honeybadger api key' do
        expect(Honeybadger).to receive(:notify)
        subject.handle(event: aws_event, context: context) do |event|
          raise "boom"
        end
      end

    end
  end

end
