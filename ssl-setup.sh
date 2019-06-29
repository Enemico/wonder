#!/bin/bash

# Takes care of setting up SSL by generating a snakeoil key (self-signed) whenever 
# HOSTNAME is defined.   You'll need to reconfigure your webserver with
# actual keys if you want to serve https properly.

# Only if we have HOSTNAME...

if [ "$APACHE_SITES" != "" ]; then

    # Generate testing certs if they aren't here.

    certpem=/etc/apache2/ssl/$APACHE_SITES.crt
    certkey=/etc/apache2/ssl/$APACHE_SITES.key

    if [ ! -f $certpem ]; then
	template="/etc/ssleay.conf"

	# # should be a less common char
	# problem is that openssl virtually accepts everything and we need to
	# sacrifice one char.

	TMPFILE="$(mktemp)" || exit 1

	sed -e s#@HostName@#"$APACHE_SITES"# $template > $TMPFILE

	# create the certificate.

	mkdir -p /etc/apache2/ssl/

	openssl req -config $TMPFILE -new -x509 -days 3650 -nodes -out $certpem -keyout $certkey

	chmod 644 $certpem
	chmod 640 $certkey

	rm -rf $TMPFILE
    fi

fi
