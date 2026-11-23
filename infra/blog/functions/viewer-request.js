// CloudFront Function（viewer-request）
// - 旧ドメイン（tech-lablog.com）からのアクセスを、同じパスのまま新ドメインへ 301 転送する
// - /slug/ を /slug/index.html に書き換える（OAC 経由の S3 は index.html を自動で返さないため）
// - 拡張子のない /slug は /slug/ へ 301 転送する
var CANONICAL_ORIGIN = 'https://blog.admon-networks.com';
var REDIRECT_HOSTS = ['tech-lablog.com', 'www.tech-lablog.com'];

function handler(event) {
  var request = event.request;
  var host = request.headers.host ? request.headers.host.value : '';
  var uri = request.uri;

  if (REDIRECT_HOSTS.indexOf(host) !== -1) {
    return redirect(CANONICAL_ORIGIN + uri);
  }

  if (uri.endsWith('/')) {
    request.uri = uri + 'index.html';
    return request;
  }

  // 最後の / より後ろにドットがなければ、拡張子のないパスとみなす
  if (uri.lastIndexOf('.') <= uri.lastIndexOf('/')) {
    return redirect(uri + '/');
  }

  return request;
}

function redirect(location) {
  return {
    statusCode: 301,
    statusDescription: 'Moved Permanently',
    headers: { location: { value: location } }
  };
}
