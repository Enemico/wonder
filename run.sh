#!/bin/bash

echo "We are running with this parameter set:" 
echo ${APACHE_SITES}

/usr/local/bin/ssl-setup.sh
/usr/local/bin/chaperone
