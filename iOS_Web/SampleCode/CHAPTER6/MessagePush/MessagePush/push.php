<?php

// 「MessagePush.php」ファイルを読み込む
require_once "/Library/WebServer/MessagePushDB.php";

// 指定したデバイスに通知する関数
function pushNotification($apnsStream, $deviceToken, $payload)
{
	// デバイストークンを16進文字列からバイナリ文字列に変換する
	$tokenBin = pack('H*', $deviceToken);
	
	// ペイロードの長さを取得する
	$len = strlen($payload);
	
	if ($len > 256)
		return; // ペイロードが長過ぎる
	
	// APNsに送信するバイト列を作成する
	$buf = chr(0) . chr(0) . chr(32) . $tokenBin .
	chr(($len >> 8) & 0xFF) . chr($len & 0xFF) . $payload;
	
	// APNsに送信する
	fwrite($apnsStream, $buf);
}

// 入力内容を取得する
// 通知内容を取得する
$msg = "";
if (isset($_POST['msg']))
$msg = $_POST['msg'];

// 効果音を取得する
$sound = "default";
if (isset($_POST['sound']))
$sound = $_POST['sound'];

// 背景色を取得する
$color = "FFFFFF";
if (isset($_POST['color']))
$color = $_POST['color'];

// 定数を定義する
// 接続先のURLを定義する
// ここでは、Sandbox環境のURLを使用する
// App Storeで配布を開始するときには、Production環境に変更する
$url = "ssl://gateway.sandbox.push.apple.com:2195";

// 証明書のファイルパス
$certFile = "/Library/WebServer/aps_developer.pem";

// 通信を行うためのストリームコンテキストを作成する
$context = stream_context_create();

// SSL証明書を使って暗号化するので、ストリームコンテキストに設定する
stream_context_set_option($context, 'ssl', 'local_cert', $certFile);

// APNsとの間でソケット接続を行う
$stream = stream_socket_client($url, $errno, $errstr, 60,
							   STREAM_CLIENT_CONNECT, $context);

if ($stream != FALSE)
{
	// 接続できたので、送信するペイロードを作成する
	// キー「aps」に格納する連想配列を作成する
	$apsDict = array("alert" => $msg,
					 "sound" => $sound);
	
	// ペイロード全体の連想配列を作成する
	$payloadDict = array("aps" => $apsDict,
						 "color" => $color);
	
	// 連想配列をJSONでエンコードする
	$payload = json_encode($payloadDict);
	
	// デバイスごとに通知を行う
	// DBに接続する
	$db = connectToDB();
	
	if ($db)
	{
		// 全デバイストークンを取得する
		$q = "SELECT token FROM device";
		$res = mysql_query($q);
		
		if ($res)
		{
			// 1レコードずつ処理する
			while ($row = mysql_fetch_assoc($res))
			{
				// このデバイスに通知する
				pushNotification($stream, $row['token'], $payload);
			}
		}
		
		// DBから切断する
		mysql_close($db);
	}
	
	// ソケットを閉じる
	fclose($stream);
}

require_once "./push.html"; // 表示するページを読み込む

?>
