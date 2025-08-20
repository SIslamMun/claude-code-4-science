#!/usr/bin/env python3
"""
Track performance metrics for scientific computing operations.
Enhanced with better error handling and path resolution.
"""
import json
import sys
import time
import os
from datetime import datetime
from pathlib import Path

def get_metrics_directory():
    """Get metrics directory with fallback options."""
    # Try environment variable first
    metrics_dir = os.environ.get('WORKFLOW_DIR', '/tmp/warpio-workflows')
    
    # Ensure directory exists and is writable
    try:
        os.makedirs(metrics_dir, exist_ok=True)
        return metrics_dir
    except (OSError, PermissionError):
        # Fallback to user's temp directory
        fallback_dir = os.path.join(os.path.expanduser('~'), '.warpio', 'metrics')
        try:
            os.makedirs(fallback_dir, exist_ok=True)
            return fallback_dir
        except (OSError, PermissionError):
            return os.getcwd()

def track_performance(tool_name, tool_output):
    """Track performance metrics for tools."""
    try:
        metrics_dir = get_metrics_directory()
    
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
        except Exception as e:
            # Log error to stderr but don't fail
            print(f"Warning: Metrics logging failed: {e}", file=sys.stderr)
    except Exception as e:
        # Log error but continue
        print(f"Warning: Performance tracking failed: {e}", file=sys.stderr)

def main():
    """Main execution for the hook."""
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)
        tool_name = input_data.get('tool_name', '')
        tool_output = input_data.get('tool_output', {})
        
        # Track performance (non-blocking)
        track_performance(tool_name, tool_output)
        
        # Always approve
        print(json.dumps({
            'decision': 'approve',
            'reason': 'Performance metrics tracked'
        }))
        sys.exit(0)
        
    except json.JSONDecodeError:
        # Invalid JSON input - approve anyway
        print(json.dumps({
            'decision': 'approve',
            'reason': 'Invalid input format, proceeding normally'
        }))
        sys.exit(0)
        
    except Exception as e:
        # On any error, allow tool to proceed normally
        print(json.dumps({
            'decision': 'approve',
            'reason': f'Hook error (continuing): {str(e)[:100]}'
        }))
        sys.exit(0)

if __name__ == '__main__':
    main()