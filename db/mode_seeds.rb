# reset table so autoincrement starts with 1
DatabaseCleaner.clean_with(:truncation, only: [:match_results])

Mode.create([
  { name: 'Arena'  },
  { name: 'Casual' },
  { name: 'Ranked' }
])
