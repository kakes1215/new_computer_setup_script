#!/bin/bash

before_reboot()
{
    #open updates manager
    echo -e "\nInstalling Updates... may take a few minutes\n"
    sudo apt-get update && sudo apt-get upgrade -y

    #install VIM
    echo -e "\nInstalling VIM"
    sudo apt-get install -y vim && echo "Vim Successfully Installed" || echo "An Error Occurred when intalling VIM"

    #Install gedit
    echo -e "\nInstalling Gedit..."
    sudo apt install gedit -y && echo "Gedit Successfully Installed" || echo "An Error Occurred when Installing Gedit"

    #atom
    echo "Installing Atom"
    sudo add-apt-repository ppa:webupd8team/atom
    sudo apt update
    sudo apt install -y atom

    # Chrome
    echo -e "\nInstalling Google Chrome"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb && echo "Google Chrome Successfully Installed" || echo "An Error Occurred when Installing Google Chrome"

    #Create SSH Key
    echo -e "\nWe are now going to generate your SSH Key\n"
    read -p  "Press enter to start..." ENTER
    read -p "Enter your GITHUB email address: " email

    echo -e "\nGenerating SSH key..."
    ssh-keygen -t rsa -b 4096 -C $email && echo "SSH Key Successfully Generated" || echo "An Error Occurred when Generating SHH"

    echo -e "\nValidating ssh-agent.."
    eval "$(ssh-agent -s)" && echo "SSH Agent is now running" || echo "SSH Agent is not running"

    echo -e "\nAdding SSH private key to the ssh-agent..."
    ssh-add ~/.ssh/id_rsa && echo "SSH private key added to SSH agent" || echo "Unable to add SSH key using SSH agent"

    echo -e "\nPlease copy the following SSH key and add it to Github and GitLab"
    read -p "Do you need instructions on how to add this to the student's Github account? (Y or N): " answer
    case $answer in
      [yY]* ) echo "\nOpening github help webpage...."
              xdg-open "https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/";;

      [nN]* ) ;;
    * ) echo "Invalid input..." ;;
    esac


    echo -e "\nCopy the following SSH key..."
    echo -e "___________________________________________________________________________________________________________________________________\n";
    cat ~/.ssh/id_rsa.pub
    echo "____________________________________________________________________________________________________________________________________";

    echo -e "\nAdd the SSH Key you copied above to your Github account"
    read -p "Press enter to continue..." ENTER
    echo -e "\nOpening Github page..."
    xdg-open "https://github.com/settings/keys"

    echo -e "\nAdd the SSH Key you copied above to your GitLab account"
    read -p "Press enter to continue..." ENTER
    echo -e "\nOpening GitLab page..."
    xdg-open "https://git.ksu.edu/profile/keys"


    echo -e "\n\nEXTRACTING FILES";
    read -p "Press enter to continue..." ENTER

     # Extract all tar.gz files
    for f in *.tar.gz
        do
            tar -xzvf $f
        done

    read -p "All the files have been extracted. Press enter to continue..." ENTER

    # Install AnyConnect
    echo "Installing AnyConnect"
    sudo apt install -y libpangox-1.0-0 libcanberra-gtk-module

    cd anyconnect-3.1.10010
    cd vpn
    sudo apt-get install -y network-manager-openconnect && echo "AnyConnect Successfully Installed" || echo "An Error Occurred when Installing AnyConnect"
    sudo sh vpn_install.sh
    cd ~

    # JDK
    echo "Copying contents of .profile"
    cat dotprofile >> .profile
    #echo "Change 'username' to your local username"
    #read -p "Press enter to continue" ENTER
    #gedit .profile
    read -p "Enter local username: " localUsername
    sed -i "s/username/$localUsername/g" .profile

    # Chef
    echo "Installing Chef"
    sudo dpkg -i chefdk* && echo "Chef Succesfully Installed" || echo "An Error Occurred when Installing Chef"

    # Virtualbox
    echo "Installing VirtualBox"
    sudo apt-get install -y libpng16-16 libqt5core5a libqt5widgets5 libsdl1.2debian libqt5x11extras5 libsdl-ttf2.0-0 libqt5opengl5 libqt5printsupport5
    sudo apt-get install -y libcurl4 && echo "libcurl4 Succesfully Installed" || echo "An Error Occurred when Installing libcurl4"
    sudo apt-get install -y build-essential gcc make perl dkms
    sudo dpkg -i virtualbox* && echo "VirtualBox Succesfully Depackaged" || echo "An Error Occurred when Depackaging VirtualBox"

    read -p "Press enter to reboot computer" ENTER
    sudo reboot
}

after_reboot()
{

    #Finish Maven / Create Master Password
    read -p "Enter Eid: " eid
    sed -i "s/eid/$eid/g" .m2/settings.xml && echo -e "\nsetting.xml eid updated" || echo -e "\nAn error occured when updating eid in settings.xml"
    prompt="Enter password: "
    while IFS= read -p "$prompt" -r -s -n 1 char
    do
      if [[ $char == $'\0' ]]
      then
        break
      fi
      prompt='*'
      passwordUnencrypted+="$char"
    done
    passwordEncrypted="$(mvn --encrypt-master-password $passwordUnencrypted)"
    sed -i "s@genPassword@$passwordEncrypted@g" .m2/settings.xml && echo -e "\nsetting.xml password updated" || echo -e "\nAn error occured when updating password in settings.xml"

    # Vagrant
    echo "Installing Vagrant and plugins"
    sudo dpkg -i vagrant*
    vagrant plugin install -y vagrant-berkshelf && echo "vagrant-berkshelf Succesfully Installed" || echo "An Error Occurred when Installing  vagrant-berkshelf"
    vagrant plugin install -y vagrant-omnibus && echo "vagrant-omnibus Succesfully Installed" || echo "An Error Occurred when Installing  vagrant-omnibus"
    vagrant plugin install -y vagrant-vbguest && echo "vagrant-vbguest/Chrome Succesfully Installed" || echo "An Error Occurred when Installing  vagrant-vbguest"

    # SQL Developer
    echo "Installing SQLDeveloper"
    cd sqldeveloper/opt/sqldeveloper
    sh sqldeveloper.sh
    cd ~

    # Git
    echo "Installing Git"
    sudo apt-get update
    sudo apt-get -f dist-upgrade
    sudo apt-get -f install
    sudo apt install git && echo "Git Succesfully Installed" || echo "An Error Occurred when Installing Git"

	 #Add Cluster Standalone Variable to .basrc
     echo "export CLUSTER_STANDALONE=true" >> .bashrc

    #Create Directories
    echo -e "\nCloning ome_chef_data git repositories"

    #create dev
    cd ~
    mkdir dev
    cd dev
    git clone git@github.com:kstateome/ome_chef_data.git
	git clone git@github.com:kstateome/student-training-project.git

	#create symbolic links
    echo -e "\nCreate symbolic links for commands"
    ln -s ome_chef_data/data_bags
    ln -s ome_chef_data/environments
    ln -s ome_chef_data/roles

    #create cookbooks
    mkdir cookbooks
    cd cookbooks
    git clone git@github.com:kstateome/ome_wildfly_cluster.git
    git clone git@github.com:kstateome/ome_wildfly.git
    cd ~

    echo -e "\nSetup Complete"


}

echo "  ____  _             _            _     ____       _             "
echo " / ___|| |_ _   _  __| | ___ _ __ | |_  / ___|  ___| |_ _   _ _ __ "
echo " \___ \| __| | | |/ _  |/ _ \  _ \| __| \___ \ / _ \ __| | | |  _ \ "
echo "  ___) | |_| |_| | (_| |  __/ | | | |_   ___) |  __/ |_| |_| | |_) |    "
echo " |____/ \__|\___|\____|\____|_| |_|\__| |____/ \___|\__|\____|  __/    "
echo -e "                                                             |_|  \n\n "


echo "Ensure that all necessary files have been copied to the home directory"
read -p "Press enter to continue" ENTER

#check if user entered a flag
if [ "$#" -ne 1 ]; then
    echo -e "\nPlease enter appropriate flag"
    echo "-a      Initial setup before reboot"
    echo "-b      Setup after reboot"
fi

while getopts 'hab' flag; do
  case "${flag}" in
    h) echo "USAGE
    -a
        Setup before reboot
    -b
        Part b after reboot. ";;

    a) before_reboot ;;
    b) after_reboot ;;
  esac
done
