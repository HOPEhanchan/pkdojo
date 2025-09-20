class ApplicationController < ActionController::Base
  before_action :set_streak

  private

  def set_streak
    return unless user_signed_in?
    # 直近の戦績から「trueが続いた回数」を数える（※効率重視→pluckでtrueの取り出し）
    # 現在の連続（新しい順に true が続く数）
    desc_results = current_user.games.order(created_at: :desc).pluck(:result)
    @streak_count = desc_results.take_while { |r| r }.size

    # 最高連続（古い順に走査して最大連続 true を求める）
    max_streak = 0
    cur = 0
    asc_results = desc_results.reverse # 昇順
    asc_results.each do |r|
      if r
        cur += 1
        max_streak = cur if cur > max_streak
      else
        cur = 0
      end
    end
    @max_streak_count = max_streak
  end
end
