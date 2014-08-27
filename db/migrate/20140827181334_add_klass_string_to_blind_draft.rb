class AddKlassStringToBlindDraft < ActiveRecord::Migration
  def change
    add_column :blind_drafts, :klass_string, :string
  end
end
