// tech-lablog.com へのアクセスを、blog.admon-networks.com の同じパスへ 301 で転送する
var NEW_ORIGIN = 'https://blog.admon-networks.com';

function handler(event) {
  var request = event.request;
  var location = NEW_ORIGIN + request.uri;

  // クエリ文字列（?p=123 など）も引き継ぐ
  var params = [];
  for (var key in request.querystring) {
    var param = request.querystring[key];
    var values = param.multiValue ? param.multiValue : [param];
    values.forEach(function (v) {
      params.push(v.value === '' ? key : key + '=' + v.value);
    });
  }
  if (params.length > 0) {
    location += '?' + params.join('&');
  }

  return {
    statusCode: 301,
    statusDescription: 'Moved Permanently',
    headers: {
      location: { value: location },
      'cache-control': { value: 'max-age=86400' }
    }
  };
}
