# frozen_string_literal: true

RSpec.context InternetController do
  before(:each) do
    allow(Rails.application.credentials).to receive(:device_ids_to_comments).and_return({ ipad: 'iPad' })
  end

  context 'GET index' do
    context 'unauthenticated' do
      subject { get :index }

      it { is_expected.to have_http_status(:found) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'authenticated' do
      before do
        sign_in create(:user)
      end

      subject { get :index }

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('index') }
    end
  end
end
