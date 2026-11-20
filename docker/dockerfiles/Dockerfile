# -----------------------------------------------
#                   Base image
# -----------------------------------------------

FROM python:3.12-slim-trixie AS base

ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1

# Working directory
WORKDIR /app

# Minimun dependencies
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    curl \
    git

# Installing UV   
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# -----------------------------------------------
#                     Builder 
# -----------------------------------------------

FROM base AS builder

WORKDIR /app

# Copying uv project settings with python dependencies
COPY pyproject.toml uv.lock ./

# Create virtual environment with dependencies first
RUN uv sync --no-install-project

# Copying project
COPY src ./src
COPY README.md .
# Installing own packages
RUN uv sync

# -----------------------------------------------
#                     Runtime 
# -----------------------------------------------

FROM base AS runtime

WORKDIR /app

COPY --from=builder /app /app/

ENV PATH="/app/.venvbin:$PATH"

EXPOSE 8888

CMD ["uv","run", "jupyter", "lab",\
    "--ip=0.0.0.0","--no-browser", \
    "--allow-root","--NotebookApp.token="]

# -----------------------------------------------