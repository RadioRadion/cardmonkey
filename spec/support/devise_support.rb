RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
end

# spec/support/shared_contexts/user_card_form_context.rb
RSpec.shared_context 'user card form' do
  let(:form_double) { instance_double(Forms::UserCardForm) }
  
  before do
    allow(Forms::UserCardForm).to receive(:new).and_return(form_double)
    allow(form_double).to receive(:user_id).and_return(user.id)
  end
end