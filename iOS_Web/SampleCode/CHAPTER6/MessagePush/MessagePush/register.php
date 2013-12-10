<?php

// 「MessagePush.php」ファイルを読み込む
require_once "/Library/WebServer/MessagePushDB.php";

// POSTからトークンを取得する
$token = null;

// POSTにキー「token」で値が設定されているかチェックする
if (!isset($_POST['token']))
{
	// 設定されていないので、エラーを出力して中断する
	print "-1";
	exit;
}

// 値を取得する
$token = $_POST['token'];

// 出力する値を入れる変数
$result = -1;

// DBに接続する
$db = connectToDB();

if ($db)
{
	// 登録済みかどうかを調べるために、デバイストークンを使って検索する
	$q = "SELECT token FROM device WHERE token='$token'";
	$res = mysql_query($q);
	
	if ($res)
	{
		// 行が取得できなければ、未登録のデバイストークン
		if (!mysql_fetch_row($res))
		{
			// まだ登録されていないデバイストークンなので
			// テーブルに追加する
			$q = "INSERT INTO device (token) VALUES ('$token')";
			
			if (mysql_query($q))
			{
				// 登録成功
				$result = 0;
			}           
		}
		else
		{
			// 登録済みのデバイストークン
			// この場合は成功として返す
			$result = 0;
		}
	}
	
	// DBから切断する
	mysql_close($db);
}

// 結果を返す
print $result;

?>
