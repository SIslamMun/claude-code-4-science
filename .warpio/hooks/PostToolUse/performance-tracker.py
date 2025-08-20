#!/usr/bin/env python3
"""
Track performance metrics for scientific computing operations.
"""
import json
import sys
import time
import os
from datetime import datetime

def track_performance(tool_name, tool_output):
    """Track performance metrics for tools."""
    metrics_dir = "/tmp/warpio-workflows"
    os.makedirs(metrics_dir, exist_ok=True)
    
    # Track specific scientific operations
    scientific_tools = ['mcp__hdf5', 'mcp__numpy', 'mcp__pandas', 'Bash']
    
    if any(tool.lower() in tool_name.lower() for tool in scientific_tools):
        metric = {
            "timestamp": datetime.now().isoformat(),
            "tool": tool_name,
            "execution_time": time.time(),
            "output_size": len(str(tool_output)) if tool_output else 0
        }
        
        # Write metrics
        metrics_file = os.path.join(metrics_dir, f"metrics_{datetime.now().strftime('%Y%m%d')}.jsonl")
        try:
            with open(metrics_file, 'a') as f:
                f.write(json.dumps(metric) + '\n')
        except Exception:
            pass

def main():
    """Main execution for the hook."""
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)
        tool_name = input_data.get('tool_name', '')
        tool_output = input_data.get('tool_output', {})
        
        # Track performance
        track_performance(tool_name, tool_output)
        
        # Always approve
        print(json.dumps({
            'decision': 'approve',
            'reason': 'Performance metrics tracked'
        }))
        sys.exit(0)
        
    except Exception:
        # On error, allow tool to proceed normally
        print(json.dumps({
            'decision': 'approve',
            'reason': 'Proceeding normally'
        }))
        sys.exit(0)

if __name__ == '__main__':
    main()