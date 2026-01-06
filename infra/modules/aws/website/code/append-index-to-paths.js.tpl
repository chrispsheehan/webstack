function handler(event) {
  var request = event.request;
  var uri = request.uri;

  // Treat anything without a dot in the path as an SPA route
  var isAsset = uri.includes(".");

  if (!isAsset) {
    request.uri = "/index.html";
  }

  return request;
}
