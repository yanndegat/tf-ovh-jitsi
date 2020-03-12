terraform {
  source = "../.."
}

remote_state {
  backend = "swift"
  config = {
    cloud             = "jitsi"
    region_name       = "GRA"
    container         = "jitsi"
    archive_container = "archive-jitsi"
    state_name        = "tfstate.tf"
  }
}

inputs = {
  name             = "jitsi"
  cloud_name       = "jitsi"
  region_name      = "GRA5"
  email            = "myjitsi@email.com"
  allowed_prefixes = ["${chomp(run_cmd("/bin/sh", "-c", "curl --silent --fail https://api.ipify.org"))}/32"]
}
