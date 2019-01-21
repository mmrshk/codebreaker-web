class Guess
  FAIL_DIGIT_CHAR = 'x'.freeze
  attr_reader :game, :guess_code

  def handle_guess_code(game, guess_code)
    @game = game
    @guess_code = guess_code
    return process if valid_size?(game, guess_code)

    produce_code
  end

  private

  def process
    @process ||= game.start_process(guess_code)
  end

  def produce_code
    code = process
    code + FAIL_DIGIT_CHAR * (Codebreaker::Entities::Game::DIGITS_COUNT - code.size)
  end

  def valid_size?(game, guess_code)
    process.size == Codebreaker::Entities::Game::DIGITS_COUNT
  end
end
