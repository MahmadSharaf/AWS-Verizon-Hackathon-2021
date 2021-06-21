import boto3
import json

print('Loading function')
dynamo = boto3.client('dynamodb')
sns_client = boto3.client('sns')
platformArn = 'arn:aws:sns:us-east-1:367176934720:app/GCM/wild_life_app'
# import paramiko
# ec2 = boto3.resource('ec2')
# def startStream():
#     running_instances = ec2.instances.filter(Filters=[{'Name': 'instance-id','Values': ['Add your instance id']}])
#     for instance in running_instances:
#     	    host = instance.public_ip_address
    
#     k = paramiko.RSAKey.from_private_key_file("/tmp/Add your key name.pem")
#     c = paramiko.SSHClient()
#     c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#     print("Connecting to " + host)
#     c.connect( hostname = host, username = "ubuntu", pkey = k )
#     print("Connected to " + host)
#     commands = ["/home/ubuntu/demo.sh"]
#     for command in commands:
#     		print("Executing {}".format(command))
#     		stdin , stdout, stderr = c.exec_command(command)
#     		print(stdout.read())
#     		print(stderr.read())

def respond(err, res=None):
    return {
        'statusCode': '400' if err else '200',
        'body': err.message if err else json.dumps(res),
        'headers': {
            'Content-Type': 'application/json',
        },
    }

def tokenHandler(deviceToken):
    tokenExists = 0
    nextPage = 1
    # Get Endpoints and Endpoints attributes for devices 
    subscribers = sns_client.list_endpoints_by_platform_application(PlatformApplicationArn=platformArn)
    subscribersEndpoint = subscribers['Endpoints']
    # Loop through pages
    while nextPage:
        # Loop through available Endpoints
        for subscriber in subscribersEndpoint:
            # Check if the device token already exist
            if deviceToken == subscriber['Attributes']['Token']:
                # If existing, get the stored EndpointArn.
                tokenExists = 1
                print('Device Token already existing')
                # Since we don't store endpoints, we will just retrieve as below. But that is not the best practice according the documetnation https://docs.aws.amazon.com/sns/latest/dg/mobile-platform-endpoint.html
                # endpointArn = sns_client.create_platform_endpoint(PlatformApplicationArn=platformArn, Token=deviceToken)
                return
        try:
            # If `list_endpoints_by_platform_application` returned NextToken, then there is another page with up to 100 items
            nextPage = subscribers['NextToken']
            # print('There is another page')
        except:
            nextPage = 0
            # print('No more pages')
    # If device token doesn't exist, create a new Endpoint
    if tokenExists == 0:
        endpointArn = sns_client.create_platform_endpoint(PlatformApplicationArn=platformArn, Token=deviceToken)
        print('Created EndpointArn:', endpointArn)
        return endpointArn

def lambda_handler(event, context):
    '''Demonstrates a simple HTTP endpoint using API Gateway. You have full
    access to the request and response payload, including headers and
    status code.

    To scan a DynamoDB table, make a GET request with the TableName as a
    query string parameter. To put, update, or delete an item, make a POST,
    PUT, or DELETE request respectively, passing in the payload to the
    DynamoDB API as a JSON body.
    '''
    
    if event['httpMethod'] == 'GET':
        if event['queryStringParameters']['stream'] == 'start':
            if event['queryStringParameters']['token']:
                deviceToken = event['queryStringParameters']['token']
                print('Platform:', event['queryStringParameters']['platform'])
                tokenHandler(deviceToken)
            if event['queryStringParameters']['cameraUrl']:
                cameraUrl = event['queryStringParameters']['cameraUrl']
            
                print('Stream Started')
            return respond(None, 'Streaming started')
        elif event['queryStringParameters']['stream'] == 'stop':
            print('Stream Stopped')
            return respond(None, 'Streaming stopped')
    
    

    # operations = {
    #     # 'DELETE': lambda dynamo, x: dynamo.delete_item(**x),
    #     'GET': lambda dynamo, x: dynamo.scan(**x),
    #     # 'POST': lambda dynamo, x: dynamo.put_item(**x),
    #     # 'PUT': lambda dynamo, x: dynamo.update_item(**x),
    # }

    # operation = event['httpMethod']
    # if operation in operations:
    #     payload = event['queryStringParameters'] if operation == 'GET' else json.loads(event['body'])
    #     return respond(None, operations[operation](dynamo, payload))
    # else:
    #     return respond(ValueError('Unsupported method "{}"'.format(operation)))
