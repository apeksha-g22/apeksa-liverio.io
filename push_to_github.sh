#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Liverio — GitHub Setup & Push Script
# Run this once to initialise git and push to your GitHub repo
# ─────────────────────────────────────────────────────────────────────────────

set -e

echo "╔══════════════════════════════════════════╗"
echo "║        Liverio — GitHub Setup            ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── 1. Configure git identity ──────────────────────────────────────────────
read -p "Enter your GitHub username : " GH_USER
read -p "Enter your email address   : " GH_EMAIL
read -p "Enter your repo name (default: liverio): " REPO_NAME
REPO_NAME=${REPO_NAME:-liverio}

git config user.name  "$GH_USER"
git config user.email "$GH_EMAIL"

# ── 2. Initialise git repo ─────────────────────────────────────────────────
if [ ! -d ".git" ]; then
  git init
  echo "✅ Git initialised"
else
  echo "ℹ️  Git already initialised"
fi

# ── 3. Stage all files ─────────────────────────────────────────────────────
git add .
echo "✅ Files staged"

# ── 4. Initial commit ──────────────────────────────────────────────────────
git commit -m "feat: initial Liverio v2 release

- FastAPI backend with ML prediction & recommendation engine
- Logistic Regression model (AUC 0.82) trained on ILPD dataset
- Premium single-page frontend (dark mode, voice input, PDF export)
- AI chatbot with Claude API + local KB fallback
- GitHub Actions CI/CD with auto-deploy to GitHub Pages
- Full README and .env.example documentation"

echo "✅ Initial commit created"

# ── 5. Create GitHub repo via API ──────────────────────────────────────────
echo ""
echo "Creating GitHub repository '$REPO_NAME'..."
read -p "Enter your GitHub Personal Access Token (PAT): " GH_TOKEN

API_RESP=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/user/repos" \
  -d "{
    \"name\": \"$REPO_NAME\",
    \"description\": \"AI-powered liver disease prediction, risk classification & personalised health recommendations\",
    \"homepage\": \"https://$GH_USER.github.io/$REPO_NAME\",
    \"private\": false,
    \"auto_init\": false,
    \"has_issues\": true,
    \"has_projects\": false,
    \"has_wiki\": false
  }")

HTTP_CODE=$(echo "$API_RESP" | tail -1)
RESP_BODY=$(echo "$API_RESP" | head -1)

if [ "$HTTP_CODE" = "201" ]; then
  echo "✅ GitHub repository created: https://github.com/$GH_USER/$REPO_NAME"
elif [ "$HTTP_CODE" = "422" ]; then
  echo "ℹ️  Repository already exists at https://github.com/$GH_USER/$REPO_NAME"
else
  echo "❌ GitHub API returned $HTTP_CODE. Check your PAT permissions."
  echo "   Response: $RESP_BODY"
  echo ""
  echo "📝 You can manually create the repo at https://github.com/new"
  echo "   Then run: git remote add origin https://github.com/$GH_USER/$REPO_NAME.git"
fi

# ── 6. Push to GitHub ──────────────────────────────────────────────────────
git remote remove origin 2>/dev/null || true
git remote add origin "https://$GH_USER:$GH_TOKEN@github.com/$GH_USER/$REPO_NAME.git"
git branch -M main
git push -u origin main

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅ Liverio is live on GitHub!"
echo ""
echo "  Repository   : https://github.com/$GH_USER/$REPO_NAME"
echo "  GitHub Pages : https://$GH_USER.github.io/$REPO_NAME"
echo "  API Docs     : http://localhost:8000/docs  (after running backend)"
echo ""
echo "  Next steps:"
echo "  1. Go to: https://github.com/$GH_USER/$REPO_NAME/settings/pages"
echo "     → Source: Deploy from branch → gh-pages → / (root)"
echo "  2. GitHub Actions will auto-deploy the frontend on every push to main"
echo "═══════════════════════════════════════════════════════"
