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
	grep -xv "$2" "$W"/refs."$1".txt >"$W"/refs."$1".txt.1 || true
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
