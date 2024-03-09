require 'rails_helper'

RSpec.describe User, type: :model do
  describe "新規ユーザー登録" do
    before do
      @user=User.new(user_name:"Tarochan",email:"aaa@aaa",  password: "password")
    end

    context "成功:ユーザー登録" do
      it "全ての項目が埋まっているとき" do
        expect(@user).to be_valid
      end
    end

    context "失敗:ユーザー登録" do
      it "20文字over ユーザーネーム" do
        @user.user_name="absdjseldkfjkdosiejfiodifsjdoifxjoijfkdfwuenoi"
        @user.valid?
        expect(@user.errors.full_messages).to include("ユーザーネームは20文字以内で入力してください")
      end

      it "空欄あり:user_name" do
        @user.user_name = ""
        @user.valid?
        expect(@user.errors.full_messages).to include("ユーザーネームを入力してください")
      end

      it "空欄あり:email" do
        @user.email = ""
        @user.valid?
        expect(@user.errors.full_messages).to include("メールアドレスを入力してください")
      end

      it "空欄あり:password" do
        @user=User.new(user_name:"Tarochan",email:"aaa@aaa",  password: "")
        @user.valid?
        expect(@user.errors.full_messages).to include("パスワードを入力してください")
      end

    end

  end
end
