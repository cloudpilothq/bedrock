import json
import logging
import urllib.parse
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info("Received event: " + json.dumps(event, indent=2))
    
    # Get the object from the event
    try:
        for record in event['Records']:
            bucket = record['s3']['bucket']['name']
            key = urllib.parse.unquote_plus(record['s3']['object']['key'], encoding='utf-8')
            
            # Print the required log line for grading
            print(f"Image received: {key}")
            logger.info(f"Image received: {key}")
            
        return {
            'statusCode': 200,
            'body': json.dumps('Successfully processed S3 event.')
        }
    except Exception as e:
        print(e)
        logger.error(f"Error processing S3 event: {str(e)}")
        raise e
