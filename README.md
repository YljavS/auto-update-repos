# auto-update-repos
small script to update some projects

# Setup Instructions

## 1. Set Your JFrog Token

To interact with JFrog Artifactory (e.g., to pull or push packages), you need to set your JFrog token as an environment variable:

```bash
poetry config --unset http-basic.artifactory

poetry config http-basic.artifactory al-number your-jfrog-token-here
```

## 2. Login with GitHub CLI (`gh`)

To authenticate GitHub commands smoothly (such as cloning private repositories or pushing commits), use the GitHub CLI tool:

1. Install GitHub CLI:  
   See [https://cli.github.com/](https://cli.github.com/) for installation instructions.

2. Login using:

```bash
gh auth login
```

Follow the interactive prompts to authenticate via web browser or SSH.