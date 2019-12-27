IMAGE := ardation/my_bank

image:
	docker build -t $(IMAGE) .

push-image:
	docker push $(IMAGE)
