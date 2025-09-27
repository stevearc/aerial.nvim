group "default" {
  targets = ["app", "infra"]
}

target "app" {
  context    = "."
  dockerfile = "images/app/Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["${REPO_URL}/app_bake:${IMAGE_TAG_VERSION_APP}"]
  attest = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
}

target "infra" {
  context    = "."
  dockerfile = "images/infra/Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["${REPO_URL}/infra_bake:${IMAGE_TAG_VERSION_INFRA}"]
  attest = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
}
