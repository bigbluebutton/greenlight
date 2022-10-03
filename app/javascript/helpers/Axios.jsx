import axios from 'axios';

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
      'X-CSRF-TOKEN':  document.querySelector('[name=csrf-token]').getAttribute("content")
    },

    // `timeout` specifies the number of milliseconds before the request times out.
    // If the request takes longer than `timeout`, the request will be aborted.
    timeout: 30_000, // default is `0` (no timeout)
  },
);

export default axiosInstance;
