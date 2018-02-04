####################################
# Jessie Hildebrandt's Fish Config #
####################################

#####################
# Setting Variables #
#####################

set __fish_git_prompt_show_informative_status 1

set fish_greeting ""
set fish_key_bindings fish_default_key_bindings

###################
# Prompt Function #
###################

function fish_prompt --description 'Write out the prompt'

       # Get Exit Status
       set -l last_status $status

       # Color Definitions
       set -l normal_color (set_color normal)
	   set -l bat_color (set_color bryellow)
       set -l usr_color (set_color brgreen)
       set -l dir_color (set_color brblue)

       set -l vcs_color (set_color brblack)
       set -l err_color (set_color red)

	   # Battery File Location
#	   set -l bat_file DISABLED
	   set -l bat_file /sys/class/power_supply/BAT0/capacity

	   # Battery Status Formatting
	   set -l bat_status ""
	   if test -f $bat_file
		   set -l bat_capacity (cat $bat_file)
		   set bat_status "$bat_color" "$bat_capacity" "%" "$normal_color" " "
	   end

       # User/Hostname Formatting
       set -l user_host $usr_color $USER "@" (hostname -s) "$normal_color"

       # Working Directory Formatting
       set -l home_escaped (echo -n $HOME | sed 's/\//\\\\\//g')
       set -l pwd (echo -n $PWD | sed "s/^$home_escaped/~/")
       set -l current_dir "$dir_color" "$pwd" "$normal_color"

       # Suffix Symbol Selection
       set -l suffix ""
       switch $USER
             case root toor; set suffix "#"
             case "*";  set suffix ">"
       end

       # VCS Status Formatting
       set -l vcs_status "$vcs_color" (__fish_vcs_prompt) "$normal_color"

       # Exit Status Formatting
       set -l prompt_status
       if test $last_status -ne 0
             set prompt_status " " "$err_color" "[$last_spptatus]" "$normal_color"
       end

       # Print Prompt
       echo -n -s $bat_status $user_host " " $current_dir $vcs_status $prompt_status $suffix " "

end
