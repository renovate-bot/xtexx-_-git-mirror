: "${W:=$(pwd)}"
if [[ -n "$CI" ]]; then
	: "${GIT_W:=$(pwd)}"
else
	: "${GIT_W:=syncworkspace}"
fi

wgit() {
	git -C "$GIT_W" "$@"
}

wyq() {
	yq -p json -o json -I0 "$@"
}

wyqs() {
	wyq --unwrapScalar=true "$@"
}

wcurl() {
	curl -sSL --retry 3 "$@"
}

# git::refs::file <list>
git::refs::file() {
	echo "$W"/refs."$1".txt
}

# git::refs::fetch <list> <url>
git::refs::fetch() {
	git ls-remote "$2" | cut -f2 >"$W"/refs."$1".txt
}

# git::refs::check <list> <ref>
git::refs::check() {
	grep -x "$2" "$W"/refs."$1".txt || return 1
}

# git::refs::remove <list> <ref>
git::refs::remove() {
	grep -xv "$2" "$W"/refs."$1".txt >"$W"/refs."$1".txt.1
	mv "$W"/refs."$1".txt.1 "$W"/refs."$1".txt
}

# git::refs::delete <list>
git::refs::delete() {
	rm -f "$W"/refs."$1".txt
}

# git::refs::withprefix <list> <prefix>
git::refs::withprefix() {
	grep -Ex "^$2.*$" "$W"/refs."$1".txt
}
