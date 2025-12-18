# Retry Feature with Backoff

## Overview

The Confluence plugin now includes automatic retry logic with configurable backoff strategies to improve the stability of write operations (`:w`).

## Configuration

Add retry configuration to your setup:

```lua
require('confluence').setup({
  -- ... other config ...
  retry = {
    max_attempts = 5,              -- Number of retry attempts
    backoff_type = "exponential",  -- or "logarithmic"
    initial_delay_ms = 1000,       -- Initial delay (1 second)
    max_delay_ms = 30000,          -- Max delay cap (30 seconds)
  }
})
```

## Backoff Strategies

### Exponential Backoff (Default)
```
Attempt 1: fails
Delay:     1s  (initial_delay_ms)
Attempt 2: fails
Delay:     2s  (2^1 * initial)
Attempt 3: fails
Delay:     4s  (2^2 * initial)
Attempt 4: fails
Delay:     8s  (2^3 * initial)
Attempt 5: fails
Final:     Error reported after 5 attempts
```

**Use case**: Fast recovery for transient issues, aggressive retry for intermittent problems.

### Logarithmic Backoff
```
Attempt 1: fails
Delay:     1s    (initial_delay_ms * log(2))
Attempt 2: fails
Delay:     1.6s  (initial_delay_ms * log(3))
Attempt 3: fails
Delay:     2.1s  (initial_delay_ms * log(4))
Attempt 4: fails
Delay:     2.6s  (initial_delay_ms * log(5))
Attempt 5: fails
Final:     Error reported after 5 attempts
```

**Use case**: Gentler retry pattern, better for rate-limited APIs or persistent issues.

## Retryable Conditions

The plugin automatically retries on:

1. **Network Errors**
   - Connection timeouts
   - DNS resolution failures
   - Network unreachable

2. **Server Errors (5xx)**
   - 500 Internal Server Error
   - 502 Bad Gateway
   - 503 Service Unavailable
   - 504 Gateway Timeout

3. **Transient Failures**
   - Invalid JSON responses (potential incomplete transmission)
   - Process failures (curl startup issues)

## Non-Retryable Conditions

The plugin will NOT retry on:

- **4xx Client Errors** (Bad Request, Unauthorized, Forbidden, Not Found)
- **Authentication failures** (invalid credentials)
- **Validation errors** (malformed requests)

## User Experience

When a retry occurs, you'll see a notification:

```
Request failed (HTTP 503), retrying in 2.0s (attempt 2/5)
```

On success after retry:
```
Page saved successfully
```

On final failure:
```
Error saving page: HTTP request failed with status 503 (failed after 5 attempts)
```

## Customization Examples

### Quick, aggressive retry (for flaky WiFi)
```lua
retry = {
  max_attempts = 3,
  backoff_type = "exponential",
  initial_delay_ms = 500,   -- Start faster
  max_delay_ms = 5000,      -- Don't wait too long
}
```

### Patient, persistent retry (for busy servers)
```lua
retry = {
  max_attempts = 10,
  backoff_type = "logarithmic",
  initial_delay_ms = 2000,
  max_delay_ms = 60000,
}
```

### No retry (disable feature)
```lua
retry = {
  max_attempts = 1,  -- No retries
}
```

## Implementation Details

- Retries are handled at the HTTP client layer (`http.lua`)
- Uses `vim.defer_fn()` for non-blocking delays
- HTTP status codes are captured via curl's `-w` flag
- Error messages are parsed for retry decision
- Version conflicts are NOT automatically retried (requires user action)

## Checking Configuration

View your current retry settings:

```vim
:Confluence setup
```

Output includes:
```
Retry configuration:
  Max attempts: 5
  Backoff type: exponential
  Initial delay: 1000ms
  Max delay: 30000ms
```
