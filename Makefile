default: docker_build

docker_build:
	@docker build \
		-t indra58/flutter-fastlane \
		--build-arg VCS_REF=`git rev-parse --short HEAD` .
