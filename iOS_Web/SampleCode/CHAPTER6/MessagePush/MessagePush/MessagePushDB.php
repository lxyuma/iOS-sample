<?php

// MySQLサーバへ接続する関数
// 使用する場所で毎回ユーザー名などを記述しないようにするために
// 関数化している。
function connectToDB()
{
	$userName = "root"; // MySQLサーバの管理者名
	$password = "test"; // MySQLサーバの管理者パスワード
	$server = "localhost";  // MySQLサーバを実行しているサーバアドレス
	$db = mysql_connect($server, $userName, $password);
	
	if ($db != false)
	{
		// データベース「MessagePush」を使うように設定する
		mysql_selectdb("MessagePush");
		
		// テキストエンコーディングにUTF-8を使用する
		mysql_set_charset('utf-8');
	}
	
	return $db;
}

?>
