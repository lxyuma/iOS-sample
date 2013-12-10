<?php
// 「PageScrap.php」ファイルを読み込む
require_once "PageScrap.php";

// URLを取得する
$url = null;
if (isset($_POST['URL']))
$url = $_POST['URL'];

// タイトルを取得する
$title = null;
if (isset($_POST['title']))
$title = $_POST['title'];

if ($url == null || $title == null)
{
	// 必要なパラメータが足りない
	print "0";
	return;
}

// 登録用の関数を実行する
if (insertNewInfo($url, $title))
print "1";  // 成功
else
print "0";  // 失敗
?>
