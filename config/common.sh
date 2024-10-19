anysyncer::hook::should_sync_ref() {
	if [[ "$2" == refs/pull/*/head ]]; then
		false
		return
	fi
	true
}

anysyncer::hook::should_fail_on_push_err() {
	false
}

anysyncer::hook::should_sync_repo() {
	[[ "$1" != "central" ]] || return 1
	[[ "$1" != "linux" ]] || return 1
	[[ "$1" != *-kernel-* ]] || return 1
	true
}
