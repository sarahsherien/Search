class CreateSearchQueries < ActiveRecord::Migration[7.0]
  def change
    create_table :search_queries do |t|
      t.references :search_session, null: false, foreign_key: true
      t.string :query_text
      t.datetime :submitted_at

      t.timestamps
    end
  end
end
