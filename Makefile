.PHONY: update server post

update:
	git submodule update --remote

server:
	hugo server -D

post:
	gum input --placeholder post-title.md | xargs -I {} hugo new content content/posts/{}
