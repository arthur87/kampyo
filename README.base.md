<!---------------------------->
<!-- multilingual suffix: en, ja -->
<!-- no suffix: en -->
<!---------------------------->

<!-- $ mmg README.base.md -->

# kampyo

[![Gem Version](https://badge.fury.io/rb/kampyo.svg)](https://badge.fury.io/rb/kampyo)

kampyo is a library for conveniently manipulating Cabocha and Mecab.

kampyo has its own analysis function.

Unique features already implemented are subject and predicate, and stylistic inference.

# Guide

Basic usage with Cabocha.

```
cabocha = Kampyo::Cabocha.new
cabocha.parser("今日は雨です")
```

You will get the following result.

```
{:chunks=>[{:id=>1, :link=>2, :score=>0.0}, {:id=>2, :link=>-1, :score=>0.0}],
 :tokens=>
  [{:id=>1, :chunk=>1, :surface=>"今日", :feature1=>"名詞", :feature2=>"副詞可能", :baseform=>"今日", :reading=>"キョウ", :ext_reading=>nil},
   {:id=>2, :chunk=>1, :surface=>"は", :feature1=>"助詞", :feature2=>"係助詞", :baseform=>"は", :reading=>"ハ", :ext_reading=>nil},
   {:id=>3, :chunk=>2, :surface=>"雨", :feature1=>"名詞", :feature2=>"一般", :baseform=>"雨", :reading=>"アメ", :ext_reading=>nil},
   {:id=>4, :chunk=>2, :surface=>"です", :feature1=>"助動詞", :feature2=>"*", :baseform=>"です", :reading=>"デス", :ext_reading=>nil}]}
```

Guess the subject, predicate and sentence system.

```
cabocha = Kampyo::Cabocha.new
cabocha.analysis(text.parser("今日は雨です"))
```

You will get the following result.

```
{:subject=>{:id=>1, :chunk=>1, :surface=>"今日", :feature1=>"名詞", :feature2=>"副詞可能", :baseform=>"今日", :reading=>"キョウ", :ext_reading=>nil},
 :predicate=>{:id=>3, :chunk=>2, :surface=>"雨", :feature1=>"名詞", :feature2=>"一般", :baseform=>"雨", :reading=>"アメ", :ext_reading=>nil},
 :tod=>"断定"}
```