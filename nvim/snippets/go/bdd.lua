local bdd_template = [[
import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func It(t *testing.T, name string, body func(t *testing.T)) {
	t.Run(name, func(t *testing.T) { body(t) })
}

func Step(t *testing.T, label, desc string, fn func()) {
  // Marks the step wrapper as a helper so failure locations point to your test body, not the wrapper.
	t.Helper()
  // Adds readable, BDD-style output without introducing subtests.
	t.Logf("%s: %s", label, desc)
  // Executes the step inline, preserving linear flow.
	fn()
}

func Given(t *testing.T, desc string, fn func()) { Step(t, "Given", desc, fn) }
func When(t *testing.T, desc string, fn func())  { Step(t, "When", desc, fn) }
func Then(t *testing.T, desc string, fn func())  { Step(t, "Then", desc, fn) }
func And(t *testing.T, desc string, fn func())   { Step(t, "And", desc, fn) }
]]
return {
  s("bdd", fmt(bdd_template, {}, {delimiters="<>"}))
}
