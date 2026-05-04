#!/bin/bash
# CampusIQ token guardrail — report mode.
# Run: ./scripts/check_tokens.sh
# Flags raw literals that should use tokens. Not a blocker; advisory only.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXIT=0

# ─── Exemptions ─────────────────────────────────────────────────────────────────
# Files that are allowed to contain raw numbers
EXEMPT_FILES=(
  "app_tokens.dart"       # token definitions themselves
  "app_theme.dart"        # theme scale knobs
  ".g.dart"               # generated code
  "app_constants.dart"    # app-level constants
)

# Patterns that ARE allowed as raw values
EXEMPT_PATTERNS=(
  "999"                   # pill radius
  "Duration"              # animation durations
  "0.5"                   # hairline borders
  "\.0"                   # double notation
)

echo "═══════════════════════════════════════════════════════════"
echo "  CampusIQ Token Guardrail — Report Mode"
echo "  Flags raw literals that should use design tokens."
echo "  Advisory only — not a blocker."
echo "═══════════════════════════════════════════════════════════"
echo ""

# Build exemption grep filter
EXEMPT_GREP="app_tokens\.dart|app_theme\.dart|\.g\.dart|app_constants\.dart"

# ─── 1. Raw fontSize ────────────────────────────────────────────────────────────
echo "── 1. Raw fontSize (should use theme text style) ──"
FOUND=$(grep -rn 'fontSize:' "$ROOT/lib" --include="*.dart" \
  | grep -vE "$EXEMPT_GREP" \
  | grep -v 'fontSize: Theme\.\|fontSize: theme\.' \
  | grep -v '// token:' \
  || true)
if [ -n "$FOUND" ]; then
  echo "$FOUND"
  COUNT=$(echo "$FOUND" | wc -l | tr -d ' ')
  echo "  → $COUNT raw fontSize occurrences"
  EXIT=1
else
  echo "  ✓ Clean"
fi
echo ""

# ─── 2. Raw EdgeInsets with numbers ─────────────────────────────────────────────
echo "── 2. Raw EdgeInsets.<all|symmetric|only>(<number>) ──"
FOUND=$(grep -rn 'EdgeInsets\.\(all\|symmetric\|only\)(' "$ROOT/lib" --include="*.dart" \
  | grep -vE "$EXEMPT_GREP" \
  | grep -E '[0-9]' \
  | grep -v 'AppSpacing\.\|AppLayout\.\|AppRadii\.\|AppComponentSizes' \
  | grep -v 'EdgeInsets\.zero' \
  || true)
if [ -n "$FOUND" ]; then
  echo "$FOUND"
  COUNT=$(echo "$FOUND" | wc -l | tr -d ' ')
  echo "  → $COUNT raw EdgeInsets occurrences"
  EXIT=1
else
  echo "  ✓ Clean"
fi
echo ""

# ─── 3. Raw BorderRadius.circular ───────────────────────────────────────────────
echo "── 3. Raw BorderRadius.circular(<number>) ──"
FOUND=$(grep -rn 'BorderRadius\.circular(' "$ROOT/lib" --include="*.dart" \
  | grep -vE "$EXEMPT_GREP" \
  | grep -E '[0-9]' \
  | grep -v 'AppRadii\.\|AppSpacing\.\|999' \
  || true)
if [ -n "$FOUND" ]; then
  echo "$FOUND"
  COUNT=$(echo "$FOUND" | wc -l | tr -d ' ')
  echo "  → $COUNT raw BorderRadius occurrences"
  EXIT=1
else
  echo "  ✓ Clean"
fi
echo ""

# ─── 4. Raw SizedBox with numbers ───────────────────────────────────────────────
echo "── 4. Raw SizedBox(height|width: <number>) ──"
FOUND=$(grep -rn 'SizedBox(\(height\|width\):' "$ROOT/lib" --include="*.dart" \
  | grep -vE "$EXEMPT_GREP" \
  | grep -E '[0-9]' \
  | grep -v 'AppSpacing\.\|AppLayout\.\|AppComponentSizes' \
  | grep -v '\.shrink\|\.expand\|double\.infinity' \
  || true)
if [ -n "$FOUND" ]; then
  echo "$FOUND"
  COUNT=$(echo "$FOUND" | wc -l | tr -d ' ')
  echo "  → $COUNT raw SizedBox occurrences"
  EXIT=1
else
  echo "  ✓ Clean"
fi
echo ""

# ─── 5. Raw Icon sizes ─────────────────────────────────────────────────────────
echo "── 5. Raw Icon size: <number> ──"
FOUND=$(grep -rn ', size: [0-9]' "$ROOT/lib" --include="*.dart" \
  | grep -vE "$EXEMPT_GREP" \
  | grep -v 'AppIconSizes\.\|AppSpacing\.' \
  || true)
if [ -n "$FOUND" ]; then
  echo "$FOUND"
  COUNT=$(echo "$FOUND" | wc -l | tr -d ' ')
  echo "  → $COUNT raw Icon size occurrences"
  EXIT=1
else
  echo "  ✓ Clean"
fi
echo ""

# ─── 6. Raw Container width/height ──────────────────────────────────────────────
echo "── 6. Raw Container/SizedBox fixed dimensions (potential scale risks) ──"
FOUND=$(grep -rn 'Container(.*\(width\|height\):\|SizedBox(.*\(width\|height\):' "$ROOT/lib" --include="*.dart" \
  | grep -vE "$EXEMPT_GREP" \
  | grep -E '[0-9]' \
  | grep -v 'AppSpacing\.\|AppLayout\.\|AppComponentSizes\|AppIconSizes' \
  | grep -v 'double\.infinity\|\.shrink\|\.expand' \
  || true)
if [ -n "$FOUND" ]; then
  COUNT=$(echo "$FOUND" | wc -l | tr -d ' ')
  echo "  → $COUNT fixed-dimension containers (review for scale safety)"
  echo "  (first 20 shown — see full report for all)"
  echo "$FOUND" | head -20
  EXIT=1
else
  echo "  ✓ Clean"
fi

echo ""

# ─── 7. Compact-scale safety: fontSize below readability floor ──────────────────
echo "── 7. Compact-scale safety: fontSize below readability floor ──"
# Check for font sizes that would drop below AppFloors.minCaptionFontSize (8px) at -20%
echo "  Checking fontSize values < 10 (would be < 8px at -20% scale)..."
FOUND=$(grep -rn 'fontSize: [0-9]' "$ROOT/lib" --include="*.dart" \
  | grep -vE "$EXEMPT_GREP" \
  | grep -v 'fontSize: 1[0-9]\|fontSize: 2[0-9]\|fontSize: 3[0-9]\|fontSize: 4[0-9]\|fontSize: 5[0-9]\|fontSize: 6[0-9]' \
  | grep -v 'fontSize: Theme\.\|fontSize: theme\.' \
  || true)
if [ -n "$FOUND" ]; then
  echo "$FOUND"
  COUNT=$(echo "$FOUND" | wc -l | tr -d ' ')
  echo "  → $COUNT fontSize values below readability floor at compact scale"
  echo "  → Review these before scaling to compact profile"
  EXIT=1
else
  echo "  ✓ No sub-floor font sizes found"
fi

# Check for fixed dimensions that might break at compact scale
echo ""
echo "── 8. Fixed dimensions that don't scale ──"
FOUND=$(grep -rn 'pixelsPerMinute\|mainAxisExtent\|childAspectRatio\|Container(width\|Container(height' "$ROOT/lib" --include="*.dart" \
  | grep -vE "$EXEMPT_GREP" \
  | grep -v 'AppSpacing\.\|AppLayout\.\|AppComponentSizes\|AppFloors\|static const\|_size\|_iconBox' \
  | grep -E '[0-9]' \
  | head -15 \
  || true)
if [ -n "$FOUND" ]; then
  echo "  → Fixed layout dimensions found (review for scale safety):"
  echo "$FOUND"
  echo "  → These may not adapt to profile changes"
else
  echo "  ✓ No unscalable fixed dimensions found"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
if [ $EXIT -eq 0 ]; then
  echo "  All checks passed. Token hygiene is clean."
else
  echo "  Review the items above. Most are legitimate overrides."
  echo "  Focus on categories 1 (fontSize), 6 (fixed dimensions),"
  echo "  and 7 (compact-scale readability)."
  echo ""
  echo "  Known safe to ignore:"
  echo "    - animation durations"
  echo "    - hairline borders (0.5, 1.0)"
  echo "    - chart math / custom paint coordinates"
  echo "    - one-off component-specific constraints"
fi
echo "═══════════════════════════════════════════════════════════"

exit $EXIT
