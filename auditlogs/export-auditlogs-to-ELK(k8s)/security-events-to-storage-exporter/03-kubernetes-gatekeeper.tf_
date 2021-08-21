

resource "null_resource" "git_clone" {
  provisioner "local-exec" {
    command = "git clone https://github.com/open-policy-agent/gatekeeper-library.git"
  }
}


resource "helm_release" "opa-gatekeeper" {
  name       = "opa-gatekeeper"
  repository = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart      = "gatekeeper"
  namespace = "gatekeeper"
  create_namespace = true
  

}

data "kustomization_build" "opa-library" {
  depends_on = [null_resource.git_clone,helm_release.opa-gatekeeper]

  path = "gatekeeper-library/library/"
}

resource "kustomization_resource" "opa-library" {
  for_each = data.kustomization_build.opa-library.ids

  manifest = data.kustomization_build.opa-library.manifests[each.value]
}