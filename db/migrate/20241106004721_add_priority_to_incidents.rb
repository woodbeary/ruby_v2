class AddPriorityToIncidents < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:incidents, :priority)
      add_column :incidents, :priority, :string
    end
  end
end
