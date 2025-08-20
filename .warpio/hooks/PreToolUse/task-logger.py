#!/usr/bin/env python3
"""
Simple task logger for Warpio orchestration tracking.
Logs tasks to help understand workflow patterns.
"""
import json
import sys
import os
from datetime import datetime

def log_task(tool_name, tool_input):
    """Log task information for workflow analysis."""
    log_dir = "/tmp/warpio-workflows"
    os.makedirs(log_dir, exist_ok=True)
    
    log_entry = {
        "timestamp": datetime.now().isoformat(),
        "tool": tool_name,
        "input_preview": str(tool_input)[:200] if tool_input else ""
    }
    
    # Write to daily log file
    log_file = os.path.join(log_dir, f"tasks_{datetime.now().strftime('%Y%m%d')}.jsonl")
    try:
        with open(log_file, 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
    except Exception:
        pass  # Silent fail for logging

def main():
    """Main execution for the hook."""
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)
        tool_name = input_data.get('tool_name', '')
        tool_input = input_data.get('tool_input', {})
        
        # Log the task
        log_task(tool_name, tool_input)
        
        # Always approve - this is just logging
        print(json.dumps({
            'decision': 'approve',
            'reason': 'Task logged for orchestration tracking'
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