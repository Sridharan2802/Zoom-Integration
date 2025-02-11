// zoomMeeting.js
import { LightningElement} from 'lwc';
import createMeeting from '@salesforce/apex/ZoomIntegration.createMeeting';
import updateMeeting from '@salesforce/apex/ZoomIntegration.updateMeeting';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ZoomMeeting extends LightningElement {
    topic = '';
    type = 2;
    startTime = '';
    duration = 60;
    timeZone = 'Asia/Kolkata';
    meetingId = ''; // For updates

    joinUrl = '';
    userEmail = '';  // Capture the user email
    selectedContacts = [];

    handleChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
    }

    handleContactSelection(event) {
        this.selectedContacts = event.detail;
    }


    handleCreate() {

        const emails = this.selectedContacts.map(contact => contact.Email).join(',');
        createMeeting({
            topic: this.topic,
            type: this.type,
            startTime: this.startTime,
            duration: this.duration,
            timeZone: this.timeZone,
            userEmail: emails

        })

        .then((result) => {
            //this.meetingId = result; // Capture Meeting ID from Apex
            this.meetingId = result.meetingId;
            this.joinUrl = result.joinUrl;
            this.showToast('Success', 'Meeting Created Successfully! Meeting ID: ' + result, 'success');
        })
        .catch((error) => {
            console.error('Error:', error);
            this.showToast('Error', error.body.message, 'error');
        });
        
        
    }

    handleUpdate() {
        if (!this.meetingId) {
            alert('Please enter the Meeting ID to update');
            return;
        }

        updateMeeting({
            meetingId: this.meetingId,
            topic: this.topic,
            type: this.type,
            startTime: this.startTime,
            duration: this.duration,
            timeZone: this.timeZone
        })
        .then(() => {
            this.showToast('Success', 'Meeting Updated Successfully!', 'success');
        })
        .catch((error) => {
            console.error('Error:', error);
            this.showToast('Error', error.body.message, 'error');
        });
    }

    showToast(title,message,variant) {
        const event = new ShowToastEvent({
            title: title,
            message:message,
            variant:variant
                
        });
        this.dispatchEvent(event);
    }

}