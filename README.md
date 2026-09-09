![CI](https://github.com/Electropsyche/kcdc-devops-foundations/actions/workflows/ci.yml/badge.svg)

# DevOps Foundations: From Code Commit to Production Confidence

Hands-on workshop · [KCDC](https://www.kcdc.info) · 4 hours · Vaibhav Gujral

Over four hours, you'll take **one small application the whole distance**: from a first commit in
a protected repository, through CI, Terraform-provisioned Azure infrastructure, and an approved
zero-downtime release — and then we break it in production on purpose and recover in about a
minute.

```
GitHub repo ──▶ Actions CI ──▶ artifact ──▶ Terraform ──▶ Azure App Service
 (protected)   (build·test)  (build once)    (via PR)    staging ─▶ swap ─▶ prod
                                                          └── App Insights + alerts
```

## Start here

| | |
|---|---|
| 🧰 **Before the workshop** | [`pre-requisites/`](pre-requisites/) — accounts, tools, versions, and verification steps. **Check this page for the most up-to-date requirements**; it may change between the confirmation email and the conference. |
| 🧪 **During the workshop** | [`labs/`](labs/) — the full lab guide: every command, workflow, and Terraform file you'll write. |
| 📦 **The app** | `src/QuoteBoard.Web` (ASP.NET Core minimal API) + `tests/QuoteBoard.Tests` (xUnit). Small on purpose — the pipeline is the product today. |

## The labs

| Lab | You build | Time |
|---|---|---|
| 1 | Protected `main`, your first guarded merge, CODEOWNERS | 20 min |
| 2 | A CI pipeline from scratch — then a broken test blocks a merge | 30 min |
| 3 | Your Azure environment from a pull request (Terraform + OIDC, no stored secrets) | 30 min |
| 4 | Staging → human approval → blue/green slot swap → feature-flag release | 30 min |
| Demo | We break production, watch the telemetry, and recover in ~60 seconds | follow along |

Fell behind? Every lab has a checkpoint branch (`checkpoint/lab-N-complete`) you can fast-forward
from — details in the lab guide.

## Cost & cleanup

Total Azure spend for the workshop is **under $1** (one S1 App Service plan for ~3 hours). The
last thing we do together is `terraform destroy` — don't skip it. Cleanup steps are at the end of
the [lab guide](labs/).

## After the workshop

The patterns here map directly to Microsoft's **AZ-2008 "DevOps foundations"** learning path on
Microsoft Learn if you want to continue toward the Applied Skills credential — plus reading and
next steps in the closing slides.

---

*See you there!*
