class Post < ApplicationRecord
  has_one :postscript

  validates :title, presence: true
  has_rich_text :content

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
