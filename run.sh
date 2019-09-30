#!/bin/bash

# This script downloads the individual Zabbix manual sections and combines them into a single PDF. 

# Prerequisites: poopler-utils
# sudo apt install poppler-utils

# Declare Variables
BASE_URL="https://www.zabbix.com/documentation/"
MANUAL_VERSION="4.2"   # Changes this to your desired version. Tested with v4.2.

# Get the HTML page which contains links to individual pages
wget $BASE_URL$MANUAL_VERSION/manual -O source.html

# Create directory for numbered downloads to be stored in
mkdir numbered

# Generate list of URLs
cat source.html | grep indexmenu_.*\.add\(\'manual/ | sed -E "s/index.*(manual\/.*)'.*/$MANUAL_VERSION\/\1\?do=export_pdf/" | sed -E 's/(.*)/https\:\/\/www.zabbix.com\/documentation\/\1/g' > Zabbix_manual_urls.txt

# Download files. URLs are defined in $READFILE.
READFILE='Zabbix_manual_urls.txt'
COUNT=1

while IFS= read -r line
do
  wget "$line" -O numbered/$COUNT.pdf
  COUNT=`expr $COUNT + 1`
done < "$READFILE"


# Combine downloaded files into one file named "zabbix_manual_[timestamp].pdf"
NUMBER_OF_FILES=`ls numbered/ -1 | wc -l`
pdfunite `for i in $(seq 1 $NUMBER_OF_FILES); do echo "numbered/$i.pdf"; done` zabbix_manual_`date +%F_%H-%M-%S`.pdf

# Cleanup
# rm -r numbered
