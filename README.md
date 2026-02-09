# xtide-docker

Docker image for [XTide](https://flaterco.com/xtide/), a tide prediction program. Includes the `tide` CLI, `xttpd` web server, and `tcd-utils` (`build_tide_db`, `restore_tide_db`), compiled from source with harmonics data.

## Usage

### tide CLI

```sh
# Plain text predictions for a location
docker run --rm ghcr.io/openwatersio/xtide tide -l "San Francisco"

# Output a PNG graph
docker run --rm ghcr.io/openwatersio/xtide tide -l "San Francisco" -m g -f p > tides.png
```

See `tide -h` for all options.

### xttpd web server

```sh
docker run --rm -p 8080:8080 ghcr.io/openwatersio/xtide xttpd 8080
```

Then open http://localhost:8080 in your browser.

### tcd-utils

```sh
docker run --rm ghcr.io/openwatersio/xtide restore_tide_db -h
docker run --rm ghcr.io/openwatersio/xtide build_tide_db -h
```

## Custom Harmonics File

The image includes the free harmonics dataset from [flaterco.com](https://flaterco.com/xtide/files.html). To use a custom `.tcd` harmonics file, mount it into the container and set the `HFILE_PATH` environment variable:

```sh
docker run --rm \
  -v /path/to/your/harmonics.tcd:/data/harmonics.tcd \
  -e HFILE_PATH=/data/harmonics.tcd \
  ghcr.io/openwatersio/xtide tide -l "San Francisco"
```

You can also combine multiple `.tcd` files by pointing `HFILE_PATH` at a directory containing them:

```sh
docker run --rm \
  -v /path/to/harmonics-dir:/data/harmonics \
  -e HFILE_PATH=/data/harmonics \
  ghcr.io/openwatersio/xtide tide -l "San Francisco"
```

## Images

Published to:

- `ghcr.io/openwatersio/xtide`
- `docker.io/openwatersio/xtide`

Multi-arch: `linux/amd64` and `linux/arm64`.

## Building Locally

```sh
docker buildx build --platform linux/amd64 -t xtide .
```
