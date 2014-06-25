module Features
  module SessionHelpers
    def sign_up_with(email, password)
      visit new_user_registration_path
      fill_in 'user_email', with: email
      fill_in 'register_password', with: password
      fill_in 'user_password_confirmation', with: password
      click_button "register-submit-btn"
    end

    def sign_in
      user = create(:user)
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      fill_in '#user_password_confirmation', with: user.password
      click_button 'Login'
    end
  end
end