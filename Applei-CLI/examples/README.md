# Applei CLI Examples

Example scripts demonstrating various use cases for the Applei CLI.

## Running Examples

```bash
cd examples
chmod +x *.sh
./batch-queries.sh
```

## Available Examples

### 1. batch-queries.sh
Process multiple questions in sequence. Useful for:
- Automated Q&A processing
- Knowledge base generation
- Documentation assistance

```bash
./batch-queries.sh
```

### 2. content-tagger.sh
Use the contentTagging model for categorization. Useful for:
- Article classification
- Content organization
- Topic extraction

```bash
./content-tagger.sh
```

### 3. temperature-test.sh
Compare outputs at different temperatures. Demonstrates:
- Effect of temperature on creativity
- When to use low vs high temperature
- Consistency vs variety tradeoffs

```bash
./temperature-test.sh
```

### 4. code-helper.sh
Use as a coding assistant. Shows:
- Custom system instructions
- Code-specific queries
- Programming help use case

```bash
./code-helper.sh
```

## Creating Your Own Examples

Template:

```bash
#!/bin/bash

CLI="../applei-cli.swift"

# Your custom logic here
"$CLI" --model general "Your prompt"
```

## Integration Ideas

### CI/CD Pipeline
```bash
# Generate commit messages
DIFF=$(git diff)
./applei-cli.swift "Generate a commit message for: $DIFF"
```

### Documentation
```bash
# Explain code
CODE=$(cat file.swift)
./applei-cli.swift "Explain this code: $CODE"
```

### Content Processing
```bash
# Summarize articles
for article in articles/*.txt; do
    ./applei-cli.swift "Summarize: $(cat $article)"
done
```

### Data Analysis
```bash
# Analyze logs
LOGS=$(tail -100 app.log)
./applei-cli.swift "Analyze these logs for errors: $LOGS"
```

## Best Practices

1. **Use appropriate temperature**:
   - 0.1-0.3 for factual/code tasks
   - 0.5-0.7 for general use
   - 0.8-1.0 for creative tasks

2. **Choose the right model**:
   - `general` for Q&A and conversations
   - `contentTagging` for categorization

3. **System instructions**:
   - Keep them concise (1-3 paragraphs)
   - Be specific about the role
   - Use clear, imperative language

4. **Error handling**:
   - Check exit codes
   - Handle model availability
   - Manage context overflow

## Tips

- Pipe output to files: `./applei-cli.swift "prompt" > output.txt`
- Combine with other tools: `cat file.txt | xargs -I {} ./applei-cli.swift "Explain: {}"`
- Use in scripts: Check examples for patterns
- Interactive for exploration: Use `--interactive` to test prompts
