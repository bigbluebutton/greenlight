require 'rails_helper'

describe SessionsController, type: :controller do

  context "GET #new," do
    it "renders the #new view." do
      get :new
      expect(response).to render_template :new
    end
  end

  context "POST #create," do
    it "should signin user." do
      user = create(:user)
      post :create, params: {session: {email: user.email, password: user.password}}

      expect(response).to redirect_to room_path(user.room.uid)
      expect(user.id).to eql(session[:user_id])
    end

    it "should render new on fail." do
      user = create(:user)
      post :create, params: {session: {email: user.email, password: "incorrect_password"}}

      expect(response).to render_template :new
    end
  end

  context "POST #launch," do
    it "should login launched user." do

    end
  end

  context "POST #omniauth," do
    it "should login omniauth user." do
      email = "omniauth@test.com"
      uid = "123456789"
  
      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(:twitter, {
        provider: "twitter",
        uid: uid,
        info: {
          email: email,
          name: "Omni User",
          nickname: "username"
        }
      })

      get "/auth/twitter"
  
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
      get omniauth_session_path(provider: "twitter")
  
      user = User.find_by(email: email, uid: uid)
  
      expect(response).to redirect_to room_path(user.room.uid)
      expect(user.id).to eql(session[:user_id])
    end
  end

  context "GET #destroy," do
    it "should logout user." do
      user = create(:user)
      session[:user_id] = user.id
      get :destroy

      expect(response).to redirect_to root_path
      expect(user.id).to_not eql(session[:user_id])
    end
  end

end