# Simple::Mu::Application

## Introduction

This is a lightweight and opinionated framework that simplifies the building and testing of Ruby event driven applications that run in serverless frameworks. 

It's opinionated in that it assumes the Lambdas in any given framework function by listening to message queues that represent topics such as 'users', 'orders'. Events are emitted onto those topics (typically by other lambdas) such as 'user.created', 'order.cancelled'. Any topic can have a number of lambdas listening for the events emitted onto the topic. Listening Lambdas processes that event which, in turn, broadcasts further messages onto topics as appropriate.

The framework can receive events directly from notifications such as AWS S3, DynamoDB or HTTP but only broadcast to SNS. The framework assumes that meaningful application events are always broadcast to topics - typically components in the system won't be connected via, say, AWS S3 or DynamoDB event notifications. This assumption provides us with both a consistent AND a robust platform as events received from a queue can stay on that queue should there be a system error at some point. Errors generated from S3 or DynamoDB events are harder to manage meaningfully.

## The Framework

The class `Simple::Mu::Application::Service` will convert inbound AWS events into common adapters with payloads and yield each adapter in turn to a block via it's handle method:

    Simple::Mu::Application::Service.new(aws_event, context).handle do |service, adapter|
      # do something here    
    end    

### 1. Before the handle method is called:

#### Adapters

Abstract inbound events from http, s3, sns and sqs events into common events. The data in each adapter is exposed as adapter.event.

Sqs & Sns adapter events look like this:

    { event_name: 'some.event', version: 1.0, payload: { foo: 1, bar: 2} }
    
S3 adapter events look like this:

    { key: 'some/key', bucket: 'some_bucket' }
    
Http adapter events look like this:

    { foo: 1, bar: 2 } # whatever post data was posted.


Remember that only Sqs events are considered first class citizens in our framework. 

### 2. During the handle method

#### Broadcasters

Can be called to send events to topics:

```
service.broadcast('messages', 'message.created', 1.0) do |payload| 
                        payload[:channel] = '1234' 
                        payload[:text] = 'hello world'
                      end
```

Typically we would want to append any new values in out lambda to existing ones received from previous events so:

```
service.broadcast('messages', 'message.created', 1.0, adapter.payload) do |payload| 
                        payload[:channel] = '1234' 
                        payload[:text] = 'hello world'
                      end
```
If our lambda is responding to an event that has the payload { user: 123 } the above method call will append the values for :channel and :text onto the payload and broadcast the payload { user: 123, channel: '1234', text: 'hello world' }

#### Registry

Before a broadcaster sends an event to a topic the structure of that payload is validated against an event payload template in the Registry. 

    Registry.register('some_topic', 'some.event', 1.0, foo: :string!, bar: string) 

The event topic/event_name/version is **required to have a key/value foo:** that is a string and an **optional key/value bar:** that is also a string. If either are not strings or the event payload has keys that are not foo: or bar: then a RegistryError will be raised.

Template values can be:

```
    string, string!, numeric, numeric!, array, array!, hash, hash! 
```
The Registry does NOT do a deep validation of hashes.

### 3. After the handle method


#### Acknowledger

The Framework handles multiple events per lambda invocation, should **some** of those events error then the **acknowledger**  will remove the successfully processed events from the message queue they came from so they are not repeated. 

#### Notifier

Will send any errors to a suitable framework such as Honeybadger when in production or console in development/test mode.

#### The Happy Path

Should all events be processed without errors then the **Acknowledger** is NOT invoked and the events are seamlessly removed from the queue by AWS without us explicitly deleting them.

## A Sample Application

Let's use the gem to create a very simple slack bot that tells the user the time when requested. Of course we could handle a trivial task such as responding with the time in a single lambda but this gem is written to simplify the building of distributed serverless applications so let's distribute this app. All of the code  and configurations are available at **[GITHUB REPO]**


To do this we'll create three lambdas:

1. The Gateway Lambda listens for HTTP events from Slack and broadcasts that event to a Messages topic.
1. The Timebot Lambda listens for events on the Messages topic, fetches the time and writes that to a Times topic.
1. The Responder Lambda listens for events on the Times topic and writes the response (the time) back to the channel in Slack that requested it.

## The Gateway Lambda

The Gateway lambda listens for events from an http endpoint set up by AWS such as `https://xyz12345.execute-api.eu-west-1.amazonaws.com/staging/gateway`. When a Slack user Direct Messages the bot or mentions `@timebot` in a channel the Slack Event API will send this event to the http endpoint. 

The Gateway will then broadcast that a 'message.created' event has occurred onto the sns/sqs topic 'Messages' along with details of that message such as the text and id of the channel and user that it came from. It's worth noting that slack messages can also be updated and deleted, 'message.updated' and 'message.deleted' events will also be broadcast to the Messages topic and the listeners downstream can decide if/what they do with those events.

### AWS Http Event

AWS Events contain a lot of contextual information we don't need so I've removed much of the data.

```
{ 
  "resource"=>"/gateway",
  "path"=>"/gateway", 
  "httpMethod"=>"POST", 
  "headers"=>{
    ...
  }, 
  "multiValueHeaders"=>{
    ...
  }, 
  ..., 
  "requestContext"=>{
     ....
  }, 
  "domainName"=>"...", 
    "apiId"=>"..."
  }, 
  "body"=> "{\"token\":\"ZZZZZZWSxiZZZ2yIvs3peJ\",\"team_id\":\"T061EG9R6\",\"api_app_id\":\"A0MDYCDME\",\"event\":{\"type\":\"app_mention\",\"user\":\"U061F7AUR\",\"text\":\"What's the time ?\",\"ts\":\"1515449522.000016\",\"channel\":\"C0LAN2Q65\",\"event_ts\":\"1515449522000016\"},\"type\":\"event_callback\",\"event_id\":\"Ev0LAN670R\",\"event_time\":1515449522000016,\"authed_users\":[\"U0LAN0Z89\"]}", 
  "isBase64Encoded"=>false
}
```

### The Slack Event

The AWS Event "body" above contains the Slack Event which looks like this when unpacked into ruby by the gem's HTTP Adapter:

```
{ 
  "token"=>"ZZZZZZWSxiZZZ2yIvs3peJ", 
  "team_id"=>"T061EG9R6",
  "api_app_id"=>"A0MDYCDME",
  "event"=>{
    "type"=>"app_mention",
    "user"=>"U061F7AUR",
    "text"=>"What is the hour of the pearl, <@U0LAN0Z89>?", 
    "ts"=>"1515449522.000016", 
    "channel"=>"C0LAN2Q65", 
    "event_ts"=>"1515449522000016"
  }, 
  "type"=>"event_callback", 
  "event_id"=>"Ev0LAN670R", 
  "event_time"=>1515449522000016, 
  "authed_users"=>["U0LAN0Z89"]
 }

```

### The Lambda Code

```
def self.handle(aws_event:, context:)
  Simple::Mu::Application::Service.new(aws_event, context).handle do |service, adapter|
    service.broadcast('messages', 'message.created', 1.0) do |payload| 
                        payload[:channel] = adapter.payload['event']['channel'] 
                        payload[:text] = adapter.payload['event']['text']
                      end
    service.respond { statusCode: 200, body: "Just checking the time for you now, wait a moment please....", headers: {"content-type" => "text/plain"} }
  end
end
```

### What just happened there ?

1. The lambda receives the HTTP event.   
1. Simple::Mu::Application::Service wraps the rest in an HTTP adapter that exposes the payload (as well as other pertinent http values).
1. The adapter is passed to the block in `Service.new(aws_event, context).handle`
1. The broadcaster sends a message to the SNS topic 'Messages', BEFORE the message is sent it checks the message structure against its registry. To be valid, the message must have been added to the Registry thus:

```
    Registry.register('messages', 'message.received', 1.0, text: :string!, channel: string!) 
```

The registry could be defined in this lambda but will typically be defined in an application wide gem that will be bundled with all lambdas so that all messages are registered in one place. We could also download and set the Registry from a common yaml file stored in, say, AWS S3 but that may have performance implications.

## The Timebot Lambda
This Lambda simply fetches the current time and broadcasts that to a topic "Times". Our lambda has a fundamental flaw in the code in that raises an error if the user does not include the lower case word 'time' in the text. A better coded lambda would broadcast to a "BadRequest" topic and let the application deal with gracefully. We can use this flaw to demonstrate the gem's error handling.  


### The AWS Event

Let's assume our Timebot is popular. It's listening to an SQS queue that is part of the 'Messages' SNS/SQS topic and it's quite possible that our Lambda will get invoked by an AWS event with multiple 'events' (Records)

```
    "Records" => [
      {"messageId"=>"...", 
        "receiptHandle"=>"...", 
        "body"=>"{\"text\":\"what's the time ?\",\"channel\":\"C0LAN2Q65\"}", 
        "attributes"=>{
          ....
        }, 
        "messageAttributes"=>{}, 
        "md5OfBody"=>"...", 
        "eventSource"=>"aws:sqs", 
        "eventSourceARN"=>"arn:aws:sqs:us-east-2:123454321:messages-queue", 
        "awsRegion"=>"xx-xxxx-x"
      },
      {"messageId"=>"...", 
        "receiptHandle"=>"...", 
        "body"=>"{\"text\":\"what's the TIME ?\",\"channel\":\"C0LAN2Q65\"}", 
        "attributes"=>{
          ....
        }, 
        "messageAttributes"=>{}, 
        "md5OfBody"=>"...", 
        "eventSource"=>"aws:sqs", 
        "eventSourceARN"=>"arn:aws:sqs:us-east-2:123454321:messages-queue", 
        "awsRegion"=>"xx-xxxx-x"
      },
      {"messageId"=>"...", 
        "receiptHandle"=>"...", 
        "body"=>"{\"text\":\"Hello what time is it ?\",\"channel\":\"C0LAN2Q65\"}",  
        "attributes"=>{
          ....
        }, 
        "messageAttributes"=>{}, 
        "md5OfBody"=>"...", 
        "eventSource"=>"aws:sqs", 
        "eventSourceARN"=>"arn:aws:sqs:us-east-2:123454321:messages-queue", 
        "awsRegion"=>"xx-xxxx-x"
      }
    ]
```

### The Lambda Code

```
def self.handle(aws_event:, context:)
  Simple::Mu::Application::Service.new(aws_event, context).handle do |service, adapter|
    raise "time is not in text" unless adapter.payload['text'].include?('time')
    service.broadcast('Times', 'time.created', 1.0, adapter.payload) do |payload|
                        payload[:time] = Time.now.strftime('%T')
                      end
  end
end
```

### What just happened there ?
The aws_event contains three Records (or events to us). 

Each event is converted into an `SQSRecord` adapter and passed, in turn, to the block in `Service.new(aws_event, context).handle |service, adapter|`.

If the code does not raises an error while processing the adapter it flags the adapter as **processed**. 

If the code raises an error while passing through the handler the **notifier** is called (this could write to local console or to an error monitoring system such as Honeybadger.io) and the adapter is flagged as **errored**.

Once all adapters have been passed to the handler, if any are flagged as **errored** then every adapter that is flagged as **processed** is passed to the **acknowledger** where its messageId and receiptHandle are used to delete that record from the SQS queue so they are not retried. The service will also respond to AWS with an error so the SQS messages that caused the error stay in the queue for retry.

If no errors occur in any of the handlers **THE ACKNOWLEDGER IS NOT CALLED** SQS will simply delete all of the records passed to the lambda if it does not raise any errors.


## The Responder Lambda

The Responder Lambda listens for events on an SQS queue on the Times topic. When an event occurs it uses the channel provided in the event to write the time back to the Slack channel where the user asked @timebot for the time.

### The AWS Event

Let's assume the two events in the Timebot above that didn't error are passed to the Responder lambda as one event. That is an assumption as there is no guarantee from AWS how it passes records from SQS to lambdas.


```
    "Records" => [
      {"messageId"=>"...", 
        "receiptHandle"=>"...", 
        "body"=>"{\"text\":\"what's the time ?\",\"channel\":\"C0LAN2Q65\",\"time\":\"14:54:14\"}", 
        "attributes"=>{
          ....
        }, 
        "messageAttributes"=>{}, 
        "md5OfBody"=>"...", 
        "eventSource"=>"aws:sqs", 
        "eventSourceARN"=>"arn:aws:sqs:us-east-2:123454321:messages-queue", 
        "awsRegion"=>"xx-xxxx-x"
      },
      {"messageId"=>"...", 
        "receiptHandle"=>"...", 
        "body"=>"{\"text\":\"Hello what time is it ?\",\"channel\":\"C0LAN2Q65\",\"time\":\"14:54:15\"}",  
        "attributes"=>{
          ....
        }, 
        "messageAttributes"=>{}, 
        "md5OfBody"=>"...", 
        "eventSource"=>"aws:sqs", 
        "eventSourceARN"=>"arn:aws:sqs:us-east-2:123454321:messages-queue", 
        "awsRegion"=>"xx-xxxx-x"
      }
    ]
```

### The Lambda Code

```
def self.handle(aws_event:, context:)
  Simple::Mu::Application::Service.new(aws_event, context).handle do |service, adapter|
    payload = adapter.payload
    api.post('chat.postMessage', { channel: payload['channel'], message: payload['time'] }.to_json) 
  end
end

def self.api
  Faraday.new(
    url: "https://slack.com/api/",
    headers: {
      'Content-Type' => 'application/json',
      'Accepts' => 'text/plain',
      'Authorization' => "Bearer #{token}"
    }) do |api|
      api.use Faraday::Response::RaiseError
      api.adapter Faraday.default_adapter
   end
end

def self.token
  ENV['SLACK_TOKEN_OUT']
end

```

### What just happened ?

Each event is converted into an `SQSRecord` adapter and passed, in turn, to the block in `Service.new(aws_event, context).handle |service, adapter|`.

The payload for each adapter was used to send a message (the time) back to the user via the Slack API.

The lambda call returned without errors and AWS seamlessly removed the events from the SQS queue.     


Assume we have a lambda listening to an SQS queue bound to the messages topic. Our lambda above will generate a message that looks something like this. 

```
    "Records" => [
       {"messageId"=>"...", 
        "receiptHandle"=>"...", 
        "body"=>"{\"message\":\"hello\",\"channel\":\"C123\",\"uid\":\"u234\"}", 
        "attributes"=>{
          ....
        }, 
        "messageAttributes"=>{}, 
        "md5OfBody"=>"...", 
        "eventSource"=>"aws:sqs", 
        "eventSourceARN"=>"arn:aws:sqs:us-east-2:123454321:messages-queue", 
        "awsRegion"=>"xx-xxxx-x"
    }]
```

If we also assume two other people sent messages at the same time - through different http lambda event invocations - the event that comes from the SQS queue will look more like this:

```
    "Records" => [
      {"messageId"=>"...", 
        "receiptHandle"=>"...", 
        "body"=>"{\"message\":\"hello\",\"channel\":\"C123\",\"uid\":\"u234\"}", 
        "attributes"=>{
          ....
        }, 
        "messageAttributes"=>{}, 
        "md5OfBody"=>"...", 
        "eventSource"=>"aws:sqs", 
        "eventSourceARN"=>"arn:aws:sqs:us-east-2:123454321:messages-queue", 
        "awsRegion"=>"xx-xxxx-x"
      },
      {"messageId"=>"...", 
        "receiptHandle"=>"...", 
        "body"=>"{\"message\":\"hi there\",\"channel\":\"C234\",\"uid\":\"u456\"}", 
        "attributes"=>{
          ....
        }, 
        "messageAttributes"=>{}, 
        "md5OfBody"=>"...", 
        "eventSource"=>"aws:sqs", 
        "eventSourceARN"=>"arn:aws:sqs:us-east-2:123454321:messages-queue", 
        "awsRegion"=>"xx-xxxx-x"
      },
      {"messageId"=>"...", 
        "receiptHandle"=>"...", 
        "body"=>"{\"message\":\"HI...???\",\"channel\":\"C789\",\"uid\":\"u567\"}", 
        "attributes"=>{
          ....
        }, 
        "messageAttributes"=>{}, 
        "md5OfBody"=>"...", 
        "eventSource"=>"aws:sqs", 
        "eventSourceARN"=>"arn:aws:sqs:us-east-2:123454321:messages-queue", 
        "awsRegion"=>"xx-xxxx-x"
      }
    ]
```

- - - - - - - - - - - - 
     

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/simple/mu/application`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple-mu-application'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install simple-mu-application

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/simple-mu-application. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/simple-mu-application/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Simple::Mu::Application project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/simple-mu-application/blob/master/CODE_OF_CONDUCT.md).
