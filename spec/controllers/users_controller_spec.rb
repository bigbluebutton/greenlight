require "rails_helper"

describe UsersController, type: :controller do

  let(:user_params) {
    {
      user: {
        name: "Example",
        email: "example@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }
  }

  let(:invalid_params) {
    {
      user: {
        name: "Invalid",
        email: "example.com",
        password: "pass",
        password_confirmation: "invalid"
      }
    }
  }

  describe "GET #new" do
    it "assigns a blank user to the view" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "POST #create" do
    it "redirects to user room on succesful create" do
      post :create, params: user_params

      u = User.last
      expect(u).to_not be_nil
      expect(u.name).to eql("Example")
      expect(response).to redirect_to(room_path(u.main_room))
    end

    it "redirects to main room if already authenticated" do
      user = create(:user)
      @request.session[:user_id] = user.id

      post :create, params: user_params
      expect(response).to redirect_to(room_path(user.main_room))
    end

    it "user saves with greenlight provider" do
      post :create, params: user_params

      u = User.last
      expect(u.provider).to eql("greenlight")
    end

    it "renders #new on unsuccessful save" do
      post :create, params: invalid_params

      expect(response).to render_template(:new)
    end
  end

  describe "PATCH #update" do
    it "properly updates user attributes" do
      @user = create(:user)

      patch :update, params: user_params.merge!(user_uid: @user)
      @user.reload

      expect(@user.name).to eql("Example")
      expect(@user.email).to eql("example@example.com")
    end

    it "properly updates user password" do

    end

    it "renders #edit on unsuccessful save" do
      @user = create(:user)

      patch :update, params: invalid_params.merge!(user_uid: @user)
      expect(response).to render_template(:edit)
    end
  end
end
