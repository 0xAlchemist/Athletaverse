package main

import (
	"github.com/bjartek/go-with-the-flow/gwtf"
)

func main() {
	em := gwtf.NewGoWithTheFlowEmulator()

	println("Emulator connected")
	// Deploy Contracts
	em.DeployContract("ExampleToken")
}
