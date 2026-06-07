// Firebase configuration placeholder
// Replace with real Firebase credentials when available
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || '',
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || '',
  databaseURL: import.meta.env.VITE_FIREBASE_DATABASE_URL || '',
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || '',
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || '',
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || '',
  appId: import.meta.env.VITE_FIREBASE_APP_ID || '',
};

// NOTE: Firebase is not initialized in the MVP.
// When ready, uncomment:
// import { initializeApp } from 'firebase/app';
// import { getDatabase } from 'firebase/database';
// import { getMessaging } from 'firebase/messaging';
// const app = initializeApp(firebaseConfig);
// export const database = getDatabase(app);
// export const messaging = getMessaging(app);

export default firebaseConfig;
