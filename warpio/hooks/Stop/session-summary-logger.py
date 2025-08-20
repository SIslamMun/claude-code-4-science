#!/usr/bin/env python3
"""
Generate comprehensive session summary at workflow completion.
Only runs when WARPIO_LOG=true.
"""
import json
import sys
import os
from datetime import datetime
from pathlib import Path
from collections import defaultdict

def parse_transcript(transcript_path):
    """Parse transcript for workflow summary."""
    summary = {
        'experts_used': set(),
        'mcps_by_expert': defaultdict(set),
        'total_mcp_calls': 0,
        'orchestration_pattern': 'single',
        'files_processed': set(),
        'performance_metrics': {}
    }
    
    try:
        with open(transcript_path, 'r') as f:
            lines = f.readlines()
            
        for line in lines:
            try:
                data = json.loads(line)
                
                # Track expert usage
                if 'subagent_type' in str(data):
                    expert = data.get('subagent_type', '')
                    summary['experts_used'].add(expert)
                
                # Track MCP usage
                if 'tool_name' in data:
                    tool = data['tool_name']
                    if tool.startswith('mcp__'):
                        summary['total_mcp_calls'] += 1
                        # Determine expert from context
                        parts = tool.split('__')
                        if len(parts) >= 2:
                            server = parts[1]
                            # Map MCP to likely expert
                            if server in ['hdf5', 'adios', 'parquet']:
                                summary['mcps_by_expert']['data-expert'].add(tool)
                            elif server in ['plot', 'pandas']:
                                summary['mcps_by_expert']['analysis-expert'].add(tool)
                            elif server in ['darshan', 'node_hardware']:
                                summary['mcps_by_expert']['hpc-expert'].add(tool)
                            elif server in ['arxiv', 'context7']:
                                summary['mcps_by_expert']['research-expert'].add(tool)
                
                # Track files
                if 'file_path' in str(data):
                    if isinstance(data, dict) and 'tool_input' in data:
                        file_path = data['tool_input'].get('file_path', '')
                        if file_path:
                            summary['files_processed'].add(file_path)
                            
            except:
                continue
        
        # Determine orchestration pattern
        if len(summary['experts_used']) > 1:
            summary['orchestration_pattern'] = 'multi-expert'
        
        # Convert sets to lists for JSON serialization
        summary['experts_used'] = list(summary['experts_used'])
        summary['files_processed'] = list(summary['files_processed'])
        summary['mcps_by_expert'] = {k: list(v) for k, v in summary['mcps_by_expert'].items()}
        
    except:
        pass
    
    return summary

def main():
    """Generate session summary with minimal overhead."""
    # Only run if logging enabled
    if not os.getenv('WARPIO_LOG'):
        sys.exit(0)
    
    try:
        input_data = json.load(sys.stdin)
        session_id = input_data.get('session_id', '')
        transcript = input_data.get('transcript_path', '')
        
        # Parse transcript for summary
        summary = parse_transcript(transcript)
        
        # Add metadata
        summary['session_id'] = session_id
        summary['timestamp'] = datetime.now().isoformat()
        summary['warpio_version'] = os.getenv('WARPIO_VERSION', '1.0.0')
        
        # Write summary
        log_dir = Path(os.getenv('WARPIO_LOG_DIR', '.warpio-logs'))
        session_dir = log_dir / f"session-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        session_dir.mkdir(parents=True, exist_ok=True)
        
        with open(session_dir / 'session-summary.json', 'w') as f:
            json.dump(summary, f, indent=2)
        
        # Also create human-readable summary
        with open(session_dir / 'summary.md', 'w') as f:
            f.write(f"# Warpio Session Summary\n\n")
            f.write(f"**Session ID**: {session_id}\n")
            f.write(f"**Timestamp**: {summary['timestamp']}\n\n")
            f.write(f"## Orchestration\n")
            f.write(f"- Pattern: {summary['orchestration_pattern']}\n")
            f.write(f"- Experts Used: {', '.join(summary['experts_used'])}\n")
            f.write(f"- Total MCP Calls: {summary['total_mcp_calls']}\n\n")
            f.write(f"## Files Processed\n")
            for file in summary['files_processed'][:10]:  # First 10
                f.write(f"- {file}\n")
            if len(summary['files_processed']) > 10:
                f.write(f"- ... and {len(summary['files_processed']) - 10} more\n")
        
    except:
        pass  # Silent fail
    
    sys.exit(0)

if __name__ == '__main__':
    main()