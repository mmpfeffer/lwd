#Can't remember every place you need in the tree?
#Have multiple LINUX sessions open at the same time?
#Want to share your shortcuts with others to collaborate?

#If you install these commands in your BASH startup on LINUX, it can help you navigate
#more easily as you work on integration tasks using multiple windows:

# Command Summary
# ---------------
# lwd  - add a shared shortcut for the current directory
# rwd  - remove shared shortcuts
# uwd  - select whose shared shortcuts to use in the current session
# mwd  - monitor shared shortcuts - update automatically
# swd  - set the home directory for relative shortcuts
# cswd - cd to current shortcut root directory
# llwd - list shared shortcuts
# luwd - show whose shortcuts you are currently using.
# lswd - show the current home directory for relative shortcuts

# Suggestion: add this to a file named .shortcuts in the ".dot" directory in your
# home directory. Then add the command "mwd" to your session startup so that
# shortcuts will be automatically updated in each session you open on LINUX.


# Latest version available at github:mmpfeffer/lwd

# By Moshe Pfeffer
# Install as Bash Startup script.

# Shared directory shortcuts

uwd() {
	if [[ "$1" == "-help" ]]
	then echo "Usage: uwd [[-u] <username>]"
	     echo "Update (shared) shell working directory shortcuts."
	     echo "-u is ignored but permitted for consistency with other shortcut commands."
	     return 0
	fi
	unset -f $_locs
	_lwd_home=
	_locs=
	if [[ -n "$1" ]]
	then if [[ "$1" == "-u" ]]; then shift; fi
	     eval _uwd_userdir=~$1
	     if [[ "$_uwd_userdir" == "~$1" ]]
	     then echo "User $1 not found."
	          return 1
             fi
	     _lwd_user=$1
	else _uwd_userdir=~
	     _lwd_user=""
	fi
	if [[ -f $_uwd_userdir/.loc.$HOSTNAME ]]
	then . $_uwd_userdir/.loc.$HOSTNAME
	fi
}

lwd() { 
	if [[ "$1" == "-help" ]]
	then echo "Usage: lwd [-u <username>] [-t | <path>] <alias>"
	     echo "Create a working directory shortcut for the current working directory or given path."
	     echo "\"alias\" indicates the shortcut name to use."
	     echo "-u <username> indicates the username's alias list to update. Write permission required."
	     echo "\"path\" indicates the path to associate with the alias."
	     return 0
	fi
	if [[ -z "$1" ]]
	then echo "Usage: lwd [-u <username>] [-t | <path>] <alias>"
	     return 1
	fi
	if [[ "$1" == "-u" ]]
	then eval _lwd_userdir=~$2
	     _user=$2
	     if [[ "$_lwd_userdir" == "~$2" ]]
	     then echo "User $2 not found."
	          return 1
             fi
	     shift 2
	else eval _lwd_userdir=~$_lwd_user
	     _user=$_lwd_user
	fi

	# temporary switch to the target user shorcut environment
	_tmp_lwd_user=$_lwd_user
	uwd $_user

	_reldir="no"
	_pwd=`pwd`

	_uwhere=""
	if [[ "$1" == "-t" ]]
	then _uwhere=$2
	elif [[ -n "$2" ]]; then
	     _uwhere=$1
	fi
	if [[ -n "$_uwhere" ]]; then
	     _where=$_uwhere # Initial assumption - use as is.
	     if [[ "$1" =~ '^[^/].*' ]]
	     then _reldir=yes
	          # If exists relative to current directory underneath lwd home, then strip it relative to lwd home.
		  if [[ ${_pwd#$_lwd_home} != ${_pwd} ]]
		  then _owhere=${_pwd#$_lwd_home}/$1
		       # If not found relative to lwd home then take as is.
	               if [[ -d "$_owhere" ]]
		       then _where=$_owhere
		       fi
		  else 
		       # If it exists as is under lwd home, warn that the cwd is out of scope, even though the target was found.
	               if [[ -d $_lwd_home/$_where ]]
	               then echo "Warning: Current directory not in scope of $_lwd_home."
	               fi

		  fi
	     fi
	     shift
	else _where=$_pwd
	fi
	uwd $_tmp_lwd_user
	# return to the previous shortcut environment

	if [[ -z "$_where" ]]
	then echo "Usage: lwd [-u <username>] [-t | <path>] <alias>"
	     return 1
	fi
	rwd -u "$_user" $1
	eval ${1}abza142ahqw123\(\) { echo\; } 2>/dev/null
	if [[ $? != 0 ]]
	then echo "Invalid name: $1"
	     return 1
	fi
	if [[ "$_reldir" == "yes" ]]
	then if [[ -n "$_lwd_home" && ! -d $_lwd_home/$_where ]]
	     then echo Warning: \'$_uwhere\' not found in $_lwd_home.
	     fi
	     echo "function $1 { if [[ -n "\$_lwd_home" ]]; then cd \$_lwd_home/$_where; else echo No shortcut home set. Use \'swd\'.; fi; }" >>$_lwd_userdir/.loc.$HOSTNAME;
	else echo "function $1 { cd $_where; }" >>$_lwd_userdir/.loc.$HOSTNAME;
	fi
	echo _locs=\"$1 \$_locs\" >>$_lwd_userdir/.loc.$HOSTNAME;
	uwd $_lwd_user
}

mwd() {
	if [[ "$1" == "-help" ]]
	then echo "Usage: mwd"
	     echo "Automatically update shortcuts in this session."
	     return 0
	fi
	PROMPT_COMMAND="uwd \$_lwd_user"
}

rwd() { 
	if [[ "$1" == "-help" ]]
	then echo "Usage: rwd [-q] [-u <username>] [<alias list>]"
	     echo "Remove working shortcuts."
	     echo "-q (optional) removes quietly. Must be first. Not used with \"alias list\"."
	     echo "-u <username> selects another user's alias list. Must have write access."
	     echo "\"alias list\" (optional) indicates which shortcuts should be removed."
	     return 0
	fi
	if [[ "$1" == "-q" ]]
	then _silent="yes"; shift;
	else _silent="no"
	fi

	if [[ "$1" == "-u" ]]
	then _rwd_user="${2}'s"
	     eval _rwd_userdir=~$2
	     if [[ "$_rwd_userdir" == "~$2" ]]
	     then echo "User $2 not found."
	          return 1
             fi
	     shift 2
	else if [[ -z "$_lwd_user" ]]
	     then _rwd_user="your"
	     else _rwd_user="${_lwd_user}'s"
	     fi
	     eval _rwd_userdir=~$_lwd_user
	fi
	if [[ -z "$1" ]]
	then if [[ "$_silent" == "no" ]]
	     then echo -n "Remove all $_rwd_user working directory aliases (y/n)? "
	          read _ans
	          case "$_ans" in 
	     	     y|Y) rm -f $_rwd_userdir/.loc.$HOSTNAME ;;
		     *) ;;
	          esac
	     else rm -f $_rwd_userdir/.loc.$HOSTNAME
	     fi
	else 
	     if [[ -w $_rwd_userdir/.loc.$HOSTNAME ]]
	     then if [[ ! -w $_rwd_userdir/.loc.$HOSTNAME ]]
	          then echo "No write permission on $_rwd_userdir/.loc.$HOSTNAME"
	               return 1
 	          fi
	          for _alias in $*
	          do ed -s $_rwd_userdir/.loc.$HOSTNAME 2>/dev/null <<END
/^function $_alias/,/^function $_alias/+1d
w
q
END
	          done
	     fi
	fi
	uwd $_lwd_user
}

llwd() {
	uwd $_lwd_user
	if [[ "$1" == "-help" ]]
	then echo "Usage: llwd [-l [[-u] <username>]]"
	     echo "List working dictory shortcuts."
	     echo "-l gives long listing"
	     echo "username selects another user's alias list"
	     echo "-u is ignored but permitted for consistency with other shortcut commands."
	     return 0
	fi
	if [[ "$1" == "-l" ]]
	then _longlist="yes"; shift
	else _longlist="no"
	fi
	if [[ "$1" == "-u" ]]; then shift; fi
	if [[ "$1" != "" ]]
	then _longlist="yes"; # assumed with username option.
	     eval _llwd_userdir=~$1
	     if [[ "$_llwd_userdir" == "~$1" ]]
	     then echo "User $1 not found."
	          return 1
             fi
	else eval _llwd_userdir=~$_lwd_user
	fi
	if [[ $_longlist == "yes" ]]
	then if [[ -f $_llwd_userdir/.loc.$HOSTNAME ]]
	     then grep '^function' $_llwd_userdir/.loc.$HOSTNAME | cut -b 10- | sed -e 's/\(^[^ ]\)* { cd \([^;]*\);.*/\1 -> \2/' -e 's/\(^[^ ]* \).*cd \$_lwd_home\/\([^;]*\)\;.*/\1->\2 (relative)/' | sort
	     fi
	else 
	     echo $_locs | tr ' ' '\n' | sort | tr '\n' ' '; echo
	fi
}

luwd() {
	if [[ "$1" == "-help" ]]
	then echo "Usage: luwd"
	     echo "Show the username whose shortcuts are active in the session."
	     return 0
	fi
	if [[ -n "$_lwd_user" ]]
	then echo "$_lwd_user"
	fi
} 

lswd() {
	if [[ "$1" == "-help" ]]
	then echo "Usage: lswd"
	     echo "Show the shortcut home directory active in the session."
	     return 0
	fi
	if [[ -n "$_lwd_home" ]]
	then echo "$_lwd_home"
	else echo "No shortcut home set."
	fi
}

cswd() {
	if [[ "$1" == "-help" ]]
	then echo "Usage: cswd"
	     echo "Change the working directory of the session to the active shortcut home directory."
	     return 0
	fi
	if [[ -z "$_lwd_home" ]]
	then echo "No shortcut home set."
	     return 1
	fi
	cd $_lwd_home
}

swd() {
	if [[ "$1" == "-help" ]]
	then echo "Usage: swd [-u <username>] [<path>]"
	     echo "Set the 'home' directory for relative-path shortcuts to the current directory or given path"
	     echo "-u <username> indicates the username's alias list to update. Write permission required."
	     echo "\"path\" indicates the path to set as the shortcut home."
	     return 0
	fi
	if [[ "$1" == "-u" ]]
	then eval _swd_userdir=~$2
	     _user=$2
	     if [[ "$_swd_userdir" == "~$2" ]]
	     then echo "User $2 not found"
	          return 1
	     fi
	     shift 2
	else eval _swd_userdir=~$_lwd_user
	     _user=$_lwd_user
	fi
	if [[ -z "$1" || "$1" == '.' ]]
	then _swd=`pwd`
	else _swd=$1
	fi
	if [[ "$_swd" != "/" ]]
	then _swd=${_swd%/}
	fi
	if [[ $_swd =~ '^[^/].*' ]]
	then _swd=`pwd`/$_swd
	fi
	if [[ ! -d $_swd ]]
	then echo \'$_swd\' is not a directory
	     return 1
	fi
	if [[ ~ != $_swd_userdir ]]
	then echo -n "Change shortcut home directory for user $_user? (y/n) "
	     read _confirm
	     case $_confirm in
	          y|Y) ;;
	          *) return 0 ;;
	     esac
	fi

	if [[ -f $_swd_userdir/.loc.$HOSTNAME ]]
	then
	     ed -s $_swd_userdir/.loc.$HOSTNAME <<END
1i
_lwd_home=$_swd
.
2,\$g/^_lwd_home=/d
w
q
END
	else
	    cat >$_swd_userdir/.loc.$HOSTNAME <<END
_lwd_home=$_swd
END
	fi
	uwd $_lwd_user
}

