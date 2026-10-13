# Snippet: redirect_lookup_recv
# Type:     recv
# Priority: 110  (must run after edge_delivery_recv at 100)
#
# Routes the restarted lookup request to the Commerce (Magento) backend.
# Replace F_REPLACE_WITH_COMMERCE_BACKEND with the backend your
# edge_delivery_recv snippet uses for Commerce routes.

# Trust the lookup marker only on our own restarts, never from the client.
if (req.restarts == 0) {
  unset req.http.X-Redirect-Lookup;
}

# Pass 1: ask Magento. edge_delivery_recv has already routed this path to
# Edge Delivery Services, so override it here.
if (req.http.X-Redirect-Lookup == "magento") {
  set req.backend = F_REPLACE_WITH_COMMERCE_BACKEND;
  set req.http.x-commerce = "true";
}
# Pass 2 ("final") needs nothing: edge_delivery_recv routes back to EDS.

# A restart turns off clustering, which would cache lookup results per server
# instead of per POP. Turn it back on for our restarted passes.
if (req.restarts > 0 && req.http.X-Redirect-Lookup) {
  set req.http.Fastly-Force-Shield = "1";
}
