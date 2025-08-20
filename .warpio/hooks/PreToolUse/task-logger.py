#!/usr/bin/env python3
"""
Simple task logger for Warpio orchestration tracking.
Enhanced with proper error handling and path resolution.
"""
import json
import sys
import os
from datetime import datetime
from pathlib import Path

def get_log_directory():
    """Get log directory with fallback options."""
    # Try environment variable first
    log_dir = os.environ.get('WORKFLOW_DIR', '/tmp/warpio-workflows')
    
    # Ensure directory exists and is writable
    try:
        os.makedirs(log_dir, exist_ok=True)
        # Test write access
        test_file = os.path.join(log_dir, '.test_write')
        with open(test_file, 'w') as f:
            f.write('test')
        os.remove(test_file)
        return log_dir
    except (OSError, PermissionError):
        # Fallback to user's temp directory
        fallback_dir = os.path.join(os.path.expanduser('~'), '.warpio', 'logs')
        try:
            os.makedirs(fallback_dir, exist_ok=True)
            return fallback_dir
        except (OSError, PermissionError):
            # Last resort: current directory
            return os.getcwd()

def log_task(tool_name, tool_input):
    """Log task information for workflow analysis."""
    try:
        log_dir = get_log_directory()
        
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "tool": tool_name,
            "input_preview": str(tool_input)[:200] if tool_input else "",
            "session_id": os.environ.get('CLAUDE_SESSION_ID', 'unknown')
        }
        
        # Write to daily log file
        log_file = os.path.join(log_dir, f"tasks_{datetime.now().strftime('%Y%m%d')}.jsonl")
        with open(log_file, 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
            
    except Exception as e:
        # Log error to stderr but don't fail the hook
        print(f"Warning: Task logging failed: {e}", file=sys.stderr)

def main():
    """Main execution for the hook."""
    try:
        # Read input from stdin with timeout
        input_data = json.load(sys.stdin)
        tool_name = input_data.get('tool_name', '')
        tool_input = input_data.get('tool_input', {})
        
        # Log the task (non-blocking)
        log_task(tool_name, tool_input)
        
        # Always approve - this is just logging
        print(json.dumps({
            'decision': 'approve',
            'reason': 'Task logged for orchestration tracking'
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