## Template rendering tests

This test suite is used to verify the behaviour of image relocation template helpers.
In order to run the tests, [`basht`](https://github.com/progrium/basht) 
should be installed, which requires Golang to be available on the workstation.

### Installing basht

Given that `go` is already installed, `basht` can be installed by running:
```shell script
$ go get github.com/progrium/basht
```

### Running the tests

The tests can be run from any folder with `basht`, e.g.:

```shell script
[concourse-chart]$ basht test/*.bash  
```

Please note that running the tests requires an active connection to a k8s cluster.