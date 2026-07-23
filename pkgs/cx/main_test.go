package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestValidAlias(t *testing.T) {
	valid := []string{"l", "_foo", "a-b", "a.b", "a1"}
	for _, name := range valid {
		if !validAlias(name) {
			t.Fatalf("validAlias(%q) = false, want true", name)
		}
	}

	invalid := []string{"", "-x", "1foo", "a b", "a/b", "älias"}
	for _, name := range invalid {
		if validAlias(name) {
			t.Fatalf("validAlias(%q) = true, want false", name)
		}
	}
}

func TestWriteAliasesRejectsInvalidAlias(t *testing.T) {
	root := &Node{Name: "cx", Items: []*Node{
		{Name: "pack", Items: []*Node{
			{Name: "bad", Cmd: "echo bad", Alias: "-x"},
		}},
	}}

	err := writeAliases(filepath.Join(t.TempDir(), aliasesFileName), root)
	if err == nil || !strings.Contains(err.Error(), "invalid alias") {
		t.Fatalf("writeAliases error = %v, want invalid alias error", err)
	}
}

func TestWriteAliasesRejectsDuplicateAlias(t *testing.T) {
	root := &Node{Name: "cx", Items: []*Node{
		{Name: "pack", Items: []*Node{
			{Name: "one", Cmd: "echo one", Alias: "dup"},
			{Name: "two", Cmd: "echo two", Alias: "dup"},
		}},
	}}

	err := writeAliases(filepath.Join(t.TempDir(), aliasesFileName), root)
	if err == nil || !strings.Contains(err.Error(), "duplicate alias") {
		t.Fatalf("writeAliases error = %v, want duplicate alias error", err)
	}
}

func TestWriteAliasesEscapesSingleQuotes(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, aliasesFileName)
	root := &Node{Name: "cx", Items: []*Node{
		{Name: "pack", Items: []*Node{
			{Name: "quote", Cmd: "echo 'hi'", Alias: "say"},
		}},
	}}

	if err := writeAliases(path, root); err != nil {
		t.Fatal(err)
	}
	got, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(got), "alias say='echo '\\''hi'\\'''") {
		t.Fatalf("aliases.sh did not escape single quotes correctly:\n%s", got)
	}
}

func TestSetAliasRejectsDuplicate(t *testing.T) {
	dir := t.TempDir()
	packNode := &Node{Name: "pack", Items: []*Node{
		{Name: "one", Cmd: "echo one", Alias: "taken"},
		{Name: "two", Cmd: "echo two"},
	}}
	p := &pack{file: filepath.Join(dir, "pack.yaml"), root: packNode}
	if err := savePack(p); err != nil {
		t.Fatal(err)
	}
	m := newModel(rootFromPacks([]*pack{p}), dir, []*pack{p}, map[string]bool{})

	m.setAlias(packNode.Items[1], "taken")

	if packNode.Items[1].Alias != "" {
		t.Fatalf("duplicate alias was persisted in memory: %q", packNode.Items[1].Alias)
	}
	if !strings.Contains(m.status, "already used") {
		t.Fatalf("status = %q, want duplicate warning", m.status)
	}
}
