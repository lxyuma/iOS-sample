<?php
// 「PageScrap.php」ファイルを読み込む
require_once "PageScrap.php";

// IDを取得する
$id = null;
if (isset($_GET['ID']))
$id = $_GET['ID'];

if ($id == null)
{
	// 必要なパラメータが足りない
	return;
}

// 情報を取得する関数を実行する
$info = getInfo($id);

// 取得した情報を出力する
if ($info)
{
	// IDを出力する
	print $id . "\n";
	
	// タイトルを出力する
	if ($info['title'])
		print $info['title'];
	print "\n";
	
	// URLを出力する
	if ($info['URL'])
		print $info['URL'];
	print "\n";
	
	// 内容を出力する
	if ($info['contents'])
		print $info['contents'];
}   
?>
