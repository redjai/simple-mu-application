module MockS3Event
    def self.event(args={})
      args[:bucket] = "red-queen-importer-api-data-staging" unless args[:bucket]
      {"Records"=>
        [
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
                "name"=> args[:bucket], 
                "ownerIdentity"=>{
                  "principalId"=>"A35OZF3796S4YB"
                }, 
                "arn"=>"arn:aws:s3:::red-queen-importer-api-data-staging"
              }, 
              "object"=>{
                "key"=> args[:key], 
                "size"=>6132, 
                "eTag"=>"bfbc387dc247e5e626cdaa9bdbe06f78", 
                "sequencer"=>"005F175DD7B4FD15F4"
              }
            }
          }
        ]}
    end
end
