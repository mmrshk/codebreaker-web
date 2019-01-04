class Storage
  attr_reader :storage

  def initialize
    @storage = Codebreaker::Entities::DataStorage.new
  end

  def save(game, user_name)
    storage.save_game_result(game.to_h(user_name))
  end

  def load
    storage.load
  end
end
