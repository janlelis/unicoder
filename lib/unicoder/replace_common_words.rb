require "json"

module Unicoder
  module ReplaceCommonWords
  	def replace_common_words!(which_index, words, count = 500, base = ?[.ord, min_word_length = 4)
  	  puts "Starting to replace the #{count} most common words"
  	  @index[:REPLACE_BASE] = base
  	  @index[:COMMON_WORDS] = words.
  	    select{_1.size >= min_word_length}.
  	    tally.
  	    max_by(count){_2}.
  	    map(&:first)
  	  @index[which_index].each{|_, name|
  	    @index[:COMMON_WORDS].each_with_index{|word, index|
  	      name.gsub! word + " ", [base + index].pack("U")
  	    }
  	  }
  	end
  end
end