
######################################################################
#### --------------------- system variables --------------------- ####
######################################################################

set -x PATH $PATH /usr/sbin ~/.local/bin


######################################################################
#### ---------------------- greeting scene ---------------------- ####
######################################################################

macchina-linux-x86_64


#######################################################################
#### -------------------------- aliases -------------------------- ####
#######################################################################

alias py="python3"
alias vim="nvim"
alias cin="cat"
alias q="exit"
alias :q="exit"
alias clip="xsel --clipboard"


#######################################################################
#### ------------------ quick directory actions ------------------ ####
#######################################################################

function qpush
    git add .
    git commit -m $argv
    git push
end

function pullsh
    git pull
    qpush $argv
end

function yd
    pwd | xsel --clipboard;
end


#######################################################################
#### ---------------------- terminal config ---------------------- ####
#######################################################################

function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

function postexec_test --on-event fish_postexec
   echo
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting
end

# starship init fish | source
if test -f ~/.cache/ags/user/generated/terminal/sequences.txt
    cat ~/.cache/ags/user/generated/terminal/sequences.txt
end

fish_config prompt choose pythonista

# function fish_prompt
#   set_color cyan; echo (pwd)
#   set_color green; echo '> '
# end
