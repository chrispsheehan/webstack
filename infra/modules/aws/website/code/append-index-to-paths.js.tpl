function handler(event) {
  var request = event.request;
  var uri = request.uri;

  var VERSION = "${version}";

  // Treat anything without a dot in the path as an SPA route
  var isAsset = uri.includes(".");

  if (!isAsset) {
    request.uri = "/" + VERSION + "/index.html";
  }

  return request;
}
