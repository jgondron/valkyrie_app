class ChangeIdToString < ActiveRecord::Migration[5.1]
  def change
    change_column :orm_resources, :id, :text, null: false, primary_key: true, default: -> { '(uuid_generate_v4())::text' }
  end
end
