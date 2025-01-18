# This file is part of Bluff.
#
# Bluff is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
#
# Bluff is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Bluff.
# If not, see <https://www.gnu.org/licenses/>.

module PlayerStatistics
  extend ActiveSupport::Concern

  included do
    # Add any needed class methods here
  end

  # Returns complete statistics for the player
  def statistics
    {
      total_games: total_games,
      total_profit: total_profit,
      win_rate: win_rate,
      average_profit: average_profit,
      biggest_win: biggest_win,
      biggest_loss: biggest_loss,
      current_streak: current_streak,
      loan_stats: loan_statistics
    }
  end

  # Total number of games played
  def total_games
    player_results.count
  end

  # Total profit/loss across all games
  def total_profit
    player_results.sum(:total_amount)
  end

  # Win rate as a percentage
  def win_rate
    return 0.0 if total_games.zero?

    winning_games = player_results.where("total_amount > ?", 0).count
    (winning_games.to_f / total_games * 100).round(1)
  end

  # Average profit per game
  def average_profit
    return 0.0 if total_games.zero?

    total_profit.to_f / total_games
  end

  # Highest amount won in a single game
  def biggest_win
    player_results.maximum(:total_amount) || 0
  end

  # Biggest loss in a single game
  def biggest_loss
    player_results.minimum(:total_amount) || 0
  end

  # Current winning/losing streak
  def current_streak
    results = player_results.order(created_at: :desc).limit(10).pluck(:total_amount)
    return 0 if results.empty?

    streak = 0
    is_winning = results.first.positive?

    results.each do |amount|
      break unless (is_winning && amount.positive?) || (!is_winning && amount.negative?)
      streak += 1
    end

    is_winning ? streak : -streak
  end

  # Loan related statistics
  def loan_statistics
    loans = transactions.loan
    repayments = transactions.repayment

    {
      total_loans: loans.sum(:amount),
      total_repayments: repayments.sum(:amount),
      outstanding_loans: loans.sum(:amount) - repayments.sum(:amount),
      loan_count: loans.count
    }
  end

  # Recent game results
  def recent_results(limit = 5)
    player_results.includes(:game_session)
                 .order(created_at: :desc)
                 .limit(limit)
  end

  # Profit trend over time
  def profit_trend(period = 30.days)
    player_results.where("created_at > ?", period.ago)
                 .group_by_day(:created_at)
                 .sum(:total_amount)
  end
end
