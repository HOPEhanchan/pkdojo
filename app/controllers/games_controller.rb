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
    # @game は set_game で取得済み
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
    render :result
  end

  def stats
  @games = current_user.games.order(created_at: :desc)

  total = @games.size
  goals = @games.where(result: true).count
  saves = @games.where(result: false).count
  streak = @games.reverse.take_while(&:result).count # 連続ゴール数の表示

  @stats = {
    total: total,
    goals: goals,
    saves: saves,
    rate: total.zero? ? 0 : ((goals.to_f / total) * 100).round(1),
    streak: streak
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
