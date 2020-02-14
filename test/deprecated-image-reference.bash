chart_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
helm_render() {
  helm install dry-run "${chart_path}" --dry-run -f "${chart_path}/test/enable-all-images.yaml" "$@"
}

T_deprecatedImageReferenceExcludesTheDigest() {
  result="$(helm_render -f "$chart_path/test/deprecated/image.yaml" | grep -c "image: docker.io/shining/moonlight:some-tag@")"
  [[ $result -eq 0 ]]
}

T_deprecatedImageTag() {
  result="$(helm_render -f "$chart_path/test/deprecated/tag.yaml" | grep -c "image: docker.io/concourse/concourse:port-royal")"
  [[ $result -eq 3 ]]
}

T_deprecatedImageDigest() {
  result="$(helm_render -f "$chart_path/test/deprecated/digest.yaml" |
    grep -c "image: docker.io/concourse/concourse:some-tag@sha3-512:7865fd90d87d7a09a8d7d98d98f7c87a90d8f7fc0978e8e7d8d8c8d8e8d8ca")"
  [[ $result -eq 3 ]]
}

T_deprecatedImagePullPolicy() {
  result="$(helm_render -f "$chart_path/test/deprecated/imagePullPolicy.yaml" |
    grep -A1 "image: docker.io/concourse/concourse:some-tag" | grep -c 'imagePullPolicy: "Never"')"
  [[ $result -eq 3 ]]
}

T_deprecatedImagePullSecrets() {
  result="$(helm_render -f "$chart_path/test/deprecated/imagePullSecrets.yaml" |
    grep -A1 "imagePullSecrets:" | grep -c 'name: Never-praise-the-self')"
  [[ $result -eq 2 ]]
}

T_noDeprecationWarningByDefault() {
  result="$(helm_render | grep -c "https://github.com/helm/helm/issues/7154")"

  [[ $result -eq 0 ]]
}

T_deprecationWarningForImage() {  result=
  result="$(helm_render -f "$chart_path/test/deprecated/image.yaml" | grep -c "https://github.com/helm/helm/issues/7154")"
  [[ $result -eq 1 ]]
}

T_deprecationWarningForImageTag() {  result=
  result="$(helm_render -f "$chart_path/test/deprecated/tag.yaml" | grep -c "https://github.com/helm/helm/issues/7154")"
  [[ $result -eq 1 ]]
}

T_deprecationWarningForImageDigest() {  result=
  result="$(helm_render -f "$chart_path/test/deprecated/digest.yaml" | grep -c "https://github.com/helm/helm/issues/7154")"
  [[ $result -eq 1 ]]
}
