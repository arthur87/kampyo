<!---------------------------->
<!-- multilingual suffix: en, ja -->
<!-- no suffix: en -->
<!---------------------------->

<!-- $ mmg README.base.md -->

# kampyo

kampyo is a library for conveniently manipulating Cabocha and Mecab.

kampyo has its own analysis function.

Unique features already implemented are subject and predicate, and stylistic inference.

# Guide

Using Cabocha.

```
text = Kampyo::Text.new
text.cabocha_parser("今日は雨です")
```

Guess the subject, predicate and sentence system.

```
text = Kampyo::Text.new
text.analysis(text.cabocha_parser("今日は雨です"))
```