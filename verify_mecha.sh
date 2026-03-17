#!/bin/bash

echo "========================================="
echo "MECHA SPRITE VERIFICATION"
echo "========================================="
echo ""

echo "1. Checking SVG file size..."
SIZE=$(wc -c < sprites/player_ship.svg | tr -d ' ')
if [ "$SIZE" -gt 3000 ]; then
    echo "   ✅ File size: $SIZE bytes (EVA mecha - correct!)"
else
    echo "   ❌ File size: $SIZE bytes (Too small - still triangle?)"
fi
echo ""

echo "2. Checking SVG content..."
if grep -q "EVA-01 Style Mecha" sprites/player_ship.svg; then
    echo "   ✅ Contains EVA mecha design"
else
    echo "   ❌ Does not contain EVA mecha design"
fi
echo ""

echo "3. Checking for cache files..."
if ls .godot/imported/player_ship.svg-* 2>/dev/null; then
    echo "   ⚠️  Cache files still exist - delete these!"
else
    echo "   ✅ No cache files - Godot will reimport fresh"
fi
echo ""

echo "4. File timestamps..."
echo "   Modified: $(stat -f '%Sm' sprites/player_ship.svg)"
echo ""

echo "========================================="
echo "NEXT STEPS:"
echo "========================================="
echo "1. Close Godot completely (if open)"
echo "2. Reopen Godot 4.6"
echo "3. Open the project"
echo "4. Press F5 to run"
echo "5. You should see: Purple EVA mecha 🤖"
echo "========================================="
