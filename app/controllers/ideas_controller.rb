class IdeasController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  # セッション情報とテーマ内検索の初期化
  before_action :set_current_user,:search_initialize
  #トップページ以外でログインを求める
  before_action :redirect_if_not_logged_in, except: :top
  # アイデアへの閲覧制限
  before_action :can_view_idea?, except: [:top,:themes,:first_create,:create,:to_theme,:create_in_parent_box]
  #他ユーザーアイデア閲覧中の編集制限
  before_action :is_only_view_idea?, only: [:set_easy_points,:set_effect_points,:update_easy_value,:update_effect_value,:public_setting,:edit,:update,:destroy_move,:destroy,:ex_form]
  # 評価に関するページで、themeと対応するvalueをセットする
  before_action :theme_and_value_set, only:[:first_solution,:public_custom, :add_weighted_value, :remove_weighted_value]
  #テーマ以下の子孫アイデアを全て取得
  before_action :get_generation, only: [:evaluations, :set_easy_points,:set_effect_points,:results,:update_easy_value,:update_effect_value]


  # 子アイデアを持たないアイデアすべてを取得
  def get_generation
    @theme = Idea.find_by(id: params[:id])
    @ideas_have_no_children = @theme.descendants.select(&:leaf?)
  end

  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id].present?
  end

  # ログインしてない場合でも、TOPページのみアクセス可能にしている
  def redirect_if_not_logged_in
    if @current_user == nil
      redirect_to root_path
      flash[:error] = "ログインしてください"
    end
  end

  #アイデア閲覧制限
  def can_view_idea?
    @idea = Idea.find_by(id: params[:id])
    root = @idea.root || @idea
    @value = Value.find_or_create_by(idea_id: root.id)
    if @idea.user_id != @current_user.id
      if @value.public == false
        redirect_to themes_ideas_path
        flash[:error] = "権限がありません"
      end
    end
  end

  def is_only_view_idea?
    @idea = Idea.find_by(id: params[:id])
    if @idea.user_id != @current_user.id
      redirect_to request.referer
      flash[:error] = "閲覧のみ可能です。編集権限がありません"
    end
  end

  # 評価の重み付けをする機能に共通部分
  def theme_and_value_set
    @theme = Idea.find(params[:id])
    @value = Value.find_or_create_by(idea_id: @theme.id)
  end



  def copy_idea_generation
    @other_your_theme = Idea.find(params[:id])
    @new_theme = Idea.create(name: @other_your_theme.name,user_id: @current_user.id)
    copy_create_children(@other_your_theme,@new_theme)

    redirect_to solutions_idea_path(@new_theme)
    flash[:notice] = "テーマのアイデアを全体コピーし、自分のアイデアとしました"
  end

  def copy_create_children(idea,new_idea)
    if idea.children.present?
      idea.children.each do |child|
        copy_name = child.name
        new_child = Idea.create(name: copy_name,parent_id: new_idea.id,user_id: @current_user.id)
        copy_create_children(child,new_child)
      end
    end
  end

  def change_to_themes
    @theme = Idea.find_by(id: params[:id])
    @all_generations = @theme.descendants
  end

  def to_theme
    if params[:idea] && params_ids = params[:idea][:id]
      ActiveRecord::Base.transaction do
        params_ids.each do |params_id|
          to_be_theme_idea = Idea.find_by(id: params_id.to_i)
          @parent_idea = to_be_theme_idea.parent
          @parent_idea = to_be_theme_idea if @parent_idea == nil
          if @parent_idea.parent_id == nil
            parent_theme = Theme.find_or_create_by(idea_id: @parent_idea.id)
          else
            parent_theme = Theme.find_by(idea_id: @parent_idea.id)
          end
          new_idea = Idea.create(name: to_be_theme_idea.name,parent_id: nil,user_id: @current_user.id)
          #名前だけコピーして新テーマにする場合
          if params[:name_to_theme]
            if parent_theme.present?
              new_theme = Theme.create(idea_id: new_idea.id,parent_theme_id: parent_theme.id)
              parent_theme.update(child_theme_id: new_theme.id)
            else
              new_theme = Theme.create(idea_id: new_idea.id)
            end
          #名前をコピーして、紐づいた子アイデアも引き継いで新テーマにする場合
          elsif params[:with_children_to_theme]
            if parent_theme.present?
              new_theme = Theme.create(idea_id: new_idea.id,parent_theme_id: parent_theme.id)
              copy_create_children(to_be_theme_idea,new_idea)
              parent_theme.update(child_theme_id: new_theme.id)
            else
              new_theme = Theme.create(idea_id: new_idea.id)
              copy_create_children(to_be_theme_idea,new_idea)
            end
          end
        end
      end
        redirect_to themes_ideas_path
        flash[:notice] = "アイデアを新しいテーマにしました"
    else
      redirect_to request.referer
    end
  end

  def to_themes_with_children
    params_ids = params[:idea][:id]
    params_ids.each do |params_id|
      parent_theme = Idea.find_by(id: params_id.to_i)
      @new_theme = Idea.create(name: parent_theme.name,parent_id: nil,user_id: @current_user.id)
      copy_create_children(parent_theme,@new_theme)
    end
    redirect_to themes_ideas_path

  end




  def public_custom
  end


  def tree
    @theme = Idea.find_by(id: params[:id])
    all_children_ideas = @theme.descendants
    @ideas_have_no_children = @theme.descendants.select(&:leaf?).sort_by(&:id)
  end


  def search_initialize
    @q = Idea.ransack(params[:q])
  end

  def index
    @problem = Idea.includes(:children).first
    @problem_children = @problem.children if @problem.present?
  end


  def search
    @q = Idea.ransack(params[:q])
    @theme = Idea.find_by(id: params[:id])
    @ideas = @q.result(distinct: true)
    if @ideas.present?
      # @ideasから@themeの子孫アイデアのみを取得
      matching_ideas = @ideas.select { |idea| @theme.descendants.include?(idea) }

      if matching_ideas.present?
        redirect_to solutions_idea_path(matching_ideas.first.id)
      else
        flash[:error] = "該当するアイデアは解決したいテーマ内にありません"
        redirect_back(fallback_location: themes_ideas_path)
      end
    else
      flash[:error] = "該当するアイデアが見つかりません"
      redirect_back(fallback_location: themes_ideas_path)
    end
  end

  def permit_user?(idea)
    if idea.user_id == @current_user.id
      return true
    else
      redirect_to request.referer
      flash[:error] = "閲覧のみ可能です。編集権限がありません"
      return false
    end
  end

  # テーマを決める
  def first_create
    name = params[:idea][:name]
    if name.present?
      ActiveRecord::Base.transaction do
        @theme = Idea.create(name: name, user_id: @current_user.id)
        Value.create(idea_id: @theme.id)
        Theme.create(idea_id: @theme.id)
      end
      redirect_to first_solution_idea_path(@theme)
    else
      flash[:error] = "テーマ名を入力してください"
      redirect_to request.referer
    end
  end

  # テーマ作成後、大きな枠組みでcreate
  def parent_create
    idea_params = params.require(:idea).permit(:parent_id, :names)
    names = idea_params[:names].split("\n").map(&:strip).reject(&:blank?)
    this_idea_parent_id = params.dig(:idea, :parent_id)
    parent = Idea.find(this_idea_parent_id)
    @theme = parent.root
    if names.present?
      if permit_user?(@theme)
        names.each do |name|
          @child_idea = parent.children.create(name: name, user_id: @current_user.id)
        end
        if parent.root?
          redirect_to solutions_idea_path(parent)
        else
          redirect_to request.referer
        end
      end
    else
      flash[:error] = "アイデア名を入力してください"
      redirect_to request.referer
    end
  end

  def create
    idea_params = params.require(:idea).permit(:parent_id, :names,:user_id)
    names = idea_params[:names].split("\n").map(&:strip).reject(&:blank?)
    this_idea_parent_id = idea_params[:parent_id]
    @parent = Idea.find(this_idea_parent_id)
    @theme = @parent.root
    if permit_user?(@theme)
      names.each do |name|
        @child_idea = @parent.children.create(name: name, user_id: @current_user.id)
      end
    end
  end

  def create_in_parent_box
    idea_params = params.require(:idea).permit(:parent_id, :names)
    names = idea_params[:names].split("\n").map(&:strip).reject(&:blank?)
    this_idea_parent_id = params.dig(:idea, :parent_id)
    @parent = Idea.find(this_idea_parent_id)
    @children_ideas = @parent.children
    @theme = @parent.root
    if permit_user?(@theme)
      names.each do |name|
        @child_idea = @parent.children.create(name: name, user_id: @current_user.id)
      end
    end
  end


  def first_solution
  end

  def top
    if @current_user
      redirect_to themes_ideas_path
    end
  end


  def themes
    @themes = Idea.where(parent_id: nil, user_id: @current_user.id).order(updated_at: :desc).page(params[:theme_page]).per(10)
    @public_themes = Value.eager_load(:idea).where(public: true)
    if @public_themes.present?
      @another_user_themes = @public_themes.map(&:idea).select { |idea| idea.user_id != @current_user.id }
      @another_user_themes = @another_user_themes.sort_by(&:updated_at).reverse
      # ページネーションとしてまとめる
      @another_user_themes = Kaminari.paginate_array(@another_user_themes).page(params[:another_user_theme_page]).per(15)
    end
  end



  def solutions
    @root_idea = Idea.find_by(id: params[:id])
    @theme = @root_idea.root
    if @root_idea == @theme && @theme.user_id == @current_user.id
      @theme.update_column(:updated_at, Time.now)
    end
    @children_ideas = @root_idea.children if @root_idea.present?
  end


  def evaluations
    @theme = Idea.find_by(id: params[:id])
    # 子アイデアを持たないアイデアすべてを取得
    @ideas_have_no_children = @theme.descendants.select(&:leaf?).sort_by(&:id)
    @last_idea = @ideas_have_no_children.last
    @value = Value.find_or_create_by(idea_id: @theme.id)
    @this_theme = Theme.find_or_create_by(idea_id: params[:id])
    @parent_themes = Theme.eager_load(:idea).where(child_theme_id: @this_theme.id)
  end

  def set_easy_points
    easy_points_params = params.require(:idea).permit!

    @idea = Idea.find_by(id: params[:id])

    if @idea.nil?
      flash[:error] = 'アイデアが見つかりません'
      redirect_to request.referer
    end

    @ideas_have_no_children = @idea.descendants.select(&:leaf?)
    @value = Value.find_or_create_by(idea_id: @idea.id)
    if @value.easy_rate == nil || @value.easy_rate == 0.0
      @value.update(easy_rate: 1.0)
    end

    ActiveRecord::Base.transaction do
      @ideas_have_no_children.each do |solution|
        easy_point = easy_points_params[:"#{solution.id}_easy_point"].first.to_i
        idea = Idea.find_by(id: solution.id)

        if @value.easy_rate > 1
          idea.update!(easy_point: easy_point * @value.easy_rate)
        else
          idea.update!(easy_point: easy_point)
        end
      end
    end
    redirect_to evaluations_idea_path(@idea, anchor: 'target'), notice: '①の評価が完了しました'

  rescue => e
    flash[:error] = "作成に失敗しました"
    redirect_to request.referer
  end


  def set_effect_points
    effect_points_params = params.require(:idea).permit!

    @idea = Idea.find_by(id: params[:id])
    @theme = Theme.find_or_create_by(idea_id: @idea.id)
    @value = Value.find_or_create_by(idea_id: @idea.id)
    if @value.effect_rate == nil || @value.effect_rate == 0.0
      @value.update(effect_rate: 1.0)
    end

    success = true

    @ideas_have_no_children.each do |solution|
      effect_point = params["idea"][:"#{solution.id}_effect_point"].first.to_i
      idea = Idea.find_by(id: solution.id)

      if @value.effect_rate > 1
        unless idea.update(effect_point: effect_point * @value.effect_rate)
          success = false
          break
        end
      else
        unless idea.update(effect_point: effect_point)
          success = false
          break
        end
      end
    end

    if success
      @theme.update(evaluation_done: 1)
      redirect_to results_idea_path(@idea), data: { turbo: "false" }, notice: '②が完了しました'
    else

    end
  end



  def results
    @theme = Idea.find(params[:id])
    @value = Value.find_or_create_by(idea_id: @theme.id)
    @value.easy_rate ||= 1.0
    @value.effect_rate ||= 1.0
    @sorted_solutions = @ideas_have_no_children.sort_by { |solution| -solution.sum_points }
    @data = @sorted_solutions.map do |solution|
      score = solution.sum_points
      [solution.name, score]
    end
  end

  def update_easy_value
    @theme = Idea.find(params[:id])
    @value = Value.find_or_create_by(idea_id: @theme.id)
    @value.easy_rate ||= 1
    @value.effect_rate ||= 1
    before_value = @value.easy_rate
    value_params = params.dig(:value, :easy_rate).to_f
    if value_params != nil
      if @value.update(easy_rate: value_params)
        if before_value != 1.0 #すでに重み付けをしてあった場合
          @ideas_have_no_children.each do |solution|
            before_points = solution.easy_point / before_value
            new_point = before_points * @value.easy_rate
            solution.update(easy_point: new_point)
          end
        else
          @ideas_have_no_children.each do |solution|
            new_point = solution.easy_point * @value.easy_rate
            solution.update(easy_point: new_point)
          end
        end
        redirect_to results_idea_path(@theme), notice: '簡単さの重みを更新しました'
      else
        redirect_to results_idea_path(@theme), notice: '更新に失敗しました'
      end
    else
    redirect_to results_idea_path(@theme), notice: '更新に失敗しました'
    end
  end

  def update_effect_value
    @theme = Idea.find(params[:id])
    @value = Value.find_or_create_by(idea_id: @theme.id)
    @value.easy_rate ||= 1
    @value.effect_rate ||= 1
    before_value = @value.effect_rate
    value_params = params.dig(:value, :effect_rate).to_f
    if @value.update(effect_rate: value_params)
      if before_value != 1.0 #すでに重み付けをしてあった場合
        @ideas_have_no_children.each do |solution|
          before_points = solution.effect_point / before_value
          new_point = before_points * @value.effect_rate
          solution.update(effect_point: new_point)
        end
      else #初めての重み付けの場合
        @ideas_have_no_children.each do |solution|
          new_point = solution.effect_point * @value.effect_rate
          solution.update(effect_point: new_point)
        end
      end
      redirect_to results_idea_path(@theme), notice: '簡単さの重みを更新しました'
    else
      redirect_to results_idea_path(@theme), notice: '更新に失敗しました'
    end
  end


  def public_setting
    @idea = Idea.find(params[:id])
    @value = Value.find_or_create_by(idea_id: @idea.id)
    value_params = params.dig(:value,:public)
    if @value.update(public: value_params)
      redirect_to request.referer, notice: '全体公開を変更しました'
    else
      redirect_to request.referer, notice: '更新に失敗しました'
    end
  end


  def edit
    @idea = Idea.find_by(id: params[:id])
    @theme = @idea.root
  end

  def update
    @idea = Idea.find_by(id: params[:id])
    if @idea.update(idea_params)
      redirect_to solutions_idea_path(@idea.id), notice: 'アイデアが更新されました。'
    else
      if @idea.parent.present?
        render :edit
      else
        redirect_to request.referer, notice: '変更しました'
      end
    end
  end

  def destroy_move
    @idea = Idea.find_by(id: params[:id])
    @idea_parent = @idea.parent
    @idea_family = @idea.self_and_descendants
    @idea_family.each(&:destroy)
    if @idea_parent == nil
      redirect_to themes_ideas_path, notice: 'テーマが削除されました'
    else
      redirect_to solutions_idea_path(@idea_parent)
    end
  end

  # solutionの小アイデアでは削除後同じページ
  def destroy
    @idea = Idea.find_by(id: params[:id])
    @parent = @idea.parent
    @theme = @idea.root
    @idea_family = @idea.self_and_descendants
    @idea_family.each(&:destroy)
  end


  def add_weighted_value
  end

  def remove_weighted_value
  end


  def ex_form
    @idea = Idea.find(params[:id])
    @child = @idea
  end


  def record_not_found
    redirect_to themes_ideas_path
  end

  private

  def idea_params
    params.require(:idea).permit(
      :name,
      :parent_id,
      :effect_point,
      :easy_point,
      name: [],
      parent_id: []
      )
  end

  def value_params
    params.require(:value).permit(:easy, :effect,:public)
  end






end
