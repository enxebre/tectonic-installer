package configgenerator

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	ignconfig "github.com/coreos/ignition/config/v2_0"
	ignconfigtypes "github.com/coreos/ignition/config/v2_0/types"
)

const (
	IgnitionMaster = "ignition-master.ign"
	IgnitionWorker = "ignition-worker.ign"
	IgnitionEtcd   = "ignition-etcd.ign"
)

var (
	ignVersion = ignconfigtypes.IgnitionVersion{
		2,
		0,
		0,
		"",
		"",
	}
	ignFilesPath = map[string]string{
		"master": IgnitionMaster,
		"worker": IgnitionWorker,
		"etcd":   IgnitionEtcd,
	}
)

func (c ConfigGenerator) poolToRoleMap() map[string]string {
	poolToRole := make(map[string]string)
	// assume no roles can share pools
	for _, n := range c.Master.NodePools {
		poolToRole[n] = "master"
	}
	for _, n := range c.Worker.NodePools {
		poolToRole[n] = "worker"
	}
	for _, n := range c.Etcd.NodePools {
		poolToRole[n] = "etcd"
	}
	return poolToRole
}

func (c ConfigGenerator) GenerateIgnConfig(clusterDir string) error {

	poolToRole := c.poolToRoleMap()
	for _, p := range c.NodePools {
		ignFile := p.IgnitionFile
		userIgnCfg, err := parseIgnFile(ignFile)
		if err != nil {
			return err
		}
		role := poolToRole[p.Name]
		// TODO(alberto): Append block need to be different for each etcd node.
		// add loop over count if role is etcd
		fullIgnCfg := c.embedAppendBlock(*userIgnCfg, role)

		fileTargetPath := filepath.Join(clusterDir, ignFilesPath[role])
		if err = ignCfgToFile(fullIgnCfg, fileTargetPath); err != nil {
			return err
		}
	}
	return nil
}

func parseIgnFile(filePath string) (*ignconfigtypes.Config, error) {
	if filePath == "" {
		ignition := &ignconfigtypes.Ignition{
			Version: ignVersion,
		}
		return &ignconfigtypes.Config{Ignition: *ignition}, nil
	}

	data, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, err
	}

	cfg, rpt, err := ignconfig.Parse(data)
	if len(rpt.Entries) > 0 {
		return nil, fmt.Errorf("failed to parse ignition file %s: %s", filePath, rpt.String())
	}

	return &cfg, nil
}

func (c ConfigGenerator) embedAppendBlock(ignCfg ignconfigtypes.Config, role string) *ignconfigtypes.Config {

	appendBlock := &ignconfigtypes.ConfigReference{
		c.getTNCURL(role),
		ignconfigtypes.Verification{Hash: nil},
	}
	ignCfg.Ignition.Config.Append = append(ignCfg.Ignition.Config.Append, *appendBlock)

	return &ignCfg
}

func (c ConfigGenerator) getTNCURL(role string) ignconfigtypes.Url {
	var url ignconfigtypes.Url
	if role == "master" || role == "worker" {
		url = ignconfigtypes.Url{
			Scheme: "http",
			Host:   fmt.Sprintf("%s-tnc.%s", c.Name, c.BaseDomain),
			Path:   fmt.Sprintf("/ign/v1/role/%s", role),
		}
	}
	return url
}

func ignCfgToFile(ignCfg *ignconfigtypes.Config, filePath string) error {
	data, err := json.MarshalIndent(&ignCfg, "", "  ")
	if err != nil {
		return err
	}

	return writeFile(filePath, string(data))
}

func writeFile(path, content string) error {
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()

	w := bufio.NewWriter(f)
	if _, err := fmt.Fprintln(w, content); err != nil {
		return err
	}
	w.Flush()

	return nil
}
