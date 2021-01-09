# frozen_string_literal: true

RSpec.context Api::InternetController do
  before(:each) do
    allow(Rails.application.credentials).to receive(:device_ids_to_comments).and_return({ ipad: 'iPad' })
    allow(Rails.application.credentials).to receive(:mikrotik_api).and_return({
                                                                                host: '192.168.1.1',
                                                                                user: 'user',
                                                                                password: 'password',
                                                                              })
  end

  shared_examples 'authentication required' do
    it { is_expected.to have_http_status(:unauthorized) }
  end

  shared_examples 'unknown device id' do
    before do
      sign_in create(:user)
    end

    let(:response) { JSON.parse(subject.body).deep_symbolize_keys }

    it { is_expected.to have_http_status(:internal_server_error) }
    it { expect(response).to eq(message: 'Unknown device id') }
  end

  context 'GET status' do
    shared_examples 'Internet test' do |enabled:|
      before do
        mikrotik_api = double('Mikrotik API')
        expect(mikrotik_api).to receive(:open).with(no_args)
        expect(mikrotik_api).to receive(:find_address).with('iPad')
                                                      .and_return(OpenStruct.new(id: '*1', enabled: !enabled))
        expect(mikrotik_api).to receive(:close).with(no_args)

        allow(MikrotikApi).to receive(:new).and_return(mikrotik_api)

        sign_in create(:user)
      end

      subject { get :status, params: { id: :ipad } }

      let(:response) { JSON.parse(subject.body).deep_symbolize_keys }

      it { is_expected.to have_http_status(:success) }
      it { expect(response).to eq(enabled: enabled) }
    end

    it_behaves_like 'authentication required' do
      subject { get :status, params: { id: :ipad } }
    end

    it_behaves_like 'Internet test', enabled: true
    it_behaves_like 'Internet test', enabled: false

    it_behaves_like 'unknown device id' do
      subject { get :status, params: { id: :unknown } }
    end
  end

  context 'POST enable' do
    shared_examples 'enable/disable Internet' do |enable:|
      before do
        mikrotik_api = double('Mikrotik API')
        expect(mikrotik_api).to receive(:open).with(no_args)
        expect(mikrotik_api).to receive(:find_address).with('iPad')
                                                      .and_return(OpenStruct.new(id: '*1', enabled: enable))
        expect(mikrotik_api).to receive(:disable_address).with('*1', enable).and_return(enable)
        expect(mikrotik_api).to receive(:close).with(no_args)

        allow(MikrotikApi).to receive(:new).and_return(mikrotik_api)

        sign_in create(:user)
      end

      subject { get :enable, params: { id: :ipad, enable: enable } }

      let(:response) { JSON.parse(subject.body).deep_symbolize_keys }

      it { is_expected.to have_http_status(:success) }
      it { expect(response).to eq(enabled: enable) }
    end

    it_behaves_like 'authentication required' do
      subject { get :enable, params: { id: :ipad, enable: true } }
    end

    it_behaves_like 'enable/disable Internet', enable: true
    it_behaves_like 'enable/disable Internet', enable: false

    it_behaves_like 'unknown device id' do
      subject { get :enable, params: { id: :unknown, enable: true } }
    end
  end
end
