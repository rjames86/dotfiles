#!/usr/bin/env bash

pushd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function iPython() {
    iPythonConfigPath=`ipython locate profile`;
    if [ ! -z "$iPythonConfigPath" ]
    then
        startupPath="$iPythonConfigPath/startup"
        rsync -avh --no-perms ipython/ "$startupPath"
    fi

}

function doIt() {
	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
	--exclude "README.md" --exclude "ipython" -avh --no-perms . ~;
    echo "export DOTFILES_DIR=\"$(pwd)\"" >> $HOME/.exports
    iPython;

    for f in $HOME/bin; do
    	chmod +x "$f"
    done
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
echo 'Sourcing ~/.bash_profile'
source ~/.bash_profile;
unset doIt;

popd;
