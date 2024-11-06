class CreateIncidentsSafely < ActiveRecord::Migration[7.2]
  def change
    create_table :incidents do |t|
      t.string :title
      t.text :description
      t.string :status
      t.timestamps
    end unless table_exists?(:incidents)
  end
end
