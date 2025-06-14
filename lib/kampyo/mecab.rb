# frozen_string_literal: true

require 'kampyo'
require 'kampyo/string'
require 'kampyo/text'
require 'mecab'

# Kampyo
module Kampyo
  # Text
  class Mecab < Text
    # rubocop:todo Metrics/MethodLength
    def parser(input) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      result = []
      parser = MeCab::Tagger.new
      node = parser.parseToNode(input)
      while node
        features = node.feature.split(',')
        if features[0] != 'BOS/EOS'
          result << {
            id: result.size + 1,
            chunk: 0,
            surface: node.surface,
            feature1: features[0],
            feature2: features[1],
            baseform: features[6],
            reading: features[7],
            ext_reading: ext_reading(features[7]),
            cost: node.cost,
            wcost: node.wcost,
            right_context: node.rcAttr,
            left_context: node.lcAttr
          }
        end
        node = node.next
      end

      result
    end
    # rubocop:enable Metrics/MethodLength
  end
end
