# frozen_string_literal: true

require 'kampyo'

# Kampyo
module Kampyo
  # Text
  class Text
    def initialize; end

    def ext_reading(feature)
      (feature =~ /\A[\p{katakana}|ー]+\z/).nil? ? feature : nil
    end
  end
end
