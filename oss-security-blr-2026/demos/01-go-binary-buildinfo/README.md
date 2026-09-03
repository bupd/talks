# Demo 1 — Go binary confesses its dependencies

**Punchline:** no source, no go.mod, just a binary — and it tells you every module baked into it. This is how Trivy/Syft scan Go binaries.

## Prereqs

- `go` toolchain
- demo app lives in `app/` (fatih/color dep); image pushed as `oss-security-demo/goapp:v1`
- captured output: assets/demo1-go-buildinfo.txt — note it even embeds `vcs.revision` (the git commit it was built from!)
- alt binaries the audience knows: harbor-core, trivy itself, kubectl

## Run

```bash
# grab a known binary, e.g. trivy scanning trivy
which trivy && go version -m "$(which trivy)" | head -40

# or build a tiny app live
mkdir /tmp/demo && cd /tmp/demo
go mod init demo
cat > main.go <<'EOF'
package main

import (
	"fmt"

	"github.com/fatih/color"
)

func main() { color.Cyan("hello %s", "blr"); fmt.Println() }
EOF
go mod tidy && go build -o app .

# the reveal
go version -m ./app
strings ./app | grep -m5 'dep\s'   # it's literally embedded in the ELF
```

## Talk beats

1. Ask: "binary only, no source — can I list its dependencies?" Room says no.
2. `go version -m` → full module list with versions + hashes.
3. Explain: Go embeds build info (module path, deps, VCS rev) in every binary since 1.12/1.18.
4. Bridge: "THIS is what Trivy reads. No magic — the ecosystem chose transparency."
5. Contrast: strip a C binary → nothing. Coverage varies per ecosystem (Q18).

## Capture for assets/

- [ ] `go version -m` output screenshot
- [ ] `strings | grep dep` screenshot
