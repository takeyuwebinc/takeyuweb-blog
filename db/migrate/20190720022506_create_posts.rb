class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts, comment: '記事' do |t|
      t.string :title, default: '', null: false, comment: '記事のタイトル'

      t.timestamps
    end
  end
end
