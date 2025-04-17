importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker
firebase.initializeApp({
    apiKey: "AIzaSyDAXdLK2NIQaJ-mhoqI44Y3UCX7NZU1GnU",
    authDomain: "resort-automation-app-backend.firebaseapp.com",
    projectId: "resort-automation-app-backend",
    storageBucket: "resort-automation-app-backend.firebasestorage.app",
    messagingSenderId: "456492763184",
    appId: "1:456492763184:web:30867fdadf8df6bde1c5f5"
});

const messaging = firebase.messaging();

// Optional: Add background message handler
messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);

    // Customize notification here
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/icon-192x192.png'
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});