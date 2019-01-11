# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Racker do
  let(:app) { Rack::Builder.parse_file('config.ru').first }
  let(:game) { Codebreaker::Entities::Game.new }
  let(:path) { 'database/data_test.yml' }
  let(:storage) { Storage.new }

  describe 'statuses' do
    context 'when root path' do
      before { get '/' }

      it 'returns status ok' do
        expect(last_response).to be_ok
      end

      it { expect(last_response.body).to include I18n.t(:short_rules) }
    end

    context 'when unknown routes' do
      before { get '/unknown' }

      it 'returns status not found' do
        expect(last_response.body).to include I18n.t(:not_found)
      end
    end

    context 'when rules path' do
      before { get '/rules' }

      it 'returns status ok' do
        expect(last_response).to be_ok
      end

      it { expect(last_response.body).to include I18n.t(:cb_rules) }
    end

    context 'when statistics path' do
      before do
        get '/stats'
      end

      it { expect(last_response.body).to include I18n.t(:top_of_players) }
      it { expect(last_response).to be_ok }
    end
  end

  describe '#hint' do
    before do
      game.generate(Codebreaker::Entities::Game::DIFFICULTIES[:hell])
      env 'rack.session', game: game, used_hints: [], level: :easy
      get '/hint'
    end

    it 'adds value to session hints array' do
      post '/hint'
      expect(last_request.session[:used_hints]).not_to be_empty
      expect(last_request.session[:game].code.join.include?(last_request.session[:used_hints].join)).to be true
    end
  end

  describe '#play' do
    before do
      game.generate(Codebreaker::Entities::Game::DIFFICULTIES[:hell])
      env 'rack.session', game: game, guess_code: ''
      post '/play', level: 'easy', player_name: 'Denis'
    end

    context 'when game page response' do
      it 'responses with ok status' do
        expect(last_response).to be_ok
      end

      it 'contains player_name' do
        expect(last_response.body).to include I18n.t(:hello_msg, name: last_request.session[:name])
      end
    end

    context 'when creates empty Array of used hints' do
      it { expect(last_request.session[:used_hints]).to be_a Array }
      it { expect(last_request.session[:used_hints]).to be_empty }
    end

    context 'when creates empty guess_code before starting the game' do
      it { expect(last_request.session[:guess_code]).to be_a String }
      it { expect(last_request.session[:guess_code]).to be_empty }
    end
  end

  describe '#guess' do
    before do
      game.generate(Codebreaker::Entities::Game::DIFFICULTIES[:hell])
      env 'rack.session', game: game, hints: [], level: 'easy', player_name: 'Dima'
      post '/guess', guess_code: '1111'
    end

    it 'check response with guess_code' do
      expect(last_request.session[:guess_code]).to be_a String
    end
  end
end
