# Jupyter notebook server with tmtk and TranSMART API client

Image to launch a Jupyter notebook server with the `tmtk` and `transmart`
packages and `transmart-copy` installed. 

## Configuration

| Variable                 | Description
|:------------------------ |:------------------------
| `TMTK_NOTEBOOK_PASSWORD` | Password used to protect the notebook server.


## Development

### Build and publish

```bash
# Build image
docker build -t "thehyve/tmtk-notebook-server" . --no-cache
```
