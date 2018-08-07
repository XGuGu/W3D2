
require_relative 'users'
require_relative 'replies'
require_relative 'questions_follows'
require_relative 'question_likes'
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

class Questions

  attr_accessor :title, :body, :author_id

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
      INSERT INTO
        questions(title, body, author_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL , id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil if question.empty?
    Questions.new(question[0])
  end


  def self.find_by_title(title)
    questions = QuestionsDatabase.instance.execute(<<-SQL , title)
      SELECT
        *
      FROM
        questions
      WHERE
        title = ?
    SQL
    return nil if questions.empty?
    questions.map{|question| Questions.new(question)}
  end

  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL

    return nil if questions.empty?
    questions.map{|question| Questions.new(question)}
  end

  def author
    author = Users.find_by_id(author_id)
  end

  def replies
    reply = Replies.find_by_question_id(@id)
  end

  def followers
    QuestionsFollows.followers_for_question_id(@id)
  end

  def self.most_followed(n)
    QuestionsFollows.most_followed_questions(n)
  end

  def likers
    QuestionLikes.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLikes.num_likes_for_question_id(@id)
  end

  def self.most_liked(n)
    QuestionLikes.most_liked_questions(n)
  end


end
