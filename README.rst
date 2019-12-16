Minimalist Python Docker Setup
==============================


Goals
~~~~~

This repo had several requirements:

* Shouldn't run container as root user
* Shouldn't include unnecessary libraries in final container
* Should be simple and easy to understand

To accomplish this, we use a multi-stage build. First, we install all
requirements which requires GCC for building C libraries (in this example,
uWSGI). Then, we use a second smaller image that copies the files over from the
first image.

See the `Dockerfile` for more detailed inline documentation


Running this
~~~~~~~~~~~~

::
	
	$ docker build -t dockertest .
	$ docker run -p 5000:5000 dockertest

To confirm, visit http://127.0.0.1:5000/ and check for the "Hello, World!"
