# Demo 2 — Trivy vs Syft: same image, different answers

**Punchline:** two scanners, one image, different component counts. SBOM quality is a property of the tool + ecosystem, not a given.

## Prereqs

- `trivy`, `syft`, `jq` (installed in `~/.local/bin`), podman
- image: our own `app2` (alpine OS pkgs + npm tree) — audience saw it built

**Real result on app2** (assets/demo2-trivy-vs-syft.txt): trivy **294** components, syft **652**.
Syft additionally emits per-file package.json evidence + binary detections; granularity differs per tool.

## Run

```bash
export PATH=~/.local/bin:$PATH
IMG=bootc.8gears.container-registry.dev/oss-security-demo/app2:v1

# generate both, CycloneDX for apples-to-apples
trivy image --format cyclonedx --output trivy.cdx.json "$IMG"
syft "registry:$IMG" -o cyclonedx-json > syft.cdx.json

# the interactive moment: ask the room to guess counts first
jq '.components | length' trivy.cdx.json syft.cdx.json

# where do they disagree?
jq -r '.components[].name' trivy.cdx.json | sort > trivy.txt
jq -r '.components[].name' syft.cdx.json  | sort > syft.txt
diff trivy.txt syft.txt | head -30
comm -23 syft.txt trivy.txt | head    # syft-only
comm -13 syft.txt trivy.txt | head    # trivy-only
```

## Talk beats

1. Room guesses component count before running. (Q7: declared vs actual.)
2. Run both → numbers differ. Ask why.
3. Walk 2–3 diff lines: binary detection, licence files, OS-pkg granularity.
4. Trivy = SBOM + vuln scan; Syft pairs with Grype. Both valid — pick one, be consistent.
5. Bridge to Q20: post-hoc SBOM = best guess; build-time = gold standard.

## Capture for assets/

- [ ] side-by-side `jq length` counts
- [ ] diff excerpt screenshot
