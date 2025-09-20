class GamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game, only: [:show]

  def index
    @games = current_user.games.order(created_at: :desc)

    total = @games.size
    goals = @games.where(result: true).count
    @stats = {
      total: total,
      goals: goals,
      rate:  total.zero? ? 0 : ((goals.to_f / total) * 100).round(1)
    }
  end

  def show
  @game = current_user.games.find(params[:id])

  @keeper_choice = @game.keeper_choice
  @result        = @game.result

  # このゲームより「前」の結果だけで直前連続を計算（新しい順）
  prev_results = current_user.games
                    .where("created_at < ?", @game.created_at)
                    .order(created_at: :desc)
                    .pluck(:result)

  @streak_just_before = prev_results.take_while { |r| r }.size
  @streak_broken      = (@streak_just_before.positive? && !@result)

  # 共有用：最高連続（古い順で走査）
  cur = 0
  @share_streak = current_user.games.order(:created_at).pluck(:result).reduce(0) do |mx, r|
    cur = r ? cur + 1 : 0
    [mx, cur].max
  end

  render :result
end


  def shoot
    user_choice   = params[:choice]                 # 選択肢は３択で"left"|"center"|"right"
    keeper_choice = %w[left center right].sample
    result        = (user_choice != keeper_choice)  # GKと違う方向ならゴール

    # 直前の“連続ゴール数”を先に計算（降順に見てtrueが続く間）
    prev_streak = current_user.games.order(created_at: :desc).pluck(:result).take_while { |r| r }.size

    @game = current_user.games.create!(result: result, choice: user_choice, keeper_choice: keeper_choice)
    @keeper_choice = keeper_choice
    @result = result
    @streak_broken = (prev_streak > 0 && !result)  # 連続が止まった？
    # ← ここからX共有用（最高記録）：最高連続を算出（古い順で走査）
    max_streak = 0
    cur = 0
    current_user.games.order(:created_at).pluck(:result).each do |r|
      if r
        cur += 1
        max_streak = [max_streak, cur].max
      else
        cur = 0
      end
    end
    @share_streak = max_streak   # X共有用（最高記録）ここまで

    redirect_to game_path(@game) #PRG(POST → redirect → GET)
  end

  def stats
  @games = current_user.games.order(created_at: :desc)

  total = @games.size
  goals = @games.where(result: true).count
  saves = @games.where(result: false).count
  streak = @games.order(created_at: :desc).pluck(:result).take_while { |r| r }.size # 連続ゴール数の表示

  max_streak = 0 # 最大連続ゴール数を計算
  current = 0
  @games.order(:created_at).each do |g|
    if g.result
      current += 1
      max_streak = [max_streak, current].max
    else
      current = 0
    end
  end

  @stats = {
    total: total,
    goals: goals,
    saves: saves,
    rate: total.zero? ? 0 : ((goals.to_f / total) * 100).round(1),
    streak: streak,
    max_streak: max_streak
  }
end

  private

  def set_game
    @game = current_user.games.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:result, :choice, :keeper_choice)
  end
end
