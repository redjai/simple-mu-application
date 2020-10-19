require 'support/events/s3'
require 'simple/mu/application/event_adapters/s3'

RSpec.describe Simple::Mu::Application::EventAdapters::S3Record do
  let(:key){ 'some/key.json' }
  let(:bucket){ 'some_bucket' }
  let(:event){ MockS3Event.event(bucket, key) }
  let(:record){ event['Records'].first }
  let(:payload){ { key: key, bucket: bucket } }
  let(:to_s){ "s3::#{record['responseElements']['x-amz-request-id']}" }

  subject{ described_class.new(record) }
    
  it 'returns the payload as key & bucket from the record' do
    expect(subject.event).to eq payload
  end
  
  it 'should return false' do
    expect(subject.delete?).to be false
  end

  it 'should return s3::{}' do
    expect(subject.to_s).to eq to_s 
  end

end 

