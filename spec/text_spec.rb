# frozen_string_literal: true

require 'kampyo/text'

RSpec.describe Kampyo::Text do # rubocop:disable Metrics/BlockLength
  let(:input) { '今日は雨です' }

  before do
    @text = Kampyo::Text.new
  end

  it 'cabocha_parser' do
    result = @text.cabocha_parser(input)
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

  it 'mecab_parser' do
    result = @text.mecab_parser(input)
    test = [
      { id: 1, chunk: 0, surface: '今日', feature1: '名詞', feature2: '副詞可能', baseform: '今日', reading: 'キョウ',
        ext_reading: nil, cost: 3947, wcost: 4263, right_context: 1314, left_context: 1314 },
      { id: 2, chunk: 0, surface: 'は', feature1: '助詞', feature2: '係助詞', baseform: 'は', reading: 'ハ', ext_reading: nil,
        cost: 4822, wcost: 3865, right_context: 261, left_context: 261 },
      { id: 3, chunk: 0, surface: '雨', feature1: '名詞', feature2: '一般', baseform: '雨', reading: 'アメ', ext_reading: nil,
        cost: 8801, wcost: 3942, right_context: 1285, left_context: 1285 },
      { id: 4, chunk: 0, surface: 'です', feature1: '助動詞', feature2: '*', baseform: 'です', reading: 'デス', ext_reading: nil,
        cost: 10_114, wcost: 4063, right_context: 460, left_context: 460 }
    ]

    expect(result).to eq test
  end

  it 'katakana' do
    expect(@text.ext_reading('あ')).to eq 'あ'
    expect(@text.ext_reading('ア')).to eq nil
  end

  it 'analysis' do
    result = @text.analysis(@text.cabocha_parser(input))
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
