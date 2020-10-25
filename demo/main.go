package main

import (
	"fmt"

	"github.com/onflow/cadence"
	"github.com/versus-flow/go-flow-tooling/tooling"
)

const NonFungibleToken = "NonFungibleToken"
const HockeyEquipment = "HockeyEquipment"

func ufix(input string) cadence.UFix64 {
	amount, err := cadence.NewUFix64(input)
	if err != nil {
		panic(err)
	}
	return amount
}

func main() {
	flow := tooling.NewFlowConfigLocalhost()

	fmt.Println("Deploy contracts - press ENTER")
	fmt.Scanln()
	flow.DeployContract(NonFungibleToken)
	flow.DeployContract(HockeyEquipment)

	fmt.Println()
	fmt.Println()
	fmt.Println("Contracts successfully deployed!")
}
