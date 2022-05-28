default: build push update-latest

TAG="dev"

build:
	docker image build -t m4xmoehl/route53-k8s-certbot:${TAG} .

push:
	docker image push m4xmoehl/route53-k8s-certbot:${TAG}

update-latest:
	docker image tag m4xmoehl/route53-k8s-certbot:${TAG} m4xmoehl/route53-k8s-certbot:latest
	docker image push m4xmoehl/route53-k8s-certbot:latest
