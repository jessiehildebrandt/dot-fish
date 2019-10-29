####################################
# Jessie Hildebrandt's Fish Config #
####################################

# Contains a pretty multi-line prompt and some useful functions.
# Compatible with Emacs' ansi-term.
#
# Provided functions:
#  * battery - Displays the battery charge (and discharge time if supported)
#
# Prompt features:
#  * SSH session indicator
#  * Virtual environment indicator
#  * Abbreviated + colorized working directory
#  * VCS status
#  * Dynamic prompt character (root/user, return status)
#  * Optional timestamps
#
# Configurable variables:
#  * __fish_prompt_show_timestamps - If set, displays timestamps on the right side of the terminal

#####################
# Setting Variables #
#####################

set __fish_git_prompt_show_informative_status true

set fish_greeting "Hello, commander."
set fish_key_bindings fish_default_key_bindings

set VIRTUAL_ENV_DISABLE_PROMPT true

####################
# Battery Function #
####################

function battery --description 'Display the current status of the battery'

    #################
    # Local variables

	set -l battery_file /sys/class/power_supply/BAT0/capacity

    set -l normal (set_color normal)
    set -l yellow (set_color bryellow)
    set -l orange (set_color yellow)
    set -l blue (set_color brblue)

    #####################
    # ACPI battery status

    if type acpi > /dev/null
        set -l battery_str (acpi | cut -d "," -f 2- | string trim)
        set battery_str (string replace -r '([[:digit:]]{1,3}%), (.*)$' "$yellow\$1$normal $orange(\$2)$normal" $battery_str)
        printf "%s" $blue "Remaining battery:$normal " $battery_str
        return
    end

    #########################
    # Fallback battery status

    if test -f $battery_file
        printf "%s" $blue "Remaining battery:$normal " $yellow (cat $battery_file) "%$normal"
        return
    end

    #####################
    # Unsupported battery

    printf "%s" $blue "No battery detected.$normal"

end

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
    set -l gray (set_color 5e5e5e brblack)
    set -l darkgray (set_color 3b3b3b brblack)
    set -l red (set_color f44336 brred)

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
    printf "%s" $venv_seg $ssh_seg $user_host_seg $pwd_seg $vcs_seg
    printf "\n%s" $prompt_char

end

#########################
# Right Prompt Function #
#########################

function fish_right_prompt

    #############################
    # Enable/disable right prompt

    if not set -q __fish_prompt_show_timestamps
        return
    end

    #################
    # Local variables

    set -l darkgray (set_color 3b3b3b brblack)

    ###########
    # Timestamp

    printf "%s" $darkgray (date +"[%H:%M:%S]")

end
