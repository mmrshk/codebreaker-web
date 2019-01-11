class Racker < Renderer
  attr_reader :request, :game

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @guess = Guess.new
    @storage = Codebreaker::Entities::DataStorage.new
  end

  def response
    case request.path
    when '/' then index
    when '/rules' then rules_view
    when '/play' then play
    when '/hint' then hint
    when '/guess' then guess
    when '/lose' then lose
    when '/win' then win
    when '/stats' then stats
    else error404_view
    end
  end

  def index
    return menu_view if not_exist?(:game)

    game_view
  end

  def stats
    @request.session[:scores] = @storage.load
    stats_view
  end

  def guess
    Rack::Response.new do |response|
      return lose unless create_game.attempts.positive?

      @guess_code = @request.params['guess_code']
      @request.session[:guess] = @guess_code
      @request.session[:guess_code] = @guess.handle_guess_code(create_game, @guess_code)
      return win if create_game.win?(@guess_code)

      create_game.decrease_attempts!
      response.redirect('/play')
    end
  end

  def lose
    return error404_view if not_exist?(:game)

    Rack::Response.new(lose_view) do
      destroy_session
    end
  end

  def win
    return error404_view if not_exist?(:game)

    Rack::Response.new(win_view) do
      game = create_game
      @storage.save_game_result(game.to_h(user_name))
      destroy_session
    end
  end

  def used_hints
    return @request.session[:used_hints] = [] if not_exist?(:used_hints)

    @request.session[:used_hints]
  end

  def hint
    Rack::Response.new do |response|
      game = create_game
      return error404_view if game.hints_spent?

      hint = game.take_a_hint!
      used_hints.push(hint)
      response.redirect('/play')
    end
  end

  def hints_spent?
    game = create_game
    game.hints_spent?
  end

  def play
    set_guess_code
    @request.session[:game] = create_game
    game_view
  end

  def user_name
    return @request.session[:name] = @request.params['player_name'] if not_exist?(:name)

    @request.session[:name]
  end

  def user_level
    return @request.session[:level] = @request.params['level'] if not_exist?(:level)

    @request.session[:level]
  end

  def user_attempts
    return Codebreaker::Entities::Game::DIFFICULTIES[user_level.to_sym][:attempts] if not_exist?(:game)

    @request.session[:game].attempts
  end

  def user_hints
    return Codebreaker::Entities::Game::DIFFICULTIES[user_level.to_sym][:hints] if not_exist?(:game)

    @request.session[:game].hints.size
  end

  def game_code
    @request.session[:game].code
  end

  private

  def destroy_session
    @request.session.clear
  end

  def set_guess_code
    return @request.session[:guess_code] if @request.session[:guess_code]

    @request.session[:guess_code] = ''
  end

  def not_exist?(param)
    @request.session[param].nil?
  end

  def create_game
    game = Codebreaker::Entities::Game.new
    game.generate(Codebreaker::Entities::Game::DIFFICULTIES[user_level.to_sym])
    return game if not_exist?(:game)

    @request.session[:game]
  end
end
