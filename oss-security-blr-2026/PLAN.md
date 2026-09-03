# Talk Plan — SBOMs in the Wild (interactive)

Source thinking: https://claude.ai/share/188d63e1-ef51-461b-bbbf-a500b3734050

Format: question-driven. One slide per question, question as title, answer revealed after audience responds. Fallback answer ready for silence. ~40 min + demos.

## Section 1 — The hook: a BOM you already trust (~5 min)

1. Who here has taken a Dolo 650? What's actually in it? (650 mg paracetamol + excipients — printed on the strip.)
2. Why does the manufacturer have to tell you? (Hypersensitivity, overdose → liver damage, interactions.)
3. Where else do bills of materials exist? (Cars, aircraft, medical devices, food labels.)
4. When Maruti recalls 134,885 cars for a fuel pump, how do they know which 134,885 — and how does Toyota know its Glanzas (rebadged Baleno) are affected too? (Shared BOM. Same defective part, two brands, both knew instantly.)

Real recall events to cite:
- Maruti: 39,506 Grand Vitaras (fuel-level indicator, chassis MA3/MBJ/MBH + 14 digits lookup page)
- Maruti: 181,754 Ciaz/Ertiga/Brezza/S-Cross/XL6; 134,885 fuel-pump recall → Toyota Glanza ~6,500
- Tata Zest/Tiago: exact chassis ranges (MAT624201FLD13319 → MAT624201GLC06228)
- Ola Electric 2022: 1,441 S1 Pro after battery fires; Takata airbags = largest recall ever
- India had no formal recall policy until voluntary SIAM code 2012 — parallel to SBOMs voluntary until EO 14028 / EU CRA

## Section 2 — WHAT is an SBOM (~5 min)

5. What would a "label" for software look like? (Components, versions, suppliers, licenses, relationships.)
6. Why can't we just read the Dockerfile or go.mod? (Transitive deps, base layers, vendored code, static binaries.)
7. Direct vs transitive dependency — guess: packages in a typical Node app vs declared?
8. Why two formats? (SPDX — Linux Foundation; CycloneDX — OWASP. Pick one, be consistent.)
9. Minimum useful SBOM? (NTIA minimum elements: supplier, name, version, unique IDs, relationships, author, timestamp.)

## Section 3 — WHY now (~5 min)

10. Where does software run today that can kill someone? (MRI, insulin pumps, avionics, self-driving.)
11. Who here has keyv, tinycolor, or anything TanStack in a lock file? → Shai-Hulud timeline:
    - **Sep 15, 2025** — first wave: self-replicating npm worm, @ctrl/tinycolor (2M+ weekly DL), 500+ packages, harvested AWS/GCP/Azure creds, GitHub Actions backdoors
    - **May 11, 2026** — "Mini Shai-Hulud": TanStack tree via CI cache poisoning + npm OIDC; AntV/echarts-for-react/timeago.js wave dumped CI secrets to public repos
    - **Aug 4, 2026** — CHAINDROP: keyv maintainer compromised, every co-owned package backdoored, 1.3B+ monthly downloads combined
    - **Aug 31, 2026** — "Trinitite" variant: TanStack Query codegen package; steals GitHub/npm/PyPI/RubyGems/cloud/Vault/K8s/Docker creds
12. When CHAINDROP hit, how long did your team take to say "we're clean"? (Nobody could — that's the gap.)
13. Why are governments involved? (US EO 14028, EU Cyber Resilience Act, FDA for medical devices.)
14. Why are CNCF / Linux Foundation / OpenSSF betting on this? (OSS is 80–90% of any codebase; SPDX, Sigstore, Scorecard, SLSA fit together.)

## Section 4 — HOW it's created: Trivy under the hood (~10 min) → demos 1–3

15. How does Trivy find what's inside a container image? (Walks layers, detects dpkg/rpm/apk DBs + language ecosystems by file fingerprints.)
16. For npm, why does package-lock.json matter more than package.json? (Resolved versions + full transitive tree.)
17. **The mesmerizing one:** how can it scan a compiled Go binary with no source? (Go embeds build info — `go version -m ./binary`. Demo 1.)
18. Languages that don't embed this? (Python wheels, JARs w/ pom.properties, Rust cargo-auditable — coverage varies → SBOM quality varies.)
19. Trivy vs Syft on the same image — compare component counts live. (Demo 2.)
20. Is a binary-derived SBOM as trustworthy as a build-time one? (No — build-time is gold standard.)

## Section 5 — WHERE it lives: Harbor (~8 min) → demo 4

21. Once generated, where does the SBOM go? PDF on a shared drive? (Must travel with the artifact.)
22. How does Harbor attach it? (OCI accessory artifact linked to image digest; auto on push or on demand via Trivy adapter.)
23. What on re-tag / replication / regeneration? (Digest-based linking; policy can require SBOM before pull.)
24. Is publishing an SBOM a security risk? (Attackers can reverse-engineer anyway; defenders gain more. OCI referrers.)

## Section 6 — HOW it's used + the ask (~7 min) → demo 5

25. What do you actually do with an SBOM? (Continuous vuln matching without rescanning, license compliance, VEX, K8s admission policy.)
26. How do OSS projects do this today? (Kubernetes, Harbor, Argo publish SBOMs with releases — show 2–3 real ones.)
27. **Can you recall software the way Maruti recalls a car?** (Demo 5: query SBOMs in Harbor across images, produce the "chassis list" of affected digests, rebuild/redeploy loop.)
28. What's stopping you Monday morning? (Enable SBOM generation in Harbor, add Trivy/Syft to CI, publish with releases.)

## Recall analogy mapping (slide)

| Car recall | Software recall |
|---|---|
| Chassis number | Image digest |
| Manufactured between X and Y | Built between commit/version X and Y |
| Faulty part: fuel pump from supplier Z | keyv@x.y.z from npm |
| Dealer DB knows which cars have the part | Harbor + SBOMs know which images contain the package |
| "Enter your chassis number" | `grype sbom:...` / query Harbor SBOM |
| Free replacement at dealer | Rebuild, re-push, redeploy |
