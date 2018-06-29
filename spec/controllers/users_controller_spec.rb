# frozen_string_literal: true

require "rails_helper"

def random_valid_user_params
  pass = Faker::Internet.password(8)
  {
    user: {
      name: Faker::Name.first_name,
      email: Faker::Internet.email,
      password: pass,
      password_confirmation: pass,
    },
  }
end

describe UsersController, type: :controller do
  let(:invalid_params) do
    {
      user: {
        name: "Invalid",
        email: "example.com",
        password: "pass",
        passwrd_confirmation: "invalid",
      },
    }
  end

  describe "GET #new" do
    it "assigns a blank user to the view" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "POST #create" do
    it "redirects to user room on succesful create" do
      params = random_valid_user_params
      post :create, params: params

      u = User.find_by(name: params[:user][:name], email: params[:user][:email])

      expect(u).to_not be_nil
      expect(u.name).to eql(params[:user][:name])
      expect(response).to redirect_to(room_path(u.main_room))
    end

    it "redirects to main room if already authenticated" do
      user = create(:user)
      @request.session[:user_id] = user.id

      post :create, params: random_valid_user_params
      expect(response).to redirect_to(room_path(user.main_room))
    end

    it "user saves with greenlight provider" do
      params = random_valid_user_params
      post :create, params: params

      u = User.find_by(name: params[:user][:name], email: params[:user][:email])

      expect(u.provider).to eql("greenlight")
    end

    it "renders #new on unsuccessful save" do
      post :create, params: invalid_params

      expect(response).to render_template(:new)
    end
  end

  describe "PATCH #update" do
    it "properly updates user attributes" do
      user = create(:user)

      params = random_valid_user_params
      patch :update, params: params.merge!(user_uid: user)
      user.reload

      expect(user.name).to eql(params[:user][:name])
      expect(user.email).to eql(params[:user][:email])
    end

    it "renders #edit on unsuccessful save" do
      @user = create(:user)

      patch :update, params: invalid_params.merge!(user_uid: @user)
      expect(response).to render_template(:edit)
    end
  end
end
