# Snippet: redirect_lookup_hash
# Type:     hash
# Priority: 10
#
# Gives the Magento lookup its own cache key. Without this, the lookup for a
# URL would find the EDS 404 cached under the same key and never reach Magento.
#
# After activating, check the generated VCL: this snippet must appear in
# vcl_hash before the default "return (hash);".

if (req.http.X-Redirect-Lookup == "magento") {
  set req.hash += "redirect-lookup";
}
