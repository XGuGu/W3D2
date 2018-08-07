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

class QuestionsFollows

  attr_accessor :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        questions_follows
      ON
        users.id = questions_follows.user_id
      WHERE
        questions_follows.question_id = ?
    SQL

    return nil if users.empty?
    users.map{|user| Users.new(user)}
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        questions_follows
      ON
        questions.id = questions_follows.question_id
      WHERE
        questions.author_id = ?
    SQL
    return nil if questions.empty?
    questions.map{|question| Questions.new(question)}
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        questions_follows
      ON
        questions.id = questions_follows.question_id
      GROUP BY
        questions.body
      ORDER BY
        COUNT(questions_follows.id) DESC 
      LIMIT
        ?
    SQL
    return nil if questions.empty?
    questions.map{|question| Questions.new(question)}
  end

end
