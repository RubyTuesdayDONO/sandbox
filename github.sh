#!/bin/bash -e

usage(){
    {
	echo 'USAGE: ' $(basename "$1") '[METHOD] /path/to/resource [DATA]' 
	echo 'METHOD defaults to HEAD if omitted'
	echo 'DATA is read from stdin if '-' or if omitted (and implied by METHOD)'
    } >&2
}

fail(){
    echo "${1:-aborted due to error}" >&2
    exit "${2:-1}"
}
    
case $# in 
    0)
	usage "$0"
	fail "" 2
	;;
    1)
	method='HEAD'
	path="$1"
	;;
    2)
	method="${1^^}"
	path="$2"
	;;
    3)
	method="${1^^}"
	path="$2"
	data="$3"
	;;
esac

path_pattern='^(/[a-zA-Z0-9_-]+)+(\?([a-zA-Z0-9_-]+=[a-zA-Z0-9_-]+)?(&[a-zA-Z0-9_-]+=[a-zA-Z0-9_-]+)*)?$'

if [[ ! "$path" =~ $path_pattern ]]
then
    fail 2 "invalid path $path (does not conform to regex pattern $path_pattern)"
fi

user="${GITHUB_USER:-RubyTuesdayDONO}"
tokenpath="$HOME/etc/github/oauth.tokens"
token="$(awk -v user="$user" '$1 ~ user { print $2 }' "$tokenpath")"
cmd="curl --silent --output - --header 'Authorization: token $token' --user-agent '$user' --include 'https://api.github.com$path'"
trailer="| tr -d '\r' | tee >( sed -r '/^\$/,\$d' ) >( sed '1,/^\$/d' | python -mjson.tool ) >/dev/null"
case "$method" in
    '' | 'GET')
	if [ ! -z "$data" ]
	then
	    cmd="$cmd --data '$data'" # pass data if specified, else omit for read-only methods
	fi
	cmd="$cmd $trailer"
	;;
    'HEAD')
	
 	if [ "$method" = 'HEAD' ]
	then
	    cmd="$cmd --head"
	fi
	;;
    'POST' | 'PATCH' | 'PUT' | 'DELETE')
	cmd="$cmd --request $method --data '${data:--}' $trailer" # default to stdin for methods that require input data
	;;
    *)
	fail "aborting - invalid method '$method'" 2
	;;
esac

cmd="$cmd"

eval $cmd
