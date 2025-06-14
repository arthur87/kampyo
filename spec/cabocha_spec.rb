# frozen_string_literal: true

require 'kampyo/cabocha'

RSpec.describe Kampyo::Cabocha do # rubocop:disable Metrics/BlockLength
  let(:input) { '今日は雨です' }

  before do
    @cabocha = Kampyo::Cabocha.new
  end

  it 'cabocha' do
    result = @cabocha.parser(input)
    test = {
      chunks: [
        { id: 1, link: 2, score: 0.0 },
        { id: 2, link: -1, score: 0.0 }
      ],
      tokens: [
        { id: 1, chunk: 1, surface: '今日', feature1: '名詞', feature2: '副詞可能', baseform: '今日', reading: 'キョウ',
          ext_reading: nil },
        { id: 2, chunk: 1, surface: 'は', feature1: '助詞', feature2: '係助詞', baseform: 'は', reading: 'ハ',
          ext_reading: nil },
        { id: 3, chunk: 2, surface: '雨', feature1: '名詞', feature2: '一般', baseform: '雨', reading: 'アメ',
          ext_reading: nil },
        { id: 4, chunk: 2, surface: 'です', feature1: '助動詞', feature2: '*', baseform: 'です', reading: 'デス',
          ext_reading: nil }
      ]
    }

    expect(result).to eq test
  end

  it 'analysis' do
    result = @cabocha.analysis(@cabocha.parser(input))
    test = { subject: {
               id: 1, chunk: 1, surface: '今日', feature1: '名詞', feature2: '副詞可能', baseform: '今日',
               reading: 'キョウ', ext_reading: nil
             },
             predicate: {
               id: 3, chunk: 2, surface: '雨', feature1: '名詞', feature2: '一般', baseform: '雨',
               reading: 'アメ', ext_reading: nil
             },
             tod: '断定' }

    expect(result).to eq test
  end
end
