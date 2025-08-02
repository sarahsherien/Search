class CreateSearchSummaries < ActiveRecord::Migration[7.0]
  def change
    create_table :search_summaries do |t|
      t.string :ip_address
      t.string :query

      t.timestamps
    end
  end
end
