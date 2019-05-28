# URL Shortener

A Rails API web service for generating short links in the style of bit.ly.

### Running the Application
The easiest way to run this package is using the included Dockerfile.
The app will run on port 3000 in development mode.  The database is stock 
sqlite3, and the included test and development databases are migrated during
container build, but otherwise empty.

First, build the container.  Access to the public Docker Hub and Alpine package
repository are required, so a system with restricted Internet access might not
work.  Change to the project source root (the directory where `Dockerfile` 
resides) and run the following:

`docker build -t shortener .`

This will take a few minutes to complete. After, you can start the application
using the command below.  If you aren't familiar with Docker, this option set
will run the server interactively, outputting logs to the console, will
forward the container port to a public port on the local host, and will 
remove the container when it is terminated.

`docker run -it --rm -p 3000:3000 shortener`

Use `Ctrl+C` to kill the server.

### Running Unit Tests
Unit tests in RSpec are included, and can be run from the same docker container:

`docker run -it --rm shortener rsync --format documentation`

### Shortening a URL Using curl
Once the container is running, you can use curl to post a shortening request:

`curl -X POST -H "Content-Type: application/json" --data '{ "user_id": "me", "long_url": "http://www.google.com/" }' http://localhost:3000/short_link`

The output will look something like this:

`{"long_url":"http://www.google.com","short_link":"http://localhost:3000/k5b4Qlf7"}`

The `short_link` URL can then be used in a local browser as usual, and should
redirect to the `long_url`.

### Analytics
After generating a `short_link` URL, request the short link with a `+` at the
end as follows to retrieve an analytics structure tracking requests for that
short link:

e.g., `http://localhost:3000/k5b4Qlf7+`

As a tip to make the output more readable, which is especially convenient on a
Mac OS X system where python is installed by default, you can pretty-print
the JSON output like so:

`curl 'http://localhost:3000/k5b4Qlf7+' | python -m json.tool`