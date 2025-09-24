json.extract! game, :id, :user_id, :result, :choice, :keeper_choice, :created_at, :updated_at
json.url game_url(game, format: :json)
