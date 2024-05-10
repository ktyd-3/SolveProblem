require 'rails_helper'

RSpec.describe "Ideas", type: :system do
    before do
      @user = FactoryBot.build(:user)
      @theme_idea = FactoryBot.build(:idea)
      @child_idea = FactoryBot.build(:idea)
      @sub_child_idea = FactoryBot.build(:idea)
      visit root_path
      visit login_ideas_path
      fill_in 'email', with: @user.email
      fill_in 'password', with: @user.password
      click_button 'ログイン'
    end
    context 'アイデア一覧表示ページの文言表示' do
      it 'ログインした後、テーマ、子アイデア、孫アイデアを順に作り、アイデア一覧表示ページに行くと、孫アイデアが2つ表示される' do
        # ログイン
        # テーマアイデアを入力
        fill_in 'idea_names', with: @theme_idea.name
        # 作成ボタンを押すと、アイデアモデルのカウントが1上がることを確認
        expect{click_on '新規作成'}.to change {Idea.count}.by(1)
        # first_solutionページに移動
        expect(current_path).to eq(first_solution_idea_path(@theme_idea))
        # 子アイデアを入力
        fill_in 'idea[names]', with: @child_idea.name
        # 作成ボタンを押すと、アイデアモデルのカウントが1上がることを確認
        expect{click_on '作成'}.to change {Idea.count}.by(1)
        # solutionsページに移動
        expect(current_path).to eq(solutions_idea_path(@theme_idea))
        # 子アイデアに対し、更に子アイデアを作成（孫アイデアの作成）
        fill_in '#idea_form_#{@child.id}', with: @sub_child_idea.name
        # 作成ボタンを押すと、アイデアモデルのカウントが1上がることを確認
        expect{click_on '作成'}.to change {Idea.count}.by(1)
        # treeページへ移動
        visit tree_idea_path(@theme_idea)
        # 孫アイデア2つ表示されていることを確認
        expect(page).to have_content('#{@sub_child_idea.name}', count: 2)
      end
    end
end
