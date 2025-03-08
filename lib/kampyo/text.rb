# frozen_string_literal: true

require 'kampyo'
require 'kampyo/scratchpad'
require 'kampyo/string'
require 'cabocha'
require 'mecab'

module Kampyo
  class Text
    def initialize
      Kampyo::Scratchpad.instance
    end

    def parse(input)
      # データベースをリセットする
      Kampyo::Scratchpad.reset

      cabocha_parser(input)
      mecab_parser(input)

      {
        query: input,
        chunks: Chunk.all,
        tokens: Token.all
      }.merge(analysis)
    end

    def cabocha_parser(input)
      # <sentence>
      #  <chunk id="0" link="1" rel="D" score="0.000000" head="0" func="1">
      #   <tok id="0" feature="名詞,副詞可能,*,*,*,*,今日,キョウ,キョー" ne="B-DATE">今日</tok>
      #   <tok id="1" feature="助詞,係助詞,*,*,*,*,は,ハ,ワ" ne="O">は</tok>
      #  </chunk>
      #  <chunk id="1" link="-1" rel="D" score="0.000000" head="2" func="3">
      #   <tok id="2" feature="名詞,一般,*,*,*,*,雨,アメ,アメ" ne="O">雨</tok>
      #   <tok id="3" feature="助動詞,*,*,*,特殊・デス,基本形,です,デス,デス" ne="O">です</tok>
      #  </chunk>
      # </sentence>

      parser = CaboCha::Parser.new
      tree = parser.parse(input)

      token_position = 0
      (0..tree.chunk_size - 1).each do |i|
        chunk = tree.chunk(i)
        token_size = chunk.token_size

        Chunk.create({
                       link: chunk.link >= 0 ? chunk.link + 1 : -1,
                       score: chunk.score
                     })

        (token_position..token_position + token_size - 1).each do |j|
          token = tree.token(j)

          surface = token.surface.to_utf8
          feature0 = token.feature_list(0).to_utf8
          feature1 = token.feature_list(1).to_utf8
          feature6 = token.feature_list(6).to_utf8
          feature7 = token.feature_list(7).to_utf8

          Token.create({
                         chunk: i + 1,
                         surface: surface,
                         feature1: feature0,
                         feature2: feature1,
                         baseform: feature6,
                         reading: feature7,
                         ext_reading: ext_reading(feature7)
                       })
        end

        token_position += token_size
      end
    end

    def mecab_parser(input)
      parser = MeCab::Tagger.new
      node = parser.parseToNode(input)
      while node
        features = node.feature.split(',')
        if features[0] != 'BOS/EOS'
          MecabToken.create({
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
                            })
        end
        node = node.next
      end
    end

    def ext_reading(feature)
      (feature =~ /\A[\p{katakana}|ー]+\z/).nil? ? feature : nil
    end

    def analysis
      subject_token = nil
      predicate_token = nil
      tod = '*'

      # 述語の候補
      predicate_chunk = Chunk.find_by(link: -1)
      predicate_tokens = Token.where({
                                       chunk: predicate_chunk.id
                                     }).order('id asc')

      # 主語の候補
      subject_chunk = Chunk.find_by(link: predicate_chunk.id)
      if subject_chunk.present?
        subject_tokens = Token.where({
                                       chunk: subject_chunk.id,
                                       feature1: ['名詞'],
                                       feature2: %w[一般 固有名詞 サ変接続 接尾 数 副詞可能]
                                     }).order('id asc')

        subject_tokens.each do |token|
          next_token = Token.find_by({
                                       id: token.id + 1,
                                       chunk: token.chunk,
                                       baseform: %w[は って も が]
                                     })

          next unless next_token.present?

          # 主語として確定する
          subject_token = token
          next
        end
      end

      predicate_tokens.each do |token|
        if %w[形容詞 動詞 名詞].include?(token.feature1) &&
           %w[一般 自立 サ変接続 接尾].include?(token.feature2) &&
           token.baseform != '*'
          # 述語として確定する

          predicate_token = token
        end

        next unless %w[動詞 終助詞 助動詞 助詞].include?(token.feature1)

        # 文体系を確定する
        tods = {
          'れる' => '受身・尊敬・可能・自発',
          'られる' => '受身・尊敬・可能・自発',
          'せる' => '使役',
          'させる' => '使役',
          'ない' => '打消',
          'ぬ' => '打消',
          'ん' => '打消',
          'う' => '推量・意志・勧誘',
          'よう' => '推量・意志・勧誘',
          'まい' => '打消推量・打消意志',
          'たい' => '希望',
          'たがる' => '希望',
          'た' => '過去・完了・存在・確認',
          'ます' => '丁寧',
          'そうだ' => '様態・伝聞',
          'らしい' => '推定',
          'ようだ' => '比況・例示・推定',
          'だ' => '断定',
          'です' => '断定',
          'な' => '禁止・感動',
          'か' => '疑問・反語・感動',
          'の' => '断定・質問',
          'よ' => '強意・呼びかけ',
          'ぞ' => '強意',
          'も' => '確信',
          'ね' => '感動・念押し',
          'わ' => '感動・強意',
          'さ' => '断定'
        }

        tod = tods[token.baseform]
      end

      last_token = predicate_tokens.last

      if predicate_token.nil? && ['助動詞'].include?(last_token.feature1)
        # 述語が確定していないとき最後の助動詞を述語として確定する
        predicate_token = last_token
      end

      if ['?', '？'].include?(last_token.surface)
        # 述語の最後の形態素が?のとき
        tod = '疑問・反語・感動'
      end

      {
        subject: subject_token,
        predicate: predicate_token,
        tod: tod
      }
    end
  end
end
