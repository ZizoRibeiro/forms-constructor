class RemoveUserIdFromAnswer < ActiveRecord::Migration[5.1]
  def change
    remove_column :answers, :user_id, :string
  end
end
