// client/src/api/axios.js

import axios from 'axios';

const instance = axios.create({
  baseURL: 'http://localhost:3000/api', // Change if your backend is different
  headers: {
    'Content-Type': 'application/json',
  },
});

export default instance;
