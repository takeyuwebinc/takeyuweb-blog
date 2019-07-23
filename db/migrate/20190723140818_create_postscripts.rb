class CreatePostscripts < ActiveRecord::Migration[6.1]
  def change
    create_table :postscripts do |t|
      t.references :post, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
  end
end
