#!/usr/bin/env python3
"""
Example: Multi-Expert Climate Data Analysis Pipeline
Demonstrates orchestration of multiple Warpio personas
"""

def orchestrate_climate_analysis():
    """
    Warpio orchestrates multiple experts for comprehensive climate analysis.
    
    This example shows how /orchestrate-experts coordinates:
    - Data Expert: Format conversion and I/O optimization
    - HPC Expert: Parallel processing setup
    - Analysis Expert: Statistical analysis and visualization
    - Research Expert: Documentation and reproducibility
    - Workflow Expert: Pipeline orchestration
    """
    
    pipeline_steps = """
    🎭 Warpio Multi-Expert Orchestration
    =====================================
    
    Step 1: Data Expert
    -------------------
    - Converting 10TB NetCDF files to optimized HDF5
    - Chunking: 128x128x24 (lat, lon, time)
    - Compression: GZIP level 6
    - Parallel I/O with 64 processes
    → zen-mcp delegates bulk conversions to local AI
    
    Step 2: HPC Expert
    ------------------
    - Generated SLURM array job (1000 tasks)
    - MPI configuration for 32 nodes
    - Optimized for Lustre filesystem
    - Checkpoint/restart enabled
    → zen-mcp reviews and optimizes scripts
    
    Step 3: Analysis Expert
    -----------------------
    - Time series decomposition
    - Spatial correlation analysis
    - Trend detection with Mann-Kendall test
    - Generated 50+ publication-ready figures
    → Local AI handles parallel statistical computations
    
    Step 4: Research Expert
    -----------------------
    - Created methods section for paper
    - Generated reproducibility package
    - Documented all parameters
    - Created Docker container
    → zen-mcp assists with documentation generation
    
    Step 5: Workflow Expert
    -----------------------
    - Nextflow pipeline created
    - DAG visualization generated
    - Error handling implemented
    - Monitoring dashboard setup
    → Orchestration validated by local AI
    
    Performance Metrics:
    - Total processing time: 4 hours (vs 48 hours manual)
    - Claude tokens saved: 75% (via local AI delegation)
    - Reproducibility score: 100%
    - Publication readiness: Complete
    """
    
    print(pipeline_steps)
    
    # In practice, Warpio would:
    # 1. Use Task tool to launch each expert
    # 2. Coordinate via zen-mcp for parallel execution
    # 3. Aggregate results with hooks
    # 4. Monitor progress with status line

if __name__ == "__main__":
    orchestrate_climate_analysis()
    print("\n✅ Multi-expert pipeline complete with Warpio orchestration!")