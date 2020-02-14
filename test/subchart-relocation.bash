chart_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

helm_command() {
  helm install dry-run "${chart_path}" --dry-run -f "${chart_path}/test/enable-all-images.yaml" "$@"
}

T_globalRegistryAndNamespace() {
  result="$(helm_command -f "$chart_path/test/global/imageRegistry.yaml" \
    -f "$chart_path/test/global/imageNamespace.yaml" | grep -c "image: registry.global/neversail/")"
  [[ $result -eq 8 ]]
}

T_useOriginalRegistryForConcourseChart() {
  output="$(helm_command -f "$chart_path/test/global/imageRegistry.yaml" -f "$chart_path/test/local/useOriginalRegistry.yaml")"
  
  concourse_image_count="$(echo "${output}" | grep -c "image: docker.io")"
  postgresql_image_count="$(echo "${output}" | grep -c "image: registry.global")"

  [[ $concourse_image_count -eq 3 ]] && [[ $postgresql_image_count -eq 5 ]]
}

T_useOriginalNamespaceForConcourseChart() {
  output="$(helm_command -f "$chart_path/test/global/imageNamespace.yaml" -f "$chart_path/test/local/useOriginalNamespace.yaml")"
  
  concourse_image_count="$(echo "${output}" | grep -c "image: docker.io/concourse/")"
  postgresql_image_count="$(echo "${output}" | grep -c "image: docker.io/neversail/")"

  [[ $concourse_image_count -eq 3 ]] && [[ $postgresql_image_count -eq 5 ]]
}

T_useOriginalRegistryForConcourseImage() {
  output="$(helm_command -f "$chart_path/test/global/imageRegistry.yaml" -f "$chart_path/test/image/useOriginalRegistry.yaml")"

  concourse_image_count="$(echo "${output}" | grep -c "image: docker.io")"
  postgresql_image_count="$(echo "${output}" | grep -c "image: registry.global")"

  [[ $concourse_image_count -eq 3 ]] && [[ $postgresql_image_count -eq 5 ]]
}

T_useOriginalNamespaceForConcourseImage() {
  output="$(helm_command -f "$chart_path/test/global/imageNamespace.yaml" -f "$chart_path/test/image/useOriginalNamespace.yaml")"

  concourse_image_count="$(echo "${output}" | grep -c "image: docker.io/concourse/")"
  postgresql_image_count="$(echo "${output}" | grep -c "image: docker.io/neversail/")"

  [[ $concourse_image_count -eq 3 ]] && [[ $postgresql_image_count -eq 5 ]]
}

T_useOriginalRegistryForPostgresqlChart() {
  output="$(helm_command -f "$chart_path/test/global/imageRegistry.yaml" -f "$chart_path/test/postgresql/chart/useOriginalRegistry.yaml")"

  concourse_image_count="$(echo "${output}" | grep -c "image: registry.global/concourse/")"
  postgresql_image_count="$(echo "${output}" | grep -c "image: docker.io/bitnami/")"

  [[ $concourse_image_count -eq 3 ]] && [[ $postgresql_image_count -eq 5 ]]
}

T_useOriginalNamespaceForPostgresqlChart() {
  output="$(helm_command -f "$chart_path/test/global/imageNamespace.yaml" -f "$chart_path/test/postgresql/chart/useOriginalNamespace.yaml")"

  concourse_image_count="$(echo "${output}" | grep -c "image: docker.io/neversail/")"
  postgresql_image_count="$(echo "${output}" | grep -c "image: docker.io/bitnami/")"

  [[ $concourse_image_count -eq 3 ]] && [[ $postgresql_image_count -eq 5 ]]
}

T_useOriginalRegistryForPostgresqlImage() {
  output="$(helm_command -f "$chart_path/test/global/imageRegistry.yaml" -f "$chart_path/test/postgresql/image/useOriginalRegistry.yaml")}"

  custom_image_count="$(echo "${output}" | grep -c "image: registry.global/")"
  original_image_count="$(echo "${output}" | grep -c "image: docker.io/bitnami/postgresql:")"

  [[ $custom_image_count -eq 6 ]] && [[ $original_image_count -eq 2 ]]
}

T_useOriginalNamespaceForPostgresqlImage() {
  output="$(helm_command -f "$chart_path/test/global/imageNamespace.yaml" -f "$chart_path/test/postgresql/image/useOriginalNamespace.yaml")"

  custom_image_count="$(echo "${output}" | grep -c "image: docker.io/neversail/")"
  original_image_count="$(echo "${output}" | grep -c "image: docker.io/bitnami/postgresql:")"

  [[ $custom_image_count -eq 6 ]] && [[ $original_image_count -eq 2 ]]
}

T_useOriginalRegistryForPostgresqlImageWithPostgresqlAndGlobalRegistrySet() {
  output="$(helm_command -f "$chart_path/test/global/imageRegistry.yaml" -f "$chart_path/test/postgresql/image/useOriginalRegistry.yaml" \
    -f "$chart_path/test/postgresql/chart/imageRegistry.yaml")"

  global_image_count="$(echo "${output}" | grep -c "image: registry.global/concourse/concourse:")"
  postgresql_alt_image_count="$(echo "${output}" | grep -c "image: smashed-noodles.io/bitnami/")"
  original_image_count="$(echo "${output}" | grep -c "image: docker.io/bitnami/postgresql:")"

  [[ $global_image_count -eq 3 ]] && [[ $postgresql_alt_image_count -eq 3 ]] && [[ $original_image_count -eq 2 ]]
}

T_useOriginalNamespaceForPostgresqlImageWithPostgresqlAndGlobalNamespaceSet() {
  output="$(helm_command -f "$chart_path/test/global/imageNamespace.yaml" -f "$chart_path/test/postgresql/image/useOriginalNamespace.yaml" \
    -f "$chart_path/test/postgresql/chart/imageNamespace.yaml")"

  global_image_count="$(echo "${output}" | grep -c "image: docker.io/neversail/concourse:")"
  postgresql_alt_image_count="$(echo "${output}" | grep -c "image: docker.io/besincere/")"
  original_image_count="$(echo "${output}" | grep -c "image: docker.io/bitnami/postgresql:")"

  [[ $global_image_count -eq 3 ]] && [[ $postgresql_alt_image_count -eq 3 ]] && [[ $original_image_count -eq 2 ]]
}

