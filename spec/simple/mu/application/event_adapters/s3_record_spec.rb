require 'support/events/s3'
require 'simple/mu/application/event_adapters/s3'

RSpec.describe Simple::Mu::Application::EventAdapters::S3Record do
  let(:key){ 'some/key.json' }
  let(:bucket){ 'some_bucket' }
  let(:event){ MockS3Event.event(bucket, key) }
  let(:record){ event['Records'].first }
  let(:payload){ { key: key, bucket: bucket } }
   
  subject{ described_class.new(record) }
    
  it 'returns the payload as key & bucket from the record' do
    expect(subject.payload).to eq payload
  end

end 

