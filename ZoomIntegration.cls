/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-14-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ZoomIntegration {
    
    @AuraEnabled
    public static Map<String,String> createMeeting(String topic, Integer type, String startTime, Integer duration, String timeZone,String userEmail) {
        wrapperMeeting wrap = new wrapperMeeting();
        wrap.topicofMeeting = topic;
        wrap.typeofMeeting = type;
        wrap.startTime = startTime;
        wrap.durationMeeting = duration;
        wrap.timeZone = timeZone;
        
        String jsonString = JSON.serialize(wrap);
    Map<String, String> meetingDetails = sendHttpRequest(jsonString, 'POST', null);  // Get Meeting ID & Join URL

    if (meetingDetails != null && meetingDetails.containsKey('joinUrl')) {
        sendMeetingEmail(userEmail, topic, meetingDetails.get('joinUrl'),meetingDetails.get('passcode'),meetingDetails.get('start_time'),meetingDetails.get('duration'));  // Send Email with Meeting Link
    
        //store meeting details in custom Object
        Zoom_Meeting__c zoomMeet = new Zoom_Meeting__c();
        zoomMeet.Meeting_Topic__c = topic;
        zoomMeet.Contact_Emails__c = userEmail;
        zoomMeet.Duration__c = Decimal.valueOf(meetingDetails.get('duration')); // Convert String to Decimal
        zoomMeet.Start_Time__c = Datetime.valueOf(meetingDetails.get('start_time').replace('T', ' ').replace('Z', '')); // Convert String to Datetime
        zoomMeet.Passcode__c = meetingDetails.get('passcode');
        zoomMeet.Invite_Link__c = meetingDetails.get('joinUrl');
        zoomMeet.Time_Zone__c=timeZone;

        insert zoomMeet;
    
    }

    return meetingDetails;
    }
    
    @AuraEnabled
    public static Map<String,String> updateMeeting(String meetingId, String topic, Integer type, String startTime, Integer duration, String timeZone,String userEmail) {
        wrapperMeeting wrap = new wrapperMeeting();
        wrap.topicofMeeting = topic;
        wrap.typeofMeeting = type;
        wrap.startTime = startTime;
        wrap.durationMeeting = duration;
        wrap.timeZone = timeZone;
        
        String jsonString = JSON.serialize(wrap);
        Map<String, String> meetingDetails = sendHttpRequest(jsonString, 'PATCH', meetingId); // Update Meeting
    
    
    }

    return meetingDetails;
    
    
    }

    
    private static Map<String, String> sendHttpRequest(String jsonBody, String method, String meetingId) {
        HttpRequest req = new HttpRequest();
        req.setBody(jsonBody);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        
        if (method == 'PATCH') {
            req.setEndpoint('callout:Zoom_integration_learning/v2/meetings/' + meetingId);
        } else {
            req.setEndpoint('callout:Zoom_integration_learning/v2/users/me/meetings');
        }
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('Response Code: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody());

        if (res.getStatusCode() == 201 || res.getStatusCode() == 204) {
        System.debug('Success');

        if (method == 'POST') {
            // Parse the JSON response to extract the Meeting ID
           Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

       // Convert Meeting ID from Long to String
        String meetingIdResponse = responseMap.containsKey('id') 
            ? String.valueOf(responseMap.get('id')) 
            : '';

        String joinUrl = (String) responseMap.get('join_url');
        String passcode = responseMap.containsKey('password') ? (String) responseMap.get('password') : '';
        String startTime = (String) responseMap.get('start_time');
        
        Integer durationInt = (Integer) responseMap.get('duration');
            String duration = String.valueOf(durationInt);

            System.debug('Start time::' + startTime);
            System.debug('Duration::' + duration);
        // Return as a Map
        return new Map<String, String>{
            'meetingId' => meetingIdResponse,
            'joinUrl' => joinUrl,
             'passcode' => passcode,
             'start_time' => startTime,
             'duration' => duration
        };
        }
    } else {
        System.debug('Error: ' + res.getBody());
        throw new AuraHandledException('Error from Zoom: ' + res.getBody());
    }
    return null;
        
       
    }

   public static void sendMeetingEmail(String recipientEmails, String meetingTopic, String joinUrl, String passcode,String startTime,String duration) {
        List<String> emailList = recipientEmails.split(',');
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (String emailAddr : emailList) {
            emailAddr = emailAddr.trim(); 
            if (emailAddr != null && emailAddr.contains('@')) { 
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { emailAddr });
                email.setSubject('Your Zoom Meeting Link: ' + meetingTopic);
                email.setPlainTextBody('Hello,\n\nYour Zoom meeting has been created successfully.\n\n' +
                                       'Meeting Topic: ' + meetingTopic + '\n' +
                                       'Meeting Time : ' + startTime + '\n' + 
                                       'Duration of Meeting : ' + duration + '\n' + 
                                       'Join using the Zoom meeting link: ' + joinUrl + '\n' +
                                       'Passcode: ' + passcode + '\n\n' +
                                       'Thank you.');
                emails.add(email);
            } else {
                System.debug('Invalid email skipped: ' + emailAddr);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    public class wrapperMeeting {
        public String topicofMeeting { get; set; }
        public Integer typeofMeeting { get; set; }
        public String startTime { get; set; }
        public Integer durationMeeting { get; set; }
        public String timeZone { get; set; }
    }
}