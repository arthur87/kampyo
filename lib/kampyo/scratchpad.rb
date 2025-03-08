# frozen_string_literal: true

require 'sqlite3'
require 'active_record'
require 'singleton'

module Kampyo
  class Scratchpad
    include Singleton

    def initialize
      database = ':memory:'

      ActiveRecord::Migration.verbose = false
      ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: database
      )

      InitialRecord.migrate(:up)
    end

    def self.reset
      InitialRecord.migrate(:down)
      InitialRecord.migrate(:up)
    end
  end
end

# モデル
class Chunk < ActiveRecord::Base
end

class Token < ActiveRecord::Base
end

class MecabToken < ActiveRecord::Base
end

# テーブル
class InitialRecord < ActiveRecord::Migration[4.2]
  def self.up
    create_table :chunks do |t|
      t.integer :link
      t.float :score
    end

    create_table :tokens do |t|
      t.integer :chunk
      t.string :surface
      t.string :feature1
      t.string :feature2
      t.string :baseform
      t.string :reading
      t.string :ext_reading
      t.float :sentiment_score
    end

    create_table :mecab_tokens do |t|
      t.integer :chunk
      t.string :surface
      t.string :feature1
      t.string :feature2
      t.string :baseform
      t.string :reading
      t.string :ext_reading
      t.integer :cost # 累積コスト
      t.integer :wcost # 単語生起コスト
      t.integer :right_context # 右文脈
      t.integer :left_context # 左文脈
    end
  end

  def self.down
    drop_table :chunks
    drop_table :tokens
    drop_table :mecab_tokens
  end
end
