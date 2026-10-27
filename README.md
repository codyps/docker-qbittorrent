# qBittorrent Docker image

Headless qBittorrent (`qbittorrent-nox`) from Debian unstable, published for
`linux/amd64` and `linux/arm64` at `ghcr.io/codyps/docker-qbittorrent:latest`.

```sh
docker pull ghcr.io/codyps/docker-qbittorrent:latest
docker run -d --name qbittorrent \
  -p 8080:8080 -p 6881:6881 -p 6881:6881/udp \
  -v qbittorrent-config:/config \
  ghcr.io/codyps/docker-qbittorrent:latest
```

Open the WebUI on port 8080. Use `docker logs qbittorrent` to find the temporary
administrator password on first startup. Mount your downloads directory as needed.
To change the WebUI port, set `WEBUI_PORT` and publish the matching container port.

## Automatic updates

GitHub Actions rebuilds and publishes the image on changes to `main` and daily at
06:17 UTC. You can also choose **Run workflow** under **Actions → Build and Push
Docker Image** on `main` to publish immediately. Pull requests build and test
without publishing.

Every build pulls the current Debian base and disables Docker layer caching so
`apt-get update` and installation run again. This picks up new qBittorrent packages,
Debian package revisions, and dependency updates without a repository commit.
Updates follow [Debian unstable's package availability](https://packages.debian.org/sid/qbittorrent-nox):
an upstream qBittorrent release is included after Debian packages it for the target
architecture. This image does not compile upstream commits or prereleases.

The build checks that qBittorrent runs on both architectures and smoke-tests WebUI
startup on amd64 with the default port and a custom port before publishing.
Each publication includes `latest` and a unique `build-<run-id>-<attempt>` tag;
the workflow summary records the image digest for pinning or rollback.
Existing running containers must be pulled and recreated to use a new image.

GitHub can delay scheduled jobs and disables schedules in public repositories after
60 days without repository activity. If that happens, re-enable the workflow in
Actions. See [GitHub's schedule documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule).
