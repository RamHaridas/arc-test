import json
import urllib3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

http = urllib3.PoolManager()

def lambda_handler(event, context):
    """
    Lambda function to handle CloudWatch Events and CloudWatch Alarms (via SNS)
    and send alerts to a Slack Webhook.
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    slack_webhook_url = os.environ.get('SLACK_WEBHOOK_URL')
    if not slack_webhook_url:
        logger.error("SLACK_WEBHOOK_URL environment variable is missing.")
        return {"statusCode": 500, "body": "Configuration error"}
        
    message = "ARC Failover Event Detected!"
    
    # 1. Handle SNS Event (from CloudWatch Alarm)
    if 'Records' in event and len(event['Records']) > 0 and 'Sns' in event['Records'][0]:
        sns_message = event['Records'][0]['Sns'].get('Message', '{}')
        try:
            alarm_info = json.loads(sns_message)
            alarm_name = alarm_info.get('AlarmName', 'Unknown')
            new_state = alarm_info.get('NewStateValue', 'UNKNOWN')
            reason = alarm_info.get('NewStateReason', 'No reason provided')
            message = f" *CloudWatch Alarm Triggered* \n*Alarm:* {alarm_name}\n*State:* {new_state}\n*Reason:* {reason}"
        except json.JSONDecodeError:
            message = f" *CloudWatch Alarm Triggered* \n{sns_message}"
            
    # 2. Handle direct CloudWatch Event / EventBridge (ARC State Change)
    elif event.get('source') == 'aws.route53-recovery-control':
        detail = event.get('detail', {})
        control_panel = detail.get('ControlPanelArn', 'Unknown Control Panel')
        routing_control = detail.get('RoutingControlArn', 'Unknown Routing Control')
        state = detail.get('State', 'UNKNOWN')
        message = f"🔄 *ARC Routing Control State Change* 🔄\n*Routing Control:* {routing_control}\n*New State:* {state}"
        
    # 3. Handle CloudWatch Alarm State Change via EventBridge
    elif event.get('source') == 'aws.cloudwatch' and event.get('detail-type') == 'CloudWatch Alarm State Change':
        alarm_name = event.get('detail', {}).get('alarmName', 'Unknown Alarm')
        state = event.get('detail', {}).get('state', {}).get('value', 'UNKNOWN')
        message = f" *CloudWatch Alarm State Change* \n*Alarm:* {alarm_name}\n*New State:* {state}"

    # Prepare Slack payload
    slack_payload = {
        "text": message
    }
    
    # Send to Slack
    try:
        response = http.request(
            "POST",
            slack_webhook_url,
            body=json.dumps(slack_payload).encode("utf-8"),
            headers={'Content-Type': 'application/json'}
        )
        logger.info(f"Slack response status: {response.status}")
        return {"statusCode": response.status, "body": "Message sent to Slack successfully"}
    except Exception as e:
        logger.error(f"Error sending message to slack: {str(e)}")
        return {"statusCode": 500, "body": f"Error sending to slack: {str(e)}"}
