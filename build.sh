#!/bin/sh

# Packages that are only used to build the site. These will be
# removed once we're done.
BUILD_PACKAGES="
        rsync
	git
	wget
	unzip
"

# Packages required to serve the website and run the services.
# We have to keep the python3 packages around in order to run
# chaperone (installed via pip).
PACKAGES="
        libapache2-mod-xsendfile
        libapache2-mod-security2
        modsecurity-crs
        php-mbstring
	php-zip
	php-curl
"

# Additional Apache modules to enable.
APACHE_MODULES_ENABLE="
        rewrite
        security2
        xsendfile
	ssl
"
export APACHE_MODULES_ENABLE

# Additional config snippets to enable for Apache.
APACHE_CONFIG_ENABLE="
        php7.0-fpm
        modsecurity-custom
"
export APACHE_CONFIG_ENABLE

# Sites to enable.
APACHE_SITES="wonder.dirtydigitalfields.net"
export APACHE_SITES

# Use php-fpm.
export PHP_FPM_ENABLE=1

# The default bitnami/minideb image defines an 'install_packages'
# command which is just a convenient helper. Define our own in
# case we are using some other Debian image.
if [ "x$(which install_packages)" = "x" ]; then
    install_packages() {
        env DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends "$@"
    }
fi

install_all_packages () {
  install_packages ${BUILD_PACKAGES} ${PACKAGES}
}

# Install the configuration, overlayed over /etc, 
sync () {
  rsync -a /tmp/conf/ /etc/
}

# clone wonder
clone () {
  # cd /opt/ && git clone https://github.com/robiso/wondercms.git
  cd /tmp && wget https://github.com/robiso/wondercms/releases/download/2.6.0/WonderCMS-2.6.0.zip
  unzip /tmp/WonderCMS* -d /opt/
  chown -R www-data:www-data /opt/wondercms
  rm /tmp/WonderCMS*
}

# Create the directories that Apache will need at runtime,
# since we won't be using the init script.
#mkdir /var/run/apache2 /var/lock/apache2

# setup apache
setup_apache () {
  /usr/local/bin/setup-apache.sh
  /usr/local/bin/ssl-setup.sh
# Set up modsecurity.
# The file is named 00modsecurity.conf so it is loaded first.
  mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/00modsecurity.conf
}

# Remove packages used for installation.
cleanup () {
  apt-get remove -y --purge ${BUILD_PACKAGES}
  apt-get autoremove -y
  apt-get clean
  rm -fr /var/lib/apt/lists/*
  rm -fr /tmp/conf
  rm -fr /var/log/dpkg.log
  rm -fr /var/log/apt/*
}

set -e
install_all_packages
sync
clone
setup_apache
cleanup

