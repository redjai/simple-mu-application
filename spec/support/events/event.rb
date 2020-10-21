require 'json'
module MockEvent

  def self.event(**payloads)
    records = payloads.collect do |key, value|
      send("#{key}_record".to_sym, value)
    end
    { "Records"=> records }
  end

  def self.s3_record(payload)
    {"eventVersion"=>"2.1", 
     "eventSource"=>"aws:s3", 
     "awsRegion"=>"eu-west-1", 
     "eventTime"=>"2020-07-21T21:27:51.110Z", 
     "eventName"=>"ObjectCreated:Put", 
     "userIdentity"=> {"principalId"=>"AWS:AROASIA6L26QS6P56LWMA:importers-kanbanize-api-staging-get-board-settings"}, 
     "requestParameters"=>{"sourceIPAddress"=>"34.244.208.239"}, 
     "responseElements"=>{"x-amz-request-id"=>"07F9A2E72F522E37","x-amz-id-2"=>"RZfkJT+nojX9DKzrLkVtMOkuehPjEdZ0RaIpYi/2+KrRCFaupI6Y5pB/dMPcZON82AlMIXGSwiQUfwc3SQS7IeZMTELetLUS"},
     "s3"=>{
        "s3SchemaVersion"=>"1.0", 
        "configurationId"=>"importers-kanbanize-api-staging-extract-users-99eb10de078cd901fa0646c60032172a", 
        "bucket"=>{
          "name"=> payload[:bucket], 
          "ownerIdentity"=>{
            "principalId"=>"A35OZF3796S4YB"
          }, 
          "arn"=>"arn:aws:s3:::red-queen-importer-api-data-staging"
        }, 
        "object"=>{
          "key"=> payload[:key], 
          "size"=>6132, 
          "eTag"=>"bfbc387dc247e5e626cdaa9bdbe06f78", 
          "sequencer"=>"005F175DD7B4FD15F4"
        }
      }
    }
  end
  
  def self.sqs_record(payload)
    {"messageId"=>"059f36b4-87a3-44ab-83d2-661975830a7d", 
     "receiptHandle"=>"AQEBwJnKyrHigUMZj6rYigCgxlaS3SLy0a...", 
     "body"=>payload.to_json, 
     "attributes"=>{
       "ApproximateReceiveCount"=>"1", 
       "SentTimestamp"=>"1545082649183", 
       "SenderId"=>"AIDAIENQZJOLO23YVJ4VO", 
       "ApproximateFirstReceiveTimestamp"=>"1545082649185"
     }, 
     "messageAttributes"=>{}, 
     "md5OfBody"=>"e4e68fb7bd0e697a0ae8f1bb342846b3", 
     "eventSource"=>"aws:sqs", 
     "eventSourceARN"=>"arn:aws:sqs:us-east-2:123456789012:my-queue", 
     "awsRegion"=>"us-east-2"
    }
  end
  
  def self.sns_record(payload)
     {
       "EventSource"=>"aws:sns",
       "EventVersion"=>"1.0",
       "EventSubscriptionArn"=>"arn:aws:sns:eu-west-1:154682513313:created_tasks:573d222d-bce3-44e6-83e4-73fa8d2eb9cb",
       "Sns"=>{
         "Type"=>"Notification",
         "MessageId"=>"e13fc9d6-27ea-5200-aa51-9e585627df05",
         "TopicArn"=>"arn:aws:sns:eu-west-1:154682513313:created_tasks",
         "Subject"=>nil,
         "Message"=>payload.to_json, 
         "Timestamp"=>"2020-07-19T16:06:37.058Z", 
         "SignatureVersion"=>"1", 
         "Signature"=>"abc123", #normally a SHA-256 string
         "SigningCertUrl"=>"https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-a86cb10b4e1f29c941702d737128f7b6.pem", 
         "UnsubscribeUrl"=>"https://sns.eu-west-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-1:154682513313:created_tasks:573d222d-bce3-44e6-83e4-73fa8d2eb9cb",
         "MessageAttributes"=>{}
       }
    }
  end
end
