#!/bin/bash

# Warpio MCP Setup Validation Script
# Validates that all required MCPs are installed and configured

echo "🔍 Warpio MCP Setup Validation"
echo "=============================="

# Check for UV installation
if ! command -v uv &> /dev/null; then
    echo "❌ UV package manager not found"
    echo "   Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

echo "✅ UV package manager found"

# Check for iowarp-mcps package
if ! uv pip list | grep -q iowarp-mcps; then
    echo "❌ iowarp-mcps package not installed"
    echo "   Install with: uv pip install iowarp-mcps"
    exit 1
fi

echo "✅ iowarp-mcps package found"

# Check critical MCPs
echo ""
echo "🔧 Testing Critical MCPs:"

critical_mcps=("hdf5" "slurm" "zen_mcp")
missing_mcps=()

for mcp in "${critical_mcps[@]}"; do
    echo -n "   $mcp... "
    if uvx iowarp-mcps "$mcp" --help &> /dev/null; then
        echo "✅"
    else
        echo "❌"
        missing_mcps+=("$mcp")
    fi
done

# Summary
echo ""
if [ ${#missing_mcps[@]} -eq 0 ]; then
    echo "🎉 All critical MCPs are working!"
    echo "   Warpio is ready for scientific computing tasks."
    exit 0
else
    echo "⚠️  Some MCPs are not working: ${missing_mcps[*]}"
    echo "   Please check your iowarp-mcps installation."
    exit 1
fi
