RSpec.context InternetController, js: true do
  before do
    driven_by(:selenium, using: :headless_firefox)
  end

  before(:each) do
    allow(Rails.application.credentials).to receive(:device_ids_to_comments).and_return({ipad: 'iPad'})
    allow(Rails.application.credentials).to receive(:mikrotik_api).and_return({
                                                                                host: '192.168.1.1',
                                                                                user: 'user',
                                                                                password: 'password',
                                                                              })
  end

  context 'GET index' do
    shared_examples 'render page' do |enabled:|
      before(:each) do
        mikrotik_api = double('Mikrotik API')
        expect(mikrotik_api).to receive(:open).with(no_args)
        expect(mikrotik_api).to receive(:find_address).with('iPad').and_return(OpenStruct.new(id: '*1', enabled: !enabled))
        expect(mikrotik_api).to receive(:close).with(no_args)

        allow(MikrotikApi).to receive(:new).and_return(mikrotik_api)
      end

      subject! { visit '/' }

      it { expect(page).to have_text("iPad - Internet #{enabled ? 'Enabled' : 'Disabled'}") }
    end

    shared_examples 'toggle Internet' do |enabled:|
      before do
        ActionController::Base.allow_forgery_protection = true
      end

      after do
        ActionController::Base.allow_forgery_protection = false
      end

      before(:each) do
        mikrotik_api = double('Mikrotik API')
        expect(mikrotik_api).to receive(:open).with(no_args).ordered
        expect(mikrotik_api).to receive(:find_address).with('iPad').and_return(OpenStruct.new(id: '*1', enabled: !enabled)).ordered
        expect(mikrotik_api).to receive(:close).with(no_args).ordered

        expect(mikrotik_api).to receive(:open).with(no_args).ordered
        expect(mikrotik_api).to receive(:find_address).with('iPad').and_return(OpenStruct.new(id: '*1', enabled: !enabled)).ordered
        expect(mikrotik_api).to receive(:disable_address).with('*1', !enabled).and_return(!enabled).ordered
        expect(mikrotik_api).to receive(:close).with(no_args).ordered

        allow(MikrotikApi).to receive(:new).and_return(mikrotik_api)
      end

      subject! do
        visit '/'

        click_button 'ipad'
      end

      it { expect(page).to have_text("iPad - Internet #{!enabled ? 'Enabled' : 'Disabled'}") }
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
