# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$HOME/.local:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{colors,path,bash_prompt,exports,aliases,functions,git_bash_completion,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

if [ `hostname` = 'ryanairdb.corp.dropbox.com' ] || [ `hostname` == 'ryan-mbp.corp.dropbox.com' ]; then
    echo "Loading Dropbox settings..."
    source .dropboxrc
fi

if [[ -a /usr/local/bin/virtualenvwrapper.sh ]]; then
    source /usr/local/bin/virtualenvwrapper.sh
fi

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;


# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
_complete_ssh_hosts ()
{
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        comp_ssh_hosts=`cat ~/.ssh/known_hosts | \
                        cut -f 1 -d ' ' | \
                        sed -e s/,.*//g | \
                        grep -v ^# | \
                        uniq | \
                        grep -v "\[" ;
                cat ~/.ssh/config | \
                        grep "^Host " | \
                        awk '{print $2}'
                `
        COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
        return 0
}
complete -F _complete_ssh_hosts ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

_start_tmux ()
{
    WHOAMI=$(whoami)
    if tmux has-session -t $WHOAMI 2>/dev/null; then
        echo "Attaching to existing session"
        tmux -2 attach-session -d -t $WHOAMI
    else
        echo "Creating new tmux session"
        tmux -2 new-session -s $WHOAMI
    fi
}


if [[ "$TMUX" == "" ]] &&
        [[ "$SSH_CONNECTION" != "" ]]; then
    # Attempt to discover a detached session and attach
    # it, else create a new session
    _start_tmux
fi
