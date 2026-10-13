# Snippet: redirect_lookup_debug_deliver  (optional, debug only)
# Type:     deliver
# Priority: 35  (must run before redirect_lookup_deliver at 40)
#
# vcl_deliver runs once per pass, before redirect_lookup_deliver decides
# whether to restart. This snippet appends one entry per pass to X-RL-Trace
# and returns it on the final response. It only runs when the request sends
# Fastly-Debug or X-Redirect-Test, so it costs nothing otherwise.

if (req.http.Fastly-Debug || req.http.X-Redirect-Test) {
  set req.http.X-RL-Trace = if(req.http.X-RL-Trace, req.http.X-RL-Trace " | ", "")
    "pass=" req.restarts
    " lookup=" if(req.http.X-Redirect-Lookup, req.http.X-Redirect-Lookup, "none")
    " status=" resp.status
    " cache=" fastly_info.state
    " result=" if(resp.http.X-Redirect-Result, resp.http.X-Redirect-Result, "-")
    " age=" if(resp.http.Age, resp.http.Age, "-");
  set resp.http.X-RL-Trace = req.http.X-RL-Trace;
}
