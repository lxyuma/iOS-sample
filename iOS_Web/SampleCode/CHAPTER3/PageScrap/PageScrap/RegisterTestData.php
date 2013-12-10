<?php
// 「PageScrap.php」ファイルを読み込む
require_once "PageScrap.php";

// テストデータを登録する
insertNewInfo("http://localhost/manual/",
			  "Apacheサーバドキュメント");
insertNewInfo("http://localhost/manual/invoking.html",
			  "Apacheの起動");
insertNewInfo("http://localhost/manual/stopping.html",
			  "停止と再起動");
insertNewInfo("http://localhost/manual/glossary.html",
			  "用語");
insertNewInfo("http://localhost/manual/configuring.html",
			  "設定ファイル");
// 完了メッセージを表示する
echo "Registered test data.";
?>
