# Glowing Bear Docker plan


## Overview

*Bundles*:
- Glowing Bear and backends
- Transmart Packer (exports)
- Keycloak (identity management)
- Data loading / data slicing / Data warehouse inventory system

*To describe per bundle*:
- Components
- Connections between components
- Configuration by environment variables

*To describe per component*:
- Purpose
- Technology used
- Volumes for state
- Configuration variables
- Logging (to stdout)
- Adaptations to existing tools that are required
- Further details

*Deployments of JVM applications*: fetch artefacts (.jar) from Nexus and run.
If Docker is used to create the artefacts, a separate Docker file is used for that process.

*SSL certificates*: possibly using Let’s Encrypt or by passing an existing key pair, or locally generated self-signed certificates.

*How to organise Dockerfile and docker-compose scripts*:
- Preferably a Dockerfile per component in its own repository, published to Docker Hub (https://cloud.docker.com/u/thehyve/repository/list; this needs some cleaning up) or Bintray
- docker-compose scripts for:
  - Transmart Packer
  - GB backend + database
  - Transmart API server + database
- docker-compose script for the Glowing Bear + backends



## Glowing Bear and backends bundle


### transmart-database

Purpose:
Database server for Transmart backend

Technology:
- PostgreSQL server (`FROM postgres:11-alpine`)
- `pg_bitcount` extension

Volumes:
- standard volume inherited from postgresql


### transmart-api-server

Purpose:
Run the Transmart API server application, initialise / migrate database schema for Transmart

Technology:
- Java Runtime Environment (FROM openjdk:8-jre-alpine)
- Liquibase

Depends on:
- `transmart-database`

Configuration:
- Keycloak parameters

Further details:
- Database schema creation and schema updates via Liquibase, at startup of the container. As a starting point, liquibase generateChangeLog can be used for creating the changelogs based on an existing database schema.


### gb-backend-database

Purpose:
Database server for Glowing Bear backend

Technology:
- PostgreSQL server (`FROM postgres:11-alpine`)

Volumes:
- standard volume inherited from postgresql


### gb-backend

Purpose:
Run the Glowing Bear backend application (jar)

Technology:
Java Runtime Environment (`FROM openjdk:8-jre-alpine`)

Depends on:
- `gb-backend-database`
- `transmart-api-server`

Configuration:
- Keycloak parameters


### transmart-packer

See [Transmart Packer bundle](#transmart-packer-bundle)

Configuration:
- Keycloak parameters


### glowing-bear

Purpose:
Serve the static content for the frontend application with suitable configuration and proxy API calls to backend components

Technology:
- nginx web server (`FROM nginx:alpine`)

Configuration:
- Keycloak parameters

Further details:
- The nginx server should redirect calls to `/api/{servicename}` to the backend service components.
- The Glowing Bear configuration should be overridden to configure this behaviour.



## Transmart Packer bundle

See [thehyve/transmart-packer](https://github.com/thehyve/transmart-packer/blob/master/docker-compose.yml).


### redis

Purpose: store information about export jobs


### transmart-packer-worker

Purpose: Run transmart-packer jobs

Technology:
- Python 3.6 (`FROM python:3.6-slim`)

Depends on:
- `redis`


### transmart-packer-webapp

Purpose:
Run the transmart-packer web application

Technology:
- Python 3.6 (`FROM python:3.6-slim`)

Depends on:
- `redis`



## Keycloak

jboss/keycloak



## Data loading, slicing, data warehouse inventory

To be determined

