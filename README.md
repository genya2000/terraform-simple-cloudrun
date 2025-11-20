# simple-cloudrun

Cloud Run + Terraform + GitHub Actions sample repo (minimal)

## Structure

```
simple-cloudrun/
├── app/                     # App source + Dockerfile
├── infra/                   # Terraform code
├── .github/workflows/       # GitHub Actions
└── README.md
```

## Quickstart (manual)

1. Create a GCP project and enable APIs:
   ```
   gcloud services enable run.googleapis.com cloudbuild.googleapis.com servicenetworking.googleapis.com
   ```

2. Create a service account and grant roles:
   - roles/run.admin
   - roles/iam.serviceAccountUser
   - roles/storage.admin
   - (optionally) roles/artifactregistry.writer

   Download JSON key and add it to GitHub Secrets as `GCP_SA_KEY`.
   Also set `GCP_PROJECT_ID` secret.

3. Push this repository to GitHub. On `main` branch push, the workflow will:
   - build Docker image and push to GCR
   - run `terraform apply` to create/update Cloud Run service

4. After workflow completes, check Terraform output or Cloud Run console for the URL.

## Notes
- Adjust CPU/memory in `infra/main.tf` for cost/performance.
- If using Artifact Registry instead of GCR, update image names and docker auth steps.

---

Cloud Run 自動デプロイ環境（GitHub Actions + Terraform）手順メモ

このリポジトリは、Cloud Run へ自動デプロイするためのサンプル構成です。

project-root/
├── app/                 # アプリケーション（Node.js）
│   ├── Dockerfile
│   └── index.js
├── infra/               # Terraform（Cloud Run / Artifact Registry）
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
├── .github/workflows/
│   └── deploy.yml       # GitHub Actions（CI/CD）
└── README.md

1. 事前準備
■ Google Cloud 側で準備するもの
① プロジェクト作成

Cloud Console で新しいプロジェクトを作成。
PROJECT_ID を控える。

② API 有効化

以下の API を有効化：

Cloud Run API

Cloud Build API

Artifact Registry API

IAM API

③ サービスアカウント作成

GitHub Actions がデプロイ権限を持つためのサービスアカウント。

gcloud iam service-accounts create github-deploy \
  --display-name="GitHub Deployment"


権限付与：

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:github-deploy@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:github-deploy@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

④ サービスアカウントキーの作成

GitHub Actions に保存する。

gcloud iam service-accounts keys create key.json \
  --iam-account=github-deploy@PROJECT_ID.iam.gserviceaccount.com


この key.json の内容を GitHub リポジトリの Secret に保存する：

GCP_SA_KEY（サービスアカウントキー）

GCP_PROJECT_ID

2. Terraform の初期設定

infra/ に移動して初期化：

cd infra
terraform init


Google Provider の認証は、GitHub Actions 側でサービスアカウントキーを設定するため、ローカルでは以下でログイン：

gcloud auth application-default login

3. GitHub Actions の設定

.github/workflows/deploy.yml で以下が動く：

push（mainブランチ）をトリガー

Docker Build

Artifact Registry へ push

Terraform Apply（Cloud Run 更新）

必要な GitHub Secrets：

SECRET 名	説明
GCP_SA_KEY	サービスアカウントキー JSON
GCP_PROJECT_ID	GCP プロジェクト ID
REGION	asia-northeast1 など
4. 自動デプロイの流れ
git push origin main
        ↓
GitHub Actions 起動
        ↓
Docker build → Artifact Registry へ push
        ↓
Terraform apply → Cloud Run 更新
        ↓
新しい URL or 既存のサービスへ更新

5. ローカルからの手動デプロイ（必要な場合）

ローカルで Docker Build → Cloud Run デプロイするなら：

gcloud builds submit --tag asia-northeast1-docker.pkg.dev/PROJECT_ID/myrepo/myapp
gcloud run deploy myapp \
  --image asia-northeast1-docker.pkg.dev/PROJECT_ID/myrepo/myapp \
  --region asia-northeast1 \
  --platform managed

6. Cloud Run の停止・削除
■ 停止（トラフィックゼロにして課金最小化）
gcloud run services update myapp --no-traffic

■ サービス削除
gcloud run services delete myapp

■ Artifact Registry のコンテナ削除
gcloud artifacts docker images delete \
  asia-northeast1-docker.pkg.dev/PROJECT_ID/myrepo/myapp

■ Terraform 管理の場合
cd infra
terraform destroy

7. リポジトリ構成のポイント

app/ にアプリのソースコード

infra/ は Terraform に特化

.github/workflows/ に CI/CD

Cloud Run の設定は Terraform 側で一元管理

GitHub Actions によって Terraform Apply まで自動化# simple-cloudrun-cicd


END
