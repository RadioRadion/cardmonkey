# spec/controllers/user_wanted_cards_controller_spec.rb
require 'rails_helper'

RSpec.describe UserWantedCardsController, type: :controller do
 let(:user) { create(:user) }
 let(:card) { create(:card) }
 
 before do
   sign_in user
 end

 describe 'GET #index' do
   it 'assigns user wanted cards and renders index template' do
     wanted_cards = create_list(:user_wanted_card, 3, user: user)
     
     get :index, params: { user_id: user.id }
     
     expect(assigns(:user_wanted_cards)).to match_array(wanted_cards)
     expect(response).to render_template(:index)
   end

   it 'eager loads associations correctly' do
     expect(user.user_wanted_cards).to receive_message_chain(:includes, :order)
     get :index, params: { user_id: user.id }
   end
 end

 describe 'GET #new' do
   it 'initializes a new form object' do
     get :new, params: { user_id: user.id }
     
     expect(assigns(:form)).to be_a(Forms::UserWantedCardForm)
     expect(assigns(:form).user_id).to eq(user.id)
     expect(response).to render_template(:new)
   end
 end

 describe 'POST #create' do
   let(:valid_attributes) do
     {
       card_id: card.id,
       quantity: 1,
       min_condition: 'near_mint',
       language: 'french',
       foil: false
     }
   end

   context 'with valid parameters' do
     before do
       allow_any_instance_of(Forms::UserWantedCardForm).to receive(:save).and_return(true)
     end

     it 'creates a new wanted card and redirects' do
       post :create, params: { 
         user_id: user.id, 
         user_wanted_card: valid_attributes 
       }

       expect(response).to redirect_to(user_user_wanted_cards_path(user))
       expect(flash[:notice]).to eq(I18n.t('user_wanted_cards.create.success'))
     end
   end

   context 'with invalid parameters' do
     before do
       allow_any_instance_of(Forms::UserWantedCardForm).to receive(:save).and_return(false)
       allow_any_instance_of(Forms::UserWantedCardForm).to receive(:errors)
         .and_return(double(full_messages: ['Error']))
     end

     it 'renders new template with errors' do
       post :create, params: { 
         user_id: user.id, 
         user_wanted_card: valid_attributes 
       }

       expect(response).to render_template(:new)
       expect(response.status).to eq(422)
     end
   end
 end

 describe 'GET #edit' do
   let(:user_wanted_card) { create(:user_wanted_card, user: user) }
   let(:card_versions) { create_list(:card_version, 2, card: user_wanted_card.card) }

   before do
     card_versions
   end

   it 'assigns form and card versions' do
     get :edit, params: { user_id: user.id, id: user_wanted_card.id }

     expect(assigns(:form)).to be_a(Forms::UserWantedCardForm)
     expect(assigns(:versions)).to match_array(card_versions)
     expect(response).to render_template(:edit)
   end

   it 'loads card versions with correct ordering' do
     expect(user_wanted_card.card.card_versions).to receive_message_chain(:includes, :order)
     get :edit, params: { user_id: user.id, id: user_wanted_card.id }
   end
 end

 describe 'PATCH #update' do
   let(:user_wanted_card) { create(:user_wanted_card, user: user) }
   let(:valid_attributes) { { quantity: 2 } }

   context 'with valid parameters' do
     before do
       allow_any_instance_of(Forms::UserWantedCardForm).to receive(:save).and_return(true)
     end

     it 'updates the wanted card and redirects for HTML request' do
       patch :update, params: { 
         user_id: user.id, 
         id: user_wanted_card.id, 
         user_wanted_card: valid_attributes 
       }

       expect(response).to redirect_to(user_user_wanted_cards_path(user))
       expect(flash[:notice]).to eq(I18n.t('user_wanted_cards.update.success'))
     end

     it 'returns success JSON response for AJAX request' do
       patch :update, params: { 
         user_id: user.id, 
         id: user_wanted_card.id, 
         user_wanted_card: valid_attributes 
       }, format: :json

       expect(response).to have_http_status(:success)
       parsed_response = JSON.parse(response.body)
       expect(parsed_response['message']).to eq(I18n.t('user_wanted_cards.update.success'))
     end
   end

   context 'with invalid parameters' do
     before do
       allow_any_instance_of(Forms::UserWantedCardForm).to receive(:save).and_return(false)
       allow_any_instance_of(Forms::UserWantedCardForm).to receive(:errors)
         .and_return(double(full_messages: ['Error']))
     end

     it 'renders edit template with errors for HTML request' do
       patch :update, params: { 
         user_id: user.id, 
         id: user_wanted_card.id, 
         user_wanted_card: valid_attributes 
       }

       expect(response).to render_template(:edit)
       expect(response.status).to eq(422)
     end

     it 'returns error JSON response for AJAX request' do
       patch :update, params: { 
         user_id: user.id, 
         id: user_wanted_card.id, 
         user_wanted_card: valid_attributes 
       }, format: :json

       expect(response).to have_http_status(:unprocessable_entity)
       parsed_response = JSON.parse(response.body)
       expect(parsed_response).to have_key('errors')
     end
   end
 end

 describe 'DELETE #destroy' do
   let!(:user_wanted_card) { create(:user_wanted_card, user: user) }

   context 'when card exists' do
     it 'deletes the card and redirects for HTML request' do
       expect {
         delete :destroy, params: { user_id: user.id, id: user_wanted_card.id }
       }.to change(UserWantedCard, :count).by(-1)

       expect(response).to redirect_to(user_user_wanted_cards_path(user))
       expect(flash[:notice]).to include(user_wanted_card.card.name_en)
     end

     it 'returns no content for JSON request' do
       delete :destroy, params: { 
         user_id: user.id, 
         id: user_wanted_card.id 
       }, format: :json

       expect(response).to have_http_status(:no_content)
     end
   end

   context 'when card does not exist' do
     it 'handles not found error for HTML request' do
       delete :destroy, params: { user_id: user.id, id: 0 }

       expect(response).to redirect_to(user_user_wanted_cards_path(user))
       expect(flash[:alert]).to eq(I18n.t('user_wanted_cards.destroy.not_found'))
     end

     it 'returns not found status for JSON request' do
       delete :destroy, params: { user_id: user.id, id: 0 }, format: :json

       expect(response).to have_http_status(:not_found)
       expect(JSON.parse(response.body)).to have_key('error')
     end
   end
 end
end