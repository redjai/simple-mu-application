require 'json'
module MockAwsEvent

  def self.sns_event(rq_event)
    {"Records"=>
       [
         {
           "EventSource"=>"aws:sns",
           "EventVersion"=>"1.0",
           "EventSubscriptionArn"=>"arn:aws:sns:eu-west-1:154682513313:created_tasks:573d222d-bce3-44e6-83e4-73fa8d2eb9cb",
           "Sns"=>{
             "Type"=>"Notification",
             "MessageId"=>"e13fc9d6-27ea-5200-aa51-9e585627df05",
             "TopicArn"=>"arn:aws:sns:eu-west-1:154682513313:created_tasks",
             "Subject"=>nil,
             "Message"=>rq_event.to_json, 
             "Timestamp"=>"2020-07-19T16:06:37.058Z", 
             "SignatureVersion"=>"1", 
             "Signature"=>"abc123", #normally a SHA-256 string
             "SigningCertUrl"=>"https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-a86cb10b4e1f29c941702d737128f7b6.pem", 
             "UnsubscribeUrl"=>"https://sns.eu-west-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-1:154682513313:created_tasks:573d222d-bce3-44e6-83e4-73fa8d2eb9cb",
             "MessageAttributes"=>{}
           }
        }
      ]
    }
  end

  def self.activities(rq_event, args={})
    folder = args[:folder] || "import/activities/year=2020/day=231/client_id=test.client/board_id=17"
    client_id = args[:client_id] || 'test.client'
    board_id = args[:board_id] || "17"
    date = args[:date] || "2020-08-18"
    sns_event(rq_event, { "client_id"=>client_id, "board_id"=>board_id, "date"=>date, "folder"=>folder })
  end

  def self.tasks(args={})
    key = args[:key] || "import/tasks/year=2020/day=231/client_id=test.client/board_id=17/tasks.json"
    client_id = args[:client_id] || 'test.client'
    board_id = args[:board_id] || "17"
    date = args[:date] || "2020-08-18"
    sns_event({ "client_id"=>client_id, "board_id"=>board_id, "date"=>date, "key"=>key })
  end
end
