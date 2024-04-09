require 'rails_helper'

RSpec.describe 'ユーザー新規登録', type: :system do
  before do
    @user = FactoryBot.build(:user)
  end
  context 'ユーザー新規登録に成功するとき' do
    it 'フォーム入力に成功し、ユーザー新規登録に成功し、themeページに移動する' do
      # topページに移動する
      visit root_path
      # signupページに移動するボタンがあることを確認する
      expect(page).to have_content('新規登録')
      # ボタンを押し、signupページに移動する
      visit signup_ideas_path
      # フォーム欄を全て入力する
      fill_in 'user[user_name]', with: @user.user_name
      fill_in 'user[email]', with: @user.email
      fill_in 'user[password]', with: @user.password
      # submitボタンを押す
      # userモデルのレコード数が1つ増える
      expect{click_on '登録'}.to change {User.count}.by(1)
      # themeページに移動する。リダイレクトを想定するので、現在のページを確認する
      expect(current_path).to eq(theme_ideas_path)
    end
  end
end
