# reset table do autoincrement starts with 1
DatabaseCleaner.clean_with(:truncation, only: [:klasses])

Klass.create([
  { name: 'Druid'},
  { name: 'Priest'},
  { name: 'Mage'},
  { name: 'Warlock'},
  { name: 'Warrior'},
  { name: 'Paladin'},
  { name: 'Shaman'},
  { name: 'Hunter'},
  { name: 'Rogue'}
])