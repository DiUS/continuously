continuously
=========

Spike to try and build a CI server based on Docker

This project should provide a server that accepts notifications from github and triggers git clone and docker commands. The plan is to have everything checked into the repository itself - the description of how the server should look, how the tests should be run, and eventually how the system should be deployed. The CI server itself should be standalone with almost no configuration whatsoever.

## Assumptions

* The code to be tested will be hosted on github (for ease of personal development, happy to accept PRs that add other notification sources)

* Dockerfile will be used per project to define the server configuration

* There will be a YAML file that defines the entry points for testing, deployment and notifications

* The system will lean on standard deployment tools (ansible etc) for deployment

* The system will lean on standard test suite tools (language-specific) for testing

* The system will test itself

## Potential Issues

* Typically when you're testing a service, you're able to run the service and then run the tests on the same server. Docker containers run a little bit differently. Need to consider what the right answer to this is, or if there's a simple pattern that can be used to make this work.

* There's a challenge around dependencies and external requirements - need to think that through. This is where Dockerfiles fall down a bit, too.

* To test, this all needs to be able to run in a container itself.

## Notes

To run the server for development locally using ngrok:

Terminal 1:
	docker run -p 3000:3000 -v /vagrant/docker/continuously/continuously:/opt/continuously -i -t continuously

Terminal 2:
	ngrok 3000

Update github.com to have the new forwarding address as the webhook (Settings -> Webhooks) for whichever project you're testing with. The destination address should look something like:

  https://799c744f.ngrok.com/github/

Make sure you've set the Payload version to be json

Once you've sent a notification (pushed something), you can replay that as many times as you like with ngrok for testing purposes.

## Quickstart:

docker run -p 3000:3000 -d --privileged silarsis/continuously
