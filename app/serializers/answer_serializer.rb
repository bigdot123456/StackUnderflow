class AnswerSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper

  attributes :id, :body, :created, :question, :comments, :edited, :files, :is_best, :total_votes
  has_one :user

  def created
    time_ago_in_words(object.created_at)
  end

  def question
    question = object.question
    {id: question.id, title: question.title, body: question.body, has_best_answer: question.has_best_answer?}
  end

  def comments
    if object.comments.any?
      object.comments.map { |comment| { id: comment.id, body: comment.body } }
    else
      false
    end
  end

  def edited
    object.updated_at.to_s > object.created_at.to_s ? time_ago_in_words(object.updated_at) : false
  end

  def files
    object.attachments.map { |a| {url: a.file.url, filename: a.file.file.filename, id: a.id, attachable: a.attachable.class.to_s.downcase}  }
  end

  def is_best
    object.best?
  end
end
