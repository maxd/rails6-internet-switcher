# frozen_string_literal: true

RSpec.context InternetController, js: true do
  before do
    driven_by(:selenium, using: :headless_firefox)
  end

  before do
    ActionController::Base.allow_forgery_protection = true
  end

  after do
    ActionController::Base.allow_forgery_protection = false
  end

  before(:each) do
    allow(Rails.application.credentials).to receive(:devices).and_return([{ id: 'ipad', name: 'iPad' }])
    allow(Rails.application.credentials).to receive(:mikrotik_api).and_return({
                                                                                host: '192.168.1.1',
                                                                                user: 'user',
                                                                                password: 'password',
                                                                              })
  end

  context 'GET index' do
    shared_examples 'render page' do |enabled:|
      before(:each) do
        expect(InternetService).to receive(:internet_enabled?).and_return(enabled)
      end

      subject! do
        sign_in create(:user)

        visit '/'
      end

      it { expect(page).to have_button("iPad - Internet #{enabled ? 'Enabled' : 'Disabled'}") }
    end

    shared_examples 'toggle Internet' do |enabled:|
      before(:each) do
        expect(InternetService).to receive(:internet_enabled?).and_return(enabled).twice
        expect(InternetService).to receive(:enable_internet).and_return(!enabled)
      end

      subject! do
        sign_in create(:user)

        visit '/'

        click_button 'ipad'
      end

      it { expect(page).to have_button("iPad - Internet #{enabled ? 'Disabled' : 'Enabled'}") }
    end

    context 'authentication required' do
      subject! { visit '/' }

      it { expect(page).to have_text('You need to sign in or sign up before continuing.') }
    end

    context 'with enabled Internet' do
      it_behaves_like 'render page', enabled: true
      it_behaves_like 'toggle Internet', enabled: true
    end

    context 'with disabled Internet' do
      it_behaves_like 'render page', enabled: false
      it_behaves_like 'toggle Internet', enabled: false
    end
  end
end
