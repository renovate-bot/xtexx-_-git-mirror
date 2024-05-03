: "${W:=$(pwd)}"
: "${GIT_W:=syncworkspace}"

try_call_func() {
	if [[ "$(type -t "$1")" == "function" ]]; then
		"$@"
		return
	fi
	return 0
}

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

# shellcheck source=sync.sh
. common/sync.sh

# shellcheck source=refs.sh
. common/refs.sh
