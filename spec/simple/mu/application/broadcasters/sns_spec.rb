require 'spec_helper'
require 'aws-sdk-sns'
require 'simple/mu/application/broadcasters/sns'
require 'simple/mu/application/templates/registry'

RSpec.describe Simple::Mu::Application::Topics::Sns do

  subject{ described_class.new }

  let(:arn){ 'bar' }
  let(:topic_region){ 'eu-west-99' }
  let(:topic_name){ :foo }

  around do |example|
    ClimateControl.modify TOPIC_FOO_ARN: arn, REGION: topic_region do
      example.run
    end
  end

  context 'arn' do

    let(:other_topic){ described_class.new(:boom) }

    it 'should return the foo arn' do
      expect(subject.arn(topic_name)).to eq 'bar'
    end
  end

  it 'should return an aws sns resource' do
    expect(subject.resource).to be_a Aws::SNS::Resource
  end

  context 'topic' do

    it 'should return an aws sns topic' do
      expect(subject.topic(topic_name)).to be_a Aws::SNS::Topic
    end

    it 'should return the correct topic arn' do
      expect(subject.topic(topic_name).arn).to eq arn
    end

  end

  context 'broadcast' do

   around do |example|
      Simple::Mu::Application::Templates::Registry.register(topic_name, 'some.event', 1, {foo1: :string, foo2: :string})
        example.run
      Simple::Mu::Application::Templates::Registry.deregister(topic_name, 'some.event', 1)
    end

    let(:payload){ { foo1: 'bar1', foo2: 'bar2' } }
    let(:event_name){ 'some.event' }
    let(:version){ 1 }
    let(:source){ 'some.arn' }
    let(:message){ {    event_name: event_name,
                             version: version,
                             payload: payload }.to_json }

    it 'should publish the event type to sns' do
      expect(subject.topic(topic_name)).to receive(:publish).with(message: message)
      subject.broadcast(topic_name, event_name, version, payload)
    end

  end

  context 'event' do

    let(:event_name){ :test_message }
    let(:version){ 1.1 }
    let(:payload){ { foo: 1, bar: 2 } }
    let(:message){ { event_name: event_name, version: version, payload: payload }}

    it 'should convert the argumnets into a message hash' do
      expect(subject.event(event_name: event_name, version: version, payload: payload)).to eq message
    end
    
    it 'should convert the  message to json' do
      expect(subject.event_json(event_name: event_name, version: version, payload: payload)).to eq message.to_json
    end

  end
end
