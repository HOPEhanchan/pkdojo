class ApplicationController < ActionController::Base
  before_action :set_streak
  private

  def set_streak
    return unless user_signed_in?
    # 直近の戦績から「trueが続いた回数」を数える（※効率重視→pluckでtrueの取り出し）
    results = current_user.games.order(created_at: :desc).pluck(:result)
    @streak_count = results.take_while { |r| r }.size
  end

end
