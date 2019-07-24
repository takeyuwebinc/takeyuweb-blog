class Post < ApplicationRecord
  validates :title, presence: true
  has_rich_text :content
  has_one :postscript, dependent: :destroy
  enum status: { unpublished: 0, published: 1 }

  scope :recent, ->{ order(created_at: :desc, id: :desc) }

  # TODO: 全文検索
  def self.search(query)
    where("title LIKE :query", query: query)
  end

  # TODO: 関連記事を取り出す
  def related
    Post.where.not(id: id)
  end
end
