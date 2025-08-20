#!/usr/bin/env python3
"""
Log expert results and MCP usage at subagent completion.
Only runs when WARPIO_LOG=true.
"""
import json
import sys
import os
from datetime import datetime
from pathlib import Path

def extract_expert_info(transcript_path):
    """Extract expert type and MCP usage from transcript."""
    expert_name = "unknown"
    mcps_used = []
    
    try:
        # Parse transcript to identify expert and MCPs
        # This is simplified - in production would parse the JSONL properly
        with open(transcript_path, 'r') as f:
            for line in f:
                if 'subagent_type' in line:
                    data = json.loads(line)
                    expert_name = data.get('subagent_type', 'unknown')
                if 'tool_name' in line and 'mcp__' in line:
                    data = json.loads(line)
                    tool = data.get('tool_name', '')
                    if tool.startswith('mcp__'):
                        mcps_used.append(tool)
    except:
        pass
    
    return expert_name, list(set(mcps_used))

def main():
    """Log expert completion with minimal overhead."""
    # Only run if logging enabled
    if not os.getenv('WARPIO_LOG'):
        sys.exit(0)
    
    try:
        input_data = json.load(sys.stdin)
        session_id = input_data.get('session_id', '')
        transcript = input_data.get('transcript_path', '')
        
        # Extract expert info from transcript
        expert_name, mcps_used = extract_expert_info(transcript)
        
        # Create log entry
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'session_id': session_id,
            'expert': expert_name,
            'mcps_used': mcps_used,
            'mcp_count': len(mcps_used)
        }
        
        # Write to session log
        log_dir = Path(os.getenv('WARPIO_LOG_DIR', '.warpio-logs'))
        session_dir = log_dir / f"session-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        session_dir.mkdir(parents=True, exist_ok=True)
        
        with open(session_dir / 'expert-results.jsonl', 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
        
    except:
        pass  # Silent fail to not disrupt workflow
    
    sys.exit(0)

if __name__ == '__main__':
    main()