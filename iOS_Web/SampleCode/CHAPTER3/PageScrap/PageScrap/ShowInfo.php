<?php
	// 「PageScrap.php」ファイルを読み込む
	require_once "PageScrap.php";
    
	// 指定された情報を取得する
    $id = 0;
    if (isset($_GET['id']))
    {
        $id = $_GET['id'];
    }
    
    $info = getInfo($id);
?>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>
<?php
	if ($info)
	{
		// 情報が取得できたとき
		print($info['title']);
	}
	else
	{
		// 情報が見つからないとき
		print "指定された情報は見つかりません";
	}
?>
</title>
</head>
<body>
<?php
    if ($info == null)
    {
        // 情報が見つからないときはエラーメッセージを表示する
        print "<p><strong>指定された情報は見つかりません</p></strong>\n";
    }
    else
    {
        // タイトルを表示する
        print "<h1>" . $info['title'] . "</h1>\n";
        // 改行文字で「<br>」タグを追加しながら、内容を表示する
        print "<p>" . nl2br($info['contents']) . "</p>";
    }
?>
</body>
</html>
