class CreateSearchSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :search_sessions do |t|
      t.string :ip
      t.datetime :started_at

      t.timestamps
    end
  end
end
