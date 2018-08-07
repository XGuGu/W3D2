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

class Replies



  attr_accessor :question_id, :parent_reply_id, :author_id, :body

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @author_id = options['author_id']
    @body = options['body']
  end

  def self.find(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL , id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if reply.empty?
    Replies.new(reply[0])
  end

  def self.find_by_user_id(author_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL , author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = ?
    SQL
    return nil if replies.empty?
    replies.map{|reply| Replies.new(reply)}
  end


  def self.find_by_question_id(question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL , question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil if reply.empty?
    Replies.new(reply[0])
  end


  def author
    author = Users.find_by_id(author_id)
  end

  def question
    question = Questions.find_by_id(question_id)
  end

  def parent_reply
    reply = Replies.find(parent_reply_id)
  end

  def child_reply
    replies = QuestionsDatabase.instance.execute(<<-SQL , @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL
    return nil if replies.empty?
    replies.map{|reply| Replies.new(reply)}
  end

end
