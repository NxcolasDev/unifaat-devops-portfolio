#!/bin/bash
set -e
yum install -y postgresql15
echo "PostgreSQL client installed" > /var/log/technova-user-data.log