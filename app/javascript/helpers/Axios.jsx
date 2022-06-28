import axios from 'axios';

// Merges custom params with search params.
function mergeConfigParams(params, configParams = { }) {
  Object.entries(configParams).forEach(
    (param) => {
      const key = param.at(0);
      const val = param.at(1);
      if (val) {
        params.set(key, val);
      }
    },
  );

  return params;
}

// Filters out unwatned serach params.
function filterParams(params) {
  const allowedParams = ['search', 'sort[column]', 'sort[direction]'];
  const isAllowed = (val) => allowedParams.includes(val);

  const keys = Array.from(params.keys());
  keys.forEach((key) => {
    if (!isAllowed(key)) {
      params.delete(key);
    }
  });

  return params;
}

export const ENDPOINTS = {
  signup: '/users.json',
  signin: '/sessions.json',
  start_meeting: (friendlyId) => `meetings/${friendlyId}/start.json`,
  createRoom: '/rooms.json',
  recordings_resync: '/recordings/resync.json',
  room_recordings: (friendlyId) => `/rooms/${friendlyId}/recordings.json`,
  updateRecording: (recordId) => `/recordings/${recordId}.json`,
  changePassword: '/users/change_password.json',
  forget_password: '/reset_password.json',
  recordings: '/recordings.json',
};

const axiosInstance = axios.create(
  {
    // `baseURL` will be prepended to `url` unless `url` is absolute.
    // It can be convenient to set `baseURL` for an instance of axios to pass relative URLs
    // to methods of that instance.
    baseURL: '/api/v1',

    // `headers` are custom headers to be sent
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },

    // `timeout` specifies the number of milliseconds before the request times out.
    // If the request takes longer than `timeout`, the request will be aborted.
    timeout: 30_000, // default is `0` (no timeout)
  },
);

// Intercepts requests, filters out and forward search params to the API.
axiosInstance.interceptors.request.use((_config) => {
  const params = new URLSearchParams(window.location.search);
  mergeConfigParams(filterParams(params), _config.params);
  return { ..._config, ...{ params } };
}, (error) => Promise.reject(error));

export default axiosInstance;
