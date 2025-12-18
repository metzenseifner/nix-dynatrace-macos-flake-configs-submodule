package main

import (
  "bytes"
  "fmt"
  "os"
  "time"
)

type cacheState struct {
  entry   string
  expires time.Time
}

type request struct {
  resp chan result
}

type result struct {
  val string
  err error
}

// NewSupplierActor returns a function that fetches the value via an internal actor.
func NewSupplierActor(envKey, filePath string) func() (string, error) {
  requests := make(chan request)

  go actorLoop(envKey, filePath, requests)

  return func() (string, error) {
    ch := make(chan result)
    requests <- request{resp: ch}
    res := <-ch
    return res.val, res.err
  }
}

// actorLoop owns the cache state and handles all incoming requests.
func actorLoop(envKey, filePath string, requests chan request) {
  state := cacheState{}

  for req := range requests {
    if val, ok := getEnvValue(envKey); ok {
      req.resp <- result{val: val}
      continue
    }

    if val, ok := getCachedValue(state); ok {
      req.resp <- result{val: val}
      continue
    }

    val, err := loadFromFile(filePath)
    if err != nil {
      req.resp <- result{"", fmt.Errorf("load file: %w", err)}
      continue
    }
    state = cacheState{
      entry:   val,
      expires: time.Now().Add(24 * time.Hour),
    }
    req.resp <- result{val: val}
  }
}

// getEnvValue checks the environment variable and returns its value if set.
func getEnvValue(envKey string) (string, bool) {
  if v := os.Getenv(envKey); v != "" {
    return v, true
  }
  return "", false
}

// getCachedValue returns the cached entry if it hasn’t expired.
func getCachedValue(state cacheState) (string, bool) {
  if time.Now().Before(state.expires) {
    return state.entry, true
  }
  return "", false
}

// loadFromFile reads, trims, and returns the file contents.
func loadFromFile(filePath string) (string, error) {
  raw, err := os.ReadFile(filePath)
  if err != nil {
    return "", err
  }
  trimmed := string(bytes.TrimSpace(raw))
  return trimmed, nil
}

func main() {
  supplier := NewSupplierActor("MY_KEY", "config.txt")

  value, err := supplier()
  if err != nil {
    fmt.Println("Error fetching value:", err)
    return
  }
  fmt.Println("Supplied value:", value)
}

