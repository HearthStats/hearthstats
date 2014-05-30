# reset table do autoincrement starts with 1
DatabaseCleaner.clean_with(:truncation, only: [:match_results])

MatchResult.create([
  { name: 'win'  },
  { name: 'loss' },
  { name: 'draw' }
])