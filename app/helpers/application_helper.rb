#!/bin/env ruby
# encoding: utf-8
module ApplicationHelper

  def available_languages
    @available_languages || available_languages_list
  end

  def available_languages_list
    {'en' => 'English', 'fr' => 'French', 'zh-TW' => '繁體中文', 'zh-CN' => '簡體中文', 'de' => 'German', 'pt-BR' => 'Português', 'ko' => 'Korean', 'el' => 'Greek', 'es' => 'Spanish', 'pl' => 'Polish'}
  end

  def featured_streamers
    ['reynad27','kisstafer','bradhs','imd2','ihosty']
  end

  def current_season
    Season.current
  end

  def current_patch
    Patch.last.num
  end

  def klasses_hash
    Klass::LIST.invert
  end

  def get_name(match, table)
    id = match.send table.downcase + "_id"
    table = "Klass" if table == "Oppclass"
    table = "MatchResult" if table == "Result"
    begin
      result = table.constantize.find(id).name
    rescue
      result = "null"
    end
  end

  def seconds_to_short_readable secs
    [[60, :s], [60, :m], [24, :h], [1000, :d]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i}#{name}"
      end
    }.compact.reverse.join('')
  end

end
