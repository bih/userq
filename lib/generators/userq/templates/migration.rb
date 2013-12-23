class CreateUserQueues < ActiveRecord::Migration
  def change
    create_table :user_queues do |t|
      t.string   :code
      t.datetime :expires_at
      t.text     :data
      t.string   :context

      t.timestamps
    end
  end
end
