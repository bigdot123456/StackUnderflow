class Question < ActiveRecord::Base
  include Votable
  attr_accessor :tag_list

  scope :where_tag, ->(tag) { joins(:tags).where("tags.name = ?", tag) }

  after_save :add_tags_from_list

  belongs_to :user
  has_and_belongs_to_many :tags

  has_many :answers, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :impressions, dependent: :destroy
  accepts_nested_attributes_for :attachments, reject_if: proc { |attrs| attrs['file'].blank? && attrs['file_cache'].blank? }

  validates :body, presence: true, length: { in: 10..5000 }
  validates :title, presence: true, length: { in: 5..512 }
  validates :tag_list, presence: true, on: :create
  validate :validate_tag_list

  def has_best_answer?
    answers.find_by(best: true) ? true : false
  end

  def form_tag_list
    tags.map(&:name).join(",")
  end

  private
    def validate_tag_list
      split_tags(tag_list) do |tag|
        tag = Tag.find_or_initialize_by(name: tag)
        if tag.new_record? && !tag.valid?
          errors[:tag_list] << "Tags #{tag.errors[:name][0]}"
          break
        end
      end
    end

    def add_tags_from_list
      tags.clear
      split_tags(tag_list) do |tag|
        tags.push Tag.find_or_create_by(name: tag)
      end
    end

    def split_tags(list, &block)
      list ||= ""
      list.split(",").each &block
    end
end
