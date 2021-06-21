# Near-Wild Safety

## How we built it

Since this was our first real exposure for all of us to AWS services. We started by searching for articles or projects that will help us to start ahead. And this led us to this [project](https://github.com/aws-samples/amazon-rekognition-video-analyzer) in [AWS-Samples](https://amazon.com/aws) account.

This GitHub project was our perfect head start. It mainly streams videos from IP cameras to AWS, recognize frames by Rekognition according to user-configured labeling list, sends alerts.

Here below the GitHub project Flow Diagram:
![GitHub Project](https://raw.githubusercontent.com/aws-samples/amazon-rekognition-video-analyzer/master/doc/serverless_pipeline_arch_2.png)

But of course, it required modifications to fit our project idea. As seen in the below flow diagram.

![Project flow diagram](https://raw.githubusercontent.com/MahmadSharaf/AWS-Verizon-Hackathon-2021/cd5809842423b44601e6c150ac54fd879d59a7a1/Documentation/Images/FlowDiagram.png)

We have changed/added the below:

1. The system is triggered from the mobile application; instead of being manually from local device.
2. Hosted the video capture client on EC2 instance that get triggered by a lambda function.
3. Added support for RTSP instead of HTTP/S streams.
4. A push notification is sent to the mobile application. Instead of checking for updates regularly from a web UI.

![Project Sequence diagram](https://raw.githubusercontent.com/MahmadSharaf/AWS-Verizon-Hackathon-2021/cd5809842423b44601e6c150ac54fd879d59a7a1/Documentation/Images/SequenceDiagram.png)

## Challenges we ran into

- Wavelength connectivity while we’re outside US
- Building the mobile application, as we had no experience in app development
- Deploying the video capture client to EC2 instance, and connect it with lambda function

## Accomplishments that we're proud of

- Building our first architecture in AWS
- Building a functioning mobile application that gets the job done

## What we learned

- There are different protocols for video streaming
- Flutter for App development
- Push Notification has different providers like FCM and APNs. It has large number of parameters that control the behavior of when and where it is being received.
- Amazon Rekognition has a large set of label types that almost cover every aspect.
- SNS can send to AWS services

## What's next for Near wild

- Productionize it by adding accounts and authentication support
- Alert customers based on their geo-location (ex: bear detected near-by)
- Alerting customers by sending sound alerts generated by Amazon Alex.
- Support a wide range of cameras.
- Add support to stream the camera within the App