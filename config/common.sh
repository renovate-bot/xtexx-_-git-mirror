forgejo::hook::should_sync_ref() {
	if [[ "$2" == refs/pull/*/head ]]; then
		false
		return
	fi
	true
}

forgejo::hook::should_fail_on_push_err() {
	false
}
