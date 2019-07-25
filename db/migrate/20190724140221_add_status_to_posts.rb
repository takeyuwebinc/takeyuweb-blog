class AddStatusToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :status, :integer, null: false, default: 0, comment: "記事の公開状態"
  end
end
