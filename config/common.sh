forgejo::hook::should_sync_ref() {
	if [[ "$2" == refs/pull/* ]]; then
		false
	fi
	true
}

forgejo::hook::should_fail_on_push_err() {
	false
}
