#!/usr/bin/env bash
# The software recall: Maruti chassis-number lookup, but for container images.
# Queries SBOMs stored in the registry (OCI referrers) for a "recalled" package.
#
# Usage: ./recall.sh <package-name> [version]
#   ./recall.sh keyv
#   ./recall.sh keyv 4.5.3
set -euo pipefail

REG="${REG:-bootc.8gears.container-registry.dev/oss-security-demo}"
FLEET=(app1 app2 app3 app4 app5 app6 goapp)
PKG="${1:?usage: recall.sh <package-name> [version]}"
VER="${2:-}"

echo "RECALL NOTICE: $PKG${VER:+@$VER}"
echo "Checking fleet of ${#FLEET[@]} images in $REG ..."
echo

for img in "${FLEET[@]}"; do
  # 1. find the SBOM attached to this image (the "service book in the glovebox")
  #    matches both oras-attached SPDX and Harbor-native (sbom.harbor) accessories
  sbom_manifest=$(oras discover --format json "$REG/$img:v1" \
    | jq -r '.referrers[] | select(.artifactType=="application/spdx+json"
                                or .artifactType=="application/vnd.goharbor.harbor.sbom.v1")
             | .digest' | head -1)

  if [ -z "$sbom_manifest" ]; then
    printf '%-8s  NO SBOM — cannot answer. This is the pre-SBOM world.\n' "$img"
    continue
  fi

  # 2. fetch the SBOM blob and query it — the chassis-number lookup
  blob=$(oras manifest fetch "$REG/$img@$sbom_manifest" | jq -r '.layers[0].digest')
  hit=$(oras blob fetch --output - "$REG/$img@$blob" \
    | jq -r --arg p "$PKG" --arg v "$VER" \
      '.packages[] | select(.name==$p) | select($v=="" or .versionInfo==$v) | "\(.name)@\(.versionInfo)"' \
    | sort -u)

  digest=$(oras discover --format json "$REG/$img:v1" | jq -r '.digest')
  if [ -n "$hit" ]; then
    printf '%-8s  AFFECTED  %s  (image %s)\n' "$img" "$hit" "${digest:0:19}"
  else
    printf '%-8s  clean\n' "$img"
  fi
done
