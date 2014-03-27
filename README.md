continuously
=========

Spike to try and build a CI server based on Docker

This project should provide a server that accepts notifications from github and
triggers git clone and docker commands. The plan is to have everything checked
into the repository itself - the description of how the server should look, how
the tests should be run, and eventually how the system should be deployed.
The CI server itself should be standalone with almost no configuration whatsoever.

## Assumptions

* The code to be tested will be hosted on github (for ease of personal development, happy to accept PRs that add other notification sources)

* Dockerfile will be used per project to define the server configuration

* There will be a file that defines the entry points for testing, deployment and notifications (format TBD)

* The system will lean on standard deployment tools (ansible etc) for deployment where appropriate (ie. not building support in directly for this)

* The system will lean on standard test suite tools (language-specific) for testing (ie. not building support in directly for this)

* The system will test itself

## Potential Issues

* Typically when you're testing a service, you're able to run the service and
then run the tests on the same server. Docker containers run a little bit
differently. Need to consider what the right answer to this is, or if there's a
simple pattern that can be used to make this work.

* There's a challenge around dependencies and external requirements - need to
think that through. This is where Dockerfiles fall down a bit, too.

## Structure

* Vagrantfile and bootstrap.sh - exist to allow for creating a new server,
either in vbox or aws, with all the required software installed.
* dockerd/ - contains a Docker-in-Docker image definition. This is the docker
"server" that will be used to create new containers for testing - thus keeping
everything self-contained.
* <TBD>/ - a container with the web server, which takes push notifications and
triggers git checkouts and builds.
* <TBD.yml?> - definition file that describes how to link the containers
together and what to run for testing.

## Notes

If you're on OS X and have no docker vbox (ie. no dvm or boot2docker), or you're
on some other system and want to constrain your docker testing, you can use
the Vagrantfile in this project to create a new vbox (or aws server) with all
the required things installed.

If you have an ubuntu server already and just need to install this package, then
you can run `./bootstrap.sh` from this project to install all the requirements,
including docker.

To run the server for development locally using ngrok:

Terminal 1:
  fig up

Terminal 2:
	ngrok 5000

Update github.com to have the new forwarding address as the webhook
(Settings -> Webhooks) for whichever project you're testing with. The
destination address should look something like:

  https://799c744f.ngrok.com/github/

Make sure you've set the Payload version to be json

Once you've sent a notification (pushed something), you can replay that as many
times as you like with ngrok for testing purposes.
