class GamesController < ApplicationController
  #before_action :set_game, only: %i[ show ]

  def index
    @games = current_user.games.order(created_at: :desc)
  end

  def shoot
    user_choice   = params[:choice]                 # 選択肢は３択で　"left"|"center"|"right"
    keeper_choice = %w[left center right].sample
    result        = (user_choice != keeper_choice)  # GKと違う方向ならゴール

    @game = current_user.games.create!(
      result: result, choice: user_choice, keeper_choice: keeper_choice
    )

    @keeper_choice = keeper_choice
    @result = result
    render :result
  end

  private
  #def set_game
  #  @game = Game.find(params[:id])
  #end

  def game_params
    params.require(:game).permit(:result, :choice, :keeper_choice)
  end
end
