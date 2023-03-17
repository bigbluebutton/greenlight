import { useEffect, useRef } from 'react';

export const useMeetingStatusPolling = (handleCheckStatus, delay) => {
  const savedCallback = useRef();

  // Save the latest callback
  useEffect(() => {
    savedCallback.current = handleCheckStatus;
  }, [handleCheckStatus]);

  // Set up the interval to check the meeting status
  useEffect(() => {
    const tick = () => {
      savedCallback.current();
    };

    if (delay !== null) {
      const id = setInterval(tick, delay);
      return () => clearInterval(id);
    }
  }, [delay]);
};
