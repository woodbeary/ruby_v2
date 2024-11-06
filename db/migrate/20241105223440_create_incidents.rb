class CreateIncidents < ActiveRecord::Migration[7.2]
  def change
    create_table :incidents do |t|
      t.string :title
      t.text :description
      t.string :priority
      t.string :status

      t.timestamps
    end
  end
end
