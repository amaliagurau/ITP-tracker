const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

const nexmoApiKey = '2237d34a';
const nexmoApiSecret = 'TeVpND1rUGXTDL8P';
const nexmoFrom = 'Vonage APIs';

async function sendITPReminders() {
    try {
        console.log('sendITPReminders function started');
        const today = new Date();
        console.log('Today\'s date:', today);

        const carsRef = admin.firestore().collection('Car');
        const snapshot = await carsRef.get();

        if (snapshot.empty) {
            console.log('No matching documents.');
            return;
        }

        snapshot.forEach(async (doc) => {
            const carData = doc.data();
            console.log('Car data:', carData);

            const itpDateStr = carData.dateOfITP;
            const itpDate = new Date(itpDateStr);

            if (isNaN(itpDate.getTime())) {
                console.error(`Invalid ITP date for car: ${carData.licensePlate}`);
                return;
            }

            console.log(`Parsed ITP date for ${carData.licensePlate}:`, itpDate);

            const timeDiff = itpDate.getTime() - today.getTime();
            const dayDiff = Math.ceil(timeDiff / (1000 * 3600 * 24));
            console.log(`Day difference for ${carData.licensePlate}: ${dayDiff}`);

            if (dayDiff === 14) {
                const message = `Buna ${carData.ownerName}, ITP-ul masinii tale cu numarul ${carData.licensePlate} va expira pe ${itpDate.toLocaleDateString()}. Te rugam sa te programezi pentru un nou ITP.`;

                console.log(`Prepared message for ${carData.phoneNumber}: ${message}`);

                try {
                    const response = await axios.post('https://rest.nexmo.com/sms/json', {
                        from: nexmoFrom,
                        text: message,
                        to: carData.phoneNumber,
                        api_key: nexmoApiKey,
                        api_secret: nexmoApiSecret
                    });

                    console.log('Nexmo response:', response.data);

                    if (response.data.messages[0].status === '0') {
                        console.log(`Message sent to ${carData.phoneNumber}: ${message}`);
                    } else {
                        console.error(`Nexmo error: ${response.data.messages[0]['error-text']}`);
                    }
                } catch (error) {
                    console.error(`Failed to send message to ${carData.phoneNumber}:`, error);
                }
            } else {
                console.log(`No message sent to ${carData.phoneNumber}, day diff: ${dayDiff}`);
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
        console.log('sendITPReminders function executed');
        res.status(200).send({ success: true });
    } catch (error) {
        console.error('Error executing sendITPReminders function:', error);
        res.status(500).send({ error: 'Unable to send ITP reminders' });
    }
});
