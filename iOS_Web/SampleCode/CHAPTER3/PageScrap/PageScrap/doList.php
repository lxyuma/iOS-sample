<?php
// 「PageScrap.php」ファイルを読み込む
require_once "PageScrap.php";

// 情報の一覧を取得する
$array = getAllInfo();

// 配列内の要素ごとに出力する
foreach($array as $info)
{
	// ID,title形式で出力して改行する
	print $info['ID'] . "," . $info['title'] . "\n";
}
?>
