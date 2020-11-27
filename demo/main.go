package main

import (
	"fmt"

	"github.com/onflow/cadence"
	"github.com/versus-flow/go-flow-tooling/tooling"

)

const Athletaverse = "Athletaverse"

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

	flow.DeployContract(Athletaverse)

	fmt.Println()
	fmt.Println()
	fmt.Println("Contracts successfully deployed!")

	flow.SendTransaction("league/create_league", Athletaverse)
	flow.SendTransaction("team/create_team", Athletaverse)
	flow.SendTransaction("team/register_team", Athletaverse)

	fmt.Println()
	fmt.Println()
	fmt.Println("Setup completed")

	flow.RunScript("league/get_team_ids")

}
