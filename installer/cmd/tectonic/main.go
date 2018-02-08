package main

import (
	"log"

	"github.com/coreos/tectonic-installer/installer/pkg/workflow"
	"gopkg.in/alecthomas/kingpin.v2"
)

var (
	dryRunFlag              = kingpin.Flag("dry-run", "Just pretend, but don't do anything").Bool()
	clusterInstallCommand   = kingpin.Command("install", "Create a new Tectonic cluster")
	clusterAssetsCommand    = clusterInstallCommand.Command("assets", "Generate assets.")
	clusterBootstrapCommand = clusterInstallCommand.Command("bootstrap", "Create a bootstrap node cluster.")
	clusterJoinCommand      = clusterInstallCommand.Command("join", "Create joining nodes.")
	clusterDeleteCommand    = kingpin.Command("delete", "Delete an existing Tectonic cluster")
	deleteClusterDir        = clusterDeleteCommand.Arg("dir", "The name of the cluster to delete").String()
	clusterConfigFlag       = clusterInstallCommand.Flag("config", "Cluster specification file").Required().ExistingFile()
)

func main() {
	switch kingpin.Parse() {
	case clusterInstallCommand.FullCommand():
		{
			w := workflow.NewInstallWorkflow(*clusterConfigFlag)
			if err := w.Execute(); err != nil {
				log.Fatal(err) // TODO: actually do proper error handling
			}
		}
	case clusterAssetsCommand.FullCommand():
		{
			w := workflow.NewAssetsWorkflow(*clusterConfigFlag)
			if err := w.Execute(); err != nil {
				log.Fatal(err) // TODO: actually do proper error handling
			}
		}
	case clusterBootstrapCommand.FullCommand():
		{
			w := workflow.NewBootstrapWorkflow(*clusterConfigFlag)
			if err := w.Execute(); err != nil {
				log.Fatal(err) // TODO: actually do proper error handling
			}
		}
	case clusterJoinCommand.FullCommand():
		{
			w := workflow.NewJoinWorkflow(*clusterConfigFlag)
			if err := w.Execute(); err != nil {
				log.Fatal(err) // TODO: actually do proper error handling
			}
		}
	case clusterDeleteCommand.FullCommand():
		{
			w := workflow.NewDestroyWorkflow(*deleteClusterDir)
			if err := w.Execute(); err != nil {
				log.Fatal(err) // TODO: actually do proper error handling
			}
		}
	}
}
