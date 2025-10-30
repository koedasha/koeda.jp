---
date: 2025-10-30
title: WEBrickでWebSocketとSSE
author: simaaaji
---
この個人事業のホームページを作る時にHTMLをDRYに書きたくて作った静的サイトジェネレータ、開発用サーバには Ruby実装で安定しているWEBRickを使っている。

サーバにホットリロードの機能を実装しようとして、最終的にはブラウザが自動で繋ぎ直してくれるSSEを採用したんだけどその過程でWebSocketとSSEの実装方法を調べたので書いておきたい。

### WebSocket

これはホットリロードに必要なブロードキャスト処理のみ実装した。WebSocketはバイナリのフレーム処理が手間なのでちゃんとやるならライブラリ使ったほうが良いと思うが今回のような要件だけなら自前実装でもなんとかなった。[こちらの記事](https://zenn.dev/mesi/articles/0dbe8e182e4e4a)のおかげ。

接続維持の仕組みとしてはSSEより単純で、ハンドシェイクリクエストが来た時にソケットを配列に保存して保持しておく。

この時にソケットのcloseメソッドが呼ばれても実際には接続を閉じないようにメソッドオーバーライドしたオブジェクトを渡すことでソケット接続を維持する。

~~~
module DontCloseAfterNonKeepAliveResponse
  def web_socket_closed? = !!@_ws_closed
  def close_web_socket
    @_ws_closed = true
    close
  end

  def close
    super if @_ws_closed
  end
end

def handshake(req, res)
  ws_key = req.header["sec-websocket-key"].first
  response_key = Digest::SHA1.base64digest([ ws_key, "258EAFA5-E914-47DA-95CA-C5AB0DC85B11" ].join)

  res.status = 101
  res.upgrade!("websocket")
  res["Sec-WebSocket-Accept"] = response_key

  sockets << req.instance_variable_get(:@socket).tap do
    it.extend(DontCloseAfterNonKeepAliveResponse)
  end
end
~~~

以降は保存したソケットにデータを流すとブラウザまで届いてくれる。

最終的にSSEを利用することになったので全体の実装は[ここに供養した](https://gist.github.com/simaaaji/a5d775aa04f0a9a9739589198866d2c8)。

### SSE

WEBrickはレスポンスのbodyにreadpartialに応答するオブジェクトを設定すると[readpartialでデータを読み込んでクライアントに送るようになっている](https://github.com/ruby/webrick/blob/master/lib/webrick/httpresponse.rb#L480)。

そこで、StringIOのreadpartialメソッドを改変してEOFErrorなどを発生させないようにしたオブジェクトを、SSE用のパスにリクエストが来た時にbodyに設定する。

すると、WEBrickはリクエストごとにスレッドを立ち上げるので、SSEエンドポイントへのリクエストはスレッドが終了せずにこのオブジェクトからのデータを待ち受けてデータがあればソケットに送り込んでくれるようになる。

そしてデータを送りたい時にはこのオブジェクトを配列に保存しておいて文字列を送り込むとブラウザまで届く。

~~~
class FileChangeStream < StringIO
  def readpartial(len, buf = +"")
    partial = nil

    while !closed? && !partial
      rewind
      partial = read_nonblock(len, buf, exception: false)
      sleep 0.1
    end

    string.clear

    partial
  end
end

server.mount_proc "/_file_changes" do |req, res|
  res["Content-Type"] = "text/event-stream"
  res.chunked = true
  res.keep_alive = true

  FileChangeStream.new.tap do |stream|
    file_change_streams << stream
    res.body = stream
  end
end
~~~

sleep 0.1はGIL解放のため。これがないとロックが働いて他のリクエストを処理できなくなってしまう。

全体実装は[こんな感じ](https://github.com/koedasha/hotpages/blob/5d4346bdf931f36709243e1300ee144575ff14c1/lib/hotpages/extensions/hot_reloading.rb#L40-L91)。
