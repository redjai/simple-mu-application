require 'simple/mu/application/notifiers/honeybadger'

RSpec.describe Simple::Mu::Application::Notifiers::Honeybadger do

  let(:opts){ {sync: true } }
  let(:error){ double("Error") } 

  context 'api key present' do
    around(:each) do |example|
      ClimateControl.modify HONEYBADGER_API_KEY: 'abc' do
        example.run
      end
    end
 
    it 'should notify honeybadger with the sync => true option' do
      expect(Honeybadger).to receive(:notify).with(error, opts).once
      subject.notify(error)
    end

    context 'error object has a response method (e.g. Faraday Http Error)' do
      let(:response){ 'boom' }
      let(:error){ double("Error", response: response) }
      let(:opts){ {sync: true, context: { response: 'boom'} } }

      it 'should add the response to the context if the erro object has this method' do
        expect(Honeybadger).to receive(:notify).with(error, opts)
        subject.notify(error)
      end
    end
  end

  context 'api key not present' do

    it 'should not notify honeybadger' do
      expect(Honeybadger).to receive(:notify).never
    end
    
  end
end
