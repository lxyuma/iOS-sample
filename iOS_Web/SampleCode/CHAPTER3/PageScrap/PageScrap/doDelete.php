<?php
// 「PageScrap.php」ファイルを読み込む
require_once "PageScrap.php";

// IDを取得する
$id = null;
if (isset($_POST['ID']))
$id = $_POST['ID'];

if ($id == null)
{
	// 必要なパラメータが足りない
	return "0";
}

// 削除用の関数を実行する
if (deleteInfo($id))
print "1";  // 成功
else
print "0";  // 失敗
?>
