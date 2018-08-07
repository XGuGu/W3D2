require_relative 'users'
require_relative 'questions'
require 'SQLite3'
require 'singleton'


class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class QuestionLikes

  attr_accessor :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.likers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_likes
      ON
        users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL

    return nil if users.empty?
    users.map{|user| Users.new(user)}
  end

  def self.num_likes_for_question_id(question_id)
    num = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        Count(users.id)
      FROM
        users
      JOIN
        question_likes
      ON
        users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL

    num[0].values[0]
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes
      ON
        questions.id = question_likes.question_id
      WHERE
        question_likes.user_id = ?
    SQL

    return nil if questions.empty?
    questions.map{|question| Questions.new(question)}
  end


  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes
      ON
        questions.id = question_likes.question_id
      GROUP BY
        questions.id
      ORDER BY
        count(question_likes.id) DESC
      LIMIT
        ?
    SQL
    return nil if questions.empty?
    questions.map{|question| Questions.new(question)}
  end
end
