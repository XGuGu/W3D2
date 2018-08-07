require 'SQLite3'
require 'singleton'
require_relative 'questions'
require_relative 'questions_follows'
require_relative 'question_likes'
require_relative 'replies'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Users

  attr_accessor :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL , id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if user.empty?
    Users.new(user[0])
  end


  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL , fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? and lname = ?
    SQL
    return nil if user.empty?
    Users.new(user[0])
  end

  def authored_questions
    questions = Questions.find_by_author_id(@id)
  end

  def authored_questions
    questions = Replies.find_by_user_id(@id)
  end

  def followed_questions
    QuestionsFollows.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLikes.liked_questions_for_user_id(@id)
  end

  def average_karma
    avg = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        cast(count(question_likes.id) as float) / (count(distinct(questions.id)))
      FROM
        question_likes
      JOIN
        questions
      ON
        question_likes.question_id = questions.id
      JOIN
        users
      ON
        users.id = questions.author_id
      WHERE
        users.id = ?
    SQL

    avg[0].values[0]

  end


end
