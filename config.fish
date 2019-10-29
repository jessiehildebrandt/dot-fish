####################################
# Jessie Hildebrandt's Fish Config #
####################################

#####################
# Setting Variables #
#####################

set __fish_git_prompt_show_informative_status true

set fish_greeting "Hello, commander."
set fish_key_bindings fish_default_key_bindings

set VIRTUAL_ENV_DISABLE_PROMPT true

##################
# Title Function #
##################

function fish_title --description 'Print the title of the window'

    # Trying to set the title inside of Emacs will break it
    if set -q INSIDE_EMACS
        return
    end

    # Set title to the command status + working directory
    echo (status current-command) (__fish_pwd)

end

###################
# Prompt Function #
###################

function fish_prompt --description 'Write out the prompt'

    ####################
    # Exit Status

    # Cache the exit status of the last command
    set -l last_status $status

    ##################
    # Global Variables

    # Format host name variable if not yet set
    if not set -q __fish_prompt_hostname
        set -g __fish_prompt_hostname (prompt_hostname)
    end

    # Format prompt character variable if not yet set
    if not set -q __fish_prompt_char
        switch (id -u)
            case 0
                # Root
                set -g __fish_prompt_char "#"
            case '*'
                # Everyone else
                set -g __fish_prompt_char ">"
        end
    end


    #################
    # Local Variables

    set -l normal (set_color normal)
    set -l white (set_color brwhite)
    set -l yellow (set_color ffeb3b bryellow)
    set -l cyan (set_color 62d7ff brcyan)
    set -l magenta (set_color f358dc brmagenta)
    set -l gray (set_color 5b5b5b brblack)
    set -l darkgray (set_color 2e2e2e black)
    set -l red (set_color f44336 brred)

	set -l battery_file /sys/class/power_supply/BAT0/capacity

    #############
    # SSH Segment

	set -l ssh_seg ""
	if test -n "$SSH_CONNECTION"
		set ssh_seg "$white[ssh]$normal "
	end

    #############################
    # Virtual Environment Segment

    set -l venv_seg ""
    if test -n "$VIRTUAL_ENV"
        set venv_seg "$gray(" (basename $VIRTUAL_ENV) ")$normal "
    end

    #################
    # Battery Segment

	set -l battery_seg ""
	if test -f $battery_file
		set battery_seg "$yellow" (cat $bat_file) "%$normal "
	end

    #################
    # User@Host Segment

    set -l user_host_seg "$cyan$USER$normal at $magenta$__fish_prompt_hostname$normal "

    ###########################
    # Working Directory (PWD) Segment

    set -g fish_prompt_pwd_dir_length 1
    set -l pwd_seg "in $gray" (prompt_pwd)
    set pwd_seg (string replace -ar '(.+/)([^/]*$)' "$darkgray\$1$gray\$2$normal" $pwd_seg)

    ####################
    # VCS Status Segment

    set -l vcs_seg (__fish_vcs_prompt) ""

    ##################
    # Prompt Character

    set -l prompt_char "$cyan$__fish_prompt_char$normal "
    if test $last_status -ne 0
        set prompt_char "$red$__fish_prompt_char$normal "
    end

    #########
    # Output

    printf "\n"
    printf "%s" $venv_seg $ssh_seg $battery_seg $user_host_seg $pwd_seg $vcs_seg
    printf "\n%s" $prompt_char

end
