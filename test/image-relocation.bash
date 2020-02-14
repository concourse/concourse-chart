chart_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
helm_render() {
  helm install dry-run "${chart_path}" --dry-run -f "${chart_path}/test/enable-all-images.yaml" "$@"
}


xT_noImagePullSecretsByDefault() {
  result="$(helm_render | grep -c "imagePullSecrets")"
  [[ $result -eq 0 ]]
}

T_defaultImagePath() {
  result="$(helm_render | grep -c "image: docker.io/concourse/concourse:")"

  [[ $result -eq 3 ]]
}

T_useGlobalRegistry() {
  result="$(helm_render -f "${chart_path}/test/global/imageRegistry.yaml" |
    grep -c "image: registry.global/concourse/concourse:")"

  [[ $result -eq 3 ]]
}

T_useChartRegistry() {
  result="$(helm_render -f "${chart_path}/test/local/imageRegistry.yaml" |
    grep -c "image: concourse.local/concourse/concourse:")"

  [[ $result -eq 3 ]]
}

T_useImageRegistry() {
  result="$(helm_render -f "${chart_path}/test/image/registry.yaml" |
    grep -c "image: image.local/concourse/concourse:")"

  [[ $result -eq 3 ]]
}

T_chartRegistryOverridesGlobalRegistry() {
  result="$(helm_render -f "${chart_path}/test/local/imageRegistry.yaml" \
    -f "${chart_path}/test/global/imageRegistry.yaml" |
    grep -c "image: concourse.local/concourse/concourse:")"

  [[ $result -eq 3 ]]
}

T_imageRegistryOverridesChartAndGlobalRegistry() {
  result="$(helm_render -f "${chart_path}/test/local/imageRegistry.yaml" \
    -f "${chart_path}/test/image/registry.yaml" \
    -f "${chart_path}/test/global/imageRegistry.yaml" |
    grep -c "image: image.local/concourse/concourse:")"

  [[ $result -eq 3 ]]
}

T_useGlobalNamespace() {
  result="$(helm_render -f "${chart_path}/test/global/imageNamespace.yaml" |
    grep -c "image: docker.io/neversail/concourse:")"

  [[ $result -eq 3 ]]
}

T_useChartNamespace() {
  result="$(helm_render -f "${chart_path}/test/local/imageNamespace.yaml" |
    grep -c "image: docker.io/concourse-chart-space/concourse:")"

  [[ $result -eq 3 ]]
}

T_useImageNamespace() {
  result="$(helm_render -f "${chart_path}/test/image/namespace.yaml" |
    grep -c "image: docker.io/concourse-image-namespace/concourse:")"

  [[ $result -eq 3 ]]
}

T_chartNamespaceOverridesGlobalNamespace() {
  result="$(helm_render -f "${chart_path}/test/local/imageNamespace.yaml" \
    -f "${chart_path}/test/global/imageNamespace.yaml" |
    grep -c "image: docker.io/concourse-chart-space/concourse:")"

  [[ $result -eq 3 ]]
}

T_imageNamespaceOverridesChartAndGlobalNamespace() {
  result="$(helm_render -f "${chart_path}/test/local/imageNamespace.yaml" \
    -f "${chart_path}/test/image/namespace.yaml" \
    -f "${chart_path}/test/global/imageNamespace.yaml" |
    grep -c "image: docker.io/concourse-image-namespace/concourse:")"

  [[ $result -eq 3 ]]
}

