FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS build
ARG build_config=Release
WORKDIR /app

# copy csproj files
COPY *.sln .
COPY Host/*.csproj ./Host/
COPY Test/*.csproj ./Test/
RUN dotnet restore

# copy rest of files
COPY Host/. ./Host/
COPY Test/. .Test/
RUN dotnet build --no-restore -c ${build_config}

# unit tests
FROM build AS unit-tests
WORKDIR /app/Test/
ENTRYPOINT ["dotnet", "test", "--no-restore", "--logger", "\"xunit;LogFilePath=../../TestResults/unit-tests.xml\"]

# publish
FROM build AS publish
ARG build_config=Release
WORKDIR /app/Host
RUN dotnet publish --no-build -c ${build_config} -o out

# run
FROM mcr.microsoft.com/dotnet/core/aspnet:3.0 AS runtime
WORKDIR /app
COPY --from=publish /app/Host/out ./
ENTRYPOINT ["dotnet", "Host.dll"]

