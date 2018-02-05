package workflow

import (
	"log"
	"os"

	"github.com/coreos/tectonic-installer/installer/pkg/tectonic"
)

// NewDestroyWorkflow creates new instances of the 'destroy' workflow,
// responsible for running the actions required to remove resources
// of an existing cluster and clean up any remaining artefacts.
func NewDestroyWorkflow(buildPath string) Workflow {
	pathStat, err := os.Stat(buildPath)
	// TODO: add deeper checking of the path for having cluster state
	if os.IsNotExist(err) || !pathStat.IsDir() {
		log.Fatalf("Provided path %s is not valid cluster state location.", buildPath)
	} else if err != nil {
		log.Fatalf("%v encountered while validating build location.", err)
	}

	// TODO: get this dynamically once we move to cluster config
	platform := "aws"

	if platform == "aws" {
		return simpleWorkflow{
			metadata: metadata{
				statePath: buildPath,
			},
			steps: []Step{
				terraformPrepareStep,
				joiningDestroyStep,
				bootstrapDestroyStep,
				assetsDestroyStep,
			},
		}
	} else {
		return simpleWorkflow{
			metadata: metadata{
				statePath: buildPath,
			},
			steps: []Step{
				terraformPrepareStep,
				terraformInitStep,
				terraformDestroyStep,
			},
		}
	}
}

func terraformDestroyStep(m *metadata) error {
	if m.statePath == "" {
		log.Fatalf("Invalid build location - cannot destroy.")
	}
	log.Printf("Destroying cluster from %s...", m.statePath)
	return tfDestroy(m.statePath, "state", tectonic.FindTemplatesForType(m.platform))
}

func joiningDestroyStep(m *metadata) error {
	log.Printf("Destroying cluster from %s...", m.statePath)
	return tfDestroy(m.statePath, "joining", tectonic.FindTemplatesForStep("joining"))
}

func bootstrapDestroyStep(m *metadata) error {
	log.Printf("Destroying cluster from %s...", m.statePath)
	return tfDestroy(m.statePath, "bootstrap", tectonic.FindTemplatesForStep("bootstrap"))
}

func assetsDestroyStep(m *metadata) error {
	log.Printf("Destroying cluster from %s...", m.statePath)
	return tfDestroy(m.statePath, "assets", tectonic.FindTemplatesForStep("assets"))
}
