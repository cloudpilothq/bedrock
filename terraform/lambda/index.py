import json
import urllib.parse
import boto3

print('Loading function')

def lambda_handler(event, context):
    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        print(f"Image received: {key} in bucket: {bucket}")
        return {
            'statusCode': 200,
            'body': json.dumps(f"Successfully processed {key}")
        }
    except Exception as e:
        print(e)
        print(f"Error getting object {key} from bucket {bucket}.")
        raise e
