import json
import boto3
import os

ses_client = boto3.client('ses')
SENDER_EMAIL = os.environ.get('SENDER_EMAIL')

def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event)}")

    if not SENDER_EMAIL:
        print("Error: SENDER_EMAIL environment variable is not set.")
        return {'statusCode': 500, 'body': 'SENDER_EMAIL is not configured'}

    for record in event['Records']:
        try:
            if record['eventName'] == 'INSERT':
                new_image = record['dynamodb']['NewImage']
                user_name = new_image['name']['S']
                user_email = new_image['email']['S']

                print(f"New user: {user_name} ({user_email}). Sending welcome email...")

                subject = f"Welcome to our system, {user_name}!"
                body_text = (f"Hello, {user_name}!\n\n"
                             f"Thank you for registering. We are happy to see you here.\n\n"
                             f"Best regards,\n"
                             f"Your Team")

                response = ses_client.send_email(
                    Source=SENDER_EMAIL,
                    Destination={'ToAddresses': [user_email]},
                    Message={
                        'Subject': {'Data': subject, 'Charset': 'UTF-8'},
                        'Body': {'Text': {'Data': body_text, 'Charset': 'UTF-8'}}
                    }
                )

                print(f"Welcome email sent successfully. Message ID: {response['MessageId']}")

            elif record['eventName'] == 'REMOVE':
                old_image = record['dynamodb']['OldImage']
                user_name = old_image['name']['S']
                user_email = old_image['email']['S']

                print(f"User deleted: {user_name} ({user_email}). Sending farewell email...")

                subject = f"We're sorry to see you go, {user_name}"
                body_text = (f"Hello, {user_name}!\n\n"
                             f"We've seen that you deleted your account. We are very sorry that you are leaving us.\n\n"
                             f"If you have a moment, please let us know what we could have done better.\n\n"
                             f"Sincerely,\n"
                             f"Your Team")

                response = ses_client.send_email(
                    Source=SENDER_EMAIL,
                    Destination={'ToAddresses': [user_email]},
                    Message={
                        'Subject': {'Data': subject, 'Charset': 'UTF-8'},
                        'Body': {'Text': {'Data': body_text, 'Charset': 'UTF-8'}}
                    }
                )

                print(f"Farewell email sent successfully. Message ID: {response['MessageId']}")

        except Exception as e:
            print(f"An error occurred while processing the record: {e}")
            continue

    return {
        'statusCode': 200,
        'body': json.dumps('Processing completed successfully!')
    }
