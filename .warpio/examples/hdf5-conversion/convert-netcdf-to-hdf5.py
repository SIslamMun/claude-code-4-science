#!/usr/bin/env python3
"""
Example: Convert NetCDF to optimized HDF5 with compression
Demonstrates Warpio's data-expert persona capabilities
"""

# This example shows how Warpio would handle a scientific data conversion task
# The data-expert persona would:
# 1. Analyze the NetCDF structure
# 2. Determine optimal HDF5 chunking
# 3. Apply appropriate compression
# 4. Preserve all metadata

def convert_netcdf_to_hdf5(nc_file, h5_file):
    """
    Convert NetCDF file to HDF5 with optimization.
    
    Warpio would enhance this with:
    - Automatic chunking optimization based on access patterns
    - Compression algorithm selection based on data type
    - Parallel I/O for large files
    - Metadata preservation and enhancement
    """
    # Example structure - would be implemented with actual libraries via UV
    print(f"Converting {nc_file} to {h5_file}")
    print("Warpio data-expert would:")
    print("  1. Analyze data dimensions and types")
    print("  2. Calculate optimal chunk sizes")
    print("  3. Select compression (GZIP for float, SZIP for int)")
    print("  4. Use parallel HDF5 for files > 1GB")
    print("  5. Validate conversion with checksums")
    
    # In practice, Warpio would use:
    # - mcp__zen__analyze for data structure analysis
    # - HDF5 MCP tools for conversion
    # - Local AI for optimization suggestions

if __name__ == "__main__":
    # Example usage
    convert_netcdf_to_hdf5("climate_data.nc", "climate_data_optimized.h5")
    print("\n✅ Conversion complete with Warpio optimization!")