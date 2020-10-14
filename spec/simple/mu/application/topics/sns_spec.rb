require 'spec_helper'
require 'aws-sdk-sns'
require 'simple/mu/application/topics/sns'
require 'simple/mu/application/templates/registry'

RSpec.describe Simple::Mu::Application::Topics::Sns do

  subject{ described_class.new(:foo) }

  let(:arn){ 'bar' }
  let(:topic_region){ 'eu-west-99' }

  around do |example|
    ClimateControl.modify TOPIC_FOO_ARN: arn, TOPIC_REGION: topic_region do
      example.run
    end
  end

  context 'arn' do

    let(:other_topic){ described_class.new(:boom) }

    it 'should return the foo arn' do
      expect(subject.arn).to eq 'bar'
    end

    it 'should raise an error if the arn ENV has not been defined'  do
      expect{
        other_topic.arn
      }.to raise_error('expected ENV to define TOPIC_BOOM_ARN')
    end

  end

  it 'should return an aws sns resource' do
    expect(subject.resource).to be_a Aws::SNS::Resource
  end

  context 'topic' do

    it 'should return an aws sns topic' do
      expect(subject.topic).to be_a Aws::SNS::Topic
    end

    it 'should return the correct topic arn' do
      expect(subject.topic.arn).to eq arn
    end

  end

  context 'broadcast' do

   around do |example|
      Simple::Mu::Application::Templates::Registry.register(:foo, 'some.event', 1, {foo1: :string, foo2: :string})
        example.run
      Simple::Mu::Application::Templates::Registry.deregister(:foo, 'some.event', 1)
    end

    let(:payload){ { foo1: 'bar1', foo2: 'bar2' } }
    let(:event_name){ 'some.event' }
    let(:version){ 1 }
    let(:source){ 'some.arn' }
    let(:message){ {    event_name: event_name,
                             version: version,
                             payload: payload }.to_json }

    it 'should publish the event type to sns' do
      expect(subject.topic).to receive(:publish).with(message: message)
      subject.broadcast(event_name, version, payload)
    end

  end

end
