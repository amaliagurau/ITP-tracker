const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

const nexmoApiKey = '2237d34a';
const nexmoApiSecret = 'TeVpND1rUGXTDL8P';
const nexmoFrom = 'Vonage APIs';

async function sendITPReminders() {
    try {
        const today = new Date();
        const carsRef = admin.firestore().collection('Car');
        const snapshot = await carsRef.get();

        if (snapshot.empty) {
            console.log('No matching documents.');
            return;
        }

        snapshot.forEach(async (doc) => {
            const carData = doc.data();
            console.log('Car data:', carData); // Debug log to check carData fields

            const itpDateStr = carData.dateOfITP; // Assuming 'dateOfITP' is a string in 'YYYY-MM-DD' format
            const itpDate = new Date(itpDateStr); // Parse the string to a Date object

            if (isNaN(itpDate.getTime())) {
                console.error(`Invalid ITP date for car: ${carData.licensePlate}`);
                return;
            }

            // Calculate the difference in days between today and the itpDate
            const timeDiff = itpDate.getTime() - today.getTime();
            const dayDiff = Math.ceil(timeDiff / (1000 * 3600 * 24));

            if (dayDiff === 14) { // Trigger only if there are 14 days left
                const message = `Buna ${carData.ownerName}, ITP-ul masinii tale cu numarul ${carData.licensePlate} va expira pe ${itpDate.toLocaleDateString()}. Te rugam sa te programezi pentru un nou ITP.`;

                console.log(`Prepared message for ${carData.phoneNumber}: ${message}`);

                // Send SMS using Nexmo
                try {
                    const response = await axios.post('https://rest.nexmo.com/sms/json', {
                        from: nexmoFrom,
                        text: message,
                        to: carData.phoneNumber,
                        api_key: nexmoApiKey,
                        api_secret: nexmoApiSecret
                    });

                    if (response.data.messages[0].status === '0') {
                        console.log(`Message sent to ${carData.phoneNumber}: ${message}`);
                    } else {
                        console.error(`Nexmo error: ${response.data.messages[0]['error-text']}`);
                    }
                } catch (error) {
                    console.error(`Failed to send message to ${carData.phoneNumber}:`, error);
                }
            }else{
             console.error(`No message sent ${carData.phoneNumber}, day diff: ${dayDiff}`);
            }
        });
    } catch (error) {
        console.error('Error sending ITP reminders:', error);
        throw new functions.https.HttpsError('internal', 'Unable to send ITP reminders', error);
    }
}

exports.sendITPReminders = functions.pubsub.schedule('every day 00:00').onRun((context) => {
    return sendITPReminders();
});

exports.testSendITPReminders = functions.https.onRequest(async (req, res) => {
    try {
        await sendITPReminders();
        res.send("ITP Reminders function executed.");
    } catch (error) {
        res.status(500).send(`Error executing ITP Reminders function: ${error.message}`);
    }
});
