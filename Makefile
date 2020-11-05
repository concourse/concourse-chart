.PHONY: test

test:
	helm unittest --helm3 -f 'unit-tests/*.yaml' ./

template:
	helm template release-name ./ > rendered.yaml

install-unittest:
	helm plugin install https://github.com/quintush/helm-unittest
