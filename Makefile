.PHONY: test

test:
	helm unittest -f 'unit-tests/*.yaml' ./ --helm3

template:
	helm template test ./ > rendered.yaml

install-unittest:
	helm plugin install https://github.com/quintush/helm-unittest
