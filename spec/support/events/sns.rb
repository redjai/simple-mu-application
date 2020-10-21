require 'json'
module MockSnsEvent

  def self.event(*payloads)
    {"Records"=>
      payloads.collect do |payload|
        record(payload)
      end
    }
  end

  def self.record(payload)
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
