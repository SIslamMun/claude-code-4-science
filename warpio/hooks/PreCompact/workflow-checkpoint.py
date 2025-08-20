#!/usr/bin/env python3
"""
Create workflow checkpoint before compaction for resumability.
Only runs when WARPIO_LOG=true.
"""
import json
import sys
import os
from datetime import datetime
from pathlib import Path

def create_checkpoint(transcript_path, trigger):
    """Create resumable checkpoint from current state."""
    checkpoint = {
        'timestamp': datetime.now().isoformat(),
        'trigger': trigger,  # 'manual' or 'auto'
        'transcript': transcript_path,
        'environment': {
            'warpio_version': os.getenv('WARPIO_VERSION', '1.0.0'),
            'working_dir': os.getcwd(),
            'python_env': sys.executable
        },
        'resume_instructions': []
    }
    
    # Parse transcript for key state
    try:
        with open(transcript_path, 'r') as f:
            lines = f.readlines()
        
        # Extract key workflow state
        experts_used = set()
        last_files = []
        
        for line in reversed(lines):  # Recent state is more relevant
            try:
                data = json.loads(line)
                
                if 'subagent_type' in str(data):
                    experts_used.add(data.get('subagent_type', ''))
                
                if 'file_path' in str(data) and len(last_files) < 5:
                    if 'tool_input' in data:
                        file_path = data['tool_input'].get('file_path', '')
                        if file_path:
                            last_files.append(file_path)
                            
            except:
                continue
        
        checkpoint['state'] = {
            'experts_active': list(experts_used),
            'recent_files': last_files
        }
        
        # Generate resume instructions
        if experts_used:
            checkpoint['resume_instructions'].append(
                f"Resume with experts: {', '.join(experts_used)}"
            )
        if last_files:
            checkpoint['resume_instructions'].append(
                f"Continue processing: {last_files[0]}"
            )
            
    except:
        pass
    
    return checkpoint

def main():
    """Create checkpoint with minimal overhead."""
    # Only run if logging enabled
    if not os.getenv('WARPIO_LOG'):
        sys.exit(0)
    
    try:
        input_data = json.load(sys.stdin)
        session_id = input_data.get('session_id', '')
        transcript = input_data.get('transcript_path', '')
        trigger = input_data.get('trigger', 'manual')
        
        # Create checkpoint
        checkpoint = create_checkpoint(transcript, trigger)
        checkpoint['session_id'] = session_id
        
        # Write checkpoint
        log_dir = Path(os.getenv('WARPIO_LOG_DIR', '.warpio-logs'))
        session_dir = log_dir / f"session-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        session_dir.mkdir(parents=True, exist_ok=True)
        
        checkpoint_file = session_dir / f"checkpoint-{datetime.now().strftime('%H%M%S')}.json"
        with open(checkpoint_file, 'w') as f:
            json.dump(checkpoint, f, indent=2)
        
        # Create symlink to latest checkpoint
        latest = session_dir / 'latest-checkpoint.json'
        if latest.exists():
            latest.unlink()
        latest.symlink_to(checkpoint_file.name)
        
        # Provide feedback
        print(f"✓ Checkpoint created: {checkpoint_file.name}")
        
    except:
        pass  # Silent fail
    
    sys.exit(0)

if __name__ == '__main__':
    main()