# frozen_string_literal: true

require 'kampyo/text'

RSpec.describe Kampyo::Text do
  let(:input) { '今日は雨です' }

  before do
    @text = Kampyo::Text.new
  end

  it 'katakana' do
    expect(@text.ext_reading('あ')).to eq 'あ'
    expect(@text.ext_reading('ア')).to eq nil
  end
end
