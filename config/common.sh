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
	if [[ "$1" == "central" ]]; then
		false
		return
	fi
	true
}
