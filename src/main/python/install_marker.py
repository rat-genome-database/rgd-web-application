#!/usr/bin/env python3
"""
Install Marker and its dependencies
"""

import subprocess
import sys

def install_marker():
    """Install marker-pdf package"""
    try:
        # Check if marker is already installed
        import marker
        print("Marker is already installed")
        return True
    except ImportError:
        print("Installing Marker...")
        
        # Install marker-pdf and dependencies
        subprocess.check_call([
            sys.executable, "-m", "pip", "install", 
            "marker-pdf", 
            "torch", 
            "torchvision",
            "--quiet"
        ])
        
        print("Marker installed successfully")
        return True
    except Exception as e:
        print(f"Failed to install Marker: {e}")
        return False

if __name__ == "__main__":
    install_marker()