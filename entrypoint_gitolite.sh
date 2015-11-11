#!/bin/bash

service ssh start

REDMINE_ROOT=/home/redmine/redmine


########################
# the init file

REDMINE_ROOT=/home/redmine
# su redmine

if [ ! -e $REDMINE_ROOT/ssh_keys ]; then
	sudo -HEu redmine mkdir $REDMINE_ROOT/ssh_keys
	sudo -HEu redmine ssh-keygen -N '' -f $REDMINE_ROOT/ssh_keys/redmine_gitolite_admin_id_rsa
fi

cp $REDMINE_ROOT/ssh_keys/redmine_gitolite_admin_id_rsa.pub /tmp/


# su git
sudo -HEu git /home/git/bin/gitolite setup -pk /tmp/redmine_gitolite_admin_id_rsa.pub

## Look for GIT_CONFIG_KEYS and make it look like :
#GIT_CONFIG_KEYS  =>  '.*',
## Enable local code directory
#LOCAL_CODE       =>  "$ENV{HOME}/local"

sudo -HEu git sed -i \
  "s#GIT_CONFIG_KEYS.*#GIT_CONFIG_KEYS  =>  '.*',#" \
  /home/git/.gitolite.rc
sudo -HEu git sed -i \
  's#LOCAL_CODE.*#LOCAL_CODE       =>  "$ENV{HOME}/local"#' \
  /home/git/.gitolite.rc



# Add Gitolite server in known_hosts list
sudo -HEu redmine ssh -o StrictHostKeyChecking=no git@localhost true

# trigger plugin install
mkdir -p /home/redmine/data/plugins
touch /home/redmine/data/plugins/install_gitolite


/sbin/entrypoint.sh $*
