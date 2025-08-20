#!/usr/bin/env python3
"""
Aggregate results from multiple expert subagents.
"""
import json
import sys
import os
from datetime import datetime

def aggregate_results(subagent_name, result):
    """Aggregate results from subagents."""
    results_dir = "/tmp/warpio-workflows"
    os.makedirs(results_dir, exist_ok=True)
    
    # Store subagent results
    result_entry = {
        "timestamp": datetime.now().isoformat(),
        "subagent": subagent_name,
        "result_preview": str(result)[:500] if result else ""
    }
    
    # Write to aggregation file
    results_file = os.path.join(results_dir, f"subagent_results_{datetime.now().strftime('%Y%m%d')}.jsonl")
    try:
        with open(results_file, 'a') as f:
            f.write(json.dumps(result_entry) + '\n')
    except Exception:
        pass

def main():
    """Main execution for the hook."""
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)
        subagent_name = input_data.get('subagent_name', '')
        result = input_data.get('result', {})
        
        # Aggregate results
        aggregate_results(subagent_name, result)
        
        # Provide context about aggregation
        print(json.dumps({
            'decision': 'approve',
            'reason': 'Subagent results aggregated',
            'hookSpecificOutput': {
                'hookEventName': 'SubagentStop',
                'additionalContext': f"Results from {subagent_name} captured for orchestration analysis"
            }
        }))
        sys.exit(0)
        
    except Exception:
        # On error, allow to proceed normally
        print(json.dumps({
            'decision': 'approve',
            'reason': 'Proceeding normally'
        }))
        sys.exit(0)

if __name__ == '__main__':
    main()