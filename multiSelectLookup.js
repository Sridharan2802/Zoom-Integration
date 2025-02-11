import { LightningElement, api, track } from 'lwc';
import getContacts from '@salesforce/apex/ContactController.getContacts';

export default class MultiSelectLookup extends LightningElement {
    @api selectedContacts = [];
    @track searchTerm = '';
    @track contacts = [];
    @track isSearching = false;

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.isSearching = true;

        getContacts({ searchTerm: this.searchTerm })
            .then(result => {
                this.contacts = result;
                this.isSearching = false;
            })
            .catch(error => {
                console.error('Error fetching contacts:', error);
                this.isSearching = false;
            });
    }

    handleSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedContact = this.contacts.find(contact => contact.Id === selectedId);

        if (!this.selectedContacts.some(contact => contact.Id === selectedId)) {
            this.selectedContacts = [...this.selectedContacts, selectedContact];
        }
        this.dispatchSelectionChange();
    }

    handleRemove(event) {
        const removedId = event.currentTarget.dataset.id;
        this.selectedContacts = this.selectedContacts.filter(contact => contact.Id !== removedId);
        this.dispatchSelectionChange();
    }

    dispatchSelectionChange() {
        const selectionChangeEvent = new CustomEvent('selectionchange', {
            detail: this.selectedContacts
        });
        this.dispatchEvent(selectionChangeEvent);
    }
}