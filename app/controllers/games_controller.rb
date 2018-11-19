require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @start_time = Time.now
  end

  def score
    end_time = Time.now
    start_time = Time.parse(params[:start_time])
    time = end_time - start_time
    user_input = params[:word]
    grid = params[:grid]
    @result = score_and_message(user_input, grid, time)
    @score = @result[0]
    @sentence = @result[1]
  end

  private

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, 'Well done']
      else
        [0, 'Not an english word']
      end
    else
      [0, 'Not in the grid']
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  # def scores
  #   if session[:score] = []
  #     session[:score] = @score
  #   else
  #     session[:score] += @score
  #   end
end
