#!/bin/bash


#export https_proxy="https://proxy.<domainname>.com:8080"

#####
##  HISTORY MANAGEMENT
if [ -e /home/abrandeis ]
then
  HISTFILE="/home/abrandeis/.bash_history"
else
  HISTFILE="/users/abrandeis/histfiles/.bash_history_$(hostname | awk -F'.' '{print $1}')"
fi

HISTTIMEFORMAT="%F %T "
export HISTIGNORE="hist*:hcg*:cd :pwd:history :$HISTIGNORE"
#HISTCONTROL=ignoreboth:erasedups

export EDITOR="/usr/bin/vim -u /home/abrandeis/.vimrc"
export VISUAL="/usr/bin/vim -u /home/abrandeis/.vimrc"


#####
## ALIAS LIST SOURCE

if [ -f /users/abrandeis/.bash_aliases ]; then
  source /users/abrandeis/.bash_aliases
fi

if [ -f /home/abrandeis/.bash_aliases ]; then
  source /home/abrandeis/.bash_aliases
fi

alias goal='ls -goal --color=always'
alias ll='ls -latrh --color=always'
alias vi='vim -u /home/abrandeis/.vimrc'
alias vim='vim -u /home/abrandeis/.vimrc'


#####
## Color Variables
C_NC="\e[0m"
C_RD="\e[31m"
C_GN="\e[32m"
C_YW="\e[33m"


####################
##   PROMPT [PS1] VARIABLES
##    COLORS IN USE FOR PS
PSC_NC='\[\e[0m\]'                                  ### Color Reset - No Color
PSC_RD='\[\e[0;41m\]'                               ### Red BG - White FG
PSC_GN='\[\e[0;32m\]'                               ### Green with black text
PSC_CY='\[\e[0;96m\]'                               ### Cyan 2
PSC_MA='\[\e[1;35m\]'                               ### Magenta Bold
PSC_RDW='\[\e[0;101m\]'                             ### Red Hi Intense BG - White FG
PSC_YW='\[\e[38;5;220m\]'                           ### Yellow
PSC_WHT='\[\e[38;5;15m\]'                           ### White
PSC_GN2='\[\e[38;5;46m\]'                           ### Neon Green
PSC_CY2='\[\e[38;5;51m\]'                           ### Cyan
PSC_PRP='\[\e[38;5;147m\]'                          ### Purple          [GreenYellow] - Hostname
PSC_RD2='\[\e[38;5;196m\]'                          ### Red FG - Black BG
PSC_YW2='\[\e[38;1;33m\]'                           ### Neon Yellow
PSC_BLK='\[\e[38;5;240m\]'                          ### Black
#PSC_RD="$PSC_NC\[\e[5;37;41m\]"                    ### Red BG - White FG


##    LINE 1 OF 3 SETUP : DATE/TIME BOX [(INSTANCES}] PROD ALERT
export PS_DT="$PSC_CY2\d \@$PSC_NC"                 ### Date/Time         - Cyan
export PSUSR="$PSC_MA\u$PSC_NC"                     ### User              - Magenta
export PS_AT="$PSC_GN2@$PSC_NC"                     ### @                 - Neon Green
export PSHOST="$PSC_YW\H:$PSC_NC"                   ### Hostname          - Yellow
export PSPWD="$PSC_WHT\w$PSC_NC"                    ### PWD               - White - with color reset
export PSPROMPT="$PSC_GN2] $PSC_NC"                 ### ]                 - Neon Green
#export PSUSR="$PSC_PRP\u$PSC_NC"                   ### User              - Purple


####################
#|  SET PROMPT [PS1] [PS2]
export PS1="\n${PS_DT}\n\
${PSUSR}${PS_AT}${PSHOST}${PSPWD}${PSPROMPT}"

export PS2="${PSC_GN2}continue-> ${PSC_NC}"

SPACER="    "

##  PROMPT_COMMAND to set the title bar of the putty window                                ::: #
##  history -a  # append history lines from this session to the history file.              ::: #
PROMPT_COMMAND='history -a; if [[ ! ( $(date +"%T") < "$prodStartTime" || $(date +"%T") > "$prodEndTime" ) ]]; then MESSAGE="  "; else MESSAGE=" "; fi; echo -ne " \e]0; ${USER}@${HOSTNAME}: ${PWD} ${SPACER}${SPACER}|${SPACER}$PC_HOST${SPACER}|${SPACER}YOU ARE $USER${SPACER}|${SPACER}$(echo ${MESSAGE})${SPACER}| \007"'


####################
##   For colorized MAN pages
export LESSBINFMT="*k<%02X>"             # show ^A [control] characters in different color
export LESS_TERMCAP_mb=$'\e[01;30m'      # begin blinking                 [grey-black bold]
export LESS_TERMCAP_md=$'\e[38;05;38m'   # begin bold                     [Cyan on black]
export LESS_TERMCAP_se=$'\e[0m'          # end standout-mode              [reset]
export LESS_TERMCAP_so=$'\e[07;107;34m'  # begin standout-mode - info box [white on blue]
export LESS_TERMCAP_ue=$'\e[0m'          # end underline                  [reset]
export LESS_TERMCAP_us=$'\e[01;04;32m'   # begin underline                [bold underlined Green]
export LESS_TERMCAP_me=$'\e[0m'          # end mode                       [reset]



#####   FUNCTIONS   #####

#####
##  [History clean up last line delete] #
##  [Function histdel] #
histdel() {
  history -d $(history | tail -n 2 | head -n 1 | awk '{print $1}');
  history -d $(history | tail -n 1 | awk '{print $1}')
  history 5
}


#####
##  [Function lcd] #
##   - ENTER AND LIST DIRECTORY
lcd() {
  if [[ $1 == '-h' ]]; then
    echo -e " "
    echo -e " ${C_YW}This is the help info for the function:${C_NC} ${C_CY} lcd ${C_NC}"
    echo -e " ${C_YW}lcd is a function that allows a user to 'cd' into a directory and 'list' the contents in a single command.${C_NC}"
    echo -e " ${C_YW}For example: ${C_NC}"
    echo -e " ${C_YW}lcd .. ${C_NC}"
    echo -e " ${C_YW}lcd ~/rtb ${C_NC}"
  elif [[ -z $1 ]]; then
    dir -latrh --color=always;
  else
    builtin cd -- "$@" && { [ "$PS1" = "" ] || dir -latrh --color=always; };
  fi
}      ##### FUNCTION END : lcd


##  [Function cpy]
##   - backs up files using filename.yyyymmdd.bak on any file or directory
##   - shortcut to cp -pr for example: cp -pr .file{,.20190505.bak}
cpy() {

  if [[ -z $1 ]] ; then
    echo -e " "
    echo -e "   ${C_GN} Use to make a .bak file with date on any file or directory ${C_NC}"
    echo -e "    Usage: cpy MyDirectory "
    echo -e "      e.g. cpy myfile"
  elif [[ -f $1 ]] || [[ -d $1 ]] ; then
    cp -pr $1{,.$(eval date '+%Y%m%d').bak}
    ls -goaltr --color=always $1 $1*.bak | grep --color=always $1 | tail -2
  elif [[ ! -f $1 ]] || [[ ! -d $1 ]]; then
    echo -e "    $C_RD \"$1\" $C_YW file or directory not found! $C_NC"
  fi
}      ##### FUNCTION END : cpy


##  [Function pwdp]
##   - runs pwd and checks to verify if working directory is physical or symlink
pwdp() {
  if [[ $(pwd) == $(pwd -P) ]]; then
    pwd
  else
    pwd; pwd -P
  fi
}      ##### FUNCTION END : pwd


#####
##  Remove which as alias so function below works
if [[ $(type -t which) = "alias"  ]]; then
  unalias which
fi

#####
##  [Function which ] - Finds the location of a function, alias, builtin, etc
which() {
## Written by Adam Brandeis - 2019-11-11
  if [[ -z $1 ]]; then
    echo -e "   ${C_GN} This finds the location of Functions and/or Alias, Builtin, File or Keyword ${C_NC}"
    echo -e "   ${C_GN} Usage: which <alias or funciton name or file or builtin or keyword>  ${C_NC}"
    echo -e "   ${C_GN} Usage: which <alias or function name or keyword, etc> ${C_NC}"
    echo -e "   ${C_GN} e.g.: which ll     ${C_NC}"    ## Example Alias
    echo -e "   ${C_GN} e.g.: which cpy    ${C_NC}"    ## Example Function
    echo -e "   ${C_GN} e.g.: which lcd    ${C_NC}"    ## Example Function
    echo -e "   ${C_GN} e.g.: which for    ${C_NC}"    ## Example keyword
    echo -e "   ${C_GN} e.g.: which awk    ${C_NC}"    ## Example file


  elif [[ $(type -t $1) =~ (alias|function|builtin|file|keyword)$ ]]; then
    echo -e " "
    echo -e "${C_GN}$1 is a          :${C_YW}" $(type -t $1) ${C_NC}

    if [[ $(type -t $1) == "alias" ]]; then
      type -a $1

    elif [[ $(type -t $1) == "function" ]]; then
      shopt -s extdebug
      echo -e "${C_GN}$1 is located in :${C_YW}" $(declare -F $1) ${C_NC}
      shopt -u extdebug
      echo " "
      type -a $1

    elif  [[ $(type -t $1) =~ (builtin|file|keyword)$ ]]; then
      echo -e "See          :   man $1"
      echo " "
      type -a $1
      echo " "
      man -f $1
    fi

  else
    echo " "
    echo -e "${C_RD}$1 not found or not a valid command ${C_NC}"
  fi
    echo " "
}      ##### FUNCTION END : which



####################
#|  BASH OPTIONS
# (for example, cd /vr/lgo/apaache would find /var/log/apache)
shopt -s cdspell                 # Correct cd typos.  When changing directory small typos can be ignored by bash
shopt -s checkwinsize            # Fix annoying line wrapping issues after resize terminal window.
shopt -s histverify              # Verify history before re-running a command via !<last_command>
shopt -s histappend              # When session close, history will append to .bash_history file rather than overwriting

# cmdhist If set, bash attempts to save all lines of a multiple-line command in the same history entry.
#        Allow easy re-editing of multi-line commands.
shopt -ps cmdhist

# lithist If set, and the cmdhist option is enabled, multi-line commands are saved to the history with embedded
#        newlines rather than using semicolon separators where possible.
shopt -pu lithist


########################
##  COMPLETE
complete -c type which man whatis locate ## (-c) Add auto complete for specific commands
complete -d -f ll ls lcd goal            ## (-d / -f) Add auto complete for directories and files

complete -C '/usr/local/bin/aws_completer' aws



## better ssh hostname autocomplete
#complete -o default -o nospace -W "$( { cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | ;  \
#                grep '^Host' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null | grep -v '[?*]' | cut -d ' ' -f 2-; } \
#                | sed -e 's/.my.domain.name.com//' -e 's/.domain2.com//'                                     \
#                | sort -u)" host ping rsync scp sftp ssh

