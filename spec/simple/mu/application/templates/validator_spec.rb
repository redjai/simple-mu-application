require 'spec_helper'
require 'simple/mu/application/templates/validator'

RSpec.describe Simple::Mu::Application::Templates::Validator do

  let(:version){ 1.1 }
  let(:event_name){ :test_name }
  let(:topic_name){ :test_topic }
  let(:payload){ {} }
  let(:payload_definition){ { foo: :string!, bar: :string } }

  subject{ described_class.new(topic_name: topic_name, event_name: event_name, version: version, payload: payload)  }

  around(:each) do |example|
    Simple::Mu::Application::Templates::Registry.register(topic_name, event_name, version, payload_definition)
    example.run
    Simple::Mu::Application::Templates::Registry.deregister(topic_name, event_name, 1.1)
  end

  context '#template' do
    it 'should fetch the template definition' do
      expect(subject.template).to eq({event_name: event_name, version: 1.1, payload_definition: payload_definition})
    end
  end

  context 'validate!' do

    context 'errors exist' do
      let(:payload){ { baz: 456 } }
      let(:error_message){
        %q{validation errors:
unexpected payload keys [:baz]
foo is a required value}
      }

      it 'should raise an error if validation fails' do
        expect{
          subject.validate!
        }.to raise_error(error_message)
      end
    end
 
    context 'errors dont exist' do
      let(:payload){ { foo: '456' } }
      
      it 'should not raise an error if validation does not fail' do
        expect{
          subject.validate!
        }.to_not raise_error
      end
    end

  end

  context 'bad keys' do
    let(:payload){ {xzy: 123} }
    before(:each){ subject.validate }
    it 'should add to errors if a key is in the payload thats not in the template payload_definition' do
      expect(subject.errors).to include("unexpected payload keys [:xzy]") 
    end
  end

  context 'required keys' do
    let(:payload){ {} }
    before(:each){ subject.validate }
    it 'should require foo :string!' do
      expect(subject.errors).to include("foo is a required value") 
    end
    it 'should not require bar :string' do
      expect(subject.errors).to_not include("bar is a required value") 
    end
  end
  
  context 'string values' do
    
    let(:payload_definition){ { foo: :string!, bar: :string } }

    before(:each){ subject.validate }

    context 'good values' do
      let(:payload){ {foo: '123', bar: '567'} }
      
      it 'should be valid when foo is a string' do
        expect(subject.errors).to be_empty
      end
      
      it 'should be valid when bar is a string' do
        expect(subject.errors).to be_empty
      end
    end

    context 'bad values' do
      let(:payload){ {foo: 123, bar: 567} }
      
      it 'should not be valid when foo is not a string' do
        expect(subject.errors).to include("expected [foo] 123 to be a string") 
      end
      it 'should not be valid when bar is not a string' do
        expect(subject.errors).to include("expected [bar] 567 to be a string") 
      end
    end
  end

  context 'numeric values' do
    let(:payload_definition){ { foo: :numeric!, bar: :numeric } }
    
    before(:each){ subject.validate }
    
    context 'good values' do

      let(:payload){ {foo: 123, bar: 567} }
      
      it 'should be valid when foo is numeric' do
        expect(subject.errors).to be_empty
      end
      
      it 'should be valid when bar is numeric' do
        expect(subject.errors).to be_empty
      end
    end

    context 'bad values' do
      
      let(:payload){ { foo: 'one-two-three', bar: 'five-six-seven'} }

      it 'should not be valid when foo is not numeric' do
        expect(subject.errors).to include("expected [foo] one-two-three to be a number") 
      end

      it 'should not be valid when bar is not numeric' do
        expect(subject.errors).to include("expected [bar] five-six-seven to be a number") 
      end
    end
  end
  
  context 'hash values' do
    let(:payload_definition){ { foo: :hash!, bar: :hash } }
    before(:each){ subject.validate }
    
    context 'good values' do

      let(:payload){ {foo: {}, bar: {}} }
      
      it 'should be valid when foo is a hash' do
        expect(subject.errors).to be_empty
      end
      
      it 'should be valid when bar is a hash' do
        expect(subject.errors).to be_empty
      end
    end

    context 'bad values' do
      let(:payload){ {foo: 'one-two-three', bar: 'five-six-seven'} }
      
      it 'should not be valid when foo is not a hash' do
        expect(subject.errors).to include("expected [foo] one-two-three to be a hash") 
      end
      it 'should not be valid when bar is not a hash' do
        expect(subject.errors).to include("expected [bar] five-six-seven to be a hash") 
      end
    end
  end
  
  context 'array values' do
    let(:payload_definition){ { foo: :array!, bar: :array } }
    before(:each){ subject.validate }
    
    context 'good values' do

      let(:payload){ {foo: [], bar: []} }
      
      it 'should be valid when foo is an array' do
        expect(subject.errors).to be_empty
      end
      
      it 'should be valud when bar is an array' do
        expect(subject.errors).to be_empty
      end
    end
    
    context 'bad values' do

      let(:payload){ {foo: 'one-two-three', bar: 'five-six-seven'} }
      
      it 'should not be valid when foo is not an array' do
        expect(subject.errors).to include("expected [foo] one-two-three to be an array") 
      end
      it 'should not be valid when bar is not an array' do
        expect(subject.errors).to include("expected [bar] five-six-seven to be an array") 
      end
    end
  end
end
