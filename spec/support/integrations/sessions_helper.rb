module SessionHelpers
  def sign_up_with(email, password)
    visit new_user_registration_path
    fill_in 'user_email', with: email
    fill_in 'register_password', with: password
    fill_in 'user_password_confirmation', with: password
    click_button "register-submit-btn"
  end

  def sign_in_int
    @user = create(:user)
    create(:season)
    create(:klass)
    visit new_user_session_path
    within(".login-form") do
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      click_button 'Login'
    end
  end
end
