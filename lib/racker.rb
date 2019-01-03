class Racker < Renderer
  attr_reader :request, :game

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    case request.path
    when '/' then index
    when '/rules' then rules_view
    when '/play' then play
    when '/hint' then hint
    when '/guess' then guess
    when '/lose' then handle_lose
    when '/win' then handle_win
    when '/stats' then stats
    when '/after_lose' then handle_after_lose
    else error404_view
    end
  end

  def index
    return Rack::Response.new(play) unless exist?(:game)

    menu_view
  end

  def guess
    Rack::Response.new do |response|
      @game = create_game
      return handle_lose unless @game.attempts.positive?

      @guess_code = @request.params['guess_code']
      @request.session[:guess_code] = @game.start_process(@guess_code)
      @game.decrease_attempts!
      response.redirect('/play')
    end
  end

  def handle_lose
    return Rack::Response.new(index) if exist?(:game)

    lose_view
  end

  def handle_after_lose
    Rack::Response.new do |response|
      destroy_session
      response.redirect('/')
    end
  end

  def used_hints
    return @request.session[:used_hints] unless exist?(:used_hints)

    @request.session[:used_hints] = []
  end

  def hint
    Rack::Response.new do |response|
      @game = create_game
      return error404_view if @game.hints_spent?

      hint = @game.take_a_hint!
      used_hints.push(hint)
      response.redirect('/play')
    end
  end

  def hints_spent
    @game = create_game
    @game.hints_spent?
  end

  def create_game
    return @request.session[:game] unless exist?(:game)

    @game = Codebreaker::Entities::Game.new
    @game.generate(Codebreaker::Entities::Game::DIFFICULTIES[user_level.to_sym])
    @game
  end

  def play
    set_quess_code
    @request.session[:game] = create_game
    game_view
  end

  def set_quess_code
    return @request.session[:guess_code] unless @request.session[:guess_code].nil?

    @request.session[:guess_code] = ''
  end

  def user_name
    return @request.session[:name] unless exist?(:name)

    @request.session[:name] = @request.params['player_name']
  end

  def user_level
    return @request.session[:level] unless exist?(:level)

    @request.session[:level] = @request.params['level']
  end

  def user_attempts
    return @request.session[:game].attempts unless exist?(:game)

    Codebreaker::Entities::Game::DIFFICULTIES[user_level.to_sym][:attempts]
  end

  def user_hints
    return @request.session[:game].hints.size unless exist?(:game)

    Codebreaker::Entities::Game::DIFFICULTIES[user_level.to_sym][:hints]
  end

  def destroy_session
    @request.session.clear
  end

  def game_code
    @request.session[:game].code
  end

  def code_size_for_view
    code_size = @request.session[:guess_code].size
    code_size += 1
  end

  private

  def exist?(param)
    @request.session[param].nil?
  end
end
