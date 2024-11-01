#!/bin/bash
# file: .devcontainer/additions/_template-install-script.sh
#
# TEMPLATE: Copy this file when creating new installation scripts
# Rename to: install-[your-name].sh
# Example: install-dev-python.sh
#
# Usage: ./install-[name].sh [options]
# 
# Options:
#   --debug     : Enable debug output for troubleshooting
#   --uninstall : Remove installed components instead of installing them
#   --force     : Force installation/uninstallation even if there are dependencies
#
#------------------------------------------------------------------------------
# CONFIGURATION - Modify this section for each new script
#------------------------------------------------------------------------------

# Script metadata - must be at the very top of the configuration section
SCRIPT_NAME="[Name]"
SCRIPT_DESCRIPTION="[Brief description of what this script installs and its purpose]"

# Before running installation, we need to add any required repositories or setup
pre_installation_setup() {
    if [ "${UNINSTALL_MODE}" -eq 1 ]; then
        echo "🔧 Preparing for uninstallation..."
    else
        echo "🔧 Performing pre-installation setup..."
        # Add repository configurations, keys, or other setup steps here
        # Example:
        # curl -fsSL https://example.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/example-archive-keyring.gpg
    fi
}

# Define package arrays (remove any empty arrays that aren't needed)
SYSTEM_PACKAGES=(
    # "package1"
    # "package2"
)

NODE_PACKAGES=(
    # "package1"
    # "package2"
)

PYTHON_PACKAGES=(
    # "package1"
    # "package2"
)

PWSH_MODULES=(
    # "module1"
    # "module2"
)

# Define VS Code extensions
declare -A EXTENSIONS
# Format: "extension-id"="Display Name|Description"
# Example: EXTENSIONS["ms-python.python"]="Python|Python language support"

# Define verification commands to run after installation
VERIFY_COMMANDS=(
    # Add commands to verify successful installation
    # Examples:
    # "command -v tool >/dev/null && tool --version || echo '❌ tool not found'"
    # "test -f /path/to/file && echo '✅ File exists' || echo '❌ File not found'"
)

# Post-installation notes
post_installation_message() {
    echo
    echo "🎉 Installation process complete for: $SCRIPT_NAME!"
    echo "Purpose: $SCRIPT_DESCRIPTION"
    echo
    echo "Important Notes:"
    echo "1. [Important note 1]"
    echo "2. [Important note 2]"
    echo "3. [Important note 3]"
    echo
    echo "Documentation Links:"
    echo "- Local Guide: .devcontainer/howto/howto-[name].md"
    echo "- [Link description]: [URL]"
    echo "- [Link description]: [URL]"
}

# Post-uninstallation notes
post_uninstallation_message() {
    echo
    echo "🏁 Uninstallation process complete for: $SCRIPT_NAME!"
    echo
    echo "Additional Notes:"
    echo "1. [Cleanup note 1]"
    echo "2. [Cleanup note 2]"
    echo "3. See the local guide for additional cleanup steps if needed:"
    echo "   .devcontainer/howto/howto-[name].md"
    
    # Add any verification of uninstallation if needed
    # Example:
    # if command -v tool >/dev/null; then
    #     echo
    #     echo "⚠️  Warning: Some components may still be installed:"
    #     echo "- tool is still present"
    # fi
}

#------------------------------------------------------------------------------
# STANDARD SCRIPT LOGIC - Do not modify anything below this line
#------------------------------------------------------------------------------

# Initialize mode flags
DEBUG_MODE=0
UNINSTALL_MODE=0
FORCE_MODE=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            DEBUG_MODE=1
            shift
            ;;
        --uninstall)
            UNINSTALL_MODE=1
            shift
            ;;
        --force)
            FORCE_MODE=1
            shift
            ;;
        *)
            echo "ERROR: Unknown option: $1" >&2
            echo "Usage: $0 [--debug] [--uninstall] [--force]" >&2
            echo "Description: $SCRIPT_DESCRIPTION"
            exit 1
            ;;
    esac
done

# Export mode flags for core scripts
export DEBUG_MODE
export UNINSTALL_MODE
export FORCE_MODE

# Source all core installation scripts
source "$(dirname "$0")/core-install-apt.sh"
source "$(dirname "$0")/core-install-node.sh"
source "$(dirname "$0")/core-install-extensions.sh"
source "$(dirname "$0")/core-install-pwsh.sh"
source "$(dirname "$0")/core-install-python-packages.sh"

# Function to process installations
process_installations() {
    # Process each type of package if array is not empty
    if [ ${#SYSTEM_PACKAGES[@]} -gt 0 ]; then
        process_system_packages "SYSTEM_PACKAGES"
    fi

    if [ ${#NODE_PACKAGES[@]} -gt 0 ]; then
        process_node_packages "NODE_PACKAGES"
    fi

    if [ ${#PYTHON_PACKAGES[@]} -gt 0 ]; then
        process_python_packages "PYTHON_PACKAGES"
    fi

    if [ ${#PWSH_MODULES[@]} -gt 0 ]; then
        process_pwsh_modules "PWSH_MODULES"
    fi

    if [ ${#EXTENSIONS[@]} -gt 0 ]; then
        process_extensions "EXTENSIONS"
    fi
}

# Function to verify installations
verify_installations() {
    if [ ${#VERIFY_COMMANDS[@]} -gt 0 ]; then
        echo
        echo "🔍 Verifying installations..."
        for cmd in "${VERIFY_COMMANDS[@]}"; do
            echo "Running: $cmd"
            if ! eval "$cmd"; then
                echo "❌ Verification failed for: $cmd"
            fi
        done
    fi
}

# Main execution
if [ "${UNINSTALL_MODE}" -eq 1 ]; then
    echo "🔄 Starting uninstallation process for: $SCRIPT_NAME"
    echo "Purpose: $SCRIPT_DESCRIPTION"
    pre_installation_setup
    process_installations
    if [ ${#EXTENSIONS[@]} -gt 0 ]; then
        for ext_id in "${!EXTENSIONS[@]}"; do
            IFS='|' read -r name description _ <<< "${EXTENSIONS[$ext_id]}"
            check_extension_state "$ext_id" "uninstall" "$name"
        done
    fi
    post_uninstallation_message
else
    echo "🔄 Starting installation process for: $SCRIPT_NAME"
    echo "Purpose: $SCRIPT_DESCRIPTION"
    pre_installation_setup
    process_installations
    verify_installations
    if [ ${#EXTENSIONS[@]} -gt 0 ]; then
        for ext_id in "${!EXTENSIONS[@]}"; do
            IFS='|' read -r name description _ <<< "${EXTENSIONS[$ext_id]}"
            check_extension_state "$ext_id" "install" "$name"
        done
    fi
    post_installation_message
fi