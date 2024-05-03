github::sync() {
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
		done < <(github::list_repos "$GITHUB_USERNAME" "$page")
		((page++))
	done
	echo "GitHub push end"

	sync::prune_refs
	echo "GitHub prune end"

	echo "GitHub sync end"
}

# github::list_repos <owner> <page (from 1)>
github::list_repos() {
	wcurl -X GET \
		"$FORGEJO_BASE_URL/$1/repos?page=$2" \
		-H "Accept: application/vnd.github+json" |
		wyq '.[] | { "name": .name, "url": .clone_url }'
}
