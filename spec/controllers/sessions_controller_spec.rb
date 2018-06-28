# frozen_string_literal: true

require "rails_helper"

describe SessionsController, type: :controller do
  before(:all) do
    @user = create(:user, password: "example", password_confirmation: "example")
  end

  describe "GET #destroy" do
    before(:each) do
      @request.session[:user_id] = @user.id
      get :destroy
    end

    it "should logout user" do
      expect(@request.session[:user_id]).to be_nil
    end

    it "should redirect to root" do
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST #create" do
    it "should login user in if credentials valid" do
      post :create, params: {
        session: {
          email: @user.email,
          password: "example",
        },
      }

      expect(@request.session[:user_id]).to eql(@user.id)
    end

    it "should not login user in if credentials invalid" do
      post :create, params: {
        session: {
          email: @user.email,
          password: "invalid",
        },
      }

      expect(@request.session[:user_id]).to be_nil
    end
  end

  describe "GET/POST #omniauth" do
    before(:all) do
      OmniAuth.config.test_mode = true

      OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
        provider: "twitter",
        uid: "twitter-user",
        info: {
          email: "user@twitter.com",
          name: "Twitter User",
          nickname: "username",
          image: "example.png",
        },
      )

      OmniAuth.config.on_failure = proc { |env|
        OmniAuth::FailureEndpoint.new(env).redirect_to_failure
      }
    end

    it "should create and login user with omniauth" do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
      get :omniauth, params: { provider: :twitter }

      u = User.last
      expect(u.provider).to eql("twitter")
      expect(u.email).to eql("user@twitter.com")
      expect(@request.session[:user_id]).to eql(u.id)
    end

    it "should redirect to root on invalid omniauth login" do
      request.env["omniauth.auth"] = :invalid_credentials
      get :omniauth, params: { provider: :twitter }

      expect(response).to redirect_to(root_path)
    end

    it "should not create session without omniauth env set" do
      get :omniauth, params: { provider: 'google' }

      expect(response).to redirect_to(root_path)
    end
  end
end
