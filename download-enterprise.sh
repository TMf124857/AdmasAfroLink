#!/bin/bash

# Download Enterprise Addons from Odoo.sh
# This script helps download and extract enterprise addons properly

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}📦 Enterprise Addons Download Helper${NC}"
echo ""

# Option 1: Use wget/curl to download from Odoo.sh
download_from_odoo_sh() {
    echo -e "${YELLOW}Option 1: Download from Odoo.sh${NC}"
    echo ""
    echo "Steps to download:"
    echo "1. Go to https://www.odoo.com/my/odoo-sh"
    echo "2. Login with your enterprise account"
    echo "3. Find 'Download Odoo Enterprise 17.0'"
    echo "4. Right-click on download link and copy URL"
    echo ""
    
    read -p "Enter the download URL (or 'skip' to try another method): " download_url
    
    if [[ "$download_url" != "skip" && ! -z "$download_url" ]]; then
        echo "Downloading enterprise addons..."
        if wget -O "odoo_enterprise_17.tar.gz" "$download_url"; then
            echo "✅ Download completed"
            extract_enterprise_addons "odoo_enterprise_17.tar.gz"
        else
            echo -e "${RED}❌ Download failed${NC}"
            return 1
        fi
    fi
}

# Option 2: Clone from GitHub (if you have access)
clone_from_github() {
    echo -e "${YELLOW}Option 2: Clone from GitHub${NC}"
    echo ""
    
    read -p "Do you have access to Odoo Enterprise GitHub repository? (y/n): " has_github_access
    
    if [[ "$has_github_access" == "y" ]]; then
        read -p "Enter your GitHub username: " github_user
        read -s -p "Enter your GitHub token or password: " github_auth
        echo ""
        
        echo "Cloning enterprise repository..."
        if git clone https://$github_user:$github_auth@github.com/odoo/enterprise.git ./addons/enterprise; then
            cd ./addons/enterprise
            git checkout 17.0
            cd ../../
            echo "✅ Enterprise repository cloned successfully"
            return 0
        else
            echo -e "${RED}❌ Failed to clone repository${NC}"
            return 1
        fi
    fi
}

# Option 3: Use existing zip file
use_existing_file() {
    echo -e "${YELLOW}Option 3: Use existing file${NC}"
    echo ""
    
    echo "Available files in current directory:"
    ls -la *.tar.gz *.zip 2>/dev/null || echo "No archive files found"
    echo ""
    
    read -p "Enter the path to your enterprise file: " enterprise_file
    
    if [[ -f "$enterprise_file" ]]; then
        extract_enterprise_addons "$enterprise_file"
    else
        echo -e "${RED}❌ File not found: $enterprise_file${NC}"
        return 1
    fi
}

# Extract enterprise addons
extract_enterprise_addons() {
    local file="$1"
    echo "Extracting enterprise addons from: $file"
    
    # Create directories
    mkdir -p ./addons/enterprise
    
    # Determine file type and extract
    if [[ "$file" == *.tar.gz ]]; then
        # Try different extraction methods
        echo "Attempting tar extraction..."
        if tar -tf "$file" >/dev/null 2>&1; then
            tar -xzf "$file" -C ./addons/enterprise --strip-components=1
        else
            echo "Standard tar failed, trying gunzip + tar..."
            gunzip -c "$file" | tar -x -C ./addons/enterprise --strip-components=1
        fi
    elif [[ "$file" == *.zip ]]; then
        echo "Extracting ZIP file..."
        unzip -q "$file" -d ./addons/enterprise/
    else
        echo -e "${RED}❌ Unsupported file format${NC}"
        return 1
    fi
    
    # Verify extraction
    if [[ -d "./addons/enterprise" ]] && [[ $(ls -A ./addons/enterprise 2>/dev/null | wc -l) -gt 0 ]]; then
        echo -e "${GREEN}✅ Enterprise addons extracted successfully${NC}"
        echo "Found $(ls ./addons/enterprise | wc -l) items in enterprise directory"
        
        # List some key enterprise modules
        echo ""
        echo "Key enterprise modules found:"
        for module in web_enterprise account_enterprise hr_enterprise sale_enterprise project_enterprise; do
            if [[ -d "./addons/enterprise/$module" ]]; then
                echo "✅ $module"
            else
                echo "⚠️  $module (not found)"
            fi
        done
        return 0
    else
        echo -e "${RED}❌ Extraction failed or no files extracted${NC}"
        return 1
    fi
}

# Option 4: Use Docker to extract from official image
extract_from_docker() {
    echo -e "${YELLOW}Option 4: Extract from Docker image${NC}"
    echo ""
    
    echo "This will extract enterprise addons from the official Odoo Enterprise Docker image..."
    read -p "Continue? (y/n): " continue_docker
    
    if [[ "$continue_docker" == "y" ]]; then
        echo "Pulling Odoo Enterprise image..."
        if docker pull odoo:17.0; then
            echo "Extracting enterprise addons..."
            mkdir -p ./addons/enterprise
            
            # Run container and copy enterprise addons
            container_id=$(docker run -d odoo:17.0 sleep 60)
            docker cp $container_id:/usr/lib/python3/dist-packages/odoo/addons/ ./addons/enterprise/
            docker stop $container_id
            docker rm $container_id
            
            echo "✅ Enterprise addons extracted from Docker image"
            return 0
        else
            echo -e "${RED}❌ Failed to pull Docker image${NC}"
            return 1
        fi
    fi
}

# Main menu
main() {
    echo "Choose an option to get enterprise addons:"
    echo "1. Download from Odoo.sh"
    echo "2. Clone from GitHub"
    echo "3. Use existing file"
    echo "4. Extract from Docker image"
    echo ""
    
    read -p "Select option (1-4): " choice
    
    case $choice in
        1) download_from_odoo_sh ;;
        2) clone_from_github ;;
        3) use_existing_file ;;
        4) extract_from_docker ;;
        *) echo -e "${RED}❌ Invalid option${NC}"; exit 1 ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}🎉 Enterprise addons ready!${NC}"
        echo "Next step: Run './enterprise-activation.sh' and choose option 2 (Use existing enterprise.zip file)"
    else
        echo -e "${RED}❌ Failed to get enterprise addons${NC}"
        echo "Please try another method or contact Odoo support"
    fi
}

main "$@"
