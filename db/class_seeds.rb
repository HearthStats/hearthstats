# reset table do autoincrement starts with 1
DatabaseCleaner.clean_with(:truncation, only: [:klasses])

Klass.create([
  { name: 'Druid'  },
  { name: 'Hunter' },
  { name: 'Mage'   },
  { name: 'Paladin'},
  { name: 'Priest' },
  { name: 'Rogue'  },
  { name: 'Shaman' },
  { name: 'Warlock'},
  { name: 'Warrior'}
])
