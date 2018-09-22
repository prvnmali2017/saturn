
#!/bin/bash
set +e

ENVIRONMENT="production"
MAJOR_REL="4.10"
RHEL_RELEASE="6"

# Automatically get Ubuntu OS release
ReleaseName=`cat /etc/lsb-release| grep DISTRIB_CODENAME | awk -F '=' '{print($2)}'`
if [ "$ReleaseName" == "trusty" ]; then
    RELEASEPKG="puppetlabs-release-pc1-trusty.deb"
elif [ "$ReleaseName" == "xenial" ]; then
    RELEASEPKG="puppetlabs-release-pc1-xenial.deb"
else
    echo "FAILURE: Cannot find an acceptable match for OS release [$ReleaseName]... exiting"
    logger "FAILURE: Cannot find an acceptable match for OS release [$ReleaseName]... exiting"
    exit
fi

### MAIN ###
logger "puppet_deploy: Starting Puppet deployment script"

is_Puppet4=`awk -v n1=$MAJOR_REL -v n2=4 'BEGIN {if (n1>=n2) printf ("true"); else printf ("false");}'`

is_Rhel=`cat /etc/*release* | grep -i centos || cat /etc/*release* | grep -i rhel`
is_Rhel=`echo $?`

is_Debian=`cat /etc/*release* | grep -i debian`
is_Debian=`echo $?`

# If this is a Amazon Linux AMI OS
if [ "$is_Amazon" == "0" ]; then

# Confirm is not rhel
   is_Rhel=1
   
# Install puppet and it's dependancies
   yum install puppet3 -y
   yum install augeas -y

# Lock the puppet version so can't be updated
   yum install yum-plugin-versionlock -y
   rpm -qa | grep -i puppet3 | head -1 >> /etc/yum/pluginconf.d/versionlock.list

else
   if [ "$is_Debian" == "0" ]; then
# This is for Debian based OS's
# Set Puppet version requirement so it stays inline with Puppet master
      if [ "$is_Puppet4" == "true" ]; then
          echo "Package: puppet-agent" > /etc/apt/preferences.d/00-puppet.pref
      else
          echo "Package: puppet puppet-common" > /etc/apt/preferences.d/00-puppet.pref
      fi
      echo "Pin: version $MAJOR_REL""*" >> /etc/apt/preferences.d/00-puppet.pref
      echo "Pin-Priority: 501" >> /etc/apt/preferences.d/00-puppet.pref

# Install Puppet
      cd ~
      wget https://apt.puppetlabs.com/$RELEASEPKG
      dpkg -i $RELEASEPKG
      apt-get update
      logger "Installing puppet agent now..."
      echo "Installing puppet agent now..."
      if [ "$is_Puppet4" == "true" ]; then
          apt-get install puppet-agent -y
      else
          apt-get install puppet -y
      fi

      # Install configure tool
      apt-get install augeas-tools -y
   else
      if [ "$is_Rhel" == "0" ]; then
         # Install repo for this OS:
         rpm -Uvh http://yum.puppetlabs.com/puppetlabs-release-el-$RHEL_RELEASE.noarch.rpm

         # Find latest minor version for required major
         install_version=`yum --showduplicates list puppet | grep $MAJOR_REL | tail -1 | awk '{print($2)}'`
         echo "Installing puppet version: $install_version"
         sleep 3

         # Install puppet and it's dependancies
         yum install puppet-$install_version
         yum install augeas

         # Lock the puppet version so can't be updated
         yum install yum-plugin-versionlock
         rpm -qa | grep -i puppet >> /etc/yum/pluginconf.d/versionlock.list

         # install extra yum repository that no longer come as default in #7
         if [ "$RHEL_RELEASE" == "7" ]; then
             yum install epel-release
         fi
     else
        echo "no suitable OS found, so exit"
        logger "no suitable OS found, so exit"
        exit
     fi
  fi
fi

######### START  AUGTOOL INTERACTIVE
cat <<EOF | augtool
# Set Agent start
set /files/etc/default/puppet/START yes

# Set Environment
set /files/etc/puppetlabs/puppet/puppet.conf/agent/environment $ENVIRONMENT
save
EOF
#########END  AUGTOOL INTERACTIVE

if [ "$is_Puppet4" == "true" ]; then
    /opt/puppetlabs/bin/puppet agent -t &> /dev/null
    sleep 1
    /opt/puppetlabs/bin/puppet agent -t &> /dev/null
else
    puppet agent -t &> /dev/null
    sleep 1
    puppet agent -t &> /dev/null
fi
service puppet restart
echo ""
echo "# puppet agent -t (puppet 4: /opt/puppetlabs/bin/puppet agent -t)"

# If this is a Rhel OS
if [ "$is_Rhel" == "0" ]; then
    chkconfig puppet on
fi

# If this is a Amazon Linux AMI OS
if [ "$is_Amazon" == "0" ]; then
    chkconfig puppet on
fi

###Exporting the Environment Variables   
export PATH=/opt/puppetlabs/bin:$PATH
###Downloading the module from puppet forge for vcs
puppet module install puppetlabs-vcsrepo --version 2.3.0
###Changing the permissions on destination directory to copy the nginx module from local host to vagrant machine
chmod 777 /etc/puppetlabs/code/environments/production/modules
echo "Puppet agent is running"
exit 0
