class AddLocaleToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :locale, :string, :default => 'en'
  end
end
