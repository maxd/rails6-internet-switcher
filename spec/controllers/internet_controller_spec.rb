# frozen_string_literal: true

RSpec.context InternetController do
  before(:each) do
    allow(Rails.application.credentials).to receive(:devices).and_return([{ id: 'ipad', name: 'iPad' }])
  end

  shared_examples 'authentication required' do
    it { is_expected.to have_http_status(:found) }
    it { is_expected.to redirect_to(new_user_session_path) }
  end

  context 'GET index' do
    it_behaves_like 'authentication required' do
      subject { get :index }
    end

    context 'render' do
      before do
        expect(InternetService).to receive(:internet_enabled?).and_return(true)

        sign_in create(:user)
      end

      subject { get :index }

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('index') }
    end
  end

  context 'POST enable' do
    shared_examples 'enable/disable Internet' do |enable:|
      before do
        expect(InternetService).to receive(:internet_enabled?).and_return(!enable)
        expect(InternetService).to receive(:enable_internet).and_return(enable)
      end

      before do
        sign_in create(:user)
      end

      subject { get :enable, params: { id: 'ipad', enable: enable } }

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('internet/_device') }
    end

    it_behaves_like 'authentication required' do
      subject { post :enable, params: { id: 'ipad', enable: false } }
    end

    it_behaves_like 'enable/disable Internet', enable: true
    it_behaves_like 'enable/disable Internet', enable: false

    context 'unknown device id' do
      before do
        sign_in create(:user)
      end

      subject { post :enable, params: { id: 'unknown', enable: false } }

      it { expect { subject }.to raise_error(ActionController::RoutingError).with_message('Device not found') }
    end
  end
end
