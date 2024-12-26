#!/bin/bash

# Set project name
PROJECT_NAME=${1:-auto-llm-notifier}
echo "Creating project: $PROJECT_NAME"

# Create base directories
mkdir -p $PROJECT_NAME/{cmd/notifier,pkg/{llm,notifications,utils},internal/{core,database/api},configs,docs,scripts,tests/{integration,e2e}}
cd $PROJECT_NAME || exit

# Create main.go
cat > cmd/notifier/main.go <<EOL
package main

import (
    "log"
    "auto-llm-notifier/internal/core"
    "auto-llm-notifier/pkg/utils"
)

func main() {
    config := utils.LoadConfig("configs/config.yaml")
    log.Println("Starting Auto LLM Notification System...")

    err := core.StartScheduler(config)
    if err != nil {
        log.Fatalf("Failed to start the scheduler: %v", err)
    }
}
EOL

# Create LLM client
cat > pkg/llm/client.go <<EOL
package llm

import "fmt"

type LLMClient struct {
    APIKey string
}

func (c *LLMClient) GenerateResponse(prompt string) (string, error) {
    return fmt.Sprintf("Response to '%s'", prompt), nil
}
EOL

# Create Notification handlers
cat > pkg/notifications/email.go <<EOL
package notifications

import "log"

func SendEmail(recipient, subject, body string) {
    log.Printf("Sending email to %s with subject: %s", recipient, subject)
}
EOL

cat > pkg/notifications/sms.go <<EOL
package notifications

import "log"

func SendSMS(phoneNumber, message string) {
    log.Printf("Sending SMS to %s with message: %s", phoneNumber, message)
}
EOL

# Create Utils
cat > pkg/utils/logger.go <<EOL
package utils

import (
    "log"
    "os"
)

func InitLogger() {
    log.SetOutput(os.Stdout)
    log.SetFlags(log.LstdFlags | log.Lshortfile)
}
EOL

cat > pkg/utils/config.go <<EOL
package utils

import (
    "gopkg.in/yaml.v2"
    "io/ioutil"
    "log"
)

func LoadConfig(path string) map[string]interface{} {
    data, err := ioutil.ReadFile(path)
    if err != nil {
        log.Fatalf("Failed to load config: %v", err)
    }

    config := make(map[string]interface{})
    err = yaml.Unmarshal(data, &config)
    if err != nil {
        log.Fatalf("Failed to parse config: %v", err)
    }

    return config
}
EOL

# Create Core Scheduler
cat > internal/core/scheduler.go <<EOL
package core

import "time"

func StartScheduler(config map[string]interface{}) error {
    ticker := time.NewTicker(1 * time.Minute)
    for range ticker.C {
        processNotifications()
    }
    return nil
}

func processNotifications() {
    // Add LLM and notification logic here
}
EOL

# Create Config Files
mkdir -p configs
cat > configs/config.yaml <<EOL
app:
  name: "Auto LLM Notifier"
  env: "development"
llm:
  api_key: "your-llm-api-key"
notifications:
  email:
    sender: "no-reply@example.com"
EOL

# Create Scripts
mkdir -p scripts
cat > scripts/run_notifier.sh <<EOL
#!/bin/bash
# Run the notifier
go run cmd/notifier/main.go
EOL

chmod +x scripts/run_notifier.sh

# Initialize go module
go mod init example.com/$PROJECT_NAME

# Add README
cat > README.md <<EOL
# $PROJECT_NAME

Auto LLM Notification System using Go.

## Features
- Integrates with LLM for prompt handling
- Sends notifications via email, SMS, and webhooks
- Scheduler for automated tasks

## How to Run
1. Ensure you have Go installed.
2. Run the application:
   \`\`\`bash
   ./scripts/run_notifier.sh
   \`\`\`

## Project Structure
- \`cmd/\`: Application entry point
- \`pkg/\`: Reusable libraries and modules
- \`internal/\`: Core business logic
- \`configs/\`: Configuration files
- \`scripts/\`: Automation scripts

EOL

echo "Project $PROJECT_NAME has been created successfully!"