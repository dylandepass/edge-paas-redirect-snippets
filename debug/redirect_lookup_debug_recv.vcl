# Snippet: redirect_lookup_debug_recv  (optional, debug only)
# Type:     recv
# Priority: 111
#
# Clears the trace at the start of each client request so clients can't
# inject their own.

if (req.restarts == 0) {
  unset req.http.X-RL-Trace;
}
