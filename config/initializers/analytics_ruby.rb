Analytics = AnalyticsRuby       # Alias for convenience
Analytics.init({
    secret: '91rigjfqas',          # The write key for hearthstats/prod
    on_error: Proc.new { |status, msg| print msg }  # Optional error handler
})