require 'rails_helper'

RSpec.describe CardsController, type: :controller do
  let(:user) { create(:user) }
  let(:card) { create(:card) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a successful response' do
      get :edit, params: { id: card.id }
      expect(response).to be_successful
    end

    it 'assigns the requested card to @card' do
      get :edit, params: { id: card.id }
      expect(assigns(:card)).to eq(card)
    end
  end

  describe 'PATCH #update' do
    let(:valid_attributes) { { name: 'Updated Name', quantity: 2, extension: 'NEO', foil: true, condition: 'NM', language: 'EN' } }
    let(:invalid_attributes) { { name: '' } }

    context 'with valid params' do
      it 'updates the requested card' do
        patch :update, params: { id: card.id, card: valid_attributes }
        card.reload
        expect(card.name).to eq('Updated Name')
      end

      it 'redirects to user_cards_path' do
        patch :update, params: { id: card.id, card: valid_attributes }
        expect(response).to redirect_to(user_cards_path)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the edit template)' do
        patch :update, params: { id: card.id, card: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested card' do
      card_to_delete = create(:card)
      expect {
        delete :destroy, params: { id: card_to_delete.id }
      }.to change(Card, :count).by(-1)
    end

    it 'redirects to user_cards_path' do
      delete :destroy, params: { id: card.id }
      expect(response).to redirect_to(user_cards_path(user))
    end
  end

  describe 'GET #search' do
    let!(:black_lotus_fr) { create(:card, name_fr: 'Lotus Noir', name_en: 'Black Lotus') }
    let!(:black_knight_fr) { create(:card, name_fr: 'Chevalier Noir', name_en: 'Black Knight') }

    it 'returns matching cards in JSON format' do
      get :search, params: { query: 'Lotus' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['name_fr']).to eq('Lotus Noir')
      expect(json_response.first['name_en']).to eq('Black Lotus')
    end

    it 'searches in both French and English names' do
      get :search, params: { query: 'Black' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
    end

    it 'limits results to 5 cards' do
      6.times { create(:card, name_fr: 'Test Card', name_en: 'Test Card') }
      get :search, params: { query: 'Test' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(5)
    end
  end

  describe 'GET #versions' do
    let(:card) { create(:card, :with_versions) }
    let(:extension) { create(:extension) }
    let!(:version) do
      create(:card_version,
        card: card,
        extension: extension,
        eur_price: 1.99,
        eur_foil_price: 5.99
      )
    end

    it 'returns card versions in JSON format' do
      get :versions, params: { oracle_id: card.scryfall_oracle_id }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.first).to include(
        'eur_price',
        'eur_foil_price',
        'extension'
      )
    end

    context 'when card is not found' do
      it 'returns a 404 status' do
        get :versions, params: { oracle_id: 'non-existent' }, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when an error occurs' do
      before do
        allow(Card).to receive(:find_by).and_raise(StandardError.new('Test error'))
      end

      it 'returns a 500 status' do
        get :versions, params: { oracle_id: card.scryfall_oracle_id }, format: :json
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
