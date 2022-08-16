# HelloBybit - iOS版

bybitのAPIの練習用に資産残高を表示するサンプルアプリを作成しました。

<img width="435" alt="image" src="https://user-images.githubusercontent.com/20147818/184793356-d33dca89-eea9-41a8-8612-f6df165602d9.png">

## できること
- 現物とデリバティブの残高を表示します
- 現在の為替レートで円換算額を表示します
- 画面を下に引っ張ると最新の情報に更新できます

## 注意事項
- USDT建のみに対応しています
- ステーキング資産はbybitのAPIで取得できなかったのでコイン数をハードコードしています

## 開発環境
- macOS Monterey 12.5
- Xcode 12.4.1
- iOS 15.6

## 参考
[bybit API](https://bybit-exchange.github.io/docs/inverse/#t-introduction)
