#!/bin/bash
# =============================================================================
# ☕ Charlie Café — Enterprise Test & Verification Export System
#
# FEATURES:
# - ASCII company logo
# - Colorized PASS / FAIL (terminal-safe)
# - One PDF per service
# - One MASTER PDF
# - Header & footer (lab name + author + page no)
# - TXT / CSV / PDF → S3
#
# PLATFORM : Amazon Linux 2023
# PDF CORE : enscript + ghostscript (ROCK SOLID)
# =============================================================================

set -Eeuo pipefail

# -----------------------------------------------------------------------------
# LAB IDENTITY
# -----------------------------------------------------------------------------
LAB_NAME="Charlie Café ☕ — Test & Verification Lab"
AUTHOR_NAME="IT Charlie"
ENVIRONMENT="Amazon Linux 2023 (EC2)"

# -----------------------------------------------------------------------------
# AWS CONFIG
# -----------------------------------------------------------------------------
AWS_REGION="us-east-1"
S3_BUCKET="charlie-cafe-s3-bucket"
S3_PREFIX="Charlie-Cafe/Test-Verification"

# -----------------------------------------------------------------------------
# TEST SCRIPTS (SERVICE LEVEL)
# -----------------------------------------------------------------------------
TEST_SCRIPTS=(
  "./charlie_cafe_lab_test_verify.sh"
  # "./api_gateway_test.sh"
  # "./lambda_test.sh"
)

# -----------------------------------------------------------------------------
# COLORS (TERMINAL ONLY)
# -----------------------------------------------------------------------------
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# -----------------------------------------------------------------------------
# TIMESTAMP & WORKSPACE
# -----------------------------------------------------------------------------
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
BASE_DIR="/tmp/charlie-cafe-$TIMESTAMP"
MASTER_TXT="$BASE_DIR/master_report.txt"
mkdir -p "$BASE_DIR"

# -----------------------------------------------------------------------------
# ASCII LOGO
# -----------------------------------------------------------------------------
read -r -d '' ASCII_LOGO <<'EOF'
   ██████╗██╗  ██╗ █████╗ ██████╗ ██╗     ██╗███████╗
  ██╔════╝██║  ██║██╔══██╗██╔══██╗██║     ██║██╔════╝
  ██║     ███████║███████║██████╔╝██║     ██║█████╗
  ██║     ██╔══██║██╔══██║██╔══██╗██║     ██║██╔══╝
  ╚██████╗██║  ██║██║  ██║██║  ██║███████╗██║███████╗
   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝
                    ☕ CHARLIE CAFÉ
EOF

# -----------------------------------------------------------------------------
# INSTALL DEPENDENCIES
# -----------------------------------------------------------------------------
echo "📦 Installing prerequisites..."
sudo dnf install -y awscli enscript ghostscript coreutils util-linux
export AWS_DEFAULT_REGION="$AWS_REGION"
echo "✅ Ready"

# -----------------------------------------------------------------------------
# MASTER REPORT HEADER
# -----------------------------------------------------------------------------
{
  echo "$ASCII_LOGO"
  echo
  echo "$LAB_NAME"
  echo "Prepared by : $AUTHOR_NAME"
  echo "Environment : $ENVIRONMENT"
  echo "Generated   : $(date)"
  echo "============================================================"
  echo
} > "$MASTER_TXT"

TOTAL=0
PASSED=0
FAILED=0

# -----------------------------------------------------------------------------
# RUN TESTS (PER SERVICE)
# -----------------------------------------------------------------------------
for SCRIPT in "${TEST_SCRIPTS[@]}"; do
  ((TOTAL++))
  SERVICE_NAME="$(basename "$SCRIPT" .sh)"
  SERVICE_DIR="$BASE_DIR/$SERVICE_NAME"
  mkdir -p "$SERVICE_DIR"

  SERVICE_TXT="$SERVICE_DIR/${SERVICE_NAME}.txt"
  SERVICE_PS="$SERVICE_DIR/${SERVICE_NAME}.ps"
  SERVICE_PDF="$SERVICE_DIR/${SERVICE_NAME}.pdf"

  {
    echo "$ASCII_LOGO"
    echo
    echo "SERVICE REPORT: $SERVICE_NAME"
    echo "Started at: $(date)"
    echo "------------------------------------------------------------"
  } > "$SERVICE_TXT"

  START=$(date +%s)

  if [[ -x "$SCRIPT" ]]; then
    if bash "$SCRIPT" >> "$SERVICE_TXT" 2>&1; then
      RESULT="PASS"
      ((PASSED++))
      echo -e "${GREEN}[PASS]${RESET} $SERVICE_NAME"
    else
      RESULT="FAIL"
      ((FAILED++))
      echo -e "${RED}[FAIL]${RESET} $SERVICE_NAME"
    fi
  else
    RESULT="FAIL (Not Executable)"
    ((FAILED++))
    echo -e "${RED}[FAIL]${RESET} $SERVICE_NAME (not executable)"
  fi

  END=$(date +%s)
  DURATION=$((END - START))

  {
    echo
    echo "------------------------------------------------------------"
    echo "Result        : [$RESULT]"
    echo "Execution Time: ${DURATION}s"
    echo "Completed at  : $(date)"
    echo
  } >> "$SERVICE_TXT"

  # Append to MASTER
  cat "$SERVICE_TXT" >> "$MASTER_TXT"

  # Generate SERVICE PDF
  enscript "$SERVICE_TXT" \
    --font=Courier10 \
    --word-wrap \
    --header="$LAB_NAME" \
    --footer="Prepared by: $AUTHOR_NAME | Page \$%" \
    --no-job-header \
    -p "$SERVICE_PS"

  ps2pdf "$SERVICE_PS" "$SERVICE_PDF"

  aws s3 cp "$SERVICE_PDF" "s3://$S3_BUCKET/$S3_PREFIX/services/$SERVICE_NAME.pdf"
done

# -----------------------------------------------------------------------------
# MASTER SUMMARY
# -----------------------------------------------------------------------------
{
  echo "============================================================"
  echo "📊 MASTER SUMMARY"
  echo "Total Services : $TOTAL"
  echo "Passed         : $PASSED"
  echo "Failed         : $FAILED"
  echo "============================================================"
} >> "$MASTER_TXT"

# -----------------------------------------------------------------------------
# MASTER PDF
# -----------------------------------------------------------------------------
MASTER_PS="$BASE_DIR/master.ps"
MASTER_PDF="$BASE_DIR/Charlie-Cafe-Master-Report_$TIMESTAMP.pdf"

enscript "$MASTER_TXT" \
  --font=Courier10 \
  --word-wrap \
  --header="$LAB_NAME" \
  --footer="Prepared by: $AUTHOR_NAME | Page \$%" \
  --no-job-header \
  -p "$MASTER_PS"

ps2pdf "$MASTER_PS" "$MASTER_PDF"

aws s3 cp "$MASTER_PDF" "s3://$S3_BUCKET/$S3_PREFIX/master/$(basename "$MASTER_PDF")"

# -----------------------------------------------------------------------------
# DONE
# -----------------------------------------------------------------------------
echo "============================================================"
echo -e "🎉 ${GREEN}EXPORT COMPLETE${RESET}"
echo "📄 Master PDF uploaded"
echo "☁️ S3 Bucket: s3://$S3_BUCKET/$S3_PREFIX/"
echo "============================================================"
