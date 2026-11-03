# Guia de Integridade de Release: SLSA Nível 3, Sigstore (Cosign) e Git-Cliff

## 1. SLSA Nível 3 (Supply-chain Levels for Software Artifacts)
Para garantir que artefatos distribuídos não foram adulterados em trânsito ou no build:

- **Builds em Runners Efêmeros e Isolados:** O processo de compilação deve rodar exclusivamente em runners gerenciados de CI (GitHub Actions com `slsa-github-generator`), sem intervenção manual de desenvolvedores.
- **Proveniência Inalterável (Provenance Attestation):** Geração de arquivo de atestação assinado criptograficamente detalhando o commit SHA exato, repositório e parâmetros de build.

---

## 2. Assinatura Criptográfica Keyless via Sigstore (Cosign)
Elimina a necessidade de gerenciar chaves privadas estáticas de longa duração:

```shell
# Assinar imagem de contêiner usando identidade OIDC do workflow
cosign sign --yes myregistry/myimage@sha256:...

# Anexar a atestação de proveniência SLSA ao artefato
cosign attest --yes --predicate provenance.json --type slsaprovenance myregistry/myimage@sha256:...

# Verificar assinatura pública via Rekor transparency log
cosign verify --certificate-identity-regexp "https://github.com/..." --certificate-oidc-issuer "https://token.actions.githubusercontent.com" myregistry/myimage@sha256:...
```

---

## 3. Automação de Changelogs Determinísticos com Git-Cliff
Configuração integrada que lê os Conventional Commits do repositório e produz o `CHANGELOG.md` estruturado:

```shell
# Gerar changelog para a release corrente
git-cliff --tag vX.Y.Z --output CHANGELOG.md

# Gerar apenas as notas do release atual para o comando gh release create
git-cliff --latest --strip header > release-notes.md
```

---

## 4. Software Bill of Materials (SBOM)
- **Geração Obrigatória:** Gerar manifesto SBOM no formato CycloneDX ou SPDX para todo release:
  ```shell
  syft dir:. -o cyclonedx-json=sbom.json
  ```
- O arquivo `sbom.json` deve ser anexado aos assets da release junto ao `SHA256SUMS`.
