# Snippet: redirect_lookup_fetch
# Type:     fetch
# Priority: 20  (must run before edge_deliver_fetch at 30)
#
# Classifies and caches Magento's answer to the lookup. This snippet never
# restarts: restarting from vcl_fetch loses request state under clustering.
# vcl_deliver reads the X-Redirect-Result label and decides what to do.

declare local var.rl_loc_path STRING;
declare local var.rl_public STRING;

if (req.http.X-Redirect-Lookup == "magento") {
  unset beresp.http.Set-Cookie;
  unset beresp.http.Vary;
  set beresp.cacheable = true;
  set beresp.http.Surrogate-Key = "redirect-lookup";

  # Path the redirect points to, without host and query string.
  set var.rl_loc_path = regsub(regsub(beresp.http.Location, "^https?://[^/]+", ""), "[?#].*$", "");

  if (http_status_matches(beresp.status, "301,302,307,308") && beresp.http.Location
      && var.rl_loc_path != req.url.path) {
    # A real URL rewrite: the path changes. Point Magento origin hostnames at
    # the public host the visitor used.
    set var.rl_public = "https://" req.http.host "\1";
    set beresp.http.Location = regsub(beresp.http.Location, "^https?://[^/]*\.magento\.cloud(/|$)", var.rl_public);
    set beresp.ttl = 3600s;
    set beresp.http.Cache-Control = "public, max-age=300";
    set beresp.http.X-Redirect-Result = "magento-redirect";
  } else if (beresp.status >= 500) {
    set beresp.ttl = 30s;
    set beresp.http.X-Redirect-Result = "magento-error";
  } else if (http_status_matches(beresp.status, "301,302,307,308")) {
    # Same path on a different host: Magento's "Auto-redirect to Base URL",
    # not a URL rewrite. Treat as "no redirect".
    set beresp.ttl = 600s;
    set beresp.http.X-Redirect-Result = "magento-host-redirect";
  } else {
    set beresp.ttl = 600s;
    set beresp.http.X-Redirect-Result = "magento-miss";
  }
  return(deliver);
}
