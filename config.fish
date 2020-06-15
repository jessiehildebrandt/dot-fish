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
#  * Dynamic greeting function
#  * Optional timestamps
#
# Configurable variables:
#  * __fish_prompt_show_timestamps - If set, displays timestamps on the right side of the terminal
#  * __fish_greeting_fortune_cookies - Overrides the default list of fortune cookies to use for greetings

#####################
# Setting Variables #
#####################

set __fish_git_prompt_show_informative_status true

set fish_key_bindings fish_default_key_bindings

set fish_color_command 8787ff

set VIRTUAL_ENV_DISABLE_PROMPT true

#####################
# Greeting Function #
#####################

function fish_greeting --description 'Display a greeting when the session begins'

    ##################
    # Fortune greeting

    if type -q fortune

        # Set up list of desired cookies
        set -l desired_cookies
        if not set -q __fish_greeting_fortune_cookies
            set desired_cookies computers people science education work wisdom
        else
            set desired_cookies $__fish_greeting_fortune_cookies
        end

        # Determine which desired cookies are available
        set -l found_cookies
        for cookie in $desired_cookies
            if fortune -s $cookie > /dev/null ^ /dev/null
                set -a found_cookies $cookie
            end
        end

        # If any desired cookies are found, source a fortune from them
        if test (count $found_cookies) -gt 0
            fortune -s $found_cookies
            return
        end

        # Otherwise, just print whatever
        fortune -s
        return

    end

    #################
    # Static greeting

    echo "Hello, commander."

end

####################
# Battery Function #
####################

function battery --description 'Display the current status of the battery'

    #################
    # Local variables

	set -l battery_files /sys/class/power_supply/BAT*/capacity

    set -l normal (set_color normal)
    set -l yellow (set_color bryellow)
    set -l gray (set_color 5e5e5e brblack)

    #####################
    # ACPI battery status

    if type -q acpi
        set -l battery_str (acpi | grep "Unknown" --invert | head -n 1 | cut -d "," -f 2- | string trim)
        set battery_str (string replace -r '([[:digit:]]{1,3}%),? ?(.*)$' "$yellow\$1$normal $gray(\$2)$normal" $battery_str)
        set battery_str (string replace -r '\(\)' "(Fully charged)" $battery_str)
        echo "Battery status: $battery_str"
        return
    end

    #########################
    # Fallback battery status

    if test -f $battery_files
        set -l battery_str (cat $battery_files | head -n 1 | string trim)
        set battery_str (string replace -r '([[:digit:]]{1,3})' "$yellow\$1%$normal" $battery_str)
        echo "Battery status: $battery_str"
        return
    end

    #####################
    # Unsupported battery

    echo "No battery detected."

end

##################
# Title Function #
##################

function fish_title --description 'Print the title of the window'

    # Trying to set the title inside of Emacs will break it
    if set -q INSIDE_EMACS
        return
    end

    # Set window title to the current command + working directory
    if test (echo $FISH_VERSION | cut -d "." -f 1) -ge 3

        # Fish 3.X.X and above use "status current-command"
        echo (status current-command) (__fish_pwd)

    else

        # Older versions of fish use the "$_" variable
        echo $_ (__fish_pwd)

    end

end

###################
# Prompt Function #
###################

function fish_prompt --description 'Display a formatted terminal prompt'

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
		set ssh_seg "$white" "[ssh]" "$normal "
	end

    #############################
    # Virtual Environment Segment

    set -l venv_seg ""
    if test -n "$VIRTUAL_ENV"
        set venv_seg "$gray("(basename $VIRTUAL_ENV)")$normal "
    end

    #################
    # User@Host Segment

    set -l user_host_seg "$cyan$USER$normal at $magenta$__fish_prompt_hostname$normal "

    ###########################
    # Working Directory (PWD) Segment

    set -g fish_prompt_pwd_dir_length 1
    set -l pwd_seg (prompt_pwd)
    if test (string length $pwd_seg) -eq 1
        set pwd_seg (string replace -ar '^.*$' "in $gray\$0$normal" $pwd_seg)
    else
        set pwd_seg (string replace -ar '^(.*[~\/])([^\/]*$)' "in $darkgray\$1$gray\$2$normal" $pwd_seg)
    end

    ####################
    # VCS Status Segment

    set -l vcs_seg (__fish_vcs_prompt)

    ##################
    # Prompt Character

    set -l prompt_char "$cyan$__fish_prompt_char$normal "
    if test $last_status -ne 0
        set prompt_char "$red$__fish_prompt_char$normal "
    end

    #########
    # Output

    echo -se "\n" $venv_seg $ssh_seg $user_host_seg $pwd_seg $vcs_seg "\n" $prompt_char

end

#########################
# Right Prompt Function #
#########################

function fish_right_prompt --description "Display a right-aligned terminal prompt"

    #############################
    # Enable/disable right prompt

    if not set -q __fish_prompt_show_timestamps
        return
    end

    #################
    # Local variables

    set -l normal (set_color normal)
    set -l darkgray (set_color 3b3b3b brblack)

    ###########
    # Timestamp

    set -l timestamp_str "$darkgray"(date +"[%H:%M:%S]")"$normal"
    echo -s "$darkgray$timestamp_str"

end
