# PgBouncer CI/CD Setup

## Prerequisites

1. **GitHub Repository**: Ensure your repository is on GitHub
2. **GitHub Token**: The system uses `GITHUB_TOKEN` for authentication (created automatically)

## GitHub Actions Setup

### 1. Enable Actions

1. Go to repository settings: `Settings` → `Actions` → `General`
2. Enable "Allow all actions and reusable workflows"
3. Save settings

### 2. Container Registry Setup

1. Go to `Settings` → `Packages`
2. Ensure GitHub Container Registry is enabled
3. Configure Action permissions in `Settings` → `Actions` → `General` → `Workflow permissions`

### 3. Secrets Setup (optional)

If you want to use external registry (e.g., Docker Hub), add secrets:

```bash
# In repository settings: Settings → Secrets and variables → Actions
DOCKER_USERNAME=your-docker-username
DOCKER_PASSWORD=your-docker-password
```

## Usage

### Automatic Build

1. **Push to main/master**: Automatically triggers build and publish
2. **Create tag**: `git tag v1.0.0 && git push origin v1.0.0`
3. **Pull Request**: Build for testing

### Manual Run

1. Go to `Actions` → `Build and Push PgBouncer Image`
2. Click "Run workflow"
3. Optionally specify PgBouncer version

### Automatic Version Updates

The system automatically:
- Checks for new PgBouncer versions daily
- Creates Pull Request when updates are found
- Allows manual trigger of version check

## Monitoring

### Build Status Check

1. Go to `Actions` tab in repository
2. View recent workflow runs
3. Check logs for errors

### View Images

1. Go to `Packages` tab in repository
2. Find your PgBouncer image
3. View available tags

## Troubleshooting

### Authentication Errors

- Ensure `GITHUB_TOKEN` is available
- Check Action permissions in settings

### Build Errors

- Check build logs in Actions
- Ensure Dockerfile is correct
- Check base image availability

### Publishing Errors

- Check Container Registry permissions
- Ensure image doesn't exceed size limits

## Customization

### Change Registry

Edit `.github/workflows/ci.yml`:

```yaml
env:
  REGISTRY: docker.io  # or other registry
  IMAGE_NAME: your-org/pgbouncer
```

### Add Additional Tests

Add new steps to the `test` job in `ci.yml`.

### Change Schedule

Edit `cron` expressions in `update-version.yml`:

```yaml
schedule:
  - cron: '0 2 * * 1'  # Every Monday at 2:00 UTC
```
