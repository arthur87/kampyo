# frozen_string_literal: true

require 'kampyo/text'

RSpec.describe Kampyo::Text do # rubocop:disable Metrics/BlockLength
  let(:input) { '今日は雨です' }

  before do
    @text = Kampyo::Text.new
  end

  it 'cabocha_parser' do
    @text.cabocha_parser(input)

    test = [
      { id: 1, link: 2 },
      { id: 2, link: -1 },
      { id: 3, link: 2 },
      { id: 4, link: -1 }
    ]

    Chunk.all.each_with_index do |chunk, i|
      expect(chunk.id).to eq test[i][:id]
      expect(chunk.link).to eq test[i][:link]
    end
  end

  it 'mecab_parser' do
    @text.mecab_parser(input)

    test = [
      { id: 1, surface: '今日' },
      { id: 2, surface: 'は' },
      { id: 3, surface: '雨' },
      { id: 4, surface: 'です' }
    ]

    MecabToken.all.each_with_index do |token, i|
      expect(token.id).to eq test[i][:id]
      expect(token.surface).to eq test[i][:surface]
    end
  end

  it 'katakana' do
    expect(@text.ext_reading('あ')).to eq 'あ'
    expect(@text.ext_reading('ア')).to eq nil
  end

  it 'analysis' do
    analysis = @text.analysis
    expect(analysis[:subject][:surface]).to eq '今日'
    expect(analysis[:predicate][:surface]).to eq '雨'
    expect(analysis[:tod]).to eq '断定'
  end
end
