# Databricks — LTI 1.3 Setup with Moodle

Two options:

1. Native LTI from Databricks (if available)

- Provide issuer and OpenID config URL from Databricks.
- In Moodle, add External Tool by discovery URL; enable LTI Advantage (NRPS/AGS/Deep Linking).
- Create activities with `databricks_path` custom param for each module.

1. LTI Proxy (this repo)

- Deploy `services/lti-proxy-databricks` and expose it via HTTPS.
- In Moodle, configure a manual tool:
  - Public keys URL: `https://TOOL_HOST/.well-known/jwks.json`
  - Initiate login URL: `https://TOOL_HOST/oidc/login`
  - Redirection URI: `https://TOOL_HOST/lti/launch`
  - Services: NRPS + AGS + Deep Linking
  - Custom params (per activity): `databricks_path=/Workspace/Folders/3782085599803958/module-03-pyspark/...`

Grade passback (AGS)

- For graded items, check “Accept grades from the tool”.
- Implement AGS calls server-side (tool) to POST scores to Moodle (TODO in app.py).

Security

- Serve over HTTPS with a real certificate.
- Change `TOOL_COOKIE_SECRET` and restrict allowed issuers.
