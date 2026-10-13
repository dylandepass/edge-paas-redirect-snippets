# Snippet: redirect_lookup_deliver
# Type:     deliver
# Priority: 40  (after edge_delivery_deliver at 30)
#
# Drives the lookup. Restarts happen here, not in vcl_fetch, because
# vcl_deliver always runs on the server that handles the client request, so
# the X-Redirect-Lookup marker survives the restart.

# Pass 0 -> 1: EDS returned 404 for an eligible legacy URL. Ask Magento.
# Adjust the path pattern to match your legacy URLs.
if (!req.http.X-Redirect-Lookup && !req.http.x-commerce
    && resp.status == 404
    && req.url.path ~ "\.html$"
    && (req.request == "GET" || req.request == "HEAD")) {
  set req.http.X-Redirect-Lookup = "magento";
  restart;
}

# Pass 1 -> 2: serve Magento's redirect, otherwise go back to EDS for its 404.
if (req.http.X-Redirect-Lookup == "magento") {
  if (!(resp.http.X-Redirect-Result == "magento-redirect")) {
    set req.http.X-Redirect-Lookup = "final";
    restart;
  }
}

# Internal label; never send it to clients.
unset resp.http.X-Redirect-Result;
