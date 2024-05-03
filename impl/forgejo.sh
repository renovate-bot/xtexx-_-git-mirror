forgejo::sync() {
	git::refs::fetch dest "$SYNCER_DEST"

	local page=1 count=1
	while ((count != 0)); do
		count=0
		while read -r repo; do
			[[ "$repo" != "" ]] || continue
			local name url
			name="$(wyqs '.name' <<<"$repo")"
			url="$(wyqs '.url' <<<"$repo")"
			((count++)) || true
			sync::sync_repo "$name" "$url"
		done < <(forgejo::list_repos "$FORGEJO_USERNAME" "$((page))")
		((page++))
	done
	echo "Forgejo push end"

	sync::prune_refs
	echo "Forgejo prune end"

	echo "Forgejo sync end"
}

# forgejo::list_repos <owner> <page (from 1)>
forgejo::list_repos() {
	wcurl -X 'GET' \
		"https://codeberg.org/api/v1/users/$1/repos?page=$2&limit=10" \
		-H 'Accept: application/json' |
		wyq '.[] | { "name": .name, "url": .clone_url }'
}
