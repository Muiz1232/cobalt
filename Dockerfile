# Base image with Node.js for Windows Server
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS base

# Set environment variables
ENV PNPM_HOME="C:\\pnpm"
ENV PATH="%PNPM_HOME%;%PATH%"

# Install Node.js and PNPM
RUN powershell -Command \
    Invoke-WebRequest -Uri https://nodejs.org/dist/v23.0.0/node-v23.0.0-x64.msi -OutFile nodejs.msi; \
    Start-Process msiexec.exe -ArgumentList '/i nodejs.msi /quiet' -NoNewWindow -Wait; \
    Remove-Item -Force nodejs.msi; \
    npm install -g corepack && corepack enable

# Install Python and build tools for Windows
RUN powershell -Command \
    Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.10.9/python-3.10.9-amd64.exe -OutFile python-installer.exe; \
    Start-Process python-installer.exe -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -NoNewWindow -Wait; \
    Remove-Item -Force python-installer.exe; \
    npm install --global --production windows-build-tools

# Build stage
FROM base AS build
WORKDIR C:\\app

# Copy source code
COPY . C:\\app

# Install dependencies with PNPM
RUN pnpm install --prod --frozen-lockfile

# Deploy application (adjust for your structure)
RUN pnpm deploy --filter=@imput/cobalt-api --prod C:\\prod\\api

# Final runtime stage
FROM base AS api
WORKDIR C:\\app

# Copy the built application
COPY --from=build C:\\prod\\api C:\\app

# Expose the application port
EXPOSE 9000

# Set the command to run the app
CMD ["node", "src\\cobalt"]
