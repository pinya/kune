class Comment < ActiveRecord::Base
  acts_as_nested_set scope: [:commentable_id, :commentable_type]

  after_save :ensure_max_nestedset_level

  validates :body, :presence => true
  validate :user_or_username

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_votable

  belongs_to :commentable, :polymorphic => true

  # NOTE: Comments belong to a user
  belongs_to :user

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, user_id, username = "", comment = "")
    new \
      :commentable => obj,
      :body        => comment,
      :user_id     => user_id,
      :username    => username
  end

  #helper method to check if a comment has children
  def has_children?
    self.children.any?
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(:user_id => user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
  }

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  #Return username in any case
  def get_username
    self.user ? self.user.name : self.username
  end

  private

  # Validates presence of user or username
  def user_or_username
    if self.user.nil? && self.username.try(:empty?)
      errors.add(:username, I18n.t("comments.comment.name_or_user_name"))
    end
  end

  # Limit deepness of threads
  def ensure_max_nestedset_level
    if self.level > 4
      self.move_to_child_of(parent.parent)
    end
  end
end
