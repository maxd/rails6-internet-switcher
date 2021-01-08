RSpec.context InternetController do
  before(:each) do
    allow(Rails.application.credentials).to receive(:device_ids_to_comments).and_return({ipad: 'iPad'})
  end

  context 'GET index' do
    subject { get :index }

    it { is_expected.to have_http_status(:success) }
    it { is_expected.to render_template('index') }
  end
end
