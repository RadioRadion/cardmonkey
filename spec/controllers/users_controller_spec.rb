require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'authentication' do
    it 'redirects to sign in when not authenticated' do
      get :show, params: { id: user.id }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'GET #show' do
    context 'when authenticated' do
      before { sign_in user }

      it 'assigns the requested user' do
        get :show, params: { id: user.id }
        expect(assigns(:user)).to eq(user)
      end

      it 'assigns stats when viewing own profile' do
        get :show, params: { id: user.id }
        expect(assigns(:stats)).to be_present
      end

      it 'does not assign stats when viewing other user profile' do
        get :show, params: { id: other_user.id }
        expect(assigns(:stats)).to be_nil
      end

      it 'assigns editing when field param is info' do
        get :show, params: { id: user.id, field: 'info' }
        expect(assigns(:editing)).to be true
      end

      it 'assigns editing_preferences when field param is preferences' do
        get :show, params: { id: user.id, field: 'preferences' }
        expect(assigns(:editing_preferences)).to be true
      end
    end
  end

  describe 'GET #edit' do
    context 'when authenticated' do
      before { sign_in user }

      it 'assigns the current user' do
        get :edit, params: { id: user.id }
        expect(assigns(:user)).to eq(user)
      end

      it 'assigns stats' do
        get :edit, params: { id: user.id }
        expect(assigns(:stats)).to be_present
      end

      it 'redirects when trying to edit another user' do
        get :edit, params: { id: other_user.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH #update' do
    context 'when authenticated' do
      before { sign_in user }

      context 'with valid params' do
        let(:new_attributes) { { username: 'New Name' } }

        it 'updates the user' do
          patch :update, params: { id: user.id, user: new_attributes }
          user.reload
          expect(user.username).to eq('New Name')
        end

        it 'redirects to user path with HTML format' do
          patch :update, params: { id: user.id, user: new_attributes }
          expect(response).to redirect_to(user_path(user))
        end

        context 'with turbo_stream format' do
          render_views

          it 'renders turbo_stream for profile update' do
            patch :update, params: { id: user.id, user: new_attributes }, format: :turbo_stream
            expect(response.media_type).to eq Mime[:turbo_stream]
            expect(response.body).to include('profile_info')
          end

          it 'renders turbo_stream for avatar update' do
            patch :update, params: { 
              id: user.id, 
              user: { avatar: fixture_file_upload('spec/fixtures/files/avatar.jpg', 'image/jpeg') }
            }, format: :turbo_stream
            expect(response.media_type).to eq Mime[:turbo_stream]
            expect(response.body).to include('profile_avatar')
          end
        end
      end

      context 'with invalid params' do
        let(:invalid_attributes) { { email: 'invalid_email' } }

        it 'does not update the user' do
          patch :update, params: { id: user.id, user: invalid_attributes }
          user.reload
          expect(user.email).not_to eq('invalid_email')
        end

        it 'renders show with unprocessable_entity status for HTML format' do
          patch :update, params: { id: user.id, user: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:show)
        end

        it 'renders show with unprocessable_entity status for turbo_stream format' do
          patch :update, params: { id: user.id, user: invalid_attributes }, format: :turbo_stream
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      it 'redirects when trying to update another user' do
        patch :update, params: { id: other_user.id, user: { username: 'New Name' } }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'authorization' do
    before { sign_in user }

    context 'when accessing another user' do
      it 'shows flash error for HTML format' do
        patch :update, params: { id: other_user.id, user: { username: 'New Name' } }
        expect(flash[:alert]).to eq("You're not authorized to perform this action.")
      end

      it 'renders flash error for turbo_stream format' do
        patch :update, params: { id: other_user.id, user: { username: 'New Name' } }, format: :turbo_stream
        expect(response.body).to include("You're not authorized to perform this action.")
      end
    end
  end
end
