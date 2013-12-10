<?php
	// 「PageScrap.php」ファイルを読み込む
	require_once "PageScrap.php";
?>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>PageScrapリストページ</title>
</head>
<body>
<p>表示したい情報をクリックしてください</p>
<ul>
<?php
	// 全情報を取得する
	$records = getAllInfo();
	
	// 取得した情報ごとに項目を作成する
	foreach($records as $record)
	{
		// リンク先のURLを作成する
		// 表示する情報はフィールド「ID」の値で指定する
		// IDの値はURLパラメータ「id」の値として渡す
		$url = "ShowInfo.php?id=" . $record['ID'];
		
		// タグを出力する
		print "<li><a href=\"$url\">" .
		$record['title'] . "</a></li>\n";
	}
?>
</ul>
</body>
</html>
