# Demo 3 — How Trivy actually scans (the rabbit hole)

**Punchline:** no magic — Trivy walks image layers, fingerprints files, reads package DBs and lock files. Show the raw evidence it reads.

## Prereqs

- `trivy`, podman, `jq`
- image: our own `app2` (node:20-alpine + npm install)
- captured run: assets/demo3-under-the-hood.txt (apk DB plaintext; package.json declares 2 deps → lock file resolves 71 packages)

## Run

```bash
IMG=bootc.8gears.container-registry.dev/oss-security-demo/app2:v1

# 1. what an image really is: layers of tarballs
podman save "$IMG" -o img.tar --format oci-archive && mkdir img && tar -xf img.tar -C img
ls img/blobs/sha256 | head

# 2. the files trivy fingerprints — OS package DB (layers are gzipped: tar -tzf)
for l in img/blobs/sha256/*; do tar -tzf "$l" 2>/dev/null | grep -q 'lib/apk/db/installed' && DB=$l; done
tar -xzOf "$DB" lib/apk/db/installed | head -20   # apk DB is plain text!

# 3. language ecosystem: lock files
for l in img/blobs/sha256/*; do tar -tzf "$l" 2>/dev/null | grep -m1 'app/package-lock.json' && LOCK=$l; done
tar -xzOf "$LOCK" app/package-lock.json | jq '.packages | keys | length'   # 71 from 2 declared deps

# 4. now run trivy with debug to see it do exactly this
trivy image --debug "$IMG" 2>&1 | grep -iE 'analyz|detect|walk' | head -20

# 5. result: SBOM assembled from those files
trivy image --format table "$IMG" | head -25
```

## Talk beats

1. "Scanner" sounds like magic. Open the tarball → it's just files.
2. apk/dpkg DB is plain text — read it live. That's the OS part of the SBOM.
3. package-lock.json (Q16) → resolved versions + transitive tree. package.json alone can't do this.
4. Go binaries → build info (demo 1). Each ecosystem = one analyzer.
5. Trivy = a bundle of analyzers + a vuln DB matcher. Demystified.

## Capture for assets/

- [ ] extracted layer listing
- [ ] apk db plaintext screenshot
- [ ] debug log "analyzer" lines
