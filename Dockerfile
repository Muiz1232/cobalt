# Use a Windows-based Node image
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS base

# Set environment variables
ENV PNPM_HOME="C:\\pnpm"
ENV PATH="$PNPM_HOME;C:\\Program Files\\nodejs;C:\\Windows\\System32;$PATH"

# Install pnpm globally using npm (since Alpine-specific tools won't work on Windows)
RUN powershell -Command \
    Invoke-WebRequest -Uri https://get.pnpm.io/v6.7.0/install.powershell -OutFile "install-pnpm.ps1"; \
    .\\install-pnpm.ps1; \
    Remove-Item -Force install-pnpm.ps1

# Build stage
FROM base AS build
WORKDIR C:/app

# Copy your project files to the container
COPY . C:/app

# Enable Corepack for pnpm
RUN corepack enable

# Install Python and build dependencies for Windows
RUN choco install python --version=3.9.6 -y && \
    npm install --global --production --no-frozen-lockfile

# Install dependencies with pnpm
RUN pnpm install --prod --frozen-lockfile

# Deploy the application
RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

# Final stage (for serving API)
FROM base AS api
WORKDIR C:/app

# Copy the API artifacts from the build stage
COPY --from=build C:/prod/api C:/app
COPY --from=build C:/app/.git C:/app/.git

# Expose the port that the app will listen on
EXPOSE 9000

# Define the entry point to start the application
CMD [ "node", "src\\cobalt" ]
