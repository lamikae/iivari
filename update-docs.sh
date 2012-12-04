#!/bin/sh

# Document source branch
branch=develop

function die {
	echo $1 1>&2
	exit 1
}

function parse_git_branch {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function express_docs {
	cd express || die "could not chdir: express"
	cake=node_modules/coffee-script/bin/cake
	if [ -x $cake ]; then
		npm install || die
	fi
	# still no luck?
	[ -x $cake ] || die "$cake is a lie"
	$cake docs
	cd - &>/dev/null
}

# Generates documentation from $branch, moves
# the files to docs/ directory in current branch.
function update_docs {
	my_branch=$(parse_git_branch)
	[[ -z $my_branch ]] && die "Could not read current branch!"

	git checkout $branch || die
	express_docs

	# return to original branch
	git checkout $my_branch || die
	# clean existing docs
	rm -rf docs && mkdir -p docs || die
	# move generated docs in place
	mv express/docs docs/express
}

update_docs
