package main

import (
	"github.com/bjartek/go-with-the-flow/gwtf"

)

func main() {
	gwtf := gwtf.NewGoWithTheFlowEmulator().
		InitializeContracts().
		CreateAccount("user_1", "user_2")

	// fmt.Println("Deploy contracts - press ENTER")

	// fmt.Scanln()

	// gwtf.DeployContract(Athletaverse)

	// fmt.Println()
	// fmt.Println()
	// fmt.Println("Contracts successfully deployed!")

	// gwtf.SendTransaction("league/create_league", Athletaverse)
	// gwtf.SendTransaction("team/create_team", Athletaverse)
	// gwtf.SendTransaction("team/register_team", Athletaverse)

	// fmt.Println()
	// fmt.Println()
	// fmt.Println("Setup completed")

	// gwtf.RunScript("league/get_team_ids")

}
