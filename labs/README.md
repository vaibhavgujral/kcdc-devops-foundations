# DevOps Foundations: From Code Commit to Production Confidence
## Hands-On Lab Guide — KCDC Workshop

**Stack:** GitHub · GitHub Actions · Terraform · Azure App Service · Application Insights · .NET 10

**Shell note:** local git commands are written one per line, so they work identically in bash,
Git Bash, and PowerShell. The Azure bootstrap in **Lab 3.1 is bash-only** — Git Bash (with
`export MSYS_NO_PATHCONV=1`) or Azure Cloud Shell, as flagged there.

**How this guide works:** Each lab builds on the previous one. Every lab has **core steps**
plus **stretch goals** — finish early and the stretch goals are for you; the timebox ends when
the room is ready, not when the first person is. If you fall behind, every lab has a
**checkpoint branch** in the workshop repo (`checkpoint/lab-N-complete`) you can fast-forward from.
Raise a hand or drop a note in the workshop chat any time.

---

# Lab 0 — Setup (complete BEFORE the workshop)

You need all of the following working before we start. Budget 30–45 minutes.

## Accounts
1. **GitHub account** — free tier is fine: https://github.com/signup
2. **Azure subscription** — a free account (https://azure.microsoft.com/free) or Visual Studio
   subscription credits. You need permission to create resource groups and an app registration
   (Entra ID). **Estimated spend for the workshop: under $1** (one S1 App Service Plan for ~3 hours,
   destroyed at the end).

## Tools
| Tool | Install | Verify |
|---|---|---|
| Git | https://git-scm.com/downloads | `git --version` |
| VS Code | https://code.visualstudio.com | — |
| Azure CLI | https://learn.microsoft.com/cli/azure/install-azure-cli | `az --version` (2.80+) |
| .NET 10 SDK *(optional but recommended)* | https://dotnet.microsoft.com/download/dotnet/10.0 | `dotnet --version` |
| Terraform *(optional)* | https://developer.hashicorp.com/terraform/install | `terraform -version` (1.9+) |

> The .NET SDK and Terraform are optional because **all builds and deployments run in GitHub
> Actions**, not on your laptop. Installing them locally just lets you experiment faster.

## Fork the workshop repository
1. Go to the workshop repo: `https://github.com/vaibhavgujral/kcdc-devops-foundations`
2. Click **Fork** → keep the default name → **Create fork**.
3. Clone *your fork* (replace `YOUR-USERNAME`):
   ```bash
   git clone https://github.com/YOUR-USERNAME/kcdc-devops-foundations.git
   cd kcdc-devops-foundations
   ```

## Sanity check
```bash
az login                # opens a browser; pick your workshop subscription
az account show -o table
git status              # should say "working tree clean"
```

✅ **You are ready** when: your fork exists, it's cloned locally, and `az account show` displays
the subscription you'll use.

---

# Lab 1 — Source Control Done Right *(Module 2 · ~20 min)*

**Goal:** Learn your way around the GitHub features this workshop lives in, then experience the
professional PR workflow — protected `main`, a feature branch, a reviewed pull request.

## 1.1 Two-minute repo tour
First, one fork quirk: **GitHub disables the Issues tab on forks by default.** Turn it on:
**Settings → General → Features → check "Issues"** — refresh, and the tab appears.

Now click through the tabs — each one comes back later today:
- **Code** — the tree, plus the branch picker (top-left) where checkpoint branches will appear.
- **Issues** — where work gets planned; PRs can close issues automatically (`fixes #12`).
- **Actions** — empty now; by Lab 2 it's the beating heart of the repo.
- **Security** — Dependabot, code scanning, secret scanning live here (Lab 2 stretch).
- **Insights → Network** — the branch/merge graph; watch it grow as you work today.
- **Settings** — where rules, environments, secrets, and variables live. We're here a lot.

## 1.2 Wire up the upstream remote
Your fork knows nothing about the original repo until you tell it. This is also how you'll grab
checkpoint branches if you fall behind:
```bash
git remote add upstream https://github.com/vaibhavgujral/kcdc-devops-foundations.git
git remote -v        # origin = your fork, upstream = the workshop repo
git fetch upstream   # now checkpoint/lab-N-complete branches are reachable
```
> **fork vs clone, in one line:** a clone is your local copy of a repo; a fork is your own
> server-side copy that can send PRs back. You have both — the clone points at the fork.

## 1.3 Protect your main branch
On your fork: **Settings → Rules → Rulesets → New ruleset → New branch ruleset**
- Name: `protect-main`
- Enforcement status: **Active**
- Target branches: **Include default branch**
- Enable:
  - ☑ **Require a pull request before merging** (required approvals: 0 for today — you're solo)
  - ☑ **Block force pushes**
- Click **Create**.

> In a real team you'd require 1–2 approvals plus passing status checks. We'll add the status-check
> requirement in Lab 2 once a CI workflow exists.

## 1.4 Prove the protection works
```bash
echo "# scratch" >> README.md
git add README.md
git commit -m "test: direct push"
git push origin main
```
**Expected:** the push is **rejected**. Undo the local commit:
```bash
git reset --hard origin/main
```

## 1.5 Make a change the right way
```bash
git switch -c feature/add-your-name
```
Open `CONTRIBUTORS.md` and add your name and city under the attendee list. Then:
```bash
git add CONTRIBUTORS.md
git commit -m "docs: add <your name> to contributors"
git push -u origin feature/add-your-name
```

## 1.6 Open a pull request — and review it like a reviewer
**Create it:**
Ensure that you select your fork in the target repo drop-down list (second in list) instead of the remote repo.

1. GitHub shows a yellow banner on your fork — click **Compare & pull request**. If the banner
   is gone, use **Pull requests → New pull request** and pick your branch. Either way, check
   the base: it must be **your fork's** `main`, not the upstream workshop repo.
2. Write a real PR description: *what* changed and *why*.
3. Click **Create pull request** — you land on the PR's **Conversation** tab. The PR now exists;
   everything below happens on this page.

**Now switch hats and review it:**
4. Open the **Files changed** tab — this is the reviewer's view of your diff. Hover over your
   changed line, click the **+**, type a comment, and choose **Add single comment**. This is
   where review conversations live.
5. While the comment box is open, notice the **±** *suggestion* button — reviewers can propose
   an exact code change the author applies with one click. Small-team superpower.
6. Back on **Conversation**, click **Resolve conversation** on your comment thread.

**Ship it:**
7. **Merge pull request → Confirm merge**, then **Delete branch** when offered.
8. On the **Code** tab, click the commit count — your merge is now history anyone can audit:
   who, what, when, and (because you wrote a real description) why.

## 1.7 Look at CODEOWNERS
Open `.github/CODEOWNERS` in the repo:
```
# Infrastructure changes require the platform team
/infra/          @<you>
/.github/        @<you>
```
On a team, GitHub auto-requests these owners as reviewers for any PR touching those paths.

## 1.8 Stretch goals (if you're ahead)
> Reference copies of every stretch-goal artifact (PR template, workflow snippets, Terraform
> blocks) live in the repo's **`stretch-resources/`** folder — copy from there rather than
> typing, if you prefer.

- **PR template:** copy `stretch-resources/pull_request_template.md` to
  `.github/pull_request_template.md` — every future PR opens pre-structured with
  *What / Why / How tested* sections.
- **Auto-merge:** first flip the repo setting — **Settings → General → Pull Requests → check
  "Allow auto-merge"** (off by default). Then, on a PR that *can't merge yet* — required checks
  still running — the merge button gains an **Enable auto-merge** option; select it and the PR
  merges itself the moment checks pass. Note the timing: if checks are already green, GitHub
  shows a plain Merge button instead, since there's nothing to wait for. (Pairs beautifully with
  the required status check you add in Lab 2 — the CI window is exactly when you'll see it.)
- **Draft PRs:** open a PR as a draft — share work-in-progress for early feedback without
  requesting review.

✅ **Done when:** your PR is merged, `main` rejects direct pushes, and you can explain why small
PRs beat big ones (faster review, smaller blast radius, easier rollback).

---

# Lab 2 — Build the CI Pipeline *(Module 3 · ~30 min)*

**Goal:** Write a CI workflow **from scratch** that restores, builds, tests, and publishes the app
as a deployable artifact — then watch it save you from a broken test.

## 2.1 Tour the app (2 min)
```
src/QuoteBoard.Web/        ASP.NET Core minimal API + homepage
tests/QuoteBoard.Tests/    xUnit tests
```
Key file — `src/QuoteBoard.Web/Services/QuoteProvider.cs` — pure logic, easy to test.

## 2.2 Create the workflow
Create the file `.github/workflows/ci.yml` on a new branch:
```bash
git switch main
git pull
git switch -c feature/ci-pipeline
mkdir -p .github/workflows
```

`.github/workflows/ci.yml`:
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Check out code
        uses: actions/checkout@v4

      - name: Set up .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '10.0.x'

      - name: Restore dependencies
        run: dotnet restore

      - name: Build (Release)
        run: dotnet build --configuration Release --no-restore

      - name: Run tests
        run: dotnet test --configuration Release --no-build --logger trx

      - name: Publish app
        run: dotnet publish src/QuoteBoard.Web -c Release -o publish

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: webapp
          path: publish/
          retention-days: 7
```

Walk through what each block means before committing:
- `on:` — the **trigger**. Every PR and every push to `main` gets built. No exceptions.
- `runs-on:` — a fresh, disposable Ubuntu VM per run. Nothing survives between runs.
- Each `- name:` is a **step**; steps share the runner's filesystem within a job.
- The artifact is the **single build output** we'll deploy in Lab 4 — *build once, deploy many.*

## 2.3 Ship it via PR
```bash
git add .github/workflows/ci.yml
git commit -m "ci: add build/test/publish workflow"
git push -u origin feature/ci-pipeline
```
Open the PR. Watch the **Checks** tab — click into the run and expand each step's logs. Merge when
green.

## 2.4 Make CI a required gate
**Settings → Rules → Rulesets → protect-main → Edit**
- ☑ **Require status checks to pass** → search and add **`build-and-test`** → Save.

Now a red build physically blocks the merge button.

## 2.5 Make it yours: a badge and a manual trigger
Two small touches you'll use on every real project. On a quick branch (or directly via the
GitHub web editor on a branch + PR):
1. Add `workflow_dispatch:` as a third trigger under `on:` in `ci.yml` — now the **Run
   workflow** button appears in the Actions tab, letting you trigger CI manually anytime.
2. Add a live status badge to the top of `README.md`:
   ```markdown
   ![CI](https://github.com/<you>/kcdc-devops-foundations/actions/workflows/ci.yml/badge.svg)
   ```
   Merge and watch your repo's front page report its own build health.

**Verify both worked:**
- **Trigger:** after the merge, go to **Actions → CI** — a **Run workflow** dropdown now appears
  above the run list (it only shows once the change is on `main`). Run it, refresh, and check the
  new run's event says `workflow_dispatch` — same pipeline, human trigger.
- **Badge:** your repo's front page shows a green **CI passing** pill. It's live, not a
  screenshot — the SVG is generated from the latest completed run on `main`. Shows
  "no status"? The filename in the URL must match `ci.yml` exactly. Looks stale? Hard-refresh;
  GitHub caches badge images.
- **Bonus observation for 2.6:** when your sabotage PR fails, the badge **stays green** — and
  that's correct. It tracks `main`, and the broken code never got there. The badge staying green
  while the PR burns red is branch protection working, in one picture.

## 2.6 Break it on purpose 🔥
```bash
git switch main
git pull
git switch -c feature/sabotage
```
Open `src/QuoteBoard.Web/Services/QuoteProvider.cs` and change `Count` in `GetDailyQuote` — e.g.
make the modulo `% (quotes.Count + 1)` — commit, push, open a PR.

**Expected:** the test job fails, the PR shows a red ❌, and **Merge is blocked**. Read the test
failure output in the logs — this is the fast feedback loop in action. Close the PR without
merging and delete the branch.

## 2.7 Stretch goals (if you're ahead)
- **Caching:** add `cache: true` to the `setup-dotnet` step and see restore time drop on re-runs.
- **Matrix:** wrap the job in `strategy: matrix: dotnet: ['10.0.x', '9.0.x']` and watch two runs
  fan out in parallel.
- **Security:** Settings → Advanced Security → enable **Dependabot alerts** and **CodeQL** default
  setup. Free shift-left security in two clicks.

✅ **Done when:** CI runs on every PR, `main` requires it to pass, and you saw a broken test block
a merge.

---

# Lab 3 — Infrastructure as Code with Terraform *(Module 4 · ~30 min)*

**Goal:** Define your entire Azure environment in code and let the pipeline create it — no portal
clicking. We provision: a resource group, an S1 App Service Plan, a Linux Web App with a
**staging deployment slot**, Log Analytics + Application Insights, and a 5xx metric alert.

## 3.1 One-time bootstrap (Azure CLI, ~8 min)

> **⚠️ Shell check first:** these commands are **bash**. On Windows, run them in **Git Bash**
> (installed with Git) or [Azure Cloud Shell](https://shell.azure.com) — **not** PowerShell or
> CMD, where `export` and `$VAR` silently do nothing and you'll get `MissingSubscription`
> errors.
>
> **Using Git Bash? Run this first:**
> ```bash
> export MSYS_NO_PATHCONV=1
> ```
> Git Bash otherwise rewrites arguments that start with `/` into Windows paths — so
> `--scope /subscriptions/...` silently becomes `--scope C:/Program Files/Git/subscriptions/...`
> and Azure returns `MissingSubscription` even though your variables are correct. Quoting does
> **not** prevent this; only the export above does.
>
> Keep everything in **one terminal session**: the `export`ed variables vanish if you close it
> (if that happens, see the re-hydrate box below).

Two things can't live in Terraform: the identity GitHub uses to log in, and the storage for
Terraform's own state. We create both with a script. Pick a unique suffix (e.g. your initials +
2 digits) and export it:

```bash
export SUFFIX="<<Initials>><<RandomString>>"   # ← REPLACE: your initials + a few random digits, all lowercase, no spaces (e.g. js4718)
# Replace the ENTIRE <<...>> including the angle brackets — e.g. SUFFIX="js4718". Keep it short (3-8 chars): it becomes part of a globally-unique storage account name.
export LOCATION=centralus
export SUB_ID=$(az account show --query id -o tsv)
```
Register Microsoft.Storage Resource Provider under your subscription before proceeding with the next steps. (Azure Portal -> Subscriptions -> Look for your subscription -> Expand Settings -> Resource Provider -> Search for "Microsoft.Storage"

<img width="1506" height="676" alt="image" src="https://github.com/user-attachments/assets/17fc3ba4-18ec-4e5e-b041-64f2753ee27a" />


Or you can execute this command:
```bash
az provider register --namespace Microsoft.Storage
```

**a) Storage account for Terraform state:**
```bash
az group create -n rg-tfstate-$SUFFIX -l $LOCATION
az storage account create -n sttf$SUFFIX -g rg-tfstate-$SUFFIX \
  --sku Standard_LRS --allow-blob-public-access false
az storage container create -n tfstate --account-name sttf$SUFFIX --auth-mode login
```

**b) Entra ID app + OIDC federation (passwordless — no secrets stored in GitHub!):**
```bash
APP_ID=$(az ad app create --display-name "gh-kcdc-$SUFFIX" --query appId -o tsv)
az ad sp create --id $APP_ID
az role assignment create --assignee $APP_ID --role Contributor --scope /subscriptions/$SUB_ID
az role assignment create --assignee $APP_ID --role "Storage Blob Data Contributor" \
  --scope $(az storage account show -n sttf$SUFFIX -g rg-tfstate-$SUFFIX --query id -o tsv)
```

Now create **four federated credentials** — one per GitHub context that will log in. (Jobs that
declare an `environment:` present environment-based subjects, so the staging and production
deploy jobs each need their own credential; ref-based ones never match them.)

> **Important — immutable subjects:** repositories created on or after **July 15, 2026** (which
> includes your fork) present OIDC subjects with numeric IDs embedded:
> `repo:owner@OWNER_ID/repo@REPO_ID:context`. Your credentials must match that exact format.

**Get your two IDs** (no tools needed — each is the first `"id"` on its page, right near the
top):
1. **Owner ID:** open `https://api.github.com/users/<you>` in a browser — copy the top-level
   `"id"`.
2. **Repo ID:** open `https://api.github.com/repos/<you>/kcdc-devops-foundations` — copy the
   top-level `"id"`.

> If you named your fork something other than `kcdc-devops-foundations`, use **your fork's
> actual name** in the URL above *and* in `SUBJECT_PREFIX` below — the subject must match your
> repo exactly, name **and** ID together (a prefix mixing the standard name with your fork's ID
> matches nothing).
>
> **Re-forked at some point?** Deleting and re-creating a fork produces a *new repo ID*, which
> silently invalidates every credential built for the old one. If you ever re-fork, re-fetch
> the repo ID and re-run the loop below — it deletes and re-creates, so running it again is
> always safe. A fresh fork also arrives **without** your repository variables, environments,
> and rulesets — re-create those too (the giveaway for missing variables: the rendered command
> at the top of a failing pipeline step shows empty values where `${{ vars.X }}` should be).

Then — **edit all three CHANGE/REPLACE values before running** (the verify table below will
show any you missed):
```bash
export GH_OWNER_ID=REPLACE_ME   # from step 1 above
export GH_REPO_ID=REPLACE_ME    # from step 2 above
SUBJECT_PREFIX="repo:YOUR-USERNAME@$GH_OWNER_ID/kcdc-devops-foundations@$GH_REPO_ID"

for CTX in 'ref:refs/heads/main' 'pull_request' 'environment:staging' 'environment:production'; do
  NAME="gh-$(echo $CTX | tr ':/' '--')"
  # delete any existing credential with this name first — makes the loop safely re-runnable
  az ad app federated-credential delete --id $APP_ID --federated-credential-id "$NAME" 2>/dev/null || true
  az ad app federated-credential create --id $APP_ID --parameters "{
    \"name\": \"$NAME\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"$SUBJECT_PREFIX:$CTX\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"
done
```
Verify:
```bash
az ad app federated-credential list --id $APP_ID --query "[].{name:name,subject:subject}" -o table
```
Four rows, every subject starting with your `repo:<you>@.../...@...` prefix. If you see extra
rows with subjects **missing the `@ID` parts**, those are stale credentials from an earlier run —
harmless but confusing; delete them by name:
`az ad app federated-credential delete --id $APP_ID --federated-credential-id <name>`.
Remember: the "already exists" check is by **name**, not subject — a name collision never means
the stored subject is correct, which is why the loop deletes before creating.

**c) Store the (non-secret) IDs as GitHub Actions variables** —
fork → **Settings → Secrets and variables → Actions → Variables tab → New repository
variable**. Repository-level, not environment-level: the `${{ vars.X }}` context only sees
environment variables inside jobs that declare that environment, and our infra pipeline
declares none — repo-level makes these visible to every workflow. (And they're variables, not
secrets, on purpose: client/tenant/subscription IDs are identifiers, not credentials — with
OIDC there is no Azure secret to store.)
Paste the **output** of each command as the value — GitHub stores plain strings and won't
expand `$VARIABLES` (e.g. if your suffix is `js4718`, `TF_STATE_SA` is literally `sttfjs4718`):

| Name | Run this, paste the output |
|---|---|
| `AZURE_CLIENT_ID` | `echo $APP_ID` |
| `AZURE_TENANT_ID` | `az account show --query tenantId -o tsv` |
| `AZURE_SUBSCRIPTION_ID` | `echo $SUB_ID` |
| `TF_STATE_SA` | `echo sttf$SUFFIX` |
| `NAME_SUFFIX` | `echo $SUFFIX` |

> **Lost your variables?** (new terminal, or resuming after a break) Re-hydrate without
> creating duplicates:
> ```bash
> export SUFFIX="<<Initials>><<RandomString>>"   # ← REPLACE with the SAME value you used the first time!
> export LOCATION=centralus
> export SUB_ID=$(az account show --query id -o tsv)
> APP_ID=$(az ad app list --display-name "gh-kcdc-$SUFFIX" --query "[0].appId" -o tsv)
> echo "APP_ID=[$APP_ID]  SUB_ID=[$SUB_ID]"   # both must be non-empty before continuing
> ```

> **Why OIDC matters:** GitHub proves its identity to Azure with a short-lived signed token per
> run. There is no client secret to leak, rotate, or expire. This is the modern pattern —
> long-lived credentials in CI are a top breach vector.

## 3.2 Write the Terraform
Create a branch and the files below.
```bash
git switch main
git pull
git switch -c feature/infrastructure
mkdir -p infra
```

`infra/providers.tf`:
```hcl
terraform {
  required_version = ">= 1.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
  }
  backend "azurerm" {
    resource_group_name  = "PLACEHOLDER"   # passed via -backend-config in the pipeline
    storage_account_name = "PLACEHOLDER"
    container_name       = "tfstate"
    key                  = "quoteboard.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}
```

`infra/variables.tf`:
```hcl
variable "suffix" {
  type = string
}

variable "location" {
  type    = string
  default = "centralus"
}
```
> HCL gotcha: a single-line block may hold only **one** argument — `{ type = string  default = "x" }`
> on one line is a syntax error. When in doubt, one argument per line.

`infra/main.tf`:
```hcl
resource "azurerm_resource_group" "app" {
  name     = "rg-quoteboard-${var.suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "log-quoteboard-${var.suffix}"
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  retention_in_days   = 30
}

resource "azurerm_application_insights" "ai" {
  name                = "appi-quoteboard-${var.suffix}"
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.logs.id
  application_type    = "web"
}

# S1 is the cheapest tier that supports deployment slots (needed for blue/green in Lab 4)
resource "azurerm_service_plan" "plan" {
  name                = "asp-quoteboard-${var.suffix}"
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "web" {
  name                = "app-quoteboard-${var.suffix}"
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack { dotnet_version = "10.0" }
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 2   # required alongside health_check_path in azurerm 4.x
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.ai.connection_string
    "FEATURE_NEW_BANNER"                    = "false"
    "FAIL_RATE"                             = "0"
  }
}

resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.web.id

  site_config {
    application_stack { dotnet_version = "10.0" }
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 2   # required alongside health_check_path in azurerm 4.x
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.ai.connection_string
    "FEATURE_NEW_BANNER"                    = "false"
    "FAIL_RATE"                             = "0"
  }
}

# Page the team when production throws 5xx errors
resource "azurerm_monitor_metric_alert" "http5xx" {
  name                = "alert-quoteboard-5xx-${var.suffix}"
  resource_group_name = azurerm_resource_group.app.name
  scopes              = [azurerm_linux_web_app.web.id]
  description         = "More than 5 server errors in 5 minutes"
  frequency           = "PT1M"
  window_size         = "PT5M"
  severity            = 1

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5
  }
}
```

`infra/outputs.tf`:
```hcl
output "webapp_name" { value = azurerm_linux_web_app.web.name }
output "prod_url"    { value = "https://${azurerm_linux_web_app.web.default_hostname}" }
output "staging_url" { value = "https://${azurerm_linux_web_app_slot.staging.default_hostname}" }
```

## 3.3 The infrastructure pipeline
`.github/workflows/infra.yml`:
```yaml
name: Infrastructure

on:
  pull_request:
    paths: ['infra/**', '.github/workflows/infra.yml']
  push:
    branches: [main]
    paths: ['infra/**', '.github/workflows/infra.yml']

permissions:
  id-token: write      # required for OIDC
  contents: read
  pull-requests: write

env:
  ARM_CLIENT_ID: ${{ vars.AZURE_CLIENT_ID }}
  ARM_TENANT_ID: ${{ vars.AZURE_TENANT_ID }}
  ARM_SUBSCRIPTION_ID: ${{ vars.AZURE_SUBSCRIPTION_ID }}
  ARM_USE_OIDC: 'true'

jobs:
  terraform:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: infra
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3

      - name: Terraform init
        run: >
          terraform init
          -backend-config="resource_group_name=rg-tfstate-${{ vars.NAME_SUFFIX }}"
          -backend-config="storage_account_name=${{ vars.TF_STATE_SA }}"

      - name: Terraform validate
        run: terraform validate

      - name: Terraform plan
        run: terraform plan -var "suffix=${{ vars.NAME_SUFFIX }}" -out=tfplan

      - name: Terraform apply (main only)
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve tfplan
```

Note the `paths` filters include the workflow file itself — without that, a PR that edits only
`infra.yml` wouldn't trigger the pipeline it defines, and pipeline changes deserve the same PR
verification as the infrastructure they manage.

The teaching moment in this file: **PRs get a `plan` (a diff of your infrastructure); only merges
to `main` get an `apply`.** Infrastructure changes go through the exact same review workflow as
code — because they *are* code.

## 3.4 Ship it
```bash
git add infra .github/workflows/infra.yml
git commit -m "infra: Azure environment as Terraform + plan/apply pipeline"
git push -u origin feature/infrastructure
```
> Why not `git add .`? It works here — the repo's `.gitignore` keeps Terraform's local
> artifacts (`.terraform/`, state files, plans) out — but staging explicit paths is the habit
> that prevents the classic accident: committing a state file or scratch notes you forgot
> about. If you prefer `git add .`, at least run `git status` before committing to review
> what's actually staged.
1. Open the PR → open the Actions run → **read the plan output**. It should say
   `Plan: 7 to add, 0 to change, 0 to destroy.` That plan *is* your review artifact.
2. Merge. Watch the `apply` run (~3–4 min).
3. Verify:
   ```bash
   az webapp list -g rg-quoteboard-$SUFFIX -o table
   ```
   Browse to `https://app-quoteboard-$SUFFIX.azurewebsites.net` — you'll see the App Service
   holding page (no code deployed yet — that's Lab 4).

> **Expected "unhealthy" banner:** the Azure Portal will show *"Your application is reporting
> as unhealthy"* on the web app. That's correct right now — the health probe is checking
> `/health`, and no app is deployed yet to answer it. The probe working against an empty site
> is proof your Terraform configured it; the banner clears a few minutes after Lab 4's first
> deployment.

## 3.5 Create drift — then catch it
The quiet killer of ClickOps environments, demonstrated in two minutes:
1. In the Azure Portal, open your resource group `rg-quoteboard-<suffix>` → **Tags** → add a tag
   `oops = portal-edit` → Save. Congratulations, reality no longer matches your code.
2. Trigger the Infrastructure workflow manually (or push a whitespace change under `infra/`),
   and read the plan: Terraform reports the tag it never asked for and plans to remove it.
3. That's drift detection — the portal edit was caught by the next plan. On real teams this runs
   on a schedule, so nothing stays quietly hand-edited.

## 3.6 Stretch goals (if you're ahead)
- **Tags:** add `tags = { workshop = "kcdc", owner = var.suffix }` to the resource group and
  re-run the pipeline — watch the plan show `1 to change, 0 to destroy`.
- **Format gate:** add a `terraform fmt -check -diff` step to `infra.yml`, placed right after
  `setup-terraform` (it needs no init — cheap checks run first). Expect it to fail on your
  hand-typed files the first time — **exit code 3** is fmt's specific "files need reformatting"
  signal, and the log lists which ones. Fix: run `terraform fmt` in `infra/` locally, review the
  `git diff` (almost always `=` alignment), commit, push, green. No Terraform installed? The
  `-diff` flag makes the pipeline log print the exact changes to hand-apply. (Your PR touching
  only `infra.yml` still triggers the pipeline because the workflow file is in its own `paths`
  filter — that's why it's there.)
- **Read the state:** run `terraform state list` locally — see the mapping between your code
  and real Azure resource IDs. This one needs a local `terraform init` first, **with the
  `-backend-config` flags from the Cleanup section** — the `PLACEHOLDER` values in
  `providers.tf` are injected by the pipeline, so a bare `init` fails with a cryptic
  `400 OutOfRangeInput`. (Plain `terraform fmt`, by contrast, needs no init at all.)

✅ **Done when:** the plan appeared on your PR, the apply created 7 resources, and the empty site
answers in a browser.

---

# Lab 4 — CD & Progressive Delivery *(Module 5 · ~30 min)*

**Goal:** Extend the pipeline to deploy every merge to **staging**, hold for a **human approval**,
then release to **production with a slot swap** (blue/green — zero downtime, instant rollback).
Finish by flipping a feature flag *without deploying anything*.

## 4.1 Create the protected environment
Fork → **Settings → Environments → New environment** → name it `production`:
- ☑ **Required reviewers** → add yourself → Save protection rules.

Also create an environment named `staging` (no protection rules).

## 4.2 The deployment workflow
Branch: `git switch main
git pull
git switch -c feature/cd-pipeline`

`.github/workflows/deploy.yml`:
```yaml
name: Deploy

on:
  push:
    branches: [main]
    paths-ignore: ['infra/**', '**.md']
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '10.0.x'
      - run: dotnet test --configuration Release
      - run: dotnet publish src/QuoteBoard.Web -c Release -o publish
      - uses: actions/upload-artifact@v4
        with:
          name: webapp
          path: publish/

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://app-quoteboard-${{ vars.NAME_SUFFIX }}-staging.azurewebsites.net
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: webapp
          path: publish

      - uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

      - uses: azure/webapps-deploy@v3
        with:
          app-name: app-quoteboard-${{ vars.NAME_SUFFIX }}
          slot-name: staging
          package: publish

      - name: Smoke test staging
        run: |
          URL=https://app-quoteboard-${{ vars.NAME_SUFFIX }}-staging.azurewebsites.net/health
          for i in $(seq 1 30); do
            CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
            if [ "$CODE" = "200" ]; then echo "Healthy after $i checks"; exit 0; fi
            echo "Attempt $i: HTTP $CODE — waiting 10s"; sleep 10
          done
          echo "Staging never became healthy"; exit 1

  release-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://app-quoteboard-${{ vars.NAME_SUFFIX }}.azurewebsites.net
    steps:
      - uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

      - name: Swap staging → production (blue/green)
        run: |
          az webapp deployment slot swap \
            --resource-group rg-quoteboard-${{ vars.NAME_SUFFIX }} \
            --name app-quoteboard-${{ vars.NAME_SUFFIX }} \
            --slot staging --target-slot production

      - name: Smoke test production
        run: |
          URL=https://app-quoteboard-${{ vars.NAME_SUFFIX }}.azurewebsites.net/health
          for i in $(seq 1 30); do
            CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
            if [ "$CODE" = "200" ]; then echo "Healthy after $i checks"; exit 0; fi
            echo "Attempt $i: HTTP $CODE — waiting 10s"; sleep 10
          done
          echo "Production never became healthy"; exit 1
```

What to notice while you write it:
- **`needs:`** chains jobs into a pipeline: build → staging → production.
- **The artifact built once in `build` is what ships to both environments.** Staging and prod run
  byte-identical bits — "it worked in staging" actually means something.
- **`environment: production`** is what triggers the approval gate you configured in 4.1.
- **The smoke tests poll rather than trusting `curl --retry`:** curl only retries *transient*
  failures (timeouts, 429, 5xx) — a 404 during the app's first cold start is treated as final
  and fails immediately. The loop treats anything non-200 as "still warming" for up to five
  minutes, and prints each attempt so the wait is visible. First deploys commonly need 1–3
  minutes.
- **The swap is the release.** Azure warms the staging slot, then flips the router. Old production
  is now sitting in the staging slot — your rollback is *another swap*, in seconds.

## 4.3 Ship it and approve your first release
```bash
git add .github/workflows/deploy.yml
git commit -m "cd: staging deploy + approved blue/green production release"
git push -u origin feature/cd-pipeline
```
1. PR → merge. The `Deploy` run starts.
2. Staging deploys automatically. Open the staging URL — the QuoteBoard app is live!
3. The run pauses at **release-production: "Review pending deployments."** This is your
   change-approval board, minus the meetings. Click **Review deployments → approve**.
4. Watch the swap, then open the production URL. 🎉 Note the **Slot** label on the page reads
   `production` — and if you kept the staging tab open, refresh it: the old production build now
   answers there. The swap really is just the router flipping.

## 4.4 Deploy ≠ release: flip a feature flag
The homepage hides a banner behind `FEATURE_NEW_BANNER`. Turn it on in production **without any
deployment**:
```bash
az webapp config appsettings set \
  -g rg-quoteboard-$SUFFIX -n app-quoteboard-$SUFFIX \
  --settings FEATURE_NEW_BANNER=true
```
Wait ~30 seconds (the setting change restarts the app), hard-refresh production — new banner.
Flip it back to `false`: instant kill switch. That decoupling — code ships dark, features
release on demand — is how large teams deploy hundreds of times a day without fear.

**No banner? Check in this order:**
1. **Right URL?** The command targets *production* — the banner won't appear on the staging URL
   (staging's flag is still `false`, correctly).
2. **Is the app there?** The flag renders nothing if production is still the Azure holding page —
   the swap in 4.3 must have completed first.
3. **Exact value?** `GetValue<bool>` needs `true` — `1`, `yes`, or a stray space parse as false:
   ```bash
   az webapp config appsettings list -g rg-quoteboard-$SUFFIX -n app-quoteboard-$SUFFIX \
     --query "[?name=='FEATURE_NEW_BANNER'].value" -o tsv
   ```
4. **Did Terraform revert it?** The flag is also declared (`"false"`) in `main.tf` — so any infra
   apply after your flip puts it back. That's Lab 3's drift machinery working as designed on a
   setting you changed out-of-band. Real teams exclude runtime flags from IaC
   (`lifecycle { ignore_changes = [...] }`) or use a flag service like Azure App Configuration —
   a good discussion point for why config has *layers*.

## 4.5 Practice the rollback (before you need it)
The whole point of blue/green is that rollback is boring. Prove it while nothing is wrong:
```bash
az webapp deployment slot swap \
  -g rg-quoteboard-$SUFFIX -n app-quoteboard-$SUFFIX \
  --slot staging --target-slot production      # "roll back"
curl https://app-quoteboard-$SUFFIX.azurewebsites.net/health   # still healthy
# ...and swap forward again to restore the release
az webapp deployment slot swap \
  -g rg-quoteboard-$SUFFIX -n app-quoteboard-$SUFFIX \
  --slot staging --target-slot production
```
Time it. That number — not a runbook page — is your mean time to recovery, and you'll use this
exact move for real in the Module 6 demo.

## 4.6 Stretch goal — canary flavor
S1 slots support **traffic splitting** — a taste of canary releasing. Three commands, run one
at a time (each is a single line — safer to edit than multi-line continuations):

**1. Start the canary** — send 10% of production traffic to the staging slot:
```bash
az webapp traffic-routing set -g rg-quoteboard-$SUFFIX -n app-quoteboard-$SUFFIX --distribution staging=10
```
Generate some traffic and watch the page's **Slot**/**Instance** labels — about one request in
ten answers from staging — and see both slots live in App Insights Live Metrics.

**2. Check the current split** (empty output = no split, all traffic to production):
```bash
az webapp traffic-routing show -g rg-quoteboard-$SUFFIX -n app-quoteboard-$SUFFIX -o table
```

**3. End the canary** — all traffic back to production:
```bash
az webapp traffic-routing clear -g rg-quoteboard-$SUFFIX -n app-quoteboard-$SUFFIX
```
Verify with the `show` command again — output should be empty.

✅ **Done when:** a merge flowed to staging automatically, you approved production, the swap
released with zero downtime, and you toggled a feature with no deployment.

---

# Lab 5 — Break Production on Purpose (Module 6 · ~10 min)

Goal: Operate what you built. You'll inject a failure into your own production app, watch your telemetry and alert catch it, and recover in about a minute — the whole incident loop, first-hand. Runs solo on your environment; the instructor runs it too on the projector so we move together. The app has a deliberately terrible hidden feature: a `FAIL_RATE` setting that makes it throw 500s randomly.

1. **Inject the failure** (instructor, on the demo app):
   ```bash
   az webapp config appsettings set -g rg-quoteboard-$SUFFIX -n app-quoteboard-$SUFFIX --settings FAIL_RATE=0.4
   ```
   **Pre-flight before generating traffic** — confirm the value stuck and give the app ~30s to
   recycle (a settings change restarts it):
   ```bash
   az webapp config appsettings list -g rg-quoteboard-$SUFFIX -n app-quoteboard-$SUFFIX --query "[?name=='FAIL_RATE'].value" -o tsv
   ```
   If it prints `0`, the injection didn't stick — most likely a Terraform apply ran after it and
   reverted the setting to its declared value (the 4.4 troubleshooting note explains this
   interplay). Re-set and re-check.
2. **Generate traffic** — everyone hit the demo URL, or:
   ```bash
   for i in $(seq 1 100); do curl -s -o /dev/null -w "%{http_code}\n" https://app-quoteboard-$SUFFIX.azurewebsites.net/; done
   ```
3. **Watch it burn, calmly:**
   - The page itself: click **Another quote** — the button fails with a 💥 message right in
     the UI, while the health dot stays green (`/health` is never chaos'd — by design).
   - App Insights → **Live Metrics**: failure rate climbing in real time.
   - **Failures** blade: which operation, which exception, full call stack.
   - The **metric alert** we created in Terraform fires (Http5xx > 5 in 5 min).
4. **Declare an incident** — roles: incident commander, comms, ops. Timestamp everything.
5. **Mitigate first, diagnose later:** `FAIL_RATE=0` (config rollback) — or if this had shipped
   in code, `az webapp deployment slot swap` right back. Recovery in under a minute.
6. **Blameless postmortem sketch (5 min, together):** timeline → impact → contributing causes →
   what made detection fast/slow → action items that are *systemic* ("add a canary stage",
   never "be more careful").

**Your MTTR just went from hypothetical to ~60 seconds.** That — not zero incidents — is what
production confidence means.

---

# Cleanup (IMPORTANT — do before you leave)

Terraform giveth, Terraform taketh away:
```bash
cd infra
terraform init \
  -backend-config="resource_group_name=rg-tfstate-$SUFFIX" \
  -backend-config="storage_account_name=sttf$SUFFIX"
terraform destroy -var "suffix=$SUFFIX"
az group delete -n rg-tfstate-$SUFFIX --yes --no-wait   # state storage
az ad app delete --id $APP_ID                            # the OIDC app registration
```
> **If init returns `403 AuthorizationPermissionMismatch`:** the bootstrap granted the state
> storage role to the *pipeline's* identity, not to you — and subscription Owner doesn't include
> data-plane access. Grant yourself the role, wait 2–3 minutes for RBAC to propagate, retry:
> ```bash
> az role assignment create \
>   --assignee $(az ad signed-in-user show --query id -o tsv) \
>   --role "Storage Blob Data Contributor" \
>   --scope $(az storage account show -n sttf$SUFFIX -g rg-tfstate-$SUFFIX --query id -o tsv)
> ```

(If Terraform isn't installed locally: `az group delete -n rg-quoteboard-$SUFFIX --yes` does the
job too — but notice how much nicer `destroy` is.)

---

# Appendix A — Sample application source

For instructors rebuilding the repo, or attendees who want it. Solution layout:

```
kcdc-devops-foundations/
├── .github/
│   ├── CODEOWNERS
│   └── workflows/           (built during labs)
├── infra/                   (built during Lab 3)
├── src/QuoteBoard.Web/
│   ├── QuoteBoard.Web.csproj
│   ├── Program.cs
│   └── Services/QuoteProvider.cs
├── tests/QuoteBoard.Tests/
│   ├── QuoteBoard.Tests.csproj
│   └── QuoteProviderTests.cs
├── CONTRIBUTORS.md
├── QuoteBoard.sln
└── README.md
```

`src/QuoteBoard.Web/Services/QuoteProvider.cs`:
```csharp
namespace QuoteBoard.Web.Services;

public class QuoteProvider
{
    private static readonly List<string> Quotes =
    [
        "You build it, you run it. — Werner Vogels",
        "If it hurts, do it more often. — Martin Fowler",
        "Hope is not a strategy. — Google SRE",
        "Simplicity is a prerequisite for reliability. — Edsger Dijkstra",
        "Blameless postmortems turn incidents into investments."
    ];

    public IReadOnlyList<string> GetAll() => Quotes;

    public string GetDailyQuote(DateOnly date) =>
        Quotes[date.DayNumber % Quotes.Count];
}
```

`src/QuoteBoard.Web/Program.cs`:
```csharp
using QuoteBoard.Web.Services;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<QuoteProvider>();
builder.Services.AddApplicationInsightsTelemetry();
var app = builder.Build();

// Chaos middleware: FAIL_RATE (0..1) randomly fails the homepage and the quotes API.
// /health is deliberately never affected — probes and the page's health dot stay honest.
app.Use(async (ctx, next) =>
{
    var rate = double.TryParse(app.Configuration["FAIL_RATE"], out var r) ? r : 0;
    var chaosPath = ctx.Request.Path == "/" || ctx.Request.Path.StartsWithSegments("/api/quotes");
    if (chaosPath && Random.Shared.NextDouble() < rate)
        throw new InvalidOperationException("Chaos monkey strikes! (FAIL_RATE is set)");
    await next();
});

app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

app.MapGet("/api/quotes", (QuoteProvider q) => q.GetAll());

app.MapGet("/", (QuoteProvider q, IConfiguration cfg) =>
{
    var banner = cfg.GetValue<bool>("FEATURE_NEW_BANNER")
        ? "<div class='banner'>🚀 New feature released — with a flag flip, not a deploy!</div>"
        : "";
    var instance = Environment.GetEnvironmentVariable("WEBSITE_INSTANCE_ID")?[..8] ?? "local";
    var slot = Environment.GetEnvironmentVariable("WEBSITE_SLOT_NAME") ?? "local";
    var quote = q.GetDailyQuote(DateOnly.FromDateTime(DateTime.UtcNow));
    return Results.Content($$"""
<!doctype html>
<html><head><meta charset="utf-8"><title>QuoteBoard · KCDC 2026</title>
<style>
  body{font-family:system-ui;max-width:680px;margin:48px auto;padding:0 16px;color:#1f2328}
  .banner{background:#2da44e;color:#fff;padding:12px 16px;border-radius:8px;margin-bottom:20px}
  h1{margin:0 0 4px}
  .sub{color:#57606a;margin:0 0 28px}
  .card{border:1px solid #d0d7de;border-radius:12px;padding:24px;margin-bottom:20px}
  #quote{font-size:1.25em;min-height:3em}
  button{background:#2da44e;color:#fff;border:0;border-radius:8px;padding:10px 18px;font-size:1em;cursor:pointer}
  button:hover{background:#1a7f37}
  .meta{color:#57606a;font-size:.9em;display:flex;gap:18px;align-items:center;flex-wrap:wrap}
  .dot{display:inline-block;width:10px;height:10px;border-radius:50%;background:#d0d7de;margin-right:6px}
  .err{color:#cf222e}
</style></head>
<body>
{{banner}}
<h1>📋 Welcome to KCDC 2026</h1>
<p class="sub">DevOps Foundations workshop — from code commit to production confidence</p>
<div class="card">
  <p id="quote">“{{quote}}”</p>
  <button onclick="newQuote()">Another quote ↻</button>
</div>
<p class="meta">
  <span><span class="dot" id="dot"></span><span id="health">checking…</span></span>
  <span>Slot: <b>{{slot}}</b></span>
  <span>Instance: {{instance}}</span>
  <span><a href="/api/quotes">API</a> · <a href="/health">Health</a></span>
</p>
<script>
async function newQuote() {
  const el = document.getElementById('quote');
  try {
    const res = await fetch('/api/quotes');
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const quotes = await res.json();
    el.textContent = '“' + quotes[Math.floor(Math.random() * quotes.length)] + '”';
    el.classList.remove('err');
  } catch (e) {
    el.textContent = '💥 ' + e.message + ' — is FAIL_RATE set? Check App Insights!';
    el.classList.add('err');
  }
}
async function ping() {
  const dot = document.getElementById('dot'), t = document.getElementById('health');
  const start = performance.now();
  try {
    const res = await fetch('/health');
    dot.style.background = res.ok ? '#2da44e' : '#cf222e';
    t.textContent = res.ok ? 'healthy · ' + Math.round(performance.now() - start) + ' ms' : 'unhealthy';
  } catch { dot.style.background = '#cf222e'; t.textContent = 'unreachable'; }
}
ping(); setInterval(ping, 5000);
</script>
</body></html>
""", "text/html; charset=utf-8");
});

app.Run();
```

`tests/QuoteBoard.Tests/QuoteProviderTests.cs`:
```csharp
using QuoteBoard.Web.Services;
using Xunit;

public class QuoteProviderTests
{
    private readonly QuoteProvider _sut = new();

    [Fact]
    public void GetAll_ReturnsAtLeastFiveQuotes() =>
        Assert.True(_sut.GetAll().Count >= 5);

    [Fact]
    public void GetDailyQuote_IsDeterministicForSameDate()
    {
        var date = new DateOnly(2026, 8, 13);
        Assert.Equal(_sut.GetDailyQuote(date), _sut.GetDailyQuote(date));
    }

    [Fact]
    public void GetDailyQuote_NeverThrows_ForAnyDate()
    {
        for (var d = 0; d < 3650; d += 37)
            Assert.False(string.IsNullOrEmpty(
                _sut.GetDailyQuote(DateOnly.FromDayNumber(730000 + d))));
    }
}
```

Project files: `QuoteBoard.Web.csproj` targets `net10.0`, references
`Microsoft.ApplicationInsights.AspNetCore`; the test project references `xunit`,
`xunit.runner.visualstudio`, `Microsoft.NET.Test.Sdk`, and the web project.

# Appendix B — Troubleshooting quick hits
| Symptom | Likely cause / fix |
|---|---|
| `MissingSubscription` on a role assignment or any az command | Three causes, check in order: (1) **Git Bash path mangling** — arguments starting with `/` get rewritten to Windows paths; fix with `export MSYS_NO_PATHCONV=1` (quoting does not help). (2) An empty variable — new terminal session lost the exports; see the re-hydrate box in Lab 3.1. (3) Running the bash script in PowerShell/CMD — switch to Git Bash (with the export above) or Cloud Shell. Still stuck? Cloud Shell sidesteps all three |
| `AADSTS700213: No matching federated identity` | The credential subject doesn't match what GitHub presented. The error message prints the **exact presented subject** — copy it verbatim into a new federated credential. Common causes: missing the numeric `@OWNER_ID`/`@REPO_ID` parts (repos created after July 15, 2026 use immutable subjects), wrong context (`pull_request` vs `ref:refs/heads/main` vs `environment:staging`/`environment:production` — environment-scoped jobs present environment subjects, not branch ones), or casing — matching is case-sensitive |
| Terraform init: `403 AuthorizationPermissionMismatch` on storage | Whoever is running init lacks **Storage Blob Data Contributor** on the state account — note the bootstrap grants it to the *pipeline's* identity only, so local init needs a grant for *your user* (command in the Cleanup section; subscription Owner does not include data-plane access). Or RBAC just hasn't propagated — wait 2–3 min and retry |
| Web app name taken | App Service names are globally unique — change `NAME_SUFFIX` |
| Slot swap says tier unsupported | Plan must be **S1 or higher** — check `sku_name` in Terraform |
| Deploy succeeds but site 503s | Cold start — wait 30s; check **Deployment Center → Logs** and `health_check_path` |
| `az` opens the wrong tenant | `az login --tenant <tenant-id>` and `az account set -s <sub-id>` |
